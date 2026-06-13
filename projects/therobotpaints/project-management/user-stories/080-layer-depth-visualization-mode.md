# US-080: Layer Depth Visualization Mode (Heightmap View)

**As a** technical artist,
**I want to** switch the canvas to a depth visualization mode that renders paint depth as a heightmap,
**So that** I can inspect the physical build-up of paint layers and diagnose simulation behavior.

## Personas
- **Primary:** P6 Alex Kirchner — needs to verify that depth accumulation, impasto behavior, and layer stacking are physically coherent
- **Also relevant:** P2 David Okafor, P4 James Whitfield

## Acceptance Criteria
- [ ] A "Depth View" toggle in the view menu (or toolbar) switches the canvas render to a false-color heightmap derived from the depth field of the active or all layers
- [ ] Depth is mapped to a perceptually uniform color ramp (e.g., dark blue = 0 depth, white = maximum depth)
- [ ] The view can be scoped to: All Layers (summed depth), Active Layer only, or any individually selected layer via a dropdown
- [ ] Toggling depth view does not affect the GPU buffer or simulation state — it is a render-pass swap only
- [ ] A legend overlay shows the depth scale in the current units (normalized 0–1 or physical microns if calibrated)
- [ ] Depth view can be screenshotted/exported as a reference image

## Notes
The depth visualization pass replaces the standard composite kernel with a specialized kernel that reads the depth field from the VolumeLayer buffer and writes false-color output. It should share the same buffer binding layout as the standard composite pass to minimize state changes on the command encoder.
