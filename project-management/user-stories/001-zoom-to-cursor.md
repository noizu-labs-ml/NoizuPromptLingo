# US-001: Zoom to Cursor Position

**As a** digital illustrator,
**I want to** pinch-to-zoom anchored at my cursor position,
**So that** the area I'm examining stays centered under my pointer instead of jumping to the canvas center.

## Personas
- **Primary:** Maya Chen — pixel-level edge control requires predictable zoom anchoring so she can inspect and paint fine detail without repositioning
- **Also relevant:** Lena Vasquez, Suki Tanaka

## Acceptance Criteria
- [ ] Pinch gesture on trackpad zooms in/out anchored at the centroid of the pinch, not the canvas center
- [ ] Scroll-wheel zoom (with modifier key) anchors at the mouse cursor position
- [ ] Zoom range spans at minimum 10% to 3200% of native canvas resolution
- [ ] The world-space coordinate under the cursor remains stable (within 1 pixel) throughout the zoom gesture
- [ ] Zoom state is reflected immediately in the viewport transform without frame skips

## Notes
Zoom anchor math must be applied in the MTKView coordinate-to-canvas-space transform before each render tick. The pinch gesture centroid should be computed from `NSEvent` touch positions and passed through the same anchor pipeline as scroll-wheel zoom.
