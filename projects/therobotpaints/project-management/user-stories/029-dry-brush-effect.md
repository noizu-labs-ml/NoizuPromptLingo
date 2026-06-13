# US-029: Dry Brush Effect with Sparse Bristle Marks

**As a** painter who uses dry brush technique to create texture and energy,
**I want to** paint with a brush that deposits paint sparsely and unevenly, following the canvas texture,
**So that** I can create the broken, bristle-separated marks characteristic of dry brush technique in oil and acrylic.

## Personas
- **Primary:** P2 David Okafor — dry brush is a core technique for gestural oil work and texture building
- **Also relevant:** P3 Lena Vasquez, P6 Alex Kirchner

## Acceptance Criteria
- [ ] The dry brush mode deposits paint only on the raised portions of the canvas texture (height map peaks), leaving valleys unpainted
- [ ] Bristle count, spread, and stiffness are configurable parameters in the brush settings
- [ ] Paint load (the amount of paint on the brush) decreases along the stroke length, producing a natural "running out of paint" fade
- [ ] Low pressure produces sparser, more broken marks; higher pressure pushes paint into more texture valleys
- [ ] The canvas texture normal map is sampled in the MSL dab kernel to determine deposition probability per texel
- [ ] Dry brush behavior is available as a variant on round, flat, and fan brush types (US-030, US-031, US-032)

## Notes
Bristle mark placement should use a deterministic noise function seeded by canvas position (not random) so that marks are stable on stroke replay (US-035) and redo (US-034). Jitter must be spatial, not temporal.
