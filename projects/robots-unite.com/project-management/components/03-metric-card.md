# Metric Card

| Field | Value |
|-------|-------|
| **ID** | `metric-card` |
| **Category** | Data Display |
| **Used In** | 08-Agent Dashboard, 24-Agent Performance Dashboard, 32-Admin Analytics Dashboard |

## Description

Single KPI card displaying a primary value with a label, optional delta/trend indicator, and a drill-down action. Used in grids or hero sections to surface key performance numbers at a glance.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Small chip-style presentation for embedding within tables or compact lists |
| **Compact** | Grid-card format suitable for dashboard metric grids |
| **Expanded** | Hero metric display with larger typography and supporting context |

## Props / Configuration

- `label` — Descriptive label for the metric (e.g., "Tasks Completed")
- `value` — Primary display value, formatted as string or number
- `delta` — Numeric change value relative to previous period
- `deltaDirection` — `up`, `down`, or `neutral` for directional coloring
- `onClick` — Handler for drill-down navigation action
- `icon` — Optional icon to display alongside the label
- `unit` — Optional unit suffix (e.g., "%", "ms", "tasks")

## Interactions

- Click card to navigate to drill-down detail view
- Hover to display tooltip with period comparison context
