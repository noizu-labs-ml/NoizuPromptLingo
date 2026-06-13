# US-057: Cross-Media Rejection (Watercolor on Dried Oil)

**As a** mixed-media concept artist,
**I want to** see watercolor applied over dried oil paint bead up and resist absorption,
**So that** the physical incompatibility between water-based and oil-based media is modeled correctly, enabling and constraining mixed-media techniques as they exist in the real world.

## Personas
- **Primary:** P3 Lena Vasquez — understanding and exploiting cross-media incompatibility is a core part of her mixed-media practice
- **Also relevant:** P6 Alex Kirchner, P4 James Whitfield

## Acceptance Criteria
- [ ] A cross-media compatibility matrix defines which pairs of media repel, absorb neutrally, or interact chemically when applied wet-over-dry or wet-over-wet
- [ ] Watercolor applied over a dried oil region experiences near-zero absorbency; it flows and beads on the surface rather than soaking in
- [ ] The beading behavior routes the rejected watercolor to adjacent non-oil regions following the fluid dynamics of the grid solver
- [ ] Wet oil applied over wet watercolor partially displaces and mixes with the water layer based on a defined interaction coefficient
- [ ] The compatibility matrix is exposed in the media type definition so custom media authors can declare their cross-media relationships (see US-055)

## Notes
Cross-media rejection is implemented by the Deposition stage reading the existing media type tag at each canvas cell and applying the compatibility matrix to modulate absorption before committing new paint. This is distinct from acrylic water-resist (US-048), which modifies the canvas material properties texture; oil rejection operates at the media-interaction layer.
