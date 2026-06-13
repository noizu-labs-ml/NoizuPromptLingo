# US-026: Brush Preview Cursor Showing Size and Shape

**As a** painter positioning a brush before committing a stroke,
**I want to** see a real-time cursor that shows the exact size and shape of my current brush,
**So that** I can place strokes accurately without guessing where paint will land.

## Personas
- **Primary:** P1 Maya Chen — pixel-level edge control requires precise cursor feedback before stroke begins
- **Also relevant:** P2 David Okafor, P3 Lena Vasquez, P4 James Whitfield

## Acceptance Criteria
- [ ] A cursor outline renders at the current brush size and shape (round, flat, fan, custom) at all times while hovering over the canvas
- [ ] The cursor updates in real time as brush size, shape, or angle changes (no frame delay)
- [ ] Cursor outline style is configurable: solid, dashed, or crosshair-center variants
- [ ] Cursor color inverts or uses a complementary color relative to the canvas content beneath it for visibility
- [ ] When pressure simulation is active, the cursor optionally scales to show the current simulated pressure-adjusted size
- [ ] The system cursor (arrow/crosshair) is hidden while the brush preview cursor is visible on the canvas
- [ ] Cursor rendering does not add measurable latency to the input pipeline (renders in a separate compositing pass)

## Notes
The brush preview cursor should be rendered via Metal in the canvas compositing layer, not as an NSCursor, to avoid OS cursor scheduling latency. It must track stylus hover position (pre-contact) on supported tablets.
