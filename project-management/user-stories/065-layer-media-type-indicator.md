# US-065: Layer Media Type Indicator

**As a** concept artist,
**I want to** see a media-type icon on each layer row,
**So that** I can instantly distinguish watercolor, oil, and acrylic layers in a mixed-media composition.

## Personas
- **Primary:** P3 Lena Vasquez — mixes media types across layers for hybrid concept sketches; needs to identify media quickly
- **Also relevant:** P4 James Whitfield, P1 Maya Chen

## Acceptance Criteria
- [ ] Each layer row displays a small icon (or colored tag) indicating the dominant substance_type value of the layer
- [ ] Supported indicators: Watercolor, Oil, Acrylic, Gouache, Ink, and Mixed (when multiple substance types coexist)
- [ ] Indicator is derived from the most prevalent substance_type value sampled across non-empty pixels in the layer
- [ ] User can manually override the displayed media type label via a layer settings popover
- [ ] Media type is shown as both icon and abbreviated text to remain legible at small panel row heights

## Notes
substance_type is stored per-pixel in the VolumeLayer flags/substance_type field. Dominant type computation can share the same aggregate compute pass used for wetness/depth badges (US-064) to avoid redundant passes.
