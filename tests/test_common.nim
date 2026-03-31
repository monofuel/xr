import xr/common
import vmath

echo "Testing xr/common"

# XrResultCode values match OpenXR spec
block:
  doAssert XrResultCode(0) == xrSuccess
  doAssert XrResultCode(1) == xrTimeoutExpired
  doAssert XrResultCode(-1) == xrErrorValidationFailure
  doAssert XrResultCode(-2) == xrErrorRuntimeFailure
  doAssert XrResultCode(-51) == xrErrorRuntimeUnavailable

# isSuccess
block:
  doAssert xrSuccess.isSuccess
  doAssert xrTimeoutExpired.isSuccess
  doAssert xrSessionLossPending.isSuccess
  doAssert not xrErrorValidationFailure.isSuccess
  doAssert not xrErrorRuntimeFailure.isSuccess
  doAssert not xrErrorRuntimeUnavailable.isSuccess

# XrSessionState values match OpenXR spec
block:
  doAssert XrSessionState(0) == xrSessionStateUnknown
  doAssert XrSessionState(1) == xrSessionStateIdle
  doAssert XrSessionState(2) == xrSessionStateReady
  doAssert XrSessionState(5) == xrSessionStateFocused
  doAssert XrSessionState(8) == xrSessionStateExiting

# XrFormFactor values
block:
  doAssert XrFormFactor(1) == xrFormFactorHeadMountedDisplay
  doAssert XrFormFactor(2) == xrFormFactorHandheldDisplay

# XrActionType values
block:
  doAssert XrActionType(1) == xrActionTypeBooleanInput
  doAssert XrActionType(2) == xrActionTypeFloatInput
  doAssert XrActionType(3) == xrActionTypeVector2fInput
  doAssert XrActionType(4) == xrActionTypePoseInput
  doAssert XrActionType(100) == xrActionTypeVibrationOutput

# XrReferenceSpaceType values
block:
  doAssert XrReferenceSpaceType(1) == xrReferenceSpaceTypeView
  doAssert XrReferenceSpaceType(2) == xrReferenceSpaceTypeLocal
  doAssert XrReferenceSpaceType(3) == xrReferenceSpaceTypeStage

# vmath converters
block:
  let v2 = XrVector2f(x: 1.0, y: 2.0)
  let vmathV2 = v2.toVec2()
  doAssert vmathV2.x == 1.0
  doAssert vmathV2.y == 2.0
  let back = vmathV2.toXrVector2f()
  doAssert back.x == 1.0
  doAssert back.y == 2.0

block:
  let v3 = XrVector3f(x: 1.0, y: 2.0, z: 3.0)
  let vmathV3 = v3.toVec3()
  doAssert vmathV3.x == 1.0
  doAssert vmathV3.y == 2.0
  doAssert vmathV3.z == 3.0
  let back = vmathV3.toXrVector3f()
  doAssert back.x == 1.0
  doAssert back.y == 2.0
  doAssert back.z == 3.0

block:
  let q = XrQuaternionf(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
  let vmathQ = q.toQuat()
  doAssert vmathQ.x == 0.0
  doAssert vmathQ.y == 0.0
  doAssert vmathQ.z == 0.0
  doAssert vmathQ.w == 1.0
  let back = vmathQ.toXrQuaternionf()
  doAssert back.x == 0.0
  doAssert back.w == 1.0

# Pose to Mat4 (identity pose = identity matrix)
block:
  let pose = XrPosef(
    orientation: XrQuaternionf(x: 0.0, y: 0.0, z: 0.0, w: 1.0),
    position: XrVector3f(x: 0.0, y: 0.0, z: 0.0)
  )
  let m = pose.toMat4()
  doAssert m[0, 0] == 1.0
  doAssert m[1, 1] == 1.0
  doAssert m[2, 2] == 1.0
  doAssert m[3, 3] == 1.0
  doAssert m[3, 0] == 0.0
  doAssert m[3, 1] == 0.0
  doAssert m[3, 2] == 0.0

# Pose with translation
block:
  let pose = XrPosef(
    orientation: XrQuaternionf(x: 0.0, y: 0.0, z: 0.0, w: 1.0),
    position: XrVector3f(x: 1.0, y: 2.0, z: 3.0)
  )
  let m = pose.toMat4()
  doAssert m[3, 0] == 1.0
  doAssert m[3, 1] == 2.0
  doAssert m[3, 2] == 3.0

echo "Success"
