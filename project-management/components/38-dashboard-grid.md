# Dashboard Grid

| Field | Value |
|-------|-------|
| **ID** | `dashboard-grid` |
| **Category** | Navigation & Layout |
| **Used In** | 29-Custom Dashboard Builder |

## Description

Drag-and-drop grid layout for arranging dashboard widgets. Supports resize, reorder, and per-widget configuration. Widgets snap to grid positions and can be resized by dragging edges.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Full Page** | Primary canvas for custom dashboard composition |

## Props / Configuration

- `widgets` — Array of placed widgets with type, position, size, config
- `columns` — Number of grid columns
- `rowHeight` — Base row height in pixels
- `onLayoutChange` — Callback when widgets are rearranged or resized
- `editable` — Whether widgets can be moved/resized (edit mode vs view mode)

## Interactions

- Drag widgets to reposition on grid
- Resize widgets by dragging edges/corners
- Click widget gear icon to open per-widget config
- Remove widgets with delete action
- Save layout
