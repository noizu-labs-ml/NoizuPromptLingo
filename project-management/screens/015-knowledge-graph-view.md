# Knowledge Graph View

| Field | Value |
|-------|-------|
| **ID** | knowledge-graph-view |
| **Type** | Primary |
| **Category** | Knowledge Graph |
| **User Stories** | US-026, US-027, US-028, US-029, US-030, US-031, US-032, US-033, US-035 |

## Description

Interactive node-edge visualization of all canon entries with zoom, pan, filtering, and interactions.

## Key Components

- **Graph Canvas** — Interactive node-edge rendering (US-026)
- **Node Display** — Color-coded by entry type with labels (US-026)
- **Legend** — Mapping of colors to entry types (US-026)
- **Zoom/Pan Controls** — Fit to screen, zoom in/out (US-027)
- **Filter Panel** — Entry type toggles, era/region/tag filters (US-028, US-029)
- **Clear Filters Button** — Reset all filters (US-029)
- **Layout Options** — Force-directed, hierarchical, radial (US-032)
- **Minimap Toggle** — Corner minimap for large graphs (US-035)
- **Hover Highlight** — Highlight node and connections on hover, dim others (US-033)
- **Node Popover** — On click: title, type, summary, direct relationships (US-030)
- **Edge Popover** — On click: relationship type, direction, notes (US-031)

## Interactions

- Mouse wheel zooms centered on cursor
- Click-drag pans canvas
- Hover highlights node and connections
- Click node opens popover with entry preview
- Click edge opens relationship detail
- Filter panel shows/hides nodes by criteria
- Layout options animate transitions (500-800ms)
- Minimap shows viewport position and allows click-to-pan
- Double-click background resets view to fit
- Empty state guides to create first entry

## Navigation

- Accessible from: Universe Overview, Canon Editor
- Links to: Canon Entry Detail (from node popover), Relationship Edit (from edge popover)