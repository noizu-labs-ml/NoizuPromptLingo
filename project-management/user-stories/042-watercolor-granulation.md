# US-042: Watercolor Granulation on Rough Canvas

**As a** watercolor illustrator,
**I want to** see pigment particles settle unevenly into the texture valleys of rough paper,
**So that** granulating pigments like ultramarine or burnt sienna produce the characteristic mottled texture that defines their character on textured watercolor paper.

## Personas
- **Primary:** P1 Maya Chen — granulation is a signature quality she relies on for atmospheric skies and earth-tone washes
- **Also relevant:** P4 James Whitfield, P6 Alex Kirchner

## Acceptance Criteria
- [ ] The canvas material properties texture exposes a roughness channel that influences pigment settling distribution
- [ ] High-roughness surfaces cause pigment to accumulate in valleys, leaving peaks lighter, producing visible granulation pattern
- [ ] Granulation intensity is a per-media-type parameter (some pigments granulate more than others) that can be authored in the media definition
- [ ] Granulation pattern is stable once the moisture layer drops below the drying threshold; it does not shift during dry phases
- [ ] On smooth (low roughness) canvas, granulation is minimal and the wash appears flat and even

## Notes
Granulation is computed during the Particle-to-Volume projection step by biasing deposition toward low-height cells in the roughness map. Canvas roughness is stored in the canvas material properties texture used across the simulation pipeline.
