# US-044: Watercolor Edge Darkening During Drying

**As a** watercolor illustrator,
**I want to** see pigment concentrate along the outer edges of a drying wash,
**So that** the characteristic dark-edged, lighter-center effect of dried watercolor washes appears automatically, matching how real paint migrates with evaporating water.

## Personas
- **Primary:** P1 Maya Chen — edge darkening defines the structural quality of her washes and is essential to realistic watercolor rendering
- **Also relevant:** P4 James Whitfield, P5 Suki Tanaka

## Acceptance Criteria
- [ ] As a wet wash enters the Drying stage, pigment in the interior migrates toward the wash perimeter driven by simulated capillary flow
- [ ] The resulting dried stroke shows visibly darker concentration at its edges compared to its center
- [ ] Edge darkening magnitude scales with the initial pigment load and the drying rate of the medium
- [ ] The effect is directional on a tilted canvas: pigment accumulates more strongly along the downhill edge when canvas tilt is nonzero
- [ ] Once fully dry, the edge concentration is locked and no longer influenced by subsequent simulation steps

## Notes
Edge darkening is a manifestation of the coffee-ring effect. It is driven by the Drying stage outward-radial flow component. Canvas tilt influence requires the grid fluid solver to incorporate a gravity vector projected onto the canvas plane.
