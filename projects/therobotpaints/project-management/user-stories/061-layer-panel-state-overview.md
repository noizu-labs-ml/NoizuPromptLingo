# US-061: Layer Panel Showing All 8 Paint Layers with State Indicators

**As a** digital illustrator,
**I want to** see all 8 paint layers in a panel with at-a-glance state indicators,
**So that** I can understand the current composition of my canvas without lifting my stylus.

## Personas
- **Primary:** P1 Maya Chen — watercolor workflow depends on knowing which layers are wet and which have dried pigment before adding new paint
- **Also relevant:** P3 Lena Vasquez, P6 Alex Kirchner

## Acceptance Criteria
- [ ] Layer panel displays all 8 VolumeLayer slots, even when empty, in fixed top-to-bottom order
- [ ] Each layer row shows: index number, thumbnail, name label, and a compact state badge cluster
- [ ] State badges communicate wetness (wet/drying/dry), paint presence (empty/has paint), and depth level (thin/medium/thick)
- [ ] Empty layer slots are visually distinct (muted, dashed border) but still occupy panel rows
- [ ] Panel updates in real time as paint state changes (age ticks, absorption events)

## Notes
State badge data is derived from per-layer aggregates of the VolumeLayer struct fields (wetness, depth, age) computed on the CPU readback path. Panel refresh rate should decouple from render frame rate to avoid GPU stalls.
