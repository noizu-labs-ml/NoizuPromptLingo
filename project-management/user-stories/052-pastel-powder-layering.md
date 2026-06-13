# US-052: Pastel Powder Layering and Mixing

**As a** mixed-media concept artist,
**I want to** layer multiple pastel colors and blend them together on the canvas,
**So that** I can build up rich optical color mixtures through additive pastel layering, matching the soft, chalky blended quality of real pastel work.

## Personas
- **Primary:** P3 Lena Vasquez — pastel layering is one of her primary mixed-media techniques for color development in concept work
- **Also relevant:** P5 Suki Tanaka, P7 Priya Sharma

## Acceptance Criteria
- [ ] Pastel deposits as a powdery dry layer similar to charcoal but with distinct per-color pigment particles
- [ ] Multiple pastel colors can be layered on the same canvas region; the layers are composited using Beer-Lambert absorption, not RGB averaging
- [ ] Canvas tooth (roughness from material properties texture) controls how many pastel particles adhere per stroke; smooth surfaces fill quickly and resist additional layers
- [ ] Soft pastel deposits a wider, softer particle distribution; hard pastel deposits a narrower, more precise line with less powder spread
- [ ] Blending pastel layers produces an optical mix color visible in the render; the underlying individual-color particle distributions remain in the simulation state

## Notes
Pastel and charcoal share the dry-particulate deposition model but differ in particle size distribution, color, and canvas-tooth sensitivity parameters. The Beer-Lambert compositing of stacked pastel layers is critical for accurate color behavior; simple alpha blending would produce incorrect results.
