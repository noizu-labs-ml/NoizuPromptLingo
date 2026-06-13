# US-064: Layer Paint State Indicators (Wet/Dry/Depth Badges)

**As a** digital illustrator,
**I want to** see wet/dry and depth badges on each layer row,
**So that** I know whether a layer's paint is still reactive before I apply the next wash.

## Personas
- **Primary:** P1 Maya Chen — wet-on-wet watercolor timing is critical; painting into a dry layer vs. a wet layer produces completely different results
- **Also relevant:** P4 James Whitfield, P6 Alex Kirchner

## Acceptance Criteria
- [ ] Each layer row displays a wetness badge: WET (wetness mean > 0.6), DRYING (0.1–0.6), DRY (< 0.1), or EMPTY
- [ ] A depth badge shows relative paint accumulation: THIN / MED / THICK derived from mean depth across non-empty pixels
- [ ] Badges update on a 500 ms polling interval from CPU-side aggregates, not per-frame
- [ ] Badge colors follow a consistent semantic scheme (blue-tinted for wet, amber for drying, muted for dry)
- [ ] Hovering a badge shows a tooltip with the exact aggregate value (e.g., "mean wetness: 0.74")

## Notes
Aggregate computation should occur in a lightweight compute pass that writes per-layer scalar summaries to a small CPU-accessible buffer, avoiding full readback of the 32 B-per-pixel layer data.
