# US-017: Split View Comparing Two Zoom Levels

**As a** art educator,
**I want to** display the same canvas at two different zoom levels side by side,
**So that** students can simultaneously see a detail view and the full composition as we work, understanding how local marks relate to the whole.

## Personas
- **Primary:** James Whitfield — simultaneous detail and overview is a core pedagogical tool; splitting the screen eliminates the need to context-switch zoom levels during a lesson
- **Also relevant:** Maya Chen, Lena Vasquez

## Acceptance Criteria
- [ ] View > Split View (Cmd+Shift+2) divides the canvas area into two panes with an adjustable divider
- [ ] Each pane has an independent zoom level, pan position, and rotation
- [ ] Both panes render from the same canvas data (no duplication); edits in either pane are reflected in both within one frame
- [ ] The divider can be dragged horizontally to adjust the relative width of the two panes
- [ ] Each pane displays its zoom percentage in a small badge in its corner
- [ ] A cursor indicator in the "overview" pane shows a rectangle representing the viewport of the "detail" pane
- [ ] Split view can be dismissed via View > Single View (Cmd+Shift+1) which returns to the last single-pane zoom level

## Notes
Split view requires two separate viewport transforms and two MTKView drawables, or a single drawable with two scissor/viewport regions. A shared drawable with scissor regions is preferred to avoid doubling GPU memory for the framebuffer. Both views share the same Metal texture for the paint volume; only the final composite blit differs.
