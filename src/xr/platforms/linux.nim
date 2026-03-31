import ../[common, internal]
import linux_defs
import opengl

export common, linux_defs

const MaxViews* = 2 ## Stereo VR = 2 views (left eye, right eye)

type
  XrSwapchainInfo* = object
    swapchain*: XrSwapchain
    images*: seq[XrSwapchainImageOpenGLKHR]
    width*, height*: uint32

  XrFrameInfo* = object
    shouldRender*: bool
    predictedDisplayTime*: XrTime
    views*: seq[XrView]

  Hand* = enum
    leftHand = 0
    rightHand = 1

  XrControllerState* = object
    gripPose*: XrPosef
    aimPose*: XrPosef
    gripActive*: bool
    aimActive*: bool
    triggerValue*: float32
    triggerClick*: bool
    squeezeValue*: float32
    squeezeClick*: bool
    thumbstick*: XrVector2f
    thumbstickClick*: bool
    buttonA*: bool  ## A/X button
    buttonB*: bool  ## B/Y button
    menuClick*: bool

var
  instance*: XrInstance
  systemId*: XrSystemId
  session*: XrSession
  sessionState*: XrSessionState = xrSessionStateUnknown
  sessionRunning*: bool
  appSpace*: XrSpace
  swapchains*: seq[XrSwapchainInfo]
  configViews*: seq[XrViewConfigurationView]
  framebuffers*: seq[GLuint]
  depthBuffers*: seq[GLuint]

  # Input state
  actionSet: XrActionSet
  handPaths: array[2, XrPath]
  gripPoseAction, aimPoseAction: XrAction
  triggerValueAction, triggerClickAction: XrAction
  squeezeValueAction, squeezeClickAction: XrAction
  thumbstickAction, thumbstickClickAction: XrAction
  buttonAAction, buttonBAction: XrAction
  menuClickAction: XrAction
  gripSpaces: array[2, XrSpace]
  aimSpaces: array[2, XrSpace]
  actionsAttached: bool

proc initXr*(appName: string) =
  ## Initialize OpenXR. Call after windy's makeContextCurrent.
  ## Uses glXGetCurrent* to extract the active OpenGL context info.

  # Create instance with OpenGL extension
  var appInfo: XrApplicationInfo
  appInfo.applicationName.setString(appName)
  appInfo.applicationVersion = 1
  appInfo.engineName.setString("xr.nim")
  appInfo.engineVersion = 1
  appInfo.apiVersion = XR_CURRENT_API_VERSION

  var extensions = [cstring"XR_KHR_opengl_enable"]
  var createInfo = XrInstanceCreateInfo(
    `type`: XR_TYPE_INSTANCE_CREATE_INFO,
    applicationInfo: appInfo,
    enabledExtensionCount: 1,
    enabledExtensionNames: addr extensions[0],
  )

  checkXr xrCreateInstance(addr createInfo, addr instance)

  # Load extension functions
  loadOpenGLExtension(instance)

  # Get system (HMD)
  var sysGetInfo = XrSystemGetInfo(
    `type`: XR_TYPE_SYSTEM_GET_INFO,
    formFactor: xrFormFactorHeadMountedDisplay.int32,
  )
  checkXr xrGetSystem(instance, addr sysGetInfo, addr systemId)

  # Check OpenGL graphics requirements (required before session creation)
  var graphicsReqs = XrGraphicsRequirementsOpenGLKHR(
    `type`: XR_TYPE_GRAPHICS_REQUIREMENTS_OPENGL_KHR,
  )
  checkXr xrGetOpenGLGraphicsRequirementsKHR(instance, systemId, addr graphicsReqs)

  # Get current OpenGL context from GLX
  let glxCtx = glXGetCurrentContext()
  let glxDisplay = glXGetCurrentDisplay()
  let glxDrawable = glXGetCurrentDrawable()

  if glxCtx == nil:
    raise XrError.newException("No current OpenGL context. Call window.makeContextCurrent() first.")
  if glxDisplay == nil:
    raise XrError.newException("No current X11 display")

  # Query visualid from the current drawable's window attributes
  var windowAttrs: XWindowAttributes
  discard XGetWindowAttributes(glxDisplay, culong(glxDrawable), addr windowAttrs)

  # Get the GLXFBConfig for the current context
  var fbConfigId: int32
  discard glXQueryContext(glxDisplay, glxCtx, GLX_FBCONFIG_ID, addr fbConfigId)

  var screenNum: int32
  discard glXQueryContext(glxDisplay, glxCtx, GLX_SCREEN, addr screenNum)

  # Find matching FBConfig
  var numConfigs: int32
  let configs = glXGetFBConfigs(glxDisplay, screenNum, addr numConfigs)
  var fbConfig: ptr GLXFBConfig = nil
  if configs != nil:
    for i in 0 ..< numConfigs:
      let cfgPtr = cast[ptr ptr GLXFBConfig](cast[uint64](configs) + uint64(i) * uint64(sizeof(pointer)))
      var thisId: int32
      discard glXGetFBConfigAttrib(glxDisplay, cfgPtr[], GLX_FBCONFIG_ID, addr thisId)
      if thisId == fbConfigId:
        fbConfig = cfgPtr[]
        break
    discard XFree(configs)

  # Query visualid from fbconfig
  var visualId: int32
  if fbConfig != nil:
    discard glXGetFBConfigAttrib(glxDisplay, fbConfig, GLX_VISUAL_ID, addr visualId)

  # Create session with OpenGL binding
  var graphicsBinding = XrGraphicsBindingOpenGLXlibKHR(
    `type`: XR_TYPE_GRAPHICS_BINDING_OPENGL_XLIB_KHR,
    xDisplay: glxDisplay,
    visualid: uint32(visualId),
    glxFBConfig: fbConfig,
    glxDrawable: glxDrawable,
    glxContext: glxCtx,
  )
  var sessionCreateInfo = XrSessionCreateInfo(
    `type`: XR_TYPE_SESSION_CREATE_INFO,
    next: addr graphicsBinding,
    systemId: systemId,
  )
  checkXr xrCreateSession(instance, addr sessionCreateInfo, addr session)

proc closeXr*() =
  ## Tear down OpenXR session and instance.
  if uint64(session) != XR_NULL_HANDLE:
    if sessionRunning:
      discard xrEndSession(session)
      sessionRunning = false
    discard xrDestroySession(session)
    session = XrSession(XR_NULL_HANDLE)

  if uint64(instance) != XR_NULL_HANDLE:
    discard xrDestroyInstance(instance)
    instance = XrInstance(XR_NULL_HANDLE)

  sessionState = xrSessionStateUnknown

proc pollXrEvents*(): XrSessionState =
  ## Poll OpenXR events and return current session state.
  ## Handles session state transitions automatically.
  var eventData: XrEventDataBuffer
  while true:
    eventData = XrEventDataBuffer(`type`: XR_TYPE_EVENT_DATA_BUFFER)
    let res = xrPollEvent(instance, addr eventData)
    if res != 0: # XR_EVENT_UNAVAILABLE or error
      break

    case eventData.`type`
    of XR_TYPE_EVENT_DATA_SESSION_STATE_CHANGED:
      let stateEvent = cast[ptr XrEventDataSessionStateChanged](addr eventData)
      sessionState = XrSessionState(stateEvent.state)

      case sessionState
      of xrSessionStateReady:
        var beginInfo = XrSessionBeginInfo(
          `type`: XR_TYPE_SESSION_BEGIN_INFO,
          primaryViewConfigurationType: xrViewConfigurationTypePrimaryStereo.int32,
        )
        checkXr xrBeginSession(session, addr beginInfo)
        sessionRunning = true
      of xrSessionStateStopping:
        checkXr xrEndSession(session)
        sessionRunning = false
      else:
        discard
    of XR_TYPE_EVENT_DATA_INSTANCE_LOSS_PENDING:
      sessionRunning = false
    else:
      discard

  return sessionState

proc createSwapchains*() =
  ## Create swapchains for stereo rendering. Call after session is created.

  # Create reference space (stage space for room-scale VR)
  var spaceCreateInfo = XrReferenceSpaceCreateInfo(
    `type`: XR_TYPE_REFERENCE_SPACE_CREATE_INFO,
    referenceSpaceType: xrReferenceSpaceTypeStage.int32,
    poseInReferenceSpace: identityPosef(),
  )
  checkXr xrCreateReferenceSpace(session, addr spaceCreateInfo, addr appSpace)

  # Get view configuration views (one per eye)
  var viewCount: uint32
  checkXr xrEnumerateViewConfigurationViews(
    instance, systemId, xrViewConfigurationTypePrimaryStereo.int32,
    0, addr viewCount, nil
  )
  configViews = newSeq[XrViewConfigurationView](viewCount)
  for i in 0 ..< viewCount:
    configViews[i].`type` = XR_TYPE_VIEW_CONFIGURATION_VIEW
  checkXr xrEnumerateViewConfigurationViews(
    instance, systemId, xrViewConfigurationTypePrimaryStereo.int32,
    viewCount, addr viewCount, addr configViews[0]
  )

  # Get supported swapchain formats
  var formatCount: uint32
  checkXr xrEnumerateSwapchainFormats(session, 0, addr formatCount, nil)
  var formats = newSeq[int64](formatCount)
  checkXr xrEnumerateSwapchainFormats(session, formatCount, addr formatCount, addr formats[0])

  # Prefer SRGB, fall back to first available
  var chosenFormat = formats[0]
  for f in formats:
    if f == GL_SRGB8_ALPHA8.int64:
      chosenFormat = f
      break

  # Create a swapchain per view (per eye)
  swapchains = newSeq[XrSwapchainInfo](viewCount)
  framebuffers = newSeq[GLuint](viewCount)
  depthBuffers = newSeq[GLuint](viewCount)

  for i in 0 ..< viewCount.int:
    let w = configViews[i].recommendedImageRectWidth
    let h = configViews[i].recommendedImageRectHeight

    var swapchainCreateInfo = XrSwapchainCreateInfo(
      `type`: XR_TYPE_SWAPCHAIN_CREATE_INFO,
      usageFlags: XR_SWAPCHAIN_USAGE_COLOR_ATTACHMENT_BIT or XR_SWAPCHAIN_USAGE_SAMPLED_BIT,
      format: chosenFormat,
      sampleCount: 1,
      width: w,
      height: h,
      faceCount: 1,
      arraySize: 1,
      mipCount: 1,
    )
    checkXr xrCreateSwapchain(session, addr swapchainCreateInfo, addr swapchains[i].swapchain)
    swapchains[i].width = w
    swapchains[i].height = h

    # Get swapchain images
    var imageCount: uint32
    checkXr xrEnumerateSwapchainImages(
      swapchains[i].swapchain, 0, addr imageCount,
      nil
    )
    swapchains[i].images = newSeq[XrSwapchainImageOpenGLKHR](imageCount)
    for j in 0 ..< imageCount:
      swapchains[i].images[j].`type` = XR_TYPE_SWAPCHAIN_IMAGE_OPENGL_KHR
    checkXr xrEnumerateSwapchainImages(
      swapchains[i].swapchain, imageCount, addr imageCount,
      cast[ptr XrSwapchainImageBaseHeader](addr swapchains[i].images[0])
    )

    # Create framebuffer and depth buffer for this eye
    glGenFramebuffers(1, addr framebuffers[i])
    glGenRenderbuffers(1, addr depthBuffers[i])
    glBindRenderbuffer(GL_RENDERBUFFER, depthBuffers[i])
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24, GLsizei(w), GLsizei(h))
    glBindRenderbuffer(GL_RENDERBUFFER, 0)

proc beginFrame*(): XrFrameInfo =
  ## Wait for and begin a new frame. Returns frame info with view poses.
  var frameWaitInfo = XrFrameWaitInfo(`type`: XR_TYPE_FRAME_WAIT_INFO)
  var frameState = XrFrameState(`type`: XR_TYPE_FRAME_STATE)
  checkXr xrWaitFrame(session, addr frameWaitInfo, addr frameState)

  var frameBeginInfo = XrFrameBeginInfo(`type`: XR_TYPE_FRAME_BEGIN_INFO)
  checkXr xrBeginFrame(session, addr frameBeginInfo)

  result.shouldRender = frameState.shouldRender != 0
  result.predictedDisplayTime = frameState.predictedDisplayTime

  if result.shouldRender:
    # Locate views (get per-eye pose and FOV)
    var viewLocateInfo = XrViewLocateInfo(
      `type`: XR_TYPE_VIEW_LOCATE_INFO,
      viewConfigurationType: xrViewConfigurationTypePrimaryStereo.int32,
      displayTime: frameState.predictedDisplayTime,
      space: appSpace,
    )
    var viewState = XrViewState(`type`: XR_TYPE_VIEW_STATE)
    var viewCount: uint32
    checkXr xrLocateViews(session, addr viewLocateInfo, addr viewState,
      0, addr viewCount, nil)

    result.views = newSeq[XrView](viewCount)
    for i in 0 ..< viewCount:
      result.views[i].`type` = XR_TYPE_VIEW
    checkXr xrLocateViews(session, addr viewLocateInfo, addr viewState,
      viewCount, addr viewCount, addr result.views[0])

proc beginEyeRender*(eyeIndex: int): tuple[framebuffer: GLuint, width, height: uint32] =
  ## Acquire swapchain image and bind framebuffer for rendering to one eye.
  var acquireInfo = XrSwapchainImageAcquireInfo(`type`: XR_TYPE_SWAPCHAIN_IMAGE_ACQUIRE_INFO)
  var imageIndex: uint32
  checkXr xrAcquireSwapchainImage(swapchains[eyeIndex].swapchain, addr acquireInfo, addr imageIndex)

  var waitInfo = XrSwapchainImageWaitInfo(
    `type`: XR_TYPE_SWAPCHAIN_IMAGE_WAIT_INFO,
    timeout: XR_INFINITE_DURATION,
  )
  checkXr xrWaitSwapchainImage(swapchains[eyeIndex].swapchain, addr waitInfo)

  let colorTex = swapchains[eyeIndex].images[imageIndex].image
  let w = swapchains[eyeIndex].width
  let h = swapchains[eyeIndex].height

  glBindFramebuffer(GL_FRAMEBUFFER, framebuffers[eyeIndex])
  glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, colorTex, 0)
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthBuffers[eyeIndex])
  glViewport(0, 0, GLsizei(w), GLsizei(h))

  return (framebuffers[eyeIndex], w, h)

proc endEyeRender*(eyeIndex: int) =
  ## Release swapchain image after rendering.
  glBindFramebuffer(GL_FRAMEBUFFER, 0)
  var releaseInfo = XrSwapchainImageReleaseInfo(`type`: XR_TYPE_SWAPCHAIN_IMAGE_RELEASE_INFO)
  checkXr xrReleaseSwapchainImage(swapchains[eyeIndex].swapchain, addr releaseInfo)

proc endFrame*(frameInfo: XrFrameInfo) =
  ## End the frame and submit layers to the compositor.
  if not frameInfo.shouldRender or frameInfo.views.len == 0:
    # Submit empty frame
    var frameEndInfo = XrFrameEndInfo(
      `type`: XR_TYPE_FRAME_END_INFO,
      displayTime: frameInfo.predictedDisplayTime,
      environmentBlendMode: xrEnvironmentBlendModeOpaque.int32,
      layerCount: 0,
      layers: nil,
    )
    checkXr xrEndFrame(session, addr frameEndInfo)
    return

  # Build projection views
  var projViews = newSeq[XrCompositionLayerProjectionView](frameInfo.views.len)
  for i in 0 ..< frameInfo.views.len:
    projViews[i] = XrCompositionLayerProjectionView(
      `type`: XR_TYPE_COMPOSITION_LAYER_PROJECTION_VIEW,
      pose: frameInfo.views[i].pose,
      fov: frameInfo.views[i].fov,
      subImage: XrSwapchainSubImage(
        swapchain: swapchains[i].swapchain,
        imageRect: XrRect2Di(
          offset: XrOffset2Di(x: 0, y: 0),
          extent: XrExtent2Di(
            width: int32(swapchains[i].width),
            height: int32(swapchains[i].height),
          ),
        ),
        imageArrayIndex: 0,
      ),
    )

  var projLayer = XrCompositionLayerProjection(
    `type`: XR_TYPE_COMPOSITION_LAYER_PROJECTION,
    space: appSpace,
    viewCount: uint32(projViews.len),
    views: addr projViews[0],
  )
  var layers = [cast[ptr XrCompositionLayerBaseHeader](addr projLayer)]

  var frameEndInfo = XrFrameEndInfo(
    `type`: XR_TYPE_FRAME_END_INFO,
    displayTime: frameInfo.predictedDisplayTime,
    environmentBlendMode: xrEnvironmentBlendModeOpaque.int32,
    layerCount: 1,
    layers: addr layers[0],
  )
  checkXr xrEndFrame(session, addr frameEndInfo)

# ---- Input / Controllers ----

proc createAction(name, localizedName: string, actionType: XrActionType): XrAction =
  var createInfo = XrActionCreateInfo(
    `type`: XR_TYPE_ACTION_CREATE_INFO,
    actionType: actionType.int32,
    countSubactionPaths: 2,
    subactionPaths: addr handPaths[0],
  )
  createInfo.actionName.setString(name)
  createInfo.localizedActionName.setString(localizedName)
  checkXr xrCreateAction(actionSet, addr createInfo, addr result)

proc setupActions*() =
  ## Set up the action system for two-handed VR controllers.
  ## Call after initXr, before the first frame.
  checkXr xrStringToPath(instance, "/user/hand/left", addr handPaths[0])
  checkXr xrStringToPath(instance, "/user/hand/right", addr handPaths[1])

  # Create action set
  var actionSetCreateInfo = XrActionSetCreateInfo(
    `type`: XR_TYPE_ACTION_SET_CREATE_INFO,
    priority: 0,
  )
  actionSetCreateInfo.actionSetName.setString("gameplay")
  actionSetCreateInfo.localizedActionSetName.setString("Gameplay")
  checkXr xrCreateActionSet(instance, addr actionSetCreateInfo, addr actionSet)

  # Create actions
  gripPoseAction = createAction("grip_pose", "Grip Pose", xrActionTypePoseInput)
  aimPoseAction = createAction("aim_pose", "Aim Pose", xrActionTypePoseInput)
  triggerValueAction = createAction("trigger", "Trigger", xrActionTypeFloatInput)
  triggerClickAction = createAction("trigger_click", "Trigger Click", xrActionTypeBooleanInput)
  squeezeValueAction = createAction("squeeze", "Squeeze", xrActionTypeFloatInput)
  squeezeClickAction = createAction("squeeze_click", "Squeeze Click", xrActionTypeBooleanInput)
  thumbstickAction = createAction("thumbstick", "Thumbstick", xrActionTypeVector2fInput)
  thumbstickClickAction = createAction("thumbstick_click", "Thumbstick Click", xrActionTypeBooleanInput)
  buttonAAction = createAction("button_a", "A/X Button", xrActionTypeBooleanInput)
  buttonBAction = createAction("button_b", "B/Y Button", xrActionTypeBooleanInput)
  menuClickAction = createAction("menu", "Menu", xrActionTypeBooleanInput)

  # Suggest bindings for Oculus Touch / Meta Quest controllers
  var touchBindings: array[20, XrActionSuggestedBinding]
  var bindCount = 0

  template addBinding(act: XrAction, path: string) =
    var p: XrPath
    checkXr xrStringToPath(instance, path, addr p)
    touchBindings[bindCount] = XrActionSuggestedBinding(action: act, binding: p)
    inc bindCount

  addBinding(gripPoseAction, "/user/hand/left/input/grip/pose")
  addBinding(gripPoseAction, "/user/hand/right/input/grip/pose")
  addBinding(aimPoseAction, "/user/hand/left/input/aim/pose")
  addBinding(aimPoseAction, "/user/hand/right/input/aim/pose")
  addBinding(triggerValueAction, "/user/hand/left/input/trigger/value")
  addBinding(triggerValueAction, "/user/hand/right/input/trigger/value")
  addBinding(squeezeValueAction, "/user/hand/left/input/squeeze/value")
  addBinding(squeezeValueAction, "/user/hand/right/input/squeeze/value")
  addBinding(thumbstickAction, "/user/hand/left/input/thumbstick")
  addBinding(thumbstickAction, "/user/hand/right/input/thumbstick")
  addBinding(thumbstickClickAction, "/user/hand/left/input/thumbstick/click")
  addBinding(thumbstickClickAction, "/user/hand/right/input/thumbstick/click")
  addBinding(buttonAAction, "/user/hand/left/input/x/click")
  addBinding(buttonAAction, "/user/hand/right/input/a/click")
  addBinding(buttonBAction, "/user/hand/left/input/y/click")
  addBinding(buttonBAction, "/user/hand/right/input/b/click")
  addBinding(menuClickAction, "/user/hand/left/input/menu/click")

  var profilePath: XrPath
  checkXr xrStringToPath(instance, "/interaction_profiles/oculus/touch_controller", addr profilePath)

  var suggestedBindings = XrInteractionProfileSuggestedBinding(
    `type`: XR_TYPE_INTERACTION_PROFILE_SUGGESTED_BINDING,
    interactionProfile: profilePath,
    countSuggestedBindings: uint32(bindCount),
    suggestedBindings: addr touchBindings[0],
  )
  checkXr xrSuggestInteractionProfileBindings(instance, addr suggestedBindings)

proc attachActions*() =
  ## Attach action sets to the session. Call after session is created and actions are set up.
  var attachInfo = XrSessionActionSetsAttachInfo(
    `type`: XR_TYPE_SESSION_ACTION_SETS_ATTACH_INFO,
    countActionSets: 1,
    actionSets: addr actionSet,
  )
  checkXr xrAttachSessionActionSets(session, addr attachInfo)

  # Create action spaces for hand tracking
  for i in 0 .. 1:
    var gripSpaceInfo = XrActionSpaceCreateInfo(
      `type`: XR_TYPE_ACTION_SPACE_CREATE_INFO,
      action: gripPoseAction,
      subactionPath: handPaths[i],
      poseInActionSpace: identityPosef(),
    )
    checkXr xrCreateActionSpace(session, addr gripSpaceInfo, addr gripSpaces[i])

    var aimSpaceInfo = XrActionSpaceCreateInfo(
      `type`: XR_TYPE_ACTION_SPACE_CREATE_INFO,
      action: aimPoseAction,
      subactionPath: handPaths[i],
      poseInActionSpace: identityPosef(),
    )
    checkXr xrCreateActionSpace(session, addr aimSpaceInfo, addr aimSpaces[i])

  actionsAttached = true

proc syncActions*() =
  ## Sync action state. Call once per frame before reading controller state.
  if not actionsAttached:
    return
  var activeSet = XrActiveActionSet(actionSet: actionSet)
  var syncInfo = XrActionsSyncInfo(
    `type`: XR_TYPE_ACTIONS_SYNC_INFO,
    countActiveActionSets: 1,
    activeActionSets: addr activeSet,
  )
  checkXr xrSyncActions(session, addr syncInfo)

proc getBool(action: XrAction, hand: Hand): bool =
  var getInfo = XrActionStateGetInfo(
    `type`: XR_TYPE_ACTION_STATE_GET_INFO,
    action: action,
    subactionPath: handPaths[hand.int],
  )
  var state = XrActionStateBoolean(`type`: XR_TYPE_ACTION_STATE_BOOLEAN)
  checkXr xrGetActionStateBoolean(session, addr getInfo, addr state)
  return state.isActive != 0 and state.currentState != 0

proc getFloat(action: XrAction, hand: Hand): float32 =
  var getInfo = XrActionStateGetInfo(
    `type`: XR_TYPE_ACTION_STATE_GET_INFO,
    action: action,
    subactionPath: handPaths[hand.int],
  )
  var state = XrActionStateFloat(`type`: XR_TYPE_ACTION_STATE_FLOAT)
  checkXr xrGetActionStateFloat(session, addr getInfo, addr state)
  if state.isActive != 0:
    return state.currentState
  return 0.0

proc getVec2(action: XrAction, hand: Hand): XrVector2f =
  var getInfo = XrActionStateGetInfo(
    `type`: XR_TYPE_ACTION_STATE_GET_INFO,
    action: action,
    subactionPath: handPaths[hand.int],
  )
  var state = XrActionStateVector2f(`type`: XR_TYPE_ACTION_STATE_VECTOR2F)
  checkXr xrGetActionStateVector2f(session, addr getInfo, addr state)
  if state.isActive != 0:
    return state.currentState
  return XrVector2f(x: 0, y: 0)

proc getControllerState*(hand: Hand, displayTime: XrTime): XrControllerState =
  ## Get the full state of one controller. Call after syncActions.
  if not actionsAttached:
    return

  result.triggerValue = getFloat(triggerValueAction, hand)
  result.triggerClick = getBool(triggerClickAction, hand)
  result.squeezeValue = getFloat(squeezeValueAction, hand)
  result.squeezeClick = getBool(squeezeClickAction, hand)
  result.thumbstick = getVec2(thumbstickAction, hand)
  result.thumbstickClick = getBool(thumbstickClickAction, hand)
  result.buttonA = getBool(buttonAAction, hand)
  result.buttonB = getBool(buttonBAction, hand)
  result.menuClick = getBool(menuClickAction, hand)

  # Get grip pose
  var gripLocation = XrSpaceLocation(`type`: XR_TYPE_SPACE_LOCATION)
  checkXr xrLocateSpace(gripSpaces[hand.int], appSpace, displayTime, addr gripLocation)
  result.gripActive = (gripLocation.locationFlags and XR_SPACE_LOCATION_POSITION_VALID_BIT) != 0
  if result.gripActive:
    result.gripPose = gripLocation.pose

  # Get aim pose
  var aimLocation = XrSpaceLocation(`type`: XR_TYPE_SPACE_LOCATION)
  checkXr xrLocateSpace(aimSpaces[hand.int], appSpace, displayTime, addr aimLocation)
  result.aimActive = (aimLocation.locationFlags and XR_SPACE_LOCATION_POSITION_VALID_BIT) != 0
  if result.aimActive:
    result.aimPose = aimLocation.pose

proc applyHaptic*(hand: Hand, durationNs: int64 = 200_000_000, frequency: float32 = 0, amplitude: float32 = 0.5) =
  ## Trigger haptic vibration on a controller.
  ## Duration is in nanoseconds (default 200ms). Frequency 0 = runtime default.
  if not actionsAttached:
    return
  var hapticInfo = XrHapticActionInfo(
    `type`: XR_TYPE_HAPTIC_ACTION_INFO,
    action: gripPoseAction,
    subactionPath: handPaths[hand.int],
  )
  var vibration = XrHapticVibration(
    `type`: XR_TYPE_HAPTIC_VIBRATION,
    duration: durationNs,
    frequency: frequency,
    amplitude: amplitude,
  )
  discard xrApplyHapticFeedback(session, addr hapticInfo, cast[ptr XrHapticBaseHeader](addr vibration))

proc stopHaptic*(hand: Hand) =
  ## Stop haptic vibration on a controller.
  if not actionsAttached:
    return
  var hapticInfo = XrHapticActionInfo(
    `type`: XR_TYPE_HAPTIC_ACTION_INFO,
    action: gripPoseAction,
    subactionPath: handPaths[hand.int],
  )
  discard xrStopHapticFeedback(session, addr hapticInfo)
