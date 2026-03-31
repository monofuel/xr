import ../common
export common

{.passL: "-lopenxr_loader".}

type
  ## OpenXR handle types (opaque 64-bit values)
  XrInstance* = distinct uint64
  XrSession* = distinct uint64
  XrSwapchain* = distinct uint64
  XrSpace* = distinct uint64
  XrAction* = distinct uint64
  XrActionSet* = distinct uint64

  XrPath* = distinct uint64
  XrSystemId* = distinct uint64

  XrBool32* = uint32
  XrTime* = int64
  XrDuration* = int64
  XrFlags64* = uint64

  XrInstanceCreateFlags* = XrFlags64
  XrSessionCreateFlags* = XrFlags64
  XrSwapchainCreateFlags* = XrFlags64
  XrSwapchainUsageFlags* = XrFlags64
  XrViewStateFlags* = XrFlags64
  XrCompositionLayerFlags* = XrFlags64
  XrSpaceLocationFlags* = XrFlags64
  XrSpaceVelocityFlags* = XrFlags64

const
  XR_NULL_HANDLE* = 0'u64
  XR_NULL_PATH* = XrPath(0)
  XR_NULL_SYSTEM_ID* = XrSystemId(0)
  XR_NO_DURATION* = 0'i64
  XR_INFINITE_DURATION* = 0x7FFFFFFFFFFFFFFF'i64
  XR_MIN_COMPOSITION_LAYERS_SUPPORTED* = 16
  XR_MAX_APPLICATION_NAME_SIZE* = 128
  XR_MAX_ENGINE_NAME_SIZE* = 128
  XR_MAX_ACTION_SET_NAME_SIZE* = 64
  XR_MAX_ACTION_NAME_SIZE* = 64
  XR_MAX_LOCALIZED_ACTION_SET_NAME_SIZE* = 128
  XR_MAX_LOCALIZED_ACTION_NAME_SIZE* = 128

  ## XR_MAKE_VERSION(major, minor, patch) = ((major & 0xffff) << 48) | ((minor & 0xffff) << 32) | (patch & 0xffffffff)
  XR_API_VERSION_1_0* = (1'u64 shl 48) or (0'u64 shl 32) or 0'u64
  XR_API_VERSION_1_1* = (1'u64 shl 48) or (1'u64 shl 32) or 0'u64
  XR_CURRENT_API_VERSION* = XR_API_VERSION_1_0

  ## Swapchain usage flags
  XR_SWAPCHAIN_USAGE_COLOR_ATTACHMENT_BIT* = 0x00000001'u64
  XR_SWAPCHAIN_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT* = 0x00000002'u64
  XR_SWAPCHAIN_USAGE_SAMPLED_BIT* = 0x00000020'u64

  ## View state flags
  XR_VIEW_STATE_ORIENTATION_VALID_BIT* = 0x00000001'u64
  XR_VIEW_STATE_POSITION_VALID_BIT* = 0x00000002'u64
  XR_VIEW_STATE_ORIENTATION_TRACKED_BIT* = 0x00000004'u64
  XR_VIEW_STATE_POSITION_TRACKED_BIT* = 0x00000008'u64

  ## Composition layer flags
  XR_COMPOSITION_LAYER_CORRECT_CHROMATIC_ABERRATION_BIT* = 0x00000001'u64
  XR_COMPOSITION_LAYER_BLEND_TEXTURE_SOURCE_ALPHA_BIT* = 0x00000002'u64

  ## Space location flags
  XR_SPACE_LOCATION_ORIENTATION_VALID_BIT* = 0x00000001'u64
  XR_SPACE_LOCATION_POSITION_VALID_BIT* = 0x00000002'u64
  XR_SPACE_LOCATION_ORIENTATION_TRACKED_BIT* = 0x00000004'u64
  XR_SPACE_LOCATION_POSITION_TRACKED_BIT* = 0x00000008'u64

const
  ## XrStructureType values (from openxr.h)
  XR_TYPE_UNKNOWN* = 0'i32
  XR_TYPE_API_LAYER_PROPERTIES* = 1'i32
  XR_TYPE_EXTENSION_PROPERTIES* = 2'i32
  XR_TYPE_INSTANCE_CREATE_INFO* = 3'i32
  XR_TYPE_SYSTEM_GET_INFO* = 4'i32
  XR_TYPE_SYSTEM_PROPERTIES* = 5'i32
  XR_TYPE_VIEW_LOCATE_INFO* = 6'i32
  XR_TYPE_VIEW* = 7'i32
  XR_TYPE_SESSION_CREATE_INFO* = 8'i32
  XR_TYPE_SWAPCHAIN_CREATE_INFO* = 9'i32
  XR_TYPE_SESSION_BEGIN_INFO* = 10'i32
  XR_TYPE_VIEW_STATE* = 11'i32
  XR_TYPE_FRAME_END_INFO* = 12'i32
  XR_TYPE_HAPTIC_VIBRATION* = 13'i32
  XR_TYPE_EVENT_DATA_BUFFER* = 16'i32
  XR_TYPE_EVENT_DATA_INSTANCE_LOSS_PENDING* = 17'i32
  XR_TYPE_EVENT_DATA_SESSION_STATE_CHANGED* = 18'i32
  XR_TYPE_ACTION_STATE_BOOLEAN* = 23'i32
  XR_TYPE_ACTION_STATE_FLOAT* = 24'i32
  XR_TYPE_ACTION_STATE_VECTOR2F* = 25'i32
  XR_TYPE_ACTION_STATE_POSE* = 27'i32
  XR_TYPE_ACTION_SET_CREATE_INFO* = 28'i32
  XR_TYPE_ACTION_CREATE_INFO* = 29'i32
  XR_TYPE_INSTANCE_PROPERTIES* = 32'i32
  XR_TYPE_FRAME_WAIT_INFO* = 33'i32
  XR_TYPE_COMPOSITION_LAYER_PROJECTION* = 35'i32
  XR_TYPE_REFERENCE_SPACE_CREATE_INFO* = 37'i32
  XR_TYPE_ACTION_SPACE_CREATE_INFO* = 38'i32
  XR_TYPE_EVENT_DATA_REFERENCE_SPACE_CHANGE_PENDING* = 40'i32
  XR_TYPE_VIEW_CONFIGURATION_VIEW* = 41'i32
  XR_TYPE_SPACE_LOCATION* = 42'i32
  XR_TYPE_FRAME_STATE* = 44'i32
  XR_TYPE_FRAME_BEGIN_INFO* = 46'i32
  XR_TYPE_COMPOSITION_LAYER_PROJECTION_VIEW* = 48'i32
  XR_TYPE_INTERACTION_PROFILE_SUGGESTED_BINDING* = 51'i32
  XR_TYPE_EVENT_DATA_INTERACTION_PROFILE_CHANGED* = 52'i32
  XR_TYPE_SWAPCHAIN_IMAGE_ACQUIRE_INFO* = 55'i32
  XR_TYPE_SWAPCHAIN_IMAGE_WAIT_INFO* = 56'i32
  XR_TYPE_SWAPCHAIN_IMAGE_RELEASE_INFO* = 57'i32
  XR_TYPE_ACTION_STATE_GET_INFO* = 58'i32
  XR_TYPE_HAPTIC_ACTION_INFO* = 59'i32
  XR_TYPE_SESSION_ACTION_SETS_ATTACH_INFO* = 60'i32
  XR_TYPE_ACTIONS_SYNC_INFO* = 61'i32

  ## OpenGL extension types
  XR_TYPE_GRAPHICS_BINDING_OPENGL_XLIB_KHR* = 1000023001'i32
  XR_TYPE_SWAPCHAIN_IMAGE_OPENGL_KHR* = 1000023004'i32
  XR_TYPE_GRAPHICS_REQUIREMENTS_OPENGL_KHR* = 1000023005'i32

type
  ## X11/GLX opaque types (for graphics binding)
  XDisplay* = object
  GLXFBConfig* = object
  GLXDrawable* = distinct culong
  GLXContext* = ptr object

  ## Core OpenXR structs

  XrApplicationInfo* = object
    applicationName*: array[128, char]
    applicationVersion*: uint32
    engineName*: array[128, char]
    engineVersion*: uint32
    apiVersion*: uint64

  XrInstanceCreateInfo* = object
    `type`*: int32
    next*: pointer
    createFlags*: XrInstanceCreateFlags
    applicationInfo*: XrApplicationInfo
    enabledApiLayerCount*: uint32
    enabledApiLayerNames*: ptr cstring
    enabledExtensionCount*: uint32
    enabledExtensionNames*: ptr cstring

  XrInstanceProperties* = object
    `type`*: int32
    next*: pointer
    runtimeVersion*: uint64
    runtimeName*: array[128, char]

  XrSystemGetInfo* = object
    `type`*: int32
    next*: pointer
    formFactor*: int32

  XrSystemGraphicsProperties* = object
    maxSwapchainImageHeight*: uint32
    maxSwapchainImageWidth*: uint32
    maxLayerCount*: uint32

  XrSystemTrackingProperties* = object
    orientationTracking*: XrBool32
    positionTracking*: XrBool32

  XrSystemProperties* = object
    `type`*: int32
    next*: pointer
    systemId*: XrSystemId
    vendorId*: uint32
    systemName*: array[256, char]
    graphicsProperties*: XrSystemGraphicsProperties
    trackingProperties*: XrSystemTrackingProperties

  XrSessionCreateInfo* = object
    `type`*: int32
    next*: pointer
    createFlags*: XrSessionCreateFlags
    systemId*: XrSystemId

  XrSessionBeginInfo* = object
    `type`*: int32
    next*: pointer
    primaryViewConfigurationType*: int32

  ## Graphics binding for OpenGL on X11

  XrGraphicsBindingOpenGLXlibKHR* = object
    `type`*: int32
    next*: pointer
    xDisplay*: ptr XDisplay
    visualid*: uint32
    glxFBConfig*: ptr GLXFBConfig
    glxDrawable*: GLXDrawable
    glxContext*: GLXContext

  XrGraphicsRequirementsOpenGLKHR* = object
    `type`*: int32
    next*: pointer
    minApiVersionSupported*: uint64
    maxApiVersionSupported*: uint64

  ## Swapchain

  XrSwapchainCreateInfo* = object
    `type`*: int32
    next*: pointer
    createFlags*: XrSwapchainCreateFlags
    usageFlags*: XrSwapchainUsageFlags
    format*: int64
    sampleCount*: uint32
    width*: uint32
    height*: uint32
    faceCount*: uint32
    arraySize*: uint32
    mipCount*: uint32

  XrSwapchainImageBaseHeader* = object
    `type`*: int32
    next*: pointer

  XrSwapchainImageOpenGLKHR* = object
    `type`*: int32
    next*: pointer
    image*: uint32

  XrSwapchainImageAcquireInfo* = object
    `type`*: int32
    next*: pointer

  XrSwapchainImageWaitInfo* = object
    `type`*: int32
    next*: pointer
    timeout*: XrDuration

  XrSwapchainImageReleaseInfo* = object
    `type`*: int32
    next*: pointer

  ## Frame lifecycle

  XrFrameWaitInfo* = object
    `type`*: int32
    next*: pointer

  XrFrameState* = object
    `type`*: int32
    next*: pointer
    predictedDisplayTime*: XrTime
    predictedDisplayPeriod*: XrDuration
    shouldRender*: XrBool32

  XrFrameBeginInfo* = object
    `type`*: int32
    next*: pointer

  XrFrameEndInfo* = object
    `type`*: int32
    next*: pointer
    displayTime*: XrTime
    environmentBlendMode*: int32
    layerCount*: uint32
    layers*: ptr ptr XrCompositionLayerBaseHeader

  ## Views

  XrViewConfigurationView* = object
    `type`*: int32
    next*: pointer
    recommendedImageRectWidth*: uint32
    maxImageRectWidth*: uint32
    recommendedImageRectHeight*: uint32
    maxImageRectHeight*: uint32
    recommendedSwapchainSampleCount*: uint32
    maxSwapchainSampleCount*: uint32

  XrViewLocateInfo* = object
    `type`*: int32
    next*: pointer
    viewConfigurationType*: int32
    displayTime*: XrTime
    space*: XrSpace

  XrViewState* = object
    `type`*: int32
    next*: pointer
    viewStateFlags*: XrViewStateFlags

  XrView* = object
    `type`*: int32
    next*: pointer
    pose*: XrPosef
    fov*: XrFovf

  ## Composition layers

  XrCompositionLayerBaseHeader* = object
    `type`*: int32
    next*: pointer
    layerFlags*: XrCompositionLayerFlags
    space*: XrSpace

  XrSwapchainSubImage* = object
    swapchain*: XrSwapchain
    imageRect*: XrRect2Di
    imageArrayIndex*: uint32

  XrCompositionLayerProjectionView* = object
    `type`*: int32
    next*: pointer
    pose*: XrPosef
    fov*: XrFovf
    subImage*: XrSwapchainSubImage

  XrCompositionLayerProjection* = object
    `type`*: int32
    next*: pointer
    layerFlags*: XrCompositionLayerFlags
    space*: XrSpace
    viewCount*: uint32
    views*: ptr XrCompositionLayerProjectionView

  ## Spaces

  XrReferenceSpaceCreateInfo* = object
    `type`*: int32
    next*: pointer
    referenceSpaceType*: int32
    poseInReferenceSpace*: XrPosef

  XrSpaceLocation* = object
    `type`*: int32
    next*: pointer
    locationFlags*: XrSpaceLocationFlags
    pose*: XrPosef

  XrActionSpaceCreateInfo* = object
    `type`*: int32
    next*: pointer
    action*: XrAction
    subactionPath*: XrPath
    poseInActionSpace*: XrPosef

  ## Actions / Input

  XrActionSetCreateInfo* = object
    `type`*: int32
    next*: pointer
    actionSetName*: array[64, char]
    localizedActionSetName*: array[128, char]
    priority*: uint32

  XrActionCreateInfo* = object
    `type`*: int32
    next*: pointer
    actionName*: array[64, char]
    actionType*: int32
    countSubactionPaths*: uint32
    subactionPaths*: ptr XrPath
    localizedActionName*: array[128, char]

  XrActionStateBoolean* = object
    `type`*: int32
    next*: pointer
    currentState*: XrBool32
    changedSinceLastSync*: XrBool32
    lastChangeTime*: XrTime
    isActive*: XrBool32

  XrActionStateFloat* = object
    `type`*: int32
    next*: pointer
    currentState*: float32
    changedSinceLastSync*: XrBool32
    lastChangeTime*: XrTime
    isActive*: XrBool32

  XrActionStateVector2f* = object
    `type`*: int32
    next*: pointer
    currentState*: XrVector2f
    changedSinceLastSync*: XrBool32
    lastChangeTime*: XrTime
    isActive*: XrBool32

  XrActionStatePose* = object
    `type`*: int32
    next*: pointer
    isActive*: XrBool32

  XrActionStateGetInfo* = object
    `type`*: int32
    next*: pointer
    action*: XrAction
    subactionPath*: XrPath

  XrActiveActionSet* = object
    actionSet*: XrActionSet
    subactionPath*: XrPath

  XrActionsSyncInfo* = object
    `type`*: int32
    next*: pointer
    countActiveActionSets*: uint32
    activeActionSets*: ptr XrActiveActionSet

  XrSessionActionSetsAttachInfo* = object
    `type`*: int32
    next*: pointer
    countActionSets*: uint32
    actionSets*: ptr XrActionSet

  XrActionSuggestedBinding* = object
    action*: XrAction
    binding*: XrPath

  XrInteractionProfileSuggestedBinding* = object
    `type`*: int32
    next*: pointer
    interactionProfile*: XrPath
    countSuggestedBindings*: uint32
    suggestedBindings*: ptr XrActionSuggestedBinding

  ## Haptics

  XrHapticActionInfo* = object
    `type`*: int32
    next*: pointer
    action*: XrAction
    subactionPath*: XrPath

  XrHapticBaseHeader* = object
    `type`*: int32
    next*: pointer

  XrHapticVibration* = object
    `type`*: int32
    next*: pointer
    duration*: XrDuration
    frequency*: float32
    amplitude*: float32

  ## Events

  XrEventDataBaseHeader* = object
    `type`*: int32
    next*: pointer

  XrEventDataBuffer* = object
    `type`*: int32
    next*: pointer
    varying*: array[4000, uint8]

  XrEventDataSessionStateChanged* = object
    `type`*: int32
    next*: pointer
    session*: XrSession
    state*: int32
    time*: XrTime

  XrEventDataInstanceLossPending* = object
    `type`*: int32
    next*: pointer
    lossTime*: XrTime

  XrEventDataInteractionProfileChanged* = object
    `type`*: int32
    next*: pointer
    session*: XrSession


## Helper to set fixed-size char arrays from strings
proc setString*(dest: var openArray[char], src: string) =
  let len = min(src.len, dest.len - 1)
  for i in 0 ..< len:
    dest[i] = src[i]
  dest[len] = '\0'

## Identity pose
proc identityPosef*(): XrPosef =
  XrPosef(
    orientation: XrQuaternionf(x: 0, y: 0, z: 0, w: 1),
    position: XrVector3f(x: 0, y: 0, z: 0)
  )

## X11 types needed for visual queries
type
  XWindowAttributes* = object
    x*, y*: int32
    width*, height*: int32
    borderWidth*: int32
    depth*: int32
    visual*: pointer
    root*: culong
    class*: int32
    bitGravity*: int32
    winGravity*: int32
    backingStore*: int32
    backingPlanes*: culong
    backingPixel*: culong
    saveUnder*: int32
    colormap*: culong
    mapInstalled*: int32
    mapState*: int32
    allEventMasks*: clong
    yourEventMask*: clong
    doNotPropagateMask*: clong
    overrideRedirect*: int32
    screen*: pointer

  XVisualInfo* = object
    visual*: pointer
    visualid*: culong
    screen*: int32
    depth*: int32
    class*: int32
    redMask*: culong
    greenMask*: culong
    blueMask*: culong
    colormapSize*: int32
    bitsPerRgb*: int32

## X11 functions
{.push cdecl, dynlib: "libX11.so.6", importc.}
proc XGetWindowAttributes*(display: ptr XDisplay, w: culong, attrs: ptr XWindowAttributes): int32
proc XGetVisualInfo*(display: ptr XDisplay, vInfoMask: clong, vInfoTemplate: ptr XVisualInfo, nitemsReturn: ptr int32): ptr XVisualInfo
proc XFree*(data: pointer): int32
{.pop.}

const VisualIDMask* = 0x01'i64

## GLX functions we need to extract current context info
{.push cdecl, dynlib: "libGL.so.1", importc.}
proc glXGetCurrentContext*(): GLXContext
proc glXGetCurrentDisplay*(): ptr XDisplay
proc glXGetCurrentDrawable*(): GLXDrawable
proc glXGetVisualFromFBConfig*(display: ptr XDisplay, config: ptr GLXFBConfig): ptr XVisualInfo
proc glXQueryContext*(display: ptr XDisplay, ctx: GLXContext, attribute: int32, value: ptr int32): int32
proc glXGetFBConfigs*(display: ptr XDisplay, screen: int32, nelements: ptr int32): ptr ptr GLXFBConfig
proc glXGetFBConfigAttrib*(display: ptr XDisplay, config: ptr GLXFBConfig, attribute: int32, value: ptr int32): int32
{.pop.}

const
  GLX_FBCONFIG_ID* = 0x8013'i32
  GLX_VISUAL_ID* = 0x800B'i32
  GLX_SCREEN* = 0x800C'i32

## Core OpenXR functions
{.push importc, cdecl.}

# Instance
proc xrCreateInstance*(createInfo: ptr XrInstanceCreateInfo, instance: ptr XrInstance): int32
proc xrDestroyInstance*(instance: XrInstance): int32
proc xrGetInstanceProperties*(instance: XrInstance, properties: ptr XrInstanceProperties): int32
proc xrResultToString*(instance: XrInstance, value: int32, buffer: ptr array[64, char]): int32

# System
proc xrGetSystem*(instance: XrInstance, getInfo: ptr XrSystemGetInfo, systemId: ptr XrSystemId): int32
proc xrGetSystemProperties*(instance: XrInstance, systemId: XrSystemId, properties: ptr XrSystemProperties): int32

# Session
proc xrCreateSession*(instance: XrInstance, createInfo: ptr XrSessionCreateInfo, session: ptr XrSession): int32
proc xrDestroySession*(session: XrSession): int32
proc xrBeginSession*(session: XrSession, beginInfo: ptr XrSessionBeginInfo): int32
proc xrEndSession*(session: XrSession): int32
proc xrRequestExitSession*(session: XrSession): int32

# Frame
proc xrWaitFrame*(session: XrSession, frameWaitInfo: ptr XrFrameWaitInfo, frameState: ptr XrFrameState): int32
proc xrBeginFrame*(session: XrSession, frameBeginInfo: ptr XrFrameBeginInfo): int32
proc xrEndFrame*(session: XrSession, frameEndInfo: ptr XrFrameEndInfo): int32

# Swapchain
proc xrCreateSwapchain*(session: XrSession, createInfo: ptr XrSwapchainCreateInfo, swapchain: ptr XrSwapchain): int32
proc xrDestroySwapchain*(swapchain: XrSwapchain): int32
proc xrEnumerateSwapchainFormats*(session: XrSession, formatCapacityInput: uint32, formatCountOutput: ptr uint32, formats: ptr int64): int32
proc xrEnumerateSwapchainImages*(swapchain: XrSwapchain, imageCapacityInput: uint32, imageCountOutput: ptr uint32, images: ptr XrSwapchainImageBaseHeader): int32
proc xrAcquireSwapchainImage*(swapchain: XrSwapchain, acquireInfo: ptr XrSwapchainImageAcquireInfo, index: ptr uint32): int32
proc xrWaitSwapchainImage*(swapchain: XrSwapchain, waitInfo: ptr XrSwapchainImageWaitInfo): int32
proc xrReleaseSwapchainImage*(swapchain: XrSwapchain, releaseInfo: ptr XrSwapchainImageReleaseInfo): int32

# Views
proc xrEnumerateViewConfigurations*(instance: XrInstance, systemId: XrSystemId, viewConfigurationTypeCapacityInput: uint32, viewConfigurationTypeCountOutput: ptr uint32, viewConfigurationTypes: ptr int32): int32
proc xrEnumerateViewConfigurationViews*(instance: XrInstance, systemId: XrSystemId, viewConfigurationType: int32, viewCapacityInput: uint32, viewCountOutput: ptr uint32, views: ptr XrViewConfigurationView): int32
proc xrLocateViews*(session: XrSession, viewLocateInfo: ptr XrViewLocateInfo, viewState: ptr XrViewState, viewCapacityInput: uint32, viewCountOutput: ptr uint32, views: ptr XrView): int32

# Spaces
proc xrCreateReferenceSpace*(session: XrSession, createInfo: ptr XrReferenceSpaceCreateInfo, space: ptr XrSpace): int32
proc xrCreateActionSpace*(session: XrSession, createInfo: ptr XrActionSpaceCreateInfo, space: ptr XrSpace): int32
proc xrDestroySpace*(space: XrSpace): int32
proc xrLocateSpace*(space: XrSpace, baseSpace: XrSpace, time: XrTime, location: ptr XrSpaceLocation): int32
proc xrEnumerateReferenceSpaces*(session: XrSession, spaceCapacityInput: uint32, spaceCountOutput: ptr uint32, spaces: ptr int32): int32

# Actions
proc xrCreateActionSet*(instance: XrInstance, createInfo: ptr XrActionSetCreateInfo, actionSet: ptr XrActionSet): int32
proc xrDestroyActionSet*(actionSet: XrActionSet): int32
proc xrCreateAction*(actionSet: XrActionSet, createInfo: ptr XrActionCreateInfo, action: ptr XrAction): int32
proc xrDestroyAction*(action: XrAction): int32
proc xrSuggestInteractionProfileBindings*(instance: XrInstance, suggestedBindings: ptr XrInteractionProfileSuggestedBinding): int32
proc xrAttachSessionActionSets*(session: XrSession, attachInfo: ptr XrSessionActionSetsAttachInfo): int32
proc xrSyncActions*(session: XrSession, syncInfo: ptr XrActionsSyncInfo): int32
proc xrGetActionStateBoolean*(session: XrSession, getInfo: ptr XrActionStateGetInfo, state: ptr XrActionStateBoolean): int32
proc xrGetActionStateFloat*(session: XrSession, getInfo: ptr XrActionStateGetInfo, state: ptr XrActionStateFloat): int32
proc xrGetActionStateVector2f*(session: XrSession, getInfo: ptr XrActionStateGetInfo, state: ptr XrActionStateVector2f): int32
proc xrGetActionStatePose*(session: XrSession, getInfo: ptr XrActionStateGetInfo, state: ptr XrActionStatePose): int32
proc xrStringToPath*(instance: XrInstance, pathString: cstring, path: ptr XrPath): int32
proc xrPathToString*(instance: XrInstance, path: XrPath, bufferCapacityInput: uint32, bufferCountOutput: ptr uint32, buffer: cstring): int32

# Haptics
proc xrApplyHapticFeedback*(session: XrSession, hapticActionInfo: ptr XrHapticActionInfo, hapticFeedback: ptr XrHapticBaseHeader): int32
proc xrStopHapticFeedback*(session: XrSession, hapticActionInfo: ptr XrHapticActionInfo): int32

# Events
proc xrPollEvent*(instance: XrInstance, eventData: ptr XrEventDataBuffer): int32

# Instance proc addr (for loading extension functions)
proc xrGetInstanceProcAddr*(instance: XrInstance, name: cstring, function: ptr pointer): int32

{.pop.}

## Extension function types (loaded at runtime via xrGetInstanceProcAddr)
type
  PFN_xrGetOpenGLGraphicsRequirementsKHR* = proc(
    instance: XrInstance, systemId: XrSystemId,
    graphicsRequirements: ptr XrGraphicsRequirementsOpenGLKHR): int32 {.cdecl.}

var
  xrGetOpenGLGraphicsRequirementsKHR*: PFN_xrGetOpenGLGraphicsRequirementsKHR

proc loadOpenGLExtension*(instance: XrInstance) =
  ## Load the OpenGL extension function. Call after xrCreateInstance.
  var fn: pointer
  let res = xrGetInstanceProcAddr(instance, "xrGetOpenGLGraphicsRequirementsKHR", addr fn)
  if res != 0 or fn == nil:
    raise XrError.newException("Failed to load xrGetOpenGLGraphicsRequirementsKHR")
  xrGetOpenGLGraphicsRequirementsKHR = cast[PFN_xrGetOpenGLGraphicsRequirementsKHR](fn)
