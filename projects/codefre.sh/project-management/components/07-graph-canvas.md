# Graph Canvas

| Field | Value |
|-------|-------|
| **ID** | `graph-canvas` |
| **Category** | Domain-Specific |
| **Used In** | 02-Graph Editor, 03-Script Version Diff |

## Description

Visual directed acyclic graph (DAG) rendering canvas for building conversation test scripts. Displays nodes as interactive blocks and edges as directed arrows. Supports drag-to-create, auto-layout, zoom/pan, bulk selection, and color-coded overlays for diff views.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Full Page** | Primary editing canvas taking most of the screen (Graph Editor) |
| **Compact** | Read-only minimap or diff overlay view (Script Version Diff) |

## Props / Configuration

- `nodes` — Array of node objects (id, type, position, label, metadata)
- `edges` — Array of edge objects (source, target, label, match_method)
- `editable` — Whether nodes/edges can be added, moved, or deleted
- `selectedNodes` — Currently selected node IDs
- `onNodeSelect` — Callback when a node is clicked
- `onEdgeSelect` — Callback when an edge is clicked
- `diffOverlay` — Optional color coding for added (green), removed (red), modified (amber) elements
- `autoLayout` — Trigger automatic topology arrangement

## Interactions

- Pan and zoom the canvas
- Drag nodes to reposition
- Click node to select and open detail pane
- Drag between nodes to create edges
- Multi-select with shift-click or lasso
- Auto-layout button rearranges topology
- In diff mode: read-only with color-coded additions/removals
