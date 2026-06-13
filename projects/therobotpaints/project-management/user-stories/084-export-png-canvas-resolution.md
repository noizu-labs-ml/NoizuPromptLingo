# US-084: Export as PNG at Canvas Resolution

**As a** digital illustrator,
**I want to** export my painting as a PNG at the native canvas resolution,
**So that** I can share previews, post to social media, or deliver web-resolution assets to clients.

## Personas
- **Primary:** P1 Maya Chen — needs clean 1:1 pixel export for client deliverables and portfolio sharing
- **Also relevant:** P5 Suki Tanaka, P7 Priya Sharma

## Acceptance Criteria
- [ ] File > Export > PNG (1x) presents a system save panel with `.png` extension pre-set
- [ ] Exported PNG is the composited visible canvas (all visible layers merged) at exact canvas pixel dimensions
- [ ] Export respects layer visibility; hidden layers are excluded from the composite
- [ ] Alpha channel is preserved if the canvas background is transparent
- [ ] Export completes asynchronously; a progress HUD appears for canvases over 2048×2048
- [ ] No simulation state is modified by the export operation

## Notes
The Metal texture must be read back to CPU memory via `MTLBlitCommandEncoder` before encoding to PNG; this is a known performance boundary for large canvases. Export should not trigger an auto-save.
