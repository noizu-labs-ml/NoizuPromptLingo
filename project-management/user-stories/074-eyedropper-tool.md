# US-074: Eyedropper Tool (Sample Color from Canvas)

**As a** digital illustrator,
**I want to** sample a color from the canvas with an eyedropper tool,
**So that** I can match or continue a color already on the canvas without guessing its value.

## Personas
- **Primary:** P1 Maya Chen — frequently needs to match an existing wash when extending it across paper
- **Also relevant:** P3 Lena Vasquez, P7 Priya Sharma

## Acceptance Criteria
- [ ] Activating the eyedropper (keyboard shortcut or toolbar) changes the cursor to a picker icon
- [ ] Clicking the canvas samples the composited color at that pixel from the rendered output texture (not raw layer data)
- [ ] Sampled color is set as the active foreground color and added to color history (US-076)
- [ ] An optional modifier key samples from the active layer only rather than the composited result
- [ ] A magnifier HUD appears near the cursor showing a zoomed neighborhood of the sample point for precision picking
- [ ] After sampling, the tool reverts to the previously active tool automatically

## Notes
Sampling from the composited render texture is a single GPU texture read via a blit to a 1×1 CPU-accessible buffer — this is cheap and should complete without a full pipeline stall. Layer-only sampling reads directly from the active layer's slice in the layer-major buffer.
