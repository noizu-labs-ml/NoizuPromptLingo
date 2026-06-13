# US-034: Brush Stroke Redo

**As a** painter who has undone strokes and wants to restore them,
**I want to** redo previously undone strokes in order,
**So that** I can step forward through my painting history after reviewing an earlier state.

## Personas
- **Primary:** P3 Lena Vasquez — iterative exploration of composition requires undo/redo cycling
- **Also relevant:** P1 Maya Chen, P4 James Whitfield

## Acceptance Criteria
- [ ] Cmd+Shift+Z (or Cmd+Y) redoes the most recently undone stroke
- [ ] Redo restores the exact VolumeLayer state that was active after the stroke was originally applied
- [ ] The redo stack is invalidated when a new stroke is painted after an undo (standard linear undo model)
- [ ] Redo is visually instantaneous (< 100ms for typical strokes on 4K canvas)
- [ ] The History panel (US-033) reflects the current undo/redo position with a clear cursor indicator
- [ ] Redo works correctly across tool types: brush strokes, eraser strokes, smudge operations, and palette knife operations are all redoable

## Notes
The redo stack is the forward portion of the undo history stack. When the redo stack is cleared by a new stroke, the evicted delta patches should be released from memory immediately to avoid unbounded memory growth. This story depends on US-033 being implemented first.
