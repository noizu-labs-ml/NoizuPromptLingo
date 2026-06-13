# US-030: Round Brush with Soft and Hard Edge Variants

**As a** digital illustrator who uses round brushes for the majority of my linework and painting,
**I want to** access a round brush with switchable soft and hard edge profiles,
**So that** I can use a single brush family for both precise linework (hard) and smooth blended fills (soft).

## Personas
- **Primary:** P1 Maya Chen — round brush is her primary tool; edge hardness determines watercolor wash vs. linework behavior
- **Also relevant:** P3 Lena Vasquez, P4 James Whitfield, P5 Suki Tanaka

## Acceptance Criteria
- [ ] The round brush dab is a radially symmetric shape with a configurable hardness value (0% = fully soft/Gaussian falloff, 100% = hard anti-aliased edge)
- [ ] Hardness is adjustable via a slider in the Tool Options bar and via a keyboard shortcut (Shift+`[`/`]`)
- [ ] The brush preview cursor (US-026) reflects the current hardness by rendering the edge at the correct softness
- [ ] Soft edges blend smoothly with underlying VolumeLayer paint; hard edges produce clean, anti-aliased boundaries
- [ ] Round brush is the default tool on application launch
- [ ] Size range: 1px to 2000px logical (actual pixel coverage depends on canvas DPI)

## Notes
The dab kernel in MSL should parameterize hardness as a smoothstep exponent applied to the radial distance function. This avoids branching in the shader and allows continuous interpolation between soft and hard modes.
