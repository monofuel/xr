import xr/common

when defined(emscripten):
  # Future WebXR support
  discard
elif defined(linux):
  import xr/platforms/linux
  export linux
else:
  discard

export common
