# US-012: Window Resize with Responsive Canvas Scaling

**As a** hobbyist painter,
**I want to** resize the application window freely and have the canvas area respond gracefully,
**So that** I can arrange TheRobotPaints alongside reference images or other apps without the canvas breaking or clipping.

## Personas
- **Primary:** Suki Tanaka — zero-friction experience means the app should never require manual adjustments after a window resize; it should just work
- **Also relevant:** Priya Sharma, Lena Vasquez

## Acceptance Criteria
- [ ] Resizing the window updates the MTKView drawable size within one frame with no visible glitch or black flash
- [ ] The canvas viewport transform is adjusted so the canvas maintains its current zoom and pan position relative to the new window size
- [ ] If the canvas was in fit-canvas mode (US-003), resizing recalculates the fit scale to fill the new window size
- [ ] Minimum window size (600 × 400 pt) is enforced; below this the canvas clips gracefully rather than crashing
- [ ] Live resize (continuous updates while dragging the window edge) sustains at least 30 FPS on M1 base
- [ ] SwiftUI panel widths are constrained so the canvas area always retains a minimum of 400 pt width

## Notes
`MTKView` should respond to `viewDidChangeEffectiveAppearance` and `viewDidEndLiveResize` in addition to continuous live resize notifications. The viewport transform update must be synchronized with the next `draw()` call to avoid a one-frame stale transform.
