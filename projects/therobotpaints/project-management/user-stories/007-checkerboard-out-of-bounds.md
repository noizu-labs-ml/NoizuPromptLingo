# US-007: Checkerboard Pattern for Out-of-Bounds Areas

**As a** concept artist working at various zoom levels,
**I want to** see a checkerboard pattern in the area surrounding the canvas,
**So that** I can clearly distinguish the canvas boundary from the application background and identify transparent regions when the canvas has an alpha channel.

## Personas
- **Primary:** Lena Vasquez — working across mixed-media layers with transparency requires immediate visual distinction between painted canvas area and the void beyond its edges
- **Also relevant:** Maya Chen, Alex Kirchner

## Acceptance Criteria
- [ ] Areas outside the canvas bounds display a neutral grey checkerboard pattern
- [ ] Checkerboard cell size scales with zoom level so cells remain visually consistent (target: 8–16 screen pixels per cell at any zoom)
- [ ] Checkerboard color pair is user-adjustable (defaults: #808080 and #999999)
- [ ] If the canvas supports an alpha channel, transparent canvas pixels also display the checkerboard beneath them
- [ ] The checkerboard is rendered in a Metal pass that executes before the canvas compositor, so paint layers composite over it correctly
- [ ] Checkerboard pattern can be replaced with a solid color via Preferences > Canvas Background (see US-019)

## Notes
The checkerboard should be generated procedurally in MSL using integer floor arithmetic on screen coordinates divided by the scaled cell size; no texture asset is needed. Cell size scaling should snap to whole numbers to avoid shimmer during pan.
