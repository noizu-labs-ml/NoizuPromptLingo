# US-073: Color Palette Panel (Save and Organize Colors)

**As a** concept artist,
**I want to** save colors to a reusable palette and organize them into named groups,
**So that** I can maintain consistent color language across a multi-session project.

## Personas
- **Primary:** P3 Lena Vasquez — production concept work requires strict color consistency; ad-hoc picking breaks cohesion
- **Also relevant:** P1 Maya Chen, P4 James Whitfield

## Acceptance Criteria
- [ ] A palette panel displays a grid of color swatches with an "Add current color" button
- [ ] Swatches can be organized into named groups (e.g., "Skin Tones", "Shadows") via drag or context menu
- [ ] Clicking a swatch sets it as the active color in the picker
- [ ] Swatches store raw pigment color_rgbo values, not absorbed values, for physics consistency
- [ ] Palettes are saved to and loaded from the project file; global palettes can also be saved to app preferences
- [ ] Right-clicking a swatch allows rename, delete, or move-to-group actions

## Notes
Palette data is lightweight CPU-side state. The panel should support import/export of palette files in a simple JSON or ASE-compatible format to allow sharing between artists.
