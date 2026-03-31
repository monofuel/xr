## Manual test: OpenXR controller input with SteamVR.
## Requires VR headset + controllers and SteamVR running.
## Run with: nix develop --command nim r tests/manual_controllers.nim

import windy, opengl
import xr
import strformat

let window = newWindow("XR Controller Test", ivec2(800, 600))
window.makeContextCurrent()
loadExtensions()

echo "Initializing OpenXR..."
initXr("xr-controller-test")
setupActions()
echo "OpenXR initialized with actions"

var swapchainCreated = false
var actionsReady = false
var frameCount = 0

echo "Entering event loop..."
while not window.closeRequested:
  pollEvents()
  let state = pollXrEvents()

  if state == xrSessionStateExiting or state == xrSessionStateLossPending:
    echo "Session ending: ", state
    break

  if not swapchainCreated and sessionRunning:
    createSwapchains()
    attachActions()
    swapchainCreated = true
    actionsReady = true
    echo "Ready! Swapchains + actions attached"

  if sessionRunning and swapchainCreated:
    let frame = beginFrame()

    if frame.shouldRender:
      # Sync and read controller state
      syncActions()
      let left = getControllerState(leftHand, frame.predictedDisplayTime)
      let right = getControllerState(rightHand, frame.predictedDisplayTime)

      # Log controller state periodically
      if frameCount mod 90 == 0:
        if left.gripActive:
          let p = left.gripPose.position
          echo &"L: pos=({p.x:.2f},{p.y:.2f},{p.z:.2f}) trigger={left.triggerValue:.2f} grip={left.squeezeValue:.2f} stick=({left.thumbstick.x:.2f},{left.thumbstick.y:.2f}) A={left.buttonA} B={left.buttonB}"
        if right.gripActive:
          let p = right.gripPose.position
          echo &"R: pos=({p.x:.2f},{p.y:.2f},{p.z:.2f}) trigger={right.triggerValue:.2f} grip={right.squeezeValue:.2f} stick=({right.thumbstick.x:.2f},{right.thumbstick.y:.2f}) A={right.buttonA} B={right.buttonB}"

      # Haptic feedback on trigger click
      if left.triggerClick:
        applyHaptic(leftHand)
      if right.triggerClick:
        applyHaptic(rightHand)

      # Render different colors based on trigger pull
      for eye in 0 ..< frame.views.len:
        discard beginEyeRender(eye)
        glClearColor(
          right.triggerValue * 0.5,
          0.1 + left.triggerValue * 0.4,
          0.2,
          1.0
        )
        glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
        endEyeRender(eye)

    endFrame(frame)

  inc frameCount

echo "Closing..."
closeXr()
echo "Done"
