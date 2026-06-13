# Metric Card

| Field | Value |
|-------|-------|
| **ID** | `metric-card` |
| **Category** | Data Display |
| **Used In** | 04-Weekly Review, 11-Archive, 15-Portfolio Dashboard, 24-Bug SLA Dashboard, 32-Uptime Dashboard, 34-SLO Dashboard, 42-Docs Health Dashboard, 57-Agent Performance Dashboard, 70-Eval Dashboard |

## Description

Single KPI display with value, label, trend indicator, and optional sparkline

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Value + label inline |
| **Compact** | Card with value, label, and trend arrow |
| **Expanded** | Card with sparkline and comparison to prior period |

## Props / Configuration

- `value` — number|string
- `label` — string
- `trend` — up|down|flat
- `trendValue` — delta string
- `sparklineData` — optional array

## Interactions

- click for detail drill-down
- hover for exact values
