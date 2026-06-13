# Usage Meter

| Field | Value |
|-------|-------|
| **ID** | `usage-meter` |
| **Category** | Data Display |
| **Used In** | 29-Billing Settings |

## Description

Gauge/progress bar showing compute usage vs. plan allowance with per-project breakdown. Triggers warning states at 80% and overage states at 100%.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Thin progress bar with percentage |
| **Compact** | Gauge with percentage + breakdown toggle |
| **Expanded** | Full panel with per-project usage table |

## Props / Configuration

- `used` — Current usage amount
- `limit` — Plan allowance
- `breakdown` — Array of {projectName, usage}
- `overageRate` — Cost per overage unit
- `warningThreshold` — Percentage to show warning (default 80)

## Interactions

- Warning state (yellow) at threshold
- Overage state (red) when exceeded
- Click breakdown toggle → shows per-project table
- Overage rate displays cost implication
