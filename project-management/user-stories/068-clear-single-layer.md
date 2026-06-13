# US-068: Clear a Single Layer

**As a** hobbyist painter,
**I want to** clear all paint from a single layer with one action,
**So that** I can redo a failed wash without disturbing the rest of my painting.

## Personas
- **Primary:** P5 Suki Tanaka — makes frequent mistakes on individual layers and needs a fast, confident reset
- **Also relevant:** P1 Maya Chen, P3 Lena Vasquez

## Acceptance Criteria
- [ ] A "Clear Layer" action (context menu on layer row or keyboard shortcut) zeros all VolumeLayer data for the selected layer slot
- [ ] The action zeroes color_rgbo, depth, wetness, viscosity, velocity_xy, and resets age to 0 for every pixel in that layer
- [ ] The clear operation is undoable; undo restores the layer's full pre-clear state
- [ ] A confirmation prompt appears if the layer has significant paint (depth mean above threshold), skippable with a held modifier key
- [ ] After clearing, the layer thumbnail and state badges update immediately to reflect the empty state

## Notes
Zeroing a single layer slot in the layer-major buffer is a targeted GPU fill operation on the slice corresponding to that layer index. It should complete in one Metal blit encoder fillBuffer call, not a full canvas reinitialization.
