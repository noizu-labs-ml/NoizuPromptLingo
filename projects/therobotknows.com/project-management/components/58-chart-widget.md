# Chart Widget

| Field | Value |
|-------|-------|
| **ID** | `chart-widget` |
| **Category** | Admin / Analytics |
| **Used In** | S-21 Admin Analytics, S-25 Admin Dashboard, S-26 Growth Charts |

## Description

Reusable chart container supporting line, bar, and sparkline rendering modes. Accepts structured time-series or categorical data with configurable labels, time range selectors, and an optional legend. Designed to be embedded in dashboard cards or analytics sections without additional wrapping.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Sparkline only — a narrow 80×24px trend line with no axes or labels; used inside metric cards |
| **Compact** | Chart with Y-axis and X-axis labels but no legend or time range controls; used in tight dashboard grid cells |
| **Expanded** | Full chart with legend, time range selector, hover tooltips, and optional export button |

## Props / Configuration

- `chartType` — `"line"` | `"bar"` | `"sparkline"`
- `data` — Array of data series: `{ label, color, values: [{ x, y }] }`
- `xAxisLabel` — Optional label for the X axis
- `yAxisLabel` — Optional label for the Y axis
- `timeRange` — Currently selected range: `"7d"` | `"30d"` | `"90d"` | `"1y"` | `"custom"`
- `customRange` — `{ from, to }` ISO date strings; used when `timeRange === "custom"`
- `showLegend` — Boolean; renders a color-keyed legend below the chart (default: true in expanded)
- `showTimeRangeSelector` — Boolean; renders range toggle buttons above the chart (default: true in expanded)
- `variant` — `"inline"` | `"compact"` | `"expanded"` (default: `"expanded"`)
- `onRangeChange` — Callback receiving new range selection
- `isLoading` — Boolean; renders a skeleton placeholder while data is fetching

## Interactions

- Hover over data points shows a tooltip with exact value, date/label, and series name
- Time range selector buttons update `timeRange` and trigger `onRangeChange`; data reloads with a subtle fade transition
- Bar chart bars are clickable — clicking a bar fires an `onBarClick` event with the data point for drill-down navigation
- Export button (expanded only) downloads the chart data as CSV or the chart image as PNG
- Empty state (no data for selected range) renders a centered "No data for this period" message with an illustration
- Loading skeleton matches the chart dimensions to prevent layout shift
