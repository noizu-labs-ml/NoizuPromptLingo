# US-005: Adjustable Light Direction for Impasto Visualization

**As a** traditional oil painter working with heavy impasto,
**I want to** rotate the virtual light source direction in real time,
**So that** I can evaluate how raised paint ridges and palette knife marks catch light from different angles.

## Personas
- **Primary:** David Okafor — impasto simulation is the core of his workflow; light direction is the primary tool for reading surface depth and making decisions about additional texture
- **Also relevant:** James Whitfield, Alex Kirchner

## Acceptance Criteria
- [ ] A light direction control (compass rose or angle dial) is available in the tool panel or HUD
- [ ] Light direction can be set by dragging the control or entering an azimuth angle (0–360°) and elevation angle (0–90°)
- [ ] Canvas re-renders with updated impasto shading within one frame of the input event
- [ ] Default light direction is top-left (azimuth 315°, elevation 45°) matching traditional studio convention
- [ ] Light direction setting is saved per-document and restored on open
- [ ] A keyboard shortcut (L + drag) allows adjusting light direction directly on the canvas without leaving the brush tool

## Notes
The impasto lighting model in the MSL compositor uses the surface normal computed from the height field in VolumeLayer. The light direction uniform must be passed to the compute shader each frame; no baking or caching of the lit result is required at this stage.
