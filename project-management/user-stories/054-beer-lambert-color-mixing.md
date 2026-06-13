# US-054: Absorptive Color Mixing (Beer-Lambert, Not Additive RGB)

**As a** technical artist building custom media types,
**I want to** the color of mixed and layered paints to be computed using Beer-Lambert transmittance rather than additive RGB blending,
**So that** mixed colors behave like real pigment mixtures — blue and yellow produce green, not grey — and layered transparent washes deepen correctly as physical paint does.

## Personas
- **Primary:** P6 Alex Kirchner — he is authoring custom media and needs the color model to be physically correct so his pigment data produces accurate results
- **Also relevant:** P1 Maya Chen, P4 James Whitfield

## Acceptance Criteria
- [ ] Each pigment is represented by spectral absorption and scattering coefficients (at minimum RGB-channel Beer-Lambert parameters) rather than a flat RGB color value
- [ ] Layered transparent paint is composited by multiplying transmittance values per channel: T_total = T1 * T2 * ... * Tn
- [ ] Reflected color seen by the viewer is computed as canvas reflectance modulated by the cumulative transmittance of all paint layers above it
- [ ] Mixing two wet pigments in the same cell blends their absorption coefficient vectors, not their RGB values, producing subtractive mixture behavior
- [ ] A color picker in the UI maps artist-friendly color selections to the underlying spectral absorption parameters using a calibrated lookup

## Notes
Beer-Lambert is the stated color model in the project architecture. This story validates that the model is applied consistently across all mixing paths: wet-on-wet blending, layer compositing, and dry-media layering. RGB-approximated spectral coefficients (3-channel) are acceptable for MVP; full spectral (e.g., 6–31 bands) is a future enhancement.
