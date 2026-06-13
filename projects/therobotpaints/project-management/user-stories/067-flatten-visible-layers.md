# US-067: Flatten Visible Layers into One

**As a** concept artist,
**I want to** flatten all visible layers into a single layer,
**So that** I can reduce complexity and continue painting on a unified paint surface.

## Personas
- **Primary:** P3 Lena Vasquez — after blocking in with multiple layers, often collapses them before detail pass
- **Also relevant:** P2 David Okafor, P5 Suki Tanaka

## Acceptance Criteria
- [ ] A "Flatten Visible" action merges all non-hidden layers into the lowest-indexed visible layer slot
- [ ] The flatten operation blends VolumeLayer data physically: color, depth, wetness, and viscosity are composited in layer order
- [ ] Hidden layers are unaffected and remain in their original slots
- [ ] Empty layer slots freed by the flatten are zeroed and marked empty in the buffer
- [ ] The action is undoable; undo restores the full pre-flatten layer buffer state
- [ ] A confirmation dialog warns the user that the operation is lossy with respect to layer separation

## Notes
Flatten is a destructive merge of GPU buffer data. The implementation should snapshot the full layer-major buffer to an undo stack entry before executing. Physical merge logic (depth stacking, wetness averaging) must respect the absorption color model to avoid hue artifacts.
