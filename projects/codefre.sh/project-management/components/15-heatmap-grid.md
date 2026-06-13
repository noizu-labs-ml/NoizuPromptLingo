# Heatmap Grid

| Field | Value |
|-------|-------|
| **ID** | `heatmap-grid` |
| **Category** | Data Display |
| **Used In** | 28-Persona Heatmap, 29-Custom Dashboard Builder |

## Description

Two-dimensional color-coded grid where rows represent one dimension (personas) and columns another (script nodes). Cell color indicates pass/warn/fail rate. Used to identify weak spots in persona x node coverage.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Widget-sized version for custom dashboards |
| **Full Page** | Primary view in Persona Heatmap screen |

## Props / Configuration

- `rows` — Row labels (e.g., persona names)
- `columns` — Column labels (e.g., node names)
- `cells` — Matrix of { passCount, warnCount, failCount } per cell
- `colorScale` — Green (high pass) to red (high fail)
- `timeRange` — Date range filter
- `onCellClick` — Callback for drill-through to underlying data

## Interactions

- Hover cells for tooltip showing pass/warn/fail counts
- Click cell to drill through to filtered run list
- Select time range to scope data
