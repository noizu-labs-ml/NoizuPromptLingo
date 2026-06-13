# US-095: Wetness Heatmap Debug Visualization Mode

**As a** technical artist debugging paint physics behavior,
**I want to** toggle a wetness heatmap overlay on the canvas,
**So that** I can see the spatial distribution of moisture in the simulation and diagnose unexpected drying or flow behavior.

## Personas
- **Primary:** P6 Alex Kirchner — needs to inspect internal simulation state spatially to tune physics parameters and validate shader correctness
- **Also relevant:** P4 James Whitfield

## Acceptance Criteria
- [ ] View > Debug > Wetness Heatmap (or keyboard shortcut) overlays a false-color heatmap on the canvas (blue=dry, red=fully wet)
- [ ] The overlay is rendered as a Metal pass reading the wetness buffer directly, not a CPU readback
- [ ] A legend showing the color scale (0.0 dry → 1.0 wet) is displayed in a corner overlay
- [ ] The heatmap updates in real time at the simulation tick rate
- [ ] Wetness heatmap mode is mutually exclusive with other debug viz modes (velocity field, layer depth); selecting one deactivates others
- [ ] The mode is only available in Advanced Mode; it is hidden in Simple Mode

## Notes
The heatmap shader should be an additional render pass that composites over the standard output using a fragment shader that maps the wetness texture value through a predefined color ramp LUT. This avoids modifying the physics pipeline itself.
