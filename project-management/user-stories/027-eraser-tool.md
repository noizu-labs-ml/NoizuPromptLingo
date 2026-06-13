# US-027: Eraser Tool That Removes Paint from Layers

**As a** painter who makes mistakes and needs to correct them non-destructively,
**I want to** erase paint from individual layers using a pressure-sensitive eraser,
**So that** I can refine edges and recover underlying layers without undoing entire strokes.

## Personas
- **Primary:** P1 Maya Chen — frequent edge refinement and masking requires precise, layered erasure
- **Also relevant:** P3 Lena Vasquez, P5 Suki Tanaka

## Acceptance Criteria
- [ ] The eraser tool removes paint volume from the active VolumeLayer only, not from layers beneath it
- [ ] Eraser size, hardness, and opacity are independently configurable (same parameter set as brush tools)
- [ ] Eraser pressure sensitivity maps to erasure strength (full pressure = full removal; light pressure = partial thinning)
- [ ] Stylus eraser end (physical flip) automatically activates the eraser tool and restores the previous tool on flip back
- [ ] "Erase to transparent" and "Erase to background color" modes are selectable
- [ ] Erased areas display a checkerboard pattern (indicating transparency) if no opaque layer lies beneath
- [ ] Eraser strokes are recorded as discrete undo events (US-033 granularity applies)

## Notes
The eraser operates on VolumeLayer pigment concentration data, not on a flat alpha mask — it must reduce pigment density values rather than simply writing alpha=0. This distinction matters for the Beer-Lambert rendering model.
