# US-040: 3D Mouse (SpaceMouse) for Canvas Navigation While Painting

**As a** technical artist who uses a SpaceMouse for viewport navigation in 3D tools,
**I want to** use a 3D mouse to pan, zoom, and rotate the canvas while my other hand paints with a stylus,
**So that** I can navigate the canvas without interrupting my painting hand or triggering keyboard shortcuts.

## Personas
- **Primary:** P6 Alex Kirchner — uses a SpaceMouse in his 3D tool pipeline and wants to bring that two-handed workflow into TheRobotPaints
- **Also relevant:** P2 David Okafor, P3 Lena Vasquez

## Acceptance Criteria
- [ ] 3Dconnexion SpaceMouse devices are detected via the 3Dconnexion SDK or HID interface at application launch
- [ ] X/Y axis tilt on the SpaceMouse pans the canvas (mapped to the same transform as two-finger scroll)
- [ ] Twist axis rotates the canvas view around its center
- [ ] Z axis (push/pull) zooms the canvas in and out
- [ ] SpaceMouse navigation input is processed on the main run loop and applied as a canvas view transform without triggering stroke input
- [ ] Sensitivity for each axis is configurable in the Input Devices settings panel
- [ ] SpaceMouse navigation works simultaneously with stylus painting (no mode-switching required; the two inputs are independent)
- [ ] If no SpaceMouse is detected, the feature is silently disabled with no UI clutter

## Notes
SpaceMouse devices send continuous 6DOF delta values; the integration must clamp and smooth these deltas to prevent jarring jumps when the device is picked up or set down. The canvas rotation applied via SpaceMouse must be the same transform as manual canvas rotation (US-002 family) and must not conflict with it.
