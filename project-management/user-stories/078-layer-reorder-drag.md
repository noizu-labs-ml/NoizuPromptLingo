# US-078: Layer Reorder via Drag (If Paint Physics Allows)

**As a** concept artist,
**I want to** drag layer rows to reorder them in the panel,
**So that** I can adjust composite stacking order to change how layers interact visually.

## Personas
- **Primary:** P3 Lena Vasquez — iterates on stacking order as part of her composition process; drag-to-reorder is expected from professional tools
- **Also relevant:** P1 Maya Chen, P6 Alex Kirchner

## Acceptance Criteria
- [ ] Layer rows in the panel support drag-and-drop reordering with a visual drop indicator between rows
- [ ] Reordering changes the composite rendering order in the Metal composite pass without modifying GPU buffer layout
- [ ] A render-order mapping array (CPU-side) translates panel position to buffer slot index; this array is the source of truth for composite pass ordering
- [ ] If two adjacent layers have active wet-paint interaction (bleed or absorption pending), a warning indicates that reorder may produce unexpected physics results
- [ ] The reorder action is undoable

## Notes
Because the layer-major GPU buffer is indexed by slot number (0–7), reordering must not physically move buffer data — it must use an indirection table. The composite kernel reads this table to determine layer draw order. Physics kernels always operate on slot-indexed data and are unaffected by display order.
