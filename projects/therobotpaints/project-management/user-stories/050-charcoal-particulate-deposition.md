# US-050: Charcoal Particulate Deposition with Variable Density

**As a** plein air sketch artist,
**I want to** lay down charcoal marks whose darkness and grain density vary with my pressure and stroke speed,
**So that** fast, light strokes produce faint granular marks while slow, heavy strokes produce dense, rich blacks that match the gestural range of real charcoal drawing.

## Personas
- **Primary:** P7 Priya Sharma — charcoal is her primary sketching medium before watercolor washes; mark quality defines her compositional speed
- **Also relevant:** P4 James Whitfield, P5 Suki Tanaka

## Acceptance Criteria
- [ ] Charcoal is modeled as dry particulate deposition: no moisture channel; particles adhere to canvas surface texture peaks
- [ ] Stylus pressure controls the quantity of particles deposited per unit length of stroke
- [ ] Stroke speed influences deposition density: faster strokes deposit fewer particles per pixel, producing lighter, sketchier marks
- [ ] Canvas roughness (from material properties texture) determines how many particles adhere versus fall off: rougher surfaces retain more charcoal
- [ ] Deposited charcoal layers are composited using the Beer-Lambert absorption model to produce accurate darkening as layers accumulate

## Notes
Charcoal particles are represented in the Lagrangian SPH layer as dry particles with zero fluid properties. Particle-to-Volume projection maps them to the opacity channel of the VolumeLayer. Unlike fluid media, charcoal does not flow between cells after deposition unless mechanically displaced (see US-051).
