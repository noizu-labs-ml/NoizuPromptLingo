# US-036: Quick Tool Switching via Keyboard Shortcuts

**As a** painter who alternates between brush, eraser, and smudge tools constantly,
**I want to** switch tools instantly using single-key shortcuts,
**So that** I can maintain painting momentum without moving my hand to the toolbar or menu.

## Personas
- **Primary:** P7 Priya Sharma — fast gestural plein air sketching demands zero-friction tool switching
- **Also relevant:** P1 Maya Chen, P3 Lena Vasquez, P4 James Whitfield

## Acceptance Criteria
- [ ] Default shortcuts: `B` = brush, `E` = eraser, `K` = palette knife/smudge, `G` = fill, `S` = selection
- [ ] Holding a shortcut key temporarily activates the tool (spring-loaded); releasing it returns to the previous tool
- [ ] All shortcuts are rebindable in the Keyboard Shortcuts settings panel
- [ ] Switching tools does not reset brush size, opacity, or other parameters (state is preserved per tool)
- [ ] The active tool is visually indicated in the toolbar with a highlighted state
- [ ] Tool switch latency is < 1 frame (< 8ms at 120Hz) from keypress to active tool change
- [ ] Shortcuts work while the stylus is hovering over the canvas (focus must not require clicking the canvas first)

## Notes
Spring-loaded tool switching (hold to borrow, release to return) is a professional workflow feature used in Photoshop and Procreate. It must be implemented at the key event level, not via a toggle, to correctly detect hold vs. tap.
