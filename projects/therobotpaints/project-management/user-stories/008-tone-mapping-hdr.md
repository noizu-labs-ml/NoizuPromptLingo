# US-008: Tone Mapping for HDR Paint Values

**As a** technical artist developing paint shaders,
**I want to** choose and tune the tone mapping operator applied to HDR paint values before display,
**So that** I can evaluate how different operators affect highlight preservation, shadow detail, and overall perceptual luminance of the composited result.

## Personas
- **Primary:** Alex Kirchner — shader development requires the ability to switch tone mapping operators and inspect their effect on out-of-range HDR values produced by thick impasto highlights
- **Also relevant:** David Okafor, Lena Vasquez

## Acceptance Criteria
- [ ] Reinhard tone mapping is applied by default as the final compositor stage before display output
- [ ] At least three tone mapping operators are available: Reinhard, ACES Filmic, and Uncharted 2 (Hable)
- [ ] Active operator and its parameters (e.g., exposure, shoulder strength) are selectable in View > Tone Mapping
- [ ] Switching operators updates the rendered output within one frame
- [ ] An "Exposure" slider (range: −3 to +3 EV, default 0) is available alongside the operator selector
- [ ] A "Clamp (no tone map)" option is available for shader debugging that simply clamps values to [0, 1]
- [ ] Tone mapping settings are saved with the document

## Notes
The Reinhard pass is already present in the compositor. This story adds the operator selection UI, the additional MSL implementations for ACES and Hable, and the exposure pre-multiplier uniform. All operators must handle FP16 input without NaN propagation.
