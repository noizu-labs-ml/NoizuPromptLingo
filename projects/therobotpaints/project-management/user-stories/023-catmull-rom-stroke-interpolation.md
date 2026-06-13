# US-023: Catmull-Rom Stroke Interpolation for Smooth Curves

**As a** concept artist drawing fast, flowing lines,
**I want to** have raw input points smoothed into continuous curves using Catmull-Rom spline interpolation,
**So that** my strokes appear fluid and free of the jagged artifacts produced by low-sample-rate input.

## Personas
- **Primary:** P3 Lena Vasquez — draws fast gestural curves at 4K resolution where stairstepping is visible
- **Also relevant:** P1 Maya Chen, P7 Priya Sharma

## Acceptance Criteria
- [ ] All brush strokes are interpolated using Catmull-Rom splines computed on the GPU (MSL kernel)
- [ ] Interpolation subdivides each segment to produce at least one sample per pixel along the stroke path
- [ ] Pressure, tilt, and speed values are interpolated alongside position (not just spatial coordinates)
- [ ] The tension parameter of the spline is exposed as a per-brush setting (0.0 = loose, 1.0 = tight)
- [ ] Interpolation is applied in real time during stroke input, not as a post-process after pen-up
- [ ] Strokes rendered with interpolation are visually indistinguishable from strokes rendered at 8000+ dpi tablet resolution in standard comparison tests

## Notes
Catmull-Rom requires at least 4 control points; the pipeline must buffer the previous two points and look ahead by one to compute each segment. Edge handling (stroke start and end) must use phantom points to avoid artifacts.
