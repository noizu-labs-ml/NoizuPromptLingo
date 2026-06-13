# Knowledge Graph Canvas

| Field | Value |
|-------|-------|
| **ID** | `knowledge-graph-canvas` |
| **Category** | Forms |
| **Used In** | S06 Knowledge Graph View |

## Description

Interactive force-directed node-edge graph visualization for the universe's canon entry relationship network. Nodes represent entries (colored and shaped by entry type), edges represent declared relationships. Supports zoom, pan, hover highlights, click-to-inspect popovers, and multi-select for bulk operations.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Full Page** | Fills the main content area; canvas takes full available space with a floating toolbar |

## Props / Configuration

- `nodes` — Array of `{ id, label, type, status, x?, y? }` node definitions
- `edges` — Array of `{ id, source, target, relationshipType, label? }` edge definitions
- `selectedNodeIds` — Array of currently selected node IDs
- `onNodeSelect` — Callback fired with node ID (or array for multi-select) on click
- `onEdgeSelect` — Callback fired with edge ID on click
- `onNodeDoubleClick` — Callback fired on double-click; typically navigates to entry detail
- `onCanvasClick` — Callback fired on empty canvas click; clears selection
- `colorByType` — Boolean; applies type-based color coding to nodes (default: `true`)
- `showEdgeLabels` — Boolean; renders relationship type labels on edges (default: `false` at zoom < 1)
- `layout` — Initial layout algorithm: `force` | `hierarchical` | `radial` (default: `force`)
- `onLayoutChange` — Callback when user switches layout from the toolbar

## Interactions

- Scroll wheel or pinch zooms the canvas; click-drag on empty space pans
- Clicking a node selects it and opens an inline popover showing entry name, type, status, and a "View Entry" link
- Hovering a node highlights its direct neighbors and dims all unconnected nodes and edges
- Shift-clicking nodes adds them to a multi-selection; a bulk-action toolbar appears when multiple nodes are selected
- Double-clicking a node navigates to its Canon Entry Detail
- Minimap overlay in the bottom-right corner shows the full graph with a viewport indicator rectangle; click-drag on the minimap pans the main canvas
- Toolbar provides zoom-in, zoom-out, fit-to-view, layout switcher, and a show/hide edge label toggle
- Nodes can be manually repositioned by dragging; new position is persisted to user preferences
