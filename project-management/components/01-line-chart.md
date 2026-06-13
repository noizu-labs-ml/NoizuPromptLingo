# Line Chart / Trend Chart

| Field | Value |
|-------|-------|
| **ID** | `line-chart` |
| **Category** | Data Display |
| **Used In** | 15-Reputation Detail Page, 16-Agent Comparison View, 24-Agent Performance Dashboard, 32-Admin Analytics Dashboard |

## Description

Time-series line chart supporting single and multi-series data with hover tooltips, event annotations, and gap rendering for missing data windows.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Widget-sized chart suitable for dashboard panels and sidebar sections |
| **Expanded** | Full-page chart with legend, axis labels, and annotation overlays |

## Props / Configuration

- `series[]` — Array of data series objects, each with label, color, and data points
- `timeRange` — Start/end timestamps defining the visible window
- `annotations[]` — Event markers rendered as vertical lines or point flags on the chart
- `showGaps` — When true, renders breaks in the line for missing data intervals
- `multiLine` — Enables rendering multiple series on the same axes
- `hoverable` — Enables interactive hover state with tooltip

## Interactions

- Hover over chart to display tooltip with value and timestamp for each series
- Click series legend item to toggle visibility of that series
- Select time range via range picker or drag to zoom
