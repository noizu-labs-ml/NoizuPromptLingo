# US-093: Status Bar Showing Canvas Info (Dimensions, Zoom Level, Memory)

**As a** professional illustrator monitoring her working environment,
**I want to** see at-a-glance canvas information in a status bar,
**So that** I can quickly verify resolution, zoom level, and memory usage without opening separate dialogs.

## Personas
- **Primary:** P1 Maya Chen — monitors canvas specs constantly to ensure deliverable correctness; memory info informs when to merge layers
- **Also relevant:** P6 Alex Kirchner, P3 Lena Vasquez

## Acceptance Criteria
- [ ] A thin status bar is visible at the bottom of the canvas window (toggleable via View menu)
- [ ] Status bar displays: canvas dimensions (W×H px), current zoom percentage, cursor position in canvas coordinates, active layer name, and GPU memory used by textures
- [ ] GPU memory figure updates every 2 seconds; other fields update in real time as the user interacts
- [ ] Clicking the zoom percentage field opens an inline popover to type an exact zoom value
- [ ] Cursor position switches between pixel coordinates and physical units (inches) based on Preferences
- [ ] Status bar height is fixed at 22pt and does not resize with window

## Notes
GPU memory estimation can use `MTLDevice.currentAllocatedSize` (available on macOS 13+); on older OS versions, display "N/A". The status bar must not overlap the MTKView canvas — account for it in layout constraints.
