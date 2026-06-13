# US-075: Color Mixing Preview (Predicted Result Before Applying)

**As a** traditional oil painter,
**I want to** see a preview of how my selected color will mix with existing paint on the active layer before I touch the canvas,
**So that** I can avoid committing a stroke that produces an unexpected mixed color.

## Personas
- **Primary:** P2 David Okafor — oil paint mixing is physical and irreversible; preview prevents costly mistakes in thick impasto layers
- **Also relevant:** P1 Maya Chen, P6 Alex Kirchner

## Acceptance Criteria
- [ ] A mixing preview swatch appears in the color picker or HUD showing the predicted blend of selected color with the paint at the cursor position
- [ ] Preview updates as the cursor moves over the canvas, sampling the underlying layer's color_rgbo at the hover point
- [ ] Mixing calculation uses viscosity and wetness of both the existing paint and the incoming color to weight the blend
- [ ] Preview is clearly labeled "Mixed Result" and shown alongside the selected pigment color for comparison
- [ ] Preview is optional and can be disabled in preferences for users who find it distracting

## Notes
Mixing preview is a CPU-side approximation using the same blending model parameters as the GPU simulation kernel. It should not be a GPU pass — it is a speculative preview, not a committed simulation step.
