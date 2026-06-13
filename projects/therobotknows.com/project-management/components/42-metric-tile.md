# Metric Tile

| Field | Value |
|-------|-------|
| **ID** | `metric-tile` |
| **Category** | Data Display / Analytics |
| **Used In** | S24 Admin Dashboard, S03 Universe Dashboard, S20 Analytics |

## Description

KPI display card presenting a single key metric with a label, a large formatted number, an optional sparkline trend chart, and optional threshold-based highlight coloring. Tiles are arranged in a responsive grid on dashboard screens. Threshold highlighting draws attention to metrics that are outside acceptable ranges (e.g., error rate above 5%, budget usage above 80%).

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Label + number only; used in dense multi-tile rows |
| **Expanded** | Label + number + sparkline + delta badge + threshold highlight; standard dashboard tile |

## Props / Configuration

- `label` — Metric name; e.g. "Active Users", "Generations Today", "Consistency Errors"
- `value` — Number or string; the primary KPI value
- `format` — `number | currency | percent | duration`; controls display formatting
- `delta` — Number; change vs previous period; rendered as a +/- delta badge with up/down arrow
- `deltaLabel` — String; e.g. "vs last 7 days"; shown beside delta
- `sparklineData` — Array of numbers; time series data for the sparkline; omit to hide chart
- `sparklineColor` — String; line color; defaults to brand accent
- `warnThreshold` — Number; value at or above which tile highlights amber
- `dangerThreshold` — Number; value at or above which tile highlights red
- `thresholdMode` — `above | below`; whether threshold activates when value is above or below the number; defaults to `above`
- `onClick` — Optional callback; when provided the tile is clickable and navigates to detailed view

## Interactions

- When `onClick` is provided, the tile renders with hover/focus styles and a subtle arrow indicator
- Delta badge is green for positive, red for negative change (inverted for error-rate metrics via `thresholdMode`)
- Sparkline tooltip shows exact value at each data point on hover
- Threshold highlights use background tint + left border color, never obscure the number
