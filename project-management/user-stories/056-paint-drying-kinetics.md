# US-056: Paint Drying Kinetics (Medium-Specific Rates)

**As a** technical artist building custom media types,
**I want to** define medium-specific drying rate parameters that control how quickly each paint type transitions from wet to dry,
**So that** watercolor, acrylic, and oil each behave with their characteristic open-time windows and I can author custom media with accurate drying behavior.

## Personas
- **Primary:** P6 Alex Kirchner — drying rate is the most impactful parameter when authoring a new media type; incorrect rates make a medium feel wrong immediately
- **Also relevant:** P2 David Okafor, P1 Maya Chen, P4 James Whitfield

## Acceptance Criteria
- [ ] Each media type definition includes a drying-rate parameter set: initial open time, drying speed curve, and final-cure flag
- [ ] The Drying simulation stage reads these parameters per-cell based on the media type of the paint at that cell
- [ ] Drying rate is spatially non-uniform: thin paint layers dry faster than thick ones; exposed edges dry faster than pool centers
- [ ] Simulated environmental conditions (canvas temperature, airflow) are exposed as global modifiers that scale all drying rates proportionally
- [ ] A drying state debug overlay visualizes the moisture/oxidation index as a heatmap so artists and media authors can inspect drying progress

## Notes
Drying kinetics differ by medium: watercolor uses evaporative moisture loss, oil uses an oxidation index, acrylic uses two-phase evaporation (see US-049). The Drying stage must dispatch to the correct kinetics model based on the media type tag stored per VolumeLayer cell. Environmental modifiers are MVP-scope; full thermodynamic simulation is out of scope.
