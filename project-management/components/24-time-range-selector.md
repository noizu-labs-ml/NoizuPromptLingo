# Time Range Selector

| Field | Value |
|-------|-------|
| **ID** | `time-range-selector` |
| **Category** | Input & Forms |
| **Used In** | 08-Run List, 26-Trend Dashboard, 27-Cohort Dashboard, 28-Persona Heatmap, 29-Custom Dashboard Builder |

## Description

Control for selecting time ranges with quick presets (Today, 7d, 30d, 90d, All) and a custom date range picker. Used to scope dashboard data and filter lists by date.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Button group with preset options + custom range trigger |

## Props / Configuration

- `presets` — Available quick-select options (7d, 30d, 90d, all)
- `value` — Current range { start, end }
- `onChange` — Callback with new range
- `showCustom` — Whether to show custom date picker

## Interactions

- Click preset button to apply
- Click "Custom" to open date picker for arbitrary range
- Selected preset highlighted
