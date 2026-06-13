# US-077: Layer Thumbnail Preview in Panel

**As a** digital illustrator,
**I want to** see a live thumbnail of each layer's paint content in the layer panel,
**So that** I can identify layers visually rather than by name or index alone.

## Personas
- **Primary:** P1 Maya Chen — works with named washes across many layers; thumbnail lets her locate the "sky wash" layer at a glance
- **Also relevant:** P3 Lena Vasquez, P4 James Whitfield

## Acceptance Criteria
- [ ] Each layer panel row displays a thumbnail image of that layer's composited paint content
- [ ] Thumbnails are generated from the layer's own VolumeLayer data, not the full composited render, to show isolated content
- [ ] Thumbnail size is at minimum 48×48 px; panel row height is adjustable between compact and comfortable modes
- [ ] Thumbnails refresh after each stroke completion, not during active stroke, to avoid GPU contention
- [ ] Empty layers display a neutral checkerboard or blank texture thumbnail
- [ ] Thumbnail for the active layer has a highlight border matching the selection state color

## Notes
Thumbnail generation should be a low-resolution downsample render pass reading from the single layer's buffer slice. At 48×48, this is negligible GPU cost. Triggering the update at stroke-end (pen-up event) rather than continuously avoids thermal pressure during active painting.
