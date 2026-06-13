# Widget Palette

| Field | Value |
|-------|-------|
| **ID** | `widget-palette` |
| **Category** | Input & Forms |
| **Used In** | 29-Custom Dashboard Builder |

## Description

Drag source palette offering dashboard widget types (trend chart, heatmap, cohort table, run list, metric card). Each widget can be dragged onto the dashboard grid and configured with entity-specific filters.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Sidebar list of available widget types with icons and labels |

## Props / Configuration

- `widgetTypes` — Available widget types with icon, label, description, default size
- `onDragStart` — Callback when a widget type starts being dragged

## Interactions

- Drag widget type from palette onto dashboard grid
- Hover for description of each widget type
- Widget appears on grid at default size, ready for configuration
