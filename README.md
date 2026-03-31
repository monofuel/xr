# xr.nim

Nim OpenXR library for VR. Hand-written bindings, thin wrapper over the OpenXR C API.

Currently supports **SteamVR + OpenGL + Linux (X11/GLX)**.

## Dependencies

- [nimby](https://github.com/nickelsworth/nimby) for dependency management
- [vmath](https://github.com/treeform/vmath) - math types and converters
- [windy](https://github.com/treeform/windy) - window/OpenGL context creation
- [opengl](https://github.com/nim-lang/opengl) - OpenGL bindings
- [Nix](https://nixos.org/) for dev environment (openxr-loader, vulkan-loader, X11 libs)

## Setup

```sh
nix develop
nimby sync -g nimby.lock   # or: make build
```

## Usage

```nim
import windy, opengl
import xr

# Create window and OpenGL context (windy)
let window = newWindow("My VR App", ivec2(800, 600))
window.makeContextCurrent()
loadExtensions()

# Initialize OpenXR
initXr("my-app")

# Main loop
var swapchainCreated = false
while not window.closeRequested:
  pollEvents()
  let state = pollXrEvents()

  if sessionRunning and not swapchainCreated:
    createSwapchains()
    swapchainCreated = true

  if sessionRunning and swapchainCreated:
    let frame = beginFrame()
    if frame.shouldRender:
      for eye in 0 ..< frame.views.len:
        discard beginEyeRender(eye)
        # Your OpenGL rendering here
        glClearColor(0.0, 0.2, 0.3, 1.0)
        glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
        endEyeRender(eye)
    endFrame(frame)

closeXr()
```

### Controllers

```nim
initXr("my-app")
setupActions()

# After session is ready:
createSwapchains()
attachActions()

# Each frame:
syncActions()
let left = getControllerState(leftHand, frame.predictedDisplayTime)
let right = getControllerState(rightHand, frame.predictedDisplayTime)

# Read input
echo left.triggerValue       # 0.0 .. 1.0
echo right.gripPose.position # XrVector3f
echo left.buttonA            # bool

# Haptics
applyHaptic(rightHand)
```

## vmath Converters

OpenXR math types convert to/from [vmath](https://github.com/treeform/vmath) types:

```nim
let pos: Vec3 = controller.gripPose.position.toVec3()
let rot: Quat = controller.gripPose.orientation.toQuat()
let viewMatrix: Mat4 = view.pose.toMat4()
```

## Tests

```sh
make test               # unit tests (parallel)
make integration-test   # integration tests (parallel)

# manual tests (require SteamVR + headset)
nim r tests/manual_headset.nim
nim r tests/manual_controllers.nim
```

## Project Structure

```
src/
  xr.nim                       # entry point, platform dispatch
  xr/common.nim                # enums, math types, vmath converters
  xr/internal.nim              # error checking (checkXr)
  xr/platforms/
    linux_defs.nim             # C FFI bindings, structs, constants
    linux.nim                  # session, rendering, input implementation
tests/
  test_common.nim              # unit tests
  manual_headset.nim           # headset rendering test
  manual_controllers.nim       # controller input test
docs/
  status.md                    # detailed status of what works / what doesn't
```

## Status

Working: session lifecycle, stereo rendering, controller input (Oculus Touch profile), haptics, vmath integration.

See [docs/status.md](docs/status.md) for full details on what's implemented, what's planned, and what's out of scope.

## License

MIT
