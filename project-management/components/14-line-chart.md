# Line Chart

| Field | Value |
|-------|-------|
| **ID** | `line-chart` |
| **Category** | Data Display |
| **Used In** | 26-Trend Dashboard, 29-Custom Dashboard Builder |

## Description

Time-series line chart with score on Y-axis and time on X-axis. Supports multiple series (one per agent), threshold bands (pass/warn/fail zones), hover tooltips with run details, and click-through to individual runs.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Widget-sized chart for custom dashboard grid |
| **Full Page** | Primary visualization in Trend Dashboard |

## Props / Configuration

- `series` — Array of { agentName, color, dataPoints: [{ timestamp, score, runId }] }
- `thresholdBands` — Visual zones for pass/warn/fail on Y-axis
- `timeRange` — 7d | 30d | 90d | all
- `onPointClick` — Callback to navigate to specific run
- `legend` — Color-coded agent labels

## Interactions

- Select time range via selector
- Hover data points for tooltip (run ID, verdict, score)
- Click data point to navigate to Run Detail
- Toggle series visibility via legend
