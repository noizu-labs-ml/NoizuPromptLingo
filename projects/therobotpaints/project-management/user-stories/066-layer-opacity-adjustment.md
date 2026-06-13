# US-066: Layer Opacity Adjustment (Post-hoc, Non-destructive)

**As a** digital illustrator,
**I want to** adjust a layer's opacity after painting,
**So that** I can tune the visual weight of a wash without modifying the underlying paint data.

## Personas
- **Primary:** P1 Maya Chen — glazing technique requires precise control over how much a dried layer contributes to the final image
- **Also relevant:** P3 Lena Vasquez, P5 Suki Tanaka

## Acceptance Criteria
- [ ] Each layer row provides an opacity slider (0–100%) accessible via the layer panel
- [ ] Opacity is applied as a scalar multiplier in the composite kernel, not written into VolumeLayer color_rgbo data
- [ ] Changing opacity updates the composite render in real time without triggering a physics simulation step
- [ ] Opacity value is persisted per layer in the project file
- [ ] Double-clicking the opacity value allows direct numeric entry

## Notes
Layer opacity is a presentation-layer concern and should live in a parallel CPU-side layer metadata struct, not in the GPU buffer, to preserve the integrity of the physical paint data for simulation purposes.
