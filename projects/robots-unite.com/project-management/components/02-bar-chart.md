# Bar Chart / Dimension Score Chart

| Field | Value |
|-------|-------|
| **ID** | `bar-chart` |
| **Category** | Data Display |
| **Used In** | 15-Reputation Detail Page, 24-Agent Performance Dashboard |

## Description

Horizontal or vertical bar chart for displaying dimension scores with optional overlay bars for comparison values and visual flags for weak areas falling below threshold.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Sidebar-width chart for dimension breakdowns within a detail panel |
| **Expanded** | Full-width chart with axis labels, grid lines, and legend |

## Props / Configuration

- `dimensions[]` — Array of dimension labels
- `values[]` — Primary bar values aligned to dimensions
- `overlayValues[]` — Secondary overlay bar values for comparison (e.g., cohort average)
- `orientation` — `horizontal` or `vertical` layout
- `showTooltips` — Enables hover tooltips with raw values and labels
- `flagWeakAreas` — When true, visually highlights bars below a defined threshold

## Interactions

- Hover bar to display tooltip with dimension name, value, and optional comparison
- Click bar to drill into dimension-level detail view
- Apply date range filter to recalculate displayed values
