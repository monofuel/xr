import vmath

type
  XrError* = object of ValueError

  XrResultCode* = enum
    xrSuccess = 0
    xrTimeoutExpired = 1
    xrSessionLossPending = 3
    xrEventUnavailable = 4
    xrSpaceBoundsUnavailable = 7
    xrSessionNotFocused = 8
    xrFrameDiscarded = 9
    xrErrorValidationFailure = -1
    xrErrorRuntimeFailure = -2
    xrErrorOutOfMemory = -3
    xrErrorApiVersionUnsupported = -4
    xrErrorInitializationFailed = -6
    xrErrorFunctionUnsupported = -7
    xrErrorFeatureUnsupported = -8
    xrErrorExtensionNotPresent = -9
    xrErrorLimitReached = -10
    xrErrorSizeInsufficient = -11
    xrErrorHandlInvalid = -12
    xrErrorInstanceLost = -13
    xrErrorSessionRunning = -14
    xrErrorSessionNotRunning = -16
    xrErrorSessionLost = -17
    xrErrorSystemInvalid = -18
    xrErrorPathInvalid = -19
    xrErrorPathCountExceeded = -20
    xrErrorPathFormatInvalid = -21
    xrErrorPathUnsupported = -22
    xrErrorLayerInvalid = -23
    xrErrorLayerLimitExceeded = -24
    xrErrorSwapchainRectInvalid = -25
    xrErrorSwapchainFormatUnsupported = -26
    xrErrorActionTypeMismatch = -27
    xrErrorSessionNotReady = -28
    xrErrorSessionNotStopping = -29
    xrErrorTimeInvalid = -30
    xrErrorReferenceSpaceUnsupported = -31
    xrErrorFileAccessError = -32
    xrErrorFileContentsInvalid = -33
    xrErrorFormFactorUnsupported = -34
    xrErrorFormFactorUnavailable = -35
    xrErrorApiLayerNotPresent = -36
    xrErrorCallOrderInvalid = -37
    xrErrorGraphicsDeviceInvalid = -38
    xrErrorPoseInvalid = -39
    xrErrorIndexOutOfRange = -40
    xrErrorViewConfigurationTypeUnsupported = -41
    xrErrorEnvironmentBlendModeUnsupported = -42
    xrErrorNameDuplicated = -44
    xrErrorNameInvalid = -45
    xrErrorActionsetNotAttached = -46
    xrErrorActionsetsAlreadyAttached = -47
    xrErrorLocalizedNameDuplicated = -48
    xrErrorLocalizedNameInvalid = -49
    xrErrorGraphicsRequirementsCallMissing = -50
    xrErrorRuntimeUnavailable = -51

  XrSessionState* = enum
    xrSessionStateUnknown = 0
    xrSessionStateIdle = 1
    xrSessionStateReady = 2
    xrSessionStateSynchronized = 3
    xrSessionStateVisible = 4
    xrSessionStateFocused = 5
    xrSessionStateStopping = 6
    xrSessionStateLossPending = 7
    xrSessionStateExiting = 8

  XrFormFactor* = enum
    xrFormFactorHeadMountedDisplay = 1
    xrFormFactorHandheldDisplay = 2

  XrViewConfigurationType* = enum
    xrViewConfigurationTypePrimaryMono = 1
    xrViewConfigurationTypePrimaryStereo = 2

  XrEnvironmentBlendMode* = enum
    xrEnvironmentBlendModeOpaque = 1
    xrEnvironmentBlendModeAdditive = 2
    xrEnvironmentBlendModeAlphaBlend = 3

  XrReferenceSpaceType* = enum
    xrReferenceSpaceTypeView = 1
    xrReferenceSpaceTypeLocal = 2
    xrReferenceSpaceTypeStage = 3

  XrActionType* = enum
    xrActionTypeBooleanInput = 1
    xrActionTypeFloatInput = 2
    xrActionTypeVector2fInput = 3
    xrActionTypePoseInput = 4
    xrActionTypeVibrationOutput = 100

  ## OpenXR math types
  XrVector2f* = object
    x*, y*: float32

  XrVector3f* = object
    x*, y*, z*: float32

  XrQuaternionf* = object
    x*, y*, z*, w*: float32

  XrPosef* = object
    orientation*: XrQuaternionf
    position*: XrVector3f

  XrFovf* = object
    angleLeft*, angleRight*, angleUp*, angleDown*: float32

  XrOffset2Di* = object
    x*, y*: int32

  XrExtent2Di* = object
    width*, height*: int32

  XrRect2Di* = object
    offset*: XrOffset2Di
    extent*: XrExtent2Di

## vmath converters

proc toVec2*(v: XrVector2f): Vec2 =
  vec2(v.x, v.y)

proc toXrVector2f*(v: Vec2): XrVector2f =
  XrVector2f(x: v.x, y: v.y)

proc toVec3*(v: XrVector3f): Vec3 =
  vec3(v.x, v.y, v.z)

proc toXrVector3f*(v: Vec3): XrVector3f =
  XrVector3f(x: v.x, y: v.y, z: v.z)

proc toQuat*(q: XrQuaternionf): Quat =
  quat(q.x, q.y, q.z, q.w)

proc toXrQuaternionf*(q: Quat): XrQuaternionf =
  XrQuaternionf(x: q.x, y: q.y, z: q.z, w: q.w)

proc toMat4*(pose: XrPosef): Mat4 =
  let q = pose.orientation.toQuat()
  let p = pose.position.toVec3()
  result = q.mat4()
  result[3, 0] = p.x
  result[3, 1] = p.y
  result[3, 2] = p.z

proc isSuccess*(code: XrResultCode): bool =
  code.int >= 0
