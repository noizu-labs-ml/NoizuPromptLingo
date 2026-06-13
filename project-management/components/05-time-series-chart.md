# Time Series Chart

| Field | Value |
|-------|-------|
| **ID** | `time-series-chart` |
| **Category** | Data Display |
| **Used In** | 04-Weekly Review, 14-Sprint Planning, 17-Sprint Retrospective, 32-Uptime Dashboard, 34-SLO Dashboard, 57-Agent Performance Dashboard, 70-Eval Dashboard, 71-A/B Test Manager |

## Description

Line/area chart plotting metrics over time with configurable time range and overlay annotations

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Sparkline in a card header |
| **Expanded** | Full chart with legend, tooltips, and range selector |
| **Full_Page** | Dashboard-sized chart with annotations and comparisons |

## Props / Configuration

- `data` — time-series array
- `timeRange` — range selector config
- `overlays` — annotation markers
- `series` — multiple series config
- `yAxisLabel` — string

## Interactions

- hover for data point tooltip
- drag to select time range
- toggle series visibility
- click annotations to navigate
