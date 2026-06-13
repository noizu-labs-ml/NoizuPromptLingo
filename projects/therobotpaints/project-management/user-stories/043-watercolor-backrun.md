# US-043: Watercolor Backrun (Pigment Migration at Wet/Dry Boundary)

**As a** watercolor illustrator,
**I want to** see a backrun "bloom" form when I drop wet paint into a partially dried area,
**So that** the irregular cauliflower-edged backrun shapes that define expressive watercolor spontaneity appear naturally without manual construction.

## Personas
- **Primary:** P1 Maya Chen — backruns are a critical expressive tool she deliberately induces and also occasionally needs to avoid
- **Also relevant:** P5 Suki Tanaka, P7 Priya Sharma

## Acceptance Criteria
- [ ] Depositing a wet stroke into an area with moisture level below the fully-wet threshold but above zero triggers a backrun event
- [ ] The incoming moisture pushes existing dried pigment outward from the contact point, creating a darker, irregular halo at the migration front
- [ ] Backrun boundary shape is non-uniform; it follows canvas texture and local moisture gradients rather than producing a perfect circle
- [ ] The backrun finalizes and locks as drying completes in the affected region; it does not continue migrating once fully dry
- [ ] Artists can prevent backruns by working only into fully wet or fully dry areas, matching real technique guidance

## Notes
Backrun physics emerge from the moisture-gradient reversal in the Grid Fluid stage: when new high-moisture paint enters a partially dry zone, the local pressure gradient reverses and drives pigment outward. This is an emergent behavior, not a separate effect pass.
