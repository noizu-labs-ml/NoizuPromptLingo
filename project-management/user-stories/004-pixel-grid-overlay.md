# US-004: Pixel Grid Overlay at High Zoom Levels

**As a** digital illustrator working at pixel level,
**I want to** see a grid overlay that delineates individual canvas pixels,
**So that** I can place precise marks and evaluate antialiasing at the single-pixel boundary.

## Personas
- **Primary:** Maya Chen — watercolor edge control requires seeing exactly which pixels a stroke will occupy before committing
- **Also relevant:** Alex Kirchner, James Whitfield

## Acceptance Criteria
- [ ] Pixel grid automatically appears when zoom level reaches or exceeds a configurable threshold (default: 800%)
- [ ] Grid automatically disappears when zoom drops below the threshold
- [ ] Grid lines are rendered as a 1-screen-pixel hairline in a neutral color (default: rgba(128,128,128,0.4))
- [ ] Grid color and opacity are user-adjustable in Preferences
- [ ] Grid can be toggled manually via View > Pixel Grid (Cmd+') regardless of zoom level
- [ ] Grid is rendered in a post-process Metal pass and does not affect paint volume data
- [ ] Grid aligns exactly to canvas pixel boundaries at all zoom levels without drift

## Notes
The grid is already scaffolded in the compositor; this story formalizes the auto-show threshold, the manual toggle, and the preference controls. Grid rendering must use integer pixel alignment to prevent sub-pixel shimmer during pan.
