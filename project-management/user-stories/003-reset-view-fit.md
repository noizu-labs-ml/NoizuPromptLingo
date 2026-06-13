# US-003: Reset View to Fit Canvas

**As a** art educator demonstrating the full canvas to a classroom,
**I want to** instantly reset the viewport so the entire canvas fits the window,
**So that** students can see the complete composition after I've been zoomed into a detail.

## Personas
- **Primary:** James Whitfield — classroom demos require instant context switching between detail work and full-composition overviews without fumbling with zoom controls
- **Also relevant:** Suki Tanaka, Priya Sharma

## Acceptance Criteria
- [ ] Double-clicking an empty (non-brush) area of the canvas resets to fit-canvas view
- [ ] Cmd+0 keyboard shortcut resets to fit-canvas view
- [ ] Fit-canvas view scales the canvas so it fills the viewport with a uniform margin (16 px default) on all sides
- [ ] Reset is animated with a smooth ease-out transition of 200 ms or less; animation can be disabled via Accessibility > Reduce Motion
- [ ] Canvas rotation (if active) is also reset to 0° when fit-canvas is triggered
- [ ] Fit-canvas respects HiDPI scaling so the canvas is not blurry at 2x displays

## Notes
The fit-scale factor must be recomputed on every window resize and stored separately from the user-driven zoom level so that manual zoom is not overwritten until the user explicitly requests a reset.
