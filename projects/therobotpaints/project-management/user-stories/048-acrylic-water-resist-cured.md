# US-048: Acrylic Fast-Drying with Water-Resist Once Cured

**As a** mixed-media concept artist,
**I want to** lay down an acrylic underpainting that dries quickly and then resists water-based media applied over it,
**So that** I can build layered mixed-media work where acrylics act as a water-resistant foundation beneath watercolor or ink washes, matching real acrylic behavior.

## Personas
- **Primary:** P3 Lena Vasquez — cross-media layering with acrylic as a resist layer is a core technique in her mixed-media workflow
- **Also relevant:** P1 Maya Chen, P6 Alex Kirchner

## Acceptance Criteria
- [ ] Acrylic medium dries significantly faster than oil but slower than watercolor, with a default open time of minutes rather than hours
- [ ] Once an acrylic layer reaches its cured state (drying index = 1.0), its surface porosity drops to near zero in the canvas material properties texture
- [ ] Water-based media (watercolor, ink) applied over a cured acrylic region bead up and flow around it rather than absorbing into the canvas
- [ ] Uncured acrylic can still be blended and dissolved with water; cured acrylic cannot be reactivated by water application
- [ ] A visual indicator (optional overlay) shows the cure-state boundary so artists can track which regions are locked

## Notes
Water-resist behavior after cure is implemented by writing a near-zero absorbency value into the canvas material properties texture at the cured cells. This integrates with the existing cross-media rejection logic (see US-057) rather than requiring a separate system.
