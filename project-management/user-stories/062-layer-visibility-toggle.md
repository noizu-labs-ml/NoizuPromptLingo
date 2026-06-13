# US-062: Layer Visibility Toggle

**As a** concept artist,
**I want to** show or hide individual paint layers,
**So that** I can isolate layers for inspection or compare composition states without destroying paint data.

## Personas
- **Primary:** P3 Lena Vasquez — rapidly iterates on layer arrangements; needs to audition layer combinations without committing
- **Also relevant:** P1 Maya Chen, P4 James Whitfield

## Acceptance Criteria
- [ ] Each layer row in the panel has an eye icon toggle; clicking it hides that layer from the composited render
- [ ] Hidden layers are excluded from the Metal composite pass but their VolumeLayer data is preserved in the buffer
- [ ] Layer panel row for a hidden layer is visually dimmed to indicate its state
- [ ] Toggling visibility does not affect paint physics simulation — wet paint on hidden layers continues to age and absorb
- [ ] Visibility state is saved and restored with the project file

## Notes
The flags field in VolumeLayer should carry a HIDDEN bit so the composite kernel can skip the layer without a separate boolean array. Simulation kernels must ignore the visibility flag and process all layers regardless.
