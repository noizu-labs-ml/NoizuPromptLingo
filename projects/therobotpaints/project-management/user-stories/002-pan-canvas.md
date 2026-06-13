# US-002: Pan Canvas with Scroll / Trackpad

**As a** concept artist working on large 4K canvases,
**I want to** pan the canvas by scrolling or two-finger dragging on a trackpad,
**So that** I can navigate quickly across the canvas surface without interrupting my workflow.

## Personas
- **Primary:** Lena Vasquez — large canvases require fast, fluid navigation between composition zones during rapid iteration
- **Also relevant:** Maya Chen, Priya Sharma

## Acceptance Criteria
- [ ] Two-finger trackpad swipe pans the canvas in the swipe direction with 1:1 pixel mapping at 100% zoom
- [ ] Middle-mouse-button drag pans the canvas
- [ ] 3D mouse (SpaceMouse) translation axes pan the canvas when a device is connected
- [ ] Pan is clamped so at least 20% of the canvas remains visible in the viewport at all times
- [ ] Pan does not trigger an accidental brush stroke on any input device
- [ ] Panning at 60 FPS produces no visible tearing or frame drops on Apple Silicon

## Notes
Pan input should be consumed before any brush hit-test occurs; event priority must ensure pan always wins over brush when middle-mouse or two-finger scroll is active. Momentum scrolling (macOS inertia) should be respected for trackpad events.
