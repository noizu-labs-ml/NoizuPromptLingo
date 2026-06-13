# US-006: Canvas Texture Visibility Under Paint

**As a** traditional oil painter,
**I want to** control how much the underlying canvas weave texture shows through thin paint layers,
**So that** I can achieve the look of paint applied to real linen or cotton canvas where the support texture contributes to the surface character.

## Personas
- **Primary:** David Okafor — canvas tooth and weave are integral to traditional oil technique; the texture must read through thin glazes and washes
- **Also relevant:** Maya Chen, Lena Vasquez

## Acceptance Criteria
- [ ] A canvas texture strength slider (0–100%) is available in canvas settings
- [ ] At 0% the procedural weave is invisible; at 100% it is fully visible through transparent paint layers
- [ ] Texture visibility is modulated by the paint opacity in each pixel: areas with more opaque paint show less weave
- [ ] Canvas texture preset options include at least: Fine Linen, Coarse Linen, Smooth Cotton, Hot Press Paper
- [ ] The weave pattern is generated procedurally in the MSL compositor and does not require a texture asset on disk
- [ ] Changes to texture strength update within one frame without restarting the render pipeline

## Notes
The procedural weave is already initialized in the current canvas init pass. This story adds the user-facing control and the per-pixel blending logic in the compositor that attenuates weave contribution based on paint volume in the alpha/coverage channel of VolumeLayer.
