# US-072: Color Picker with Absorption-Aware Preview

**As a** digital illustrator,
**I want to** see how a chosen color will appear after absorption into the current canvas material,
**So that** I can select paint color based on the dried result rather than the raw pigment value.

## Personas
- **Primary:** P1 Maya Chen — watercolor pigments shift significantly on absorption; picking by eye appearance rather than pigment value is essential
- **Also relevant:** P2 David Okafor, P4 James Whitfield

## Acceptance Criteria
- [ ] The color picker shows two swatches side by side: "Pigment" (raw color_rgbo) and "On Canvas" (predicted absorbed appearance)
- [ ] The "On Canvas" preview is computed using the absorption color model with the current canvas material's absorbency and sizing values
- [ ] Preview accounts for whether the active layer is wet or dry, showing different absorbed results for each state
- [ ] The picker supports HSB, RGB, and hex input modes
- [ ] Absorption preview updates within one frame of color selection change (no perceptible lag)

## Notes
The absorption preview computation should be a lightweight CPU-side approximation of the GPU absorption model, not a full GPU render pass, to keep the picker responsive. Accuracy can be approximate — the goal is directional guidance, not pixel-perfect prediction.
