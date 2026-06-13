# US-033: Brush Stroke Undo with Single-Stroke Granularity

**As a** painter who makes mistakes,
**I want to** undo my most recent brush stroke as a single atomic action,
**So that** I can quickly recover from errors without losing multiple strokes of good work.

## Personas
- **Primary:** P3 Lena Vasquez — fast iteration workflow requires rapid undo without losing adjacent strokes
- **Also relevant:** P1 Maya Chen, P4 James Whitfield, P5 Suki Tanaka

## Acceptance Criteria
- [ ] Cmd+Z undoes the last complete stroke (pen-down to pen-up) as one unit, regardless of stroke length or complexity
- [ ] The undo operation restores the exact VolumeLayer state prior to that stroke (full pigment concentration data for affected pixels)
- [ ] Undo history depth is configurable (default: 100 strokes); oldest strokes are evicted when the limit is reached
- [ ] Undo is visually instantaneous (< 100ms for typical strokes on 4K canvas)
- [ ] Partial strokes (pen-down but not yet pen-up) are discarded entirely on undo, not partially reverted
- [ ] Undo history persists across tool switches (eraser undos and brush undos share the same stack)
- [ ] The undo stack is displayed in a History panel showing stroke thumbnails and timestamps

## Notes
Storing full VolumeLayer snapshots per stroke will be memory-intensive at 4K; the implementation should store delta patches (dirty rectangle of changed pixels) rather than full canvas copies. Compression of FP16 deltas should be evaluated.
