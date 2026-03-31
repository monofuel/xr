## Manual test: OpenXR VR rendering with SteamVR.
## Requires a VR headset connected and SteamVR running.
## Run with: nix develop --command nim r tests/manual_headset.nim

import windy, opengl
import xr

# Create a window with OpenGL context
let window = newWindow("XR Test", ivec2(800, 600))
window.makeContextCurrent()
loadExtensions()

echo "Initializing OpenXR..."
initXr("xr-manual-test")
echo "OpenXR initialized"

var swapchainCreated = false
var frameCount = 0

echo "Entering event loop (Ctrl+C or close window to exit)..."
while not window.closeRequested:
  pollEvents()
  let state = pollXrEvents()

  if state == xrSessionStateExiting or state == xrSessionStateLossPending:
    echo "Session ending: ", state
    break

  # Create swapchains once session is ready
  if not swapchainCreated and sessionRunning:
    echo "Creating swapchains..."
    createSwapchains()
    swapchainCreated = true
    echo "Swapchains created: ", swapchains.len, " views"
    for i, sc in swapchains:
      echo "  Eye ", i, ": ", sc.width, "x", sc.height, " (", sc.images.len, " images)"

  # Render if session is running
  if sessionRunning and swapchainCreated:
    let frame = beginFrame()

    if frame.shouldRender:
      for eye in 0 ..< frame.views.len:
        let (_, w, h) = beginEyeRender(eye)

        # Render a solid color per eye (left=teal, right=coral)
        if eye == 0:
          glClearColor(0.0, 0.4, 0.5, 1.0)
        else:
          glClearColor(0.5, 0.3, 0.2, 1.0)
        glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

        endEyeRender(eye)

    endFrame(frame)

  if frameCount mod 300 == 0 and frameCount > 0:
    echo "Frame ", frameCount, " | State: ", state

  inc frameCount

echo "Closing OpenXR..."
closeXr()
echo "Done"
