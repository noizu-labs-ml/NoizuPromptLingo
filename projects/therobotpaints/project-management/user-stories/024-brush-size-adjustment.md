# US-024: Brush Size Adjustment via Keyboard Shortcut or Gesture

**As a** painter who switches brush sizes frequently during a session,
**I want to** adjust brush size quickly using keyboard shortcuts or a drag gesture,
**So that** I can change scale without interrupting my creative flow to find a slider in the UI.

## Personas
- **Primary:** P3 Lena Vasquez — fast iteration workflow requires instant size changes mid-sketch
- **Also relevant:** P1 Maya Chen, P2 David Okafor, P7 Priya Sharma

## Acceptance Criteria
- [ ] `[` decreases brush size and `]` increases brush size by a configurable step (default: 10% relative)
- [ ] Holding Shift with `[`/`]` applies a larger step (default: 50% relative)
- [ ] A right-click drag gesture (horizontal axis) adjusts brush size in real time with visual feedback
- [ ] Brush size changes are reflected immediately in the brush preview cursor (US-026) without lag
- [ ] Size range is enforced: minimum 1px logical, maximum defined by canvas DPI and brush type
- [ ] Size changes are undoable as part of brush state but do not create undo history entries on their own

## Notes
Keyboard shortcut assignments must be rebindable in system preferences. The drag gesture must not conflict with canvas pan (which uses a different modifier key combination).
