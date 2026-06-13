# Persona Heatmap

| Field | Value |
|-------|-------|
| **ID** | `persona-heatmap` |
| **Type** | Dashboard |
| **Category** | Persona Management |
| **User Stories** | US-117 |

## Description

Heatmap visualization where rows are personas, columns are script nodes, and cells show pass/warn/fail rates. Identifies which persona x node combinations are weakest.

## Key Components

- **Heatmap grid** — Persona rows x node columns, color-coded cells (green/amber/red)
- **Cell tooltip** — Pass, warn, fail counts on hover
- **Time range selector** — Filter to specific date range
- **Drill-through** — Click cell to see all run_steps at that (persona x node)

## Interactions

- Hover cells for detail counts
- Click cells to drill into underlying data
- Select time range

## Navigation

- Accessible from: Script Detail (Coverage tab)
- Links to: Run List (filtered to persona + script)
