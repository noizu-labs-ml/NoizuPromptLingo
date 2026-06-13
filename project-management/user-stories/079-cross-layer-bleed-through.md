# US-079: Cross-Layer Bleed-Through for Wet Paint

**As a** digital illustrator,
**I want to** see wet paint on an upper layer bleed through and interact with wet paint on a lower layer,
**So that** layered watercolor washes behave like their physical counterparts when both are wet simultaneously.

## Personas
- **Primary:** P1 Maya Chen — watercolor's defining quality is wet-into-wet interaction; single-layer isolation breaks the physical model
- **Also relevant:** P2 David Okafor, P6 Alex Kirchner

## Acceptance Criteria
- [ ] When two adjacent layers (by composite order) both have wetness above a configurable bleed threshold, the physics simulation allows color and pigment to migrate across the layer boundary
- [ ] Bleed rate is proportional to the wetness product of the two layers — fully wet layers bleed fastest
- [ ] Bleed is bidirectional: upper layer pigment can descend into lower, and lower layer pigment can rise into upper
- [ ] Bleed behavior respects viscosity differences between layers — high-viscosity paint bleeds more slowly
- [ ] A per-layer "bleed isolation" flag in the flags field can disable bleed for that layer (useful for masking layers or specialty effects)
- [ ] Bleed-through is visible in the composite render and in per-layer thumbnails

## Notes
Cross-layer bleed requires the simulation kernel to read from adjacent layers' VolumeLayer data when computing diffusion. This increases kernel memory bandwidth; the implementation should gate bleed computation on a pre-pass that identifies active wet-wet adjacent pairs to skip dry-layer pairs entirely.
