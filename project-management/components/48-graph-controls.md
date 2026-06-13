# Graph Controls

| Field | Value |
|-------|-------|
| **ID** | `graph-controls` |
| **Category** | Graph |
| **Used In** | S-18 Knowledge Graph View |

## Description

Floating toolbar anchored to the knowledge graph canvas providing layout switching, zoom controls, viewport utilities, and display filter toggles. Stays in a fixed corner of the canvas regardless of pan position.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Icon-only buttons with tooltips; used at narrow viewport widths |
| **Expanded** | Icons with text labels; used at standard desktop widths |

## Props / Configuration

- `layout` — Current layout mode: `"force"` | `"hierarchical"` | `"radial"`
- `zoomLevel` — Current zoom scalar (0.1–4.0); displayed as percentage
- `minimapVisible` — Boolean controlling minimap panel visibility
- `activeFilters` — Array of active filter tokens (entry types, relationship types)
- `onLayoutChange` — Callback receiving new layout mode string
- `onZoomIn` — Callback for zoom-in button press
- `onZoomOut` — Callback for zoom-out button press
- `onFitToScreen` — Callback to reset viewport to fit all nodes
- `onToggleMinimap` — Callback to show/hide minimap overlay
- `onFilterChange` — Callback receiving updated filter token array

## Interactions

- Layout switcher cycles between force-directed, hierarchical (top-down), and radial layouts; switching re-runs layout algorithm with a 300ms animated transition
- Zoom In / Zoom Out buttons step zoom by 25%; zoom level also updated by scroll wheel and trackpad pinch on the canvas
- Fit to Screen resets pan and zoom so all nodes are visible within the canvas bounds
- Minimap toggle shows/hides a picture-in-picture overview in the bottom-right corner of the canvas
- Filter toggles show a dropdown list of entry types and relationship types; deselected types hide their nodes/edges
- Active filter count badge appears on the filter button when any filter is active
- Keyboard shortcuts: `+`/`-` for zoom, `0` for fit-to-screen, `M` for minimap toggle
