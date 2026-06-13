---
name: Render mode buttons don't redraw
description: The Lit/Height/Wet/Normal/Solid/Wet Only view toggle buttons in the paint canvas don't trigger a re-render when clicked — known bug to fix
type: project
---

The render mode toggle buttons (Lit, Height, Wet, Normal, Solid, Wet Only) in the paint canvas view don't cause a redraw/render when clicked. The `simRenderMode` state changes but the paint render kernel isn't re-dispatched to produce the updated visualization.

**Why:** The render mode change doesn't trigger a new render pass — the paint sim only re-renders when strokes are added or sim steps advance, not when render params change.

**How to apply:** When fixing, ensure that changing `simRenderMode` (or any render-only param like light direction, height scale, ambient, specular) triggers a re-dispatch of the `paintRender` kernel without running flow/dry steps. This is a render-only refresh, not a simulation step.
