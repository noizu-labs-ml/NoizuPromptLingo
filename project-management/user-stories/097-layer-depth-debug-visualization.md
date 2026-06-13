# US-097: Layer Depth Debug Visualization Mode

**As a** technical artist inspecting paint build-up across the canvas,
**I want to** visualize paint layer depth (pigment accumulation thickness) as a height-map overlay,
**So that** I can verify that impasto effects, glazing, and wash layers are accumulating as physically expected.

## Personas
- **Primary:** P6 Alex Kirchner — layer depth directly affects light scattering and impasto simulation; validating it visually is essential for shader correctness
- **Also relevant:** P4 James Whitfield

## Acceptance Criteria
- [ ] View > Debug > Layer Depth renders a grayscale or false-color height-map overlay where darker = thin/no paint and brighter = thick accumulation
- [ ] The visualization reads from the layer depth buffer used by the lighting/impasto shader pass
- [ ] A numerical probe mode allows clicking a canvas pixel to display the exact depth value (in simulation units) in the status bar
- [ ] The overlay renders at full canvas resolution without aliasing artifacts
- [ ] Mode is mutually exclusive with other debug overlays and hidden in Simple Mode
- [ ] Depth range for the color mapping is auto-scaled to the current canvas min/max, with an option to fix the range manually

## Notes
Auto-scaling the depth range requires a GPU reduction pass to find min/max each frame; a fixed range fallback avoids this cost for real-time use. The pixel probe on click requires a single-pixel CPU readback from the depth texture at the clicked coordinates.
