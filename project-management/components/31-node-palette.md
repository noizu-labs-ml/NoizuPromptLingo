# Node Palette

| Field | Value |
|-------|-------|
| **ID** | `node-palette` |
| **Category** | Domain-Specific |
| **Used In** | 02-Graph Editor |

## Description

Toolbar/palette showing available node types that can be dragged onto the graph canvas. Node types include user_turn, system, terminal, and freeball_anchor, each with distinct visual representation and icon.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Horizontal toolbar above or beside the canvas |

## Props / Configuration

- `nodeTypes` — Available types with icon, label, color, description
- `onDragStart` — Callback when a node type is dragged from palette

## Interactions

- Drag a node type from palette onto the canvas to create a new node
- Hover for tooltip describing the node type
- Visual distinction per type (color/icon)
