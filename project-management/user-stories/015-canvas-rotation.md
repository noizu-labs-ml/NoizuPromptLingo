# US-015: Canvas Rotation for Comfortable Stroke Angles

**As a** digital illustrator,
**I want to** rotate the canvas view to any angle,
**So that** I can draw curves and strokes along my natural hand direction without awkward wrist positions.

## Personas
- **Primary:** Maya Chen — watercolor stroke quality depends on stroke direction relative to hand posture; rotating the canvas is standard practice in traditional and digital media alike
- **Also relevant:** Priya Sharma, David Okafor

## Acceptance Criteria
- [ ] The canvas can be rotated in the viewport by holding R and dragging horizontally
- [ ] A rotation indicator showing the current angle (−180° to +180°) is displayed in the HUD while rotating
- [ ] Rotation snaps to 0°, 90°, 180°, 270° when within 5° of those values (snap can be bypassed with Shift held)
- [ ] Cmd+0 (fit-canvas) resets rotation to 0° as well as zoom and pan
- [ ] Rotation is a view transform only — the canvas pixel data is not resampled or modified
- [ ] All input coordinates (brush hit-test, pan, zoom anchor) are correctly transformed through the rotation matrix before processing
- [ ] Canvas rotation is not saved with the document; it resets to 0° on document open

## Notes
The viewport transform matrix is currently scale + translation; rotation must be inserted as a rotation component in the same transform pipeline. Input event coordinates must be inverse-transformed through the full matrix (scale × rotation × translation) to obtain canvas-space coordinates correctly.
