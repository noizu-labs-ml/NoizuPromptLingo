# US-063: Active Layer Selection for Painting Target

**As a** digital illustrator,
**I want to** tap a layer row to make it the active painting target,
**So that** my brush strokes deposit paint into the correct layer without accidentally contaminating others.

## Personas
- **Primary:** P1 Maya Chen — layered watercolor technique requires deliberate placement of washes on specific layers
- **Also relevant:** P3 Lena Vasquez, P2 David Okafor

## Acceptance Criteria
- [ ] Clicking a layer row selects it as the active layer; the row is highlighted with a distinct selection state
- [ ] All brush stroke kernels write paint data exclusively to the active layer's VolumeLayer slot in the buffer
- [ ] Only one layer can be active at a time; selecting a new layer deselects the previous
- [ ] Keyboard shortcuts (e.g., 1–8) jump directly to the corresponding layer slot
- [ ] The active layer indicator is visible in the toolbar or HUD so the user always knows the target without looking at the panel

## Notes
Active layer index should be a single integer in app state, not embedded in the GPU buffer, to keep the selection change free of GPU round-trips. The brush kernel reads this index as a push constant.
