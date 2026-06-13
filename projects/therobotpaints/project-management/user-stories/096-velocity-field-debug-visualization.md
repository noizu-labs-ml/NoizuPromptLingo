# US-096: Velocity Field Debug Visualization Mode

**As a** technical artist tuning fluid dynamics in the paint simulation,
**I want to** visualize the paint velocity field as an arrow or flow overlay on the canvas,
**So that** I can see how paint is moving and identify vortices, stagnation zones, or unexpected flow directions.

## Personas
- **Primary:** P6 Alex Kirchner — velocity field is the core of fluid simulation; visual inspection is essential for shader development and parameter tuning
- **Also relevant:** P4 James Whitfield

## Acceptance Criteria
- [ ] View > Debug > Velocity Field renders an arrow-field or LIC (Line Integral Convolution) overlay showing paint flow direction and magnitude
- [ ] Arrow density and scale are adjustable via a compact inspector panel that appears when the mode is active
- [ ] Arrow color encodes speed magnitude (cool=slow, warm=fast) using the same LUT infrastructure as the wetness heatmap
- [ ] The visualization samples the velocity buffer on-GPU; no CPU readback is required for rendering
- [ ] The overlay updates every simulation tick without frame-rate degradation on M-series hardware
- [ ] Mode is mutually exclusive with other debug modes; deactivated by switching to another debug view or disabling Advanced Mode

## Notes
A simplified arrow-field approach (sample velocity texture at grid intervals, draw quads) is sufficient for v1; LIC is a stretch goal. Arrow geometry should be generated in a compute shader outputting to a vertex buffer consumed by the overlay render pass.
