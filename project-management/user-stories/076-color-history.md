# US-076: Color History (Recently Used Colors)

**As a** hobbyist painter,
**I want to** see my recently used colors in a scrollable history strip,
**So that** I can quickly return to a color I used earlier without re-mixing or re-picking.

## Personas
- **Primary:** P5 Suki Tanaka — works with a small recurring set of colors; history lets her cycle back without the palette panel complexity
- **Also relevant:** P7 Priya Sharma, P1 Maya Chen

## Acceptance Criteria
- [ ] A horizontal history strip near the color picker shows the last 20 used colors as small swatches, most recent on the left
- [ ] Clicking a history swatch sets it as the active color
- [ ] A new color is pushed to history when a stroke is committed, not on every picker interaction
- [ ] Duplicate consecutive colors are collapsed (no repetition of the same color back-to-back)
- [ ] History persists across sessions in app preferences (not per-project)
- [ ] History can be cleared via a right-click context menu option

## Notes
Color history stores raw pigment color_rgbo values. The 20-item limit keeps the strip compact enough to remain visible without scrolling on standard panel widths. History is a global preference, not project-scoped, since color muscle memory is user-level.
