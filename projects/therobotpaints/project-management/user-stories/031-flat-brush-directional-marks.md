# US-031: Flat Brush with Directional Marks

**As a** painter who uses flat brushes to build structured, directional strokes,
**I want to** paint with a flat brush that deposits rectangular marks oriented along the stroke direction,
**So that** I can create the chiseled, directional brushwork characteristic of flat brush technique in oil and acrylic.

## Personas
- **Primary:** P2 David Okafor — flat brush is essential for his structured impasto and directional oil technique
- **Also relevant:** P1 Maya Chen, P6 Alex Kirchner

## Acceptance Criteria
- [ ] The flat brush dab shape is a rectangle with configurable width-to-height aspect ratio (default 4:1)
- [ ] The dab automatically rotates to align with the stroke direction vector at each interpolated sample point
- [ ] When stroke direction changes rapidly, the dab rotation transitions smoothly (angle interpolated across samples, not snapped)
- [ ] Brush width and height are independently adjustable; width follows the size control (US-024), height is a ratio of width
- [ ] The chisel edge (short axis) produces a thinner mark; dragging along the long axis produces a wide mark — both controlled by stroke angle relative to brush angle
- [ ] A fixed angle mode locks the dab orientation to a user-specified angle regardless of stroke direction

## Notes
The angle calculation must handle the 180° ambiguity in stroke direction (a stroke drawn left-to-right and right-to-left should produce the same dab orientation). Use the absolute angle modulo π, not the full 2π range.
