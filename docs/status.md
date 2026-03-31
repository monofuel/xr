# xr.nim - Status

Nim OpenXR library for VR. Hand-written bindings, thin wrapper over the OpenXR C API.

## What's Working

### Core Session Lifecycle
- Instance creation with OpenGL extension (`XR_KHR_opengl_enable`)
- System (HMD) discovery
- Session creation with OpenGL/GLX graphics binding
- Session state machine (idle -> ready -> synchronized -> visible -> focused -> stopping)
- Automatic `beginSession`/`endSession` on state transitions
- Clean teardown (`closeXr`)

### Rendering
- Stereo swapchain creation (one per eye)
- Swapchain format enumeration with SRGB preference (`GL_SRGB8_ALPHA8`)
- Per-eye framebuffer + depth buffer setup
- Frame lifecycle: `beginFrame` -> per-eye `beginEyeRender`/`endEyeRender` -> `endFrame`
- View (eye) pose and FOV from the runtime each frame
- Composition layer projection submission to compositor
- Stage reference space (room-scale)

### Controller Input
- Action system setup with "gameplay" action set
- Oculus Touch / Meta Quest controller interaction profile bindings
- Per-hand grip and aim poses
- Trigger (value + click), squeeze (value + click)
- Thumbstick (2D axis + click)
- A/X, B/Y buttons
- Menu button
- Haptic vibration output (apply + stop)

### Math / Converters
- OpenXR math types: `XrVector2f`, `XrVector3f`, `XrQuaternionf`, `XrPosef`, `XrFovf`
- vmath converters: `toVec2`, `toVec3`, `toQuat`, `toMat4` (and reverse)
- `XrPosef` -> `Mat4` for use with typical 3D rendering pipelines

### FFI Bindings (linux_defs.nim)
- ~45 core OpenXR C functions
- All `XrStructureType` constants verified against `openxr.h`
- Extension function loading via `xrGetInstanceProcAddr`
- X11/GLX functions for extracting OpenGL context info (`glXGetCurrentContext`, etc.)

### Build / Dev Environment
- `nix develop` via `flake.nix` (openxr-loader, vulkan-loader, X11, GLX, libuuid)
- `nimby` for Nim dependency management
- `Makefile` with `make test` (parallel unit tests) and `make integration-test`
- Unit tests for enum values, vmath converters, pose math

### Tested With
- SteamVR on Linux (X11)
- Meta Quest 3 (via SteamVR Link)
- OpenGL rendering
- Nim 2.0+

## Not Yet Implemented

### Rendering
- Quad composition layers (for UI panels in world space)
- Cylinder / equirect composition layers
- Multisampled swapchains
- Depth submission (`XR_KHR_composition_layer_depth`)
- Visibility mask (`XR_KHR_visibility_mask`)

### Input
- Additional interaction profiles (Valve Index, HTC Vive, HP Reverb, etc.)
- Hand tracking extension (`XR_EXT_hand_tracking`)
- Eye tracking extension (`XR_EXT_eye_gaze_interaction`)

### Spaces
- Local reference space (seated VR)
- View reference space (head-locked content)
- Bounded reference space
- Space velocity tracking

### Session
- Multiple simultaneous sessions
- Session loss recovery / reconnection
- Runtime property queries (runtime name, version)

### API Coverage
- API layer enumeration
- Extension enumeration / capability queries
- `xrResultToString` error message formatting
- Path enumeration for interaction profiles
- System property queries (max resolution, tracking capabilities)

## Out of Scope (For Now)

### Platforms
- **Windows** - no Win32/D3D graphics binding
- **macOS** - no Metal graphics binding (OpenXR support limited on macOS anyway)
- **Android** - no Android/OpenGLES or Vulkan graphics binding
- **WebXR** - planned for the future, but a completely separate API (not OpenXR)

### Graphics APIs
- **Vulkan** - only OpenGL is supported; Vulkan binding would be a separate graphics binding type
- **Direct3D 11/12** - Windows only

### Advanced Features
- Passthrough / mixed reality (`XR_FB_passthrough`, `XR_META_passthrough`)
- Scene understanding / spatial anchors
- Body tracking / face tracking
- Overlay / companion window rendering
- Performance profiling extensions
- Foveated rendering
- Controller model rendering (`XR_MSFT_controller_model`)

### Tooling
- Auto-generated bindings from `openxr.h` (hand-written by design)
- OpenXR validation layer integration
- Runtime switching (currently assumes SteamVR is the active runtime)
