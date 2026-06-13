# Error Budget Gauge

| Field | Value |
|-------|-------|
| **ID** | `error-budget-gauge` |
| **Category** | Data Display |
| **Used In** | 34-SLO Dashboard |

## Description

Circular or linear gauge showing remaining error budget with threshold markers

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Mini gauge icon with percentage |
| **Compact** | Gauge with label and threshold markers |
| **Expanded** | Gauge with burn rate chart below |

## Props / Configuration

- `remaining` — percentage
- `thresholds` — alert levels array
- `burnRate` — trend value
- `sloTarget` — string

## Interactions

- hover for exact values
- click for SLO detail
