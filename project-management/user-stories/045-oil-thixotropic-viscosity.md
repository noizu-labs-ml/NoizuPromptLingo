# US-045: Oil Paint Thixotropic Viscosity (Thick Paint That Thins Under Brush Pressure)

**As a** traditional oil painter,
**I want to** press harder with my brush and feel the paint thin and flow more easily, then watch it stiffen again when I lift,
**So that** oil paint behaves with the shear-thinning thixotropy I depend on for controlling loaded brush strokes and impasto marks.

## Personas
- **Primary:** P2 David Okafor — thixotropic behavior is the defining mechanical property of the oil medium he works with daily
- **Also relevant:** P6 Alex Kirchner, P3 Lena Vasquez

## Acceptance Criteria
- [ ] Oil medium viscosity is represented as a dynamic value per-cell that decreases with applied shear stress from the brush
- [ ] Higher pen/stylus pressure maps to higher shear stress input, reducing local viscosity and allowing faster pigment displacement
- [ ] When brush contact ends, viscosity recovers toward its rest value at a medium-specific recovery rate (thixotropic recovery time)
- [ ] Paint loaded on the brush drags and smears more when viscosity is low; it resists displacement and stands in peaks when viscosity is high
- [ ] Viscosity recovery is visible in the simulation: a recently disturbed area gradually stiffens over the recovery time window

## Notes
Thixotropy is modeled as a structural parameter S per grid cell in [0,1], where S=1 is fully structured (high viscosity) and S=0 is fully broken down. Shear from brush input decreases S; a relaxation term rebuilds it over time. Viscosity is then a function of S and the medium's rest/breakdown viscosity pair.
