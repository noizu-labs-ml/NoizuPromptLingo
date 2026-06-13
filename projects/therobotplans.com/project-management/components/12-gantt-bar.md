# Gantt Timeline Bar

| Field | Value |
|-------|-------|
| **ID** | `gantt-bar` |
| **Category** | Data Display |
| **Used In** | 16-Gantt View |

## Description

Horizontal duration bar on a timeline with drag-to-resize, milestone markers, and dependency connectors

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full Gantt chart with multiple bars and dependencies |
| **Full_Page** | Full-page timeline with zoom levels |

## Props / Configuration

- `items` — array with start/end dates
- `milestones` — marker array
- `dependencies` — connector array
- `zoom` — day|week|month
- `criticalPath` — highlighted items

## Interactions

- drag edges to adjust dates
- click milestone for detail
- zoom in/out
- hover for date tooltip
