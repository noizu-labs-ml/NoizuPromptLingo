# Graph Canvas

| Field | Value |
|-------|-------|
| **ID** | `graph-canvas` |
| **Category** | Domain-Specific |
| **Used In** | 01-Fighter Studio, 04-Training Gym (weight heatmap), 07-Laboratory (comparison view), 26-Shared Fighter View |

## Description

Visual node graph editor canvas supporting drag-to-position nodes, edge connections between ports, snap-to-grid, multi-select, and alignment tools. Renders node state via non-color icons. Supports color themes and annotation labels.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Interactive editor with full toolbar, context menus, and editing capabilities |
| **Full Page** | Standalone view used in shared and comparison modes; read-only or minimal controls |

## Props / Configuration

- `nodes` — Node list with positions and metadata
- `edges` — Connection definitions between node ports
- `theme` — Color theme ID applied to canvas and node rendering
- `readOnly` — Disables editing interactions when true
- `showHeatmap` — Overlays training activation data on nodes
- `showAnnotations` — Toggles visibility of annotation labels
- `snapToGrid` — Enables grid alignment for node positioning

## Interactions

- Drag nodes to reposition on canvas
- Connect ports via drag from output to input
- Multi-select nodes for bulk alignment operations
- Zoom and pan canvas
- Right-click for context menu (duplicate, delete, annotate)
- Toggle snap-to-grid from toolbar
