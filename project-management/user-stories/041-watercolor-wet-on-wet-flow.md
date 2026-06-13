# US-041: Watercolor Wet-on-Wet Flow and Blending

**As a** watercolor illustrator,
**I want to** paint into a wet area and watch pigment diffuse naturally through the water layer,
**So that** I can achieve soft, luminous blends that match the behavior of real wet-on-wet watercolor technique.

## Personas
- **Primary:** P1 Maya Chen — her entire workflow depends on wet-on-wet as the foundation of luminous watercolor rendering
- **Also relevant:** P5 Suki Tanaka, P7 Priya Sharma

## Acceptance Criteria
- [ ] A freshly painted wet stroke creates a moisture field on the canvas grid that neighboring pigment deposits diffuse into
- [ ] Pigment concentration gradient is driven by the Eulerian moisture layer; drier areas receive less diffusion spread
- [ ] Two wet strokes with different pigment colors blend at their intersection, producing a weighted mixture that follows Beer-Lambert absorption
- [ ] Diffusion rate scales with the local moisture value in the VolumeLayer grid rather than applying a global constant
- [ ] Blended edges appear soft with no hard pixel boundary between the two color regions

## Notes
Diffusion is modeled on the Grid Fluid stage of the simulation pipeline; moisture content is tracked in VolumeLayer channels. Wet-on-wet blending must remain stable at 60 fps on M1; avoid iterative solvers that stall the render loop.
