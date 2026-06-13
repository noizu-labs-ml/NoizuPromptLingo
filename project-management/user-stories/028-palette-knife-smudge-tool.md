# US-028: Palette Knife / Smudge Tool

**As a** traditional oil painter who works paint on the surface after laying it down,
**I want to** use a palette knife or smudge tool to move, mix, and blend wet paint across the canvas,
**So that** I can create the thick impasto and color-mixing effects that define my physical painting style.

## Personas
- **Primary:** P2 David Okafor — impasto technique requires moving large volumes of paint across the canvas surface
- **Also relevant:** P1 Maya Chen, P3 Lena Vasquez

## Acceptance Criteria
- [ ] The palette knife tool displaces paint volume laterally across VolumeLayer cells rather than depositing new pigment
- [ ] Displacement strength is controlled by pressure and a configurable "load" parameter
- [ ] The smudge variant picks up a sample of paint at stroke start and drags it along the stroke path, mixing with paint encountered along the way
- [ ] SPH particle interactions govern mixing behavior: pigments combine according to the Beer-Lambert absorption model
- [ ] Tool shape variants are available: straight edge (palette knife) and rounded tip (smudge/blending stump)
- [ ] Dry paint (paint that has been on canvas longer than a configurable "dry time" threshold) resists displacement
- [ ] The tool produces no new paint deposition; it only moves existing paint

## Notes
This tool depends on the SPH particle system being initialized for the affected canvas region. If SPH particles have not been generated for an area (e.g., it was painted in a prior session and settled), the tool must re-hydrate particles before displacement.
