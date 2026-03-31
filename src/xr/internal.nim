import common

template checkXr*(call: untyped) =
  let res = call.int32
  if res < 0:
    raise XrError.newException("OpenXR error: " & $res)
