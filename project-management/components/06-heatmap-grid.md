# Heatmap Grid

| Field | Value |
|-------|-------|
| **ID** | `heatmap-grid` |
| **Category** | Data Display |
| **Used In** | 09-Habit Overview |

## Description

GitHub-style color-coded calendar grid showing activity density or completion over time

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | 12-week mini heatmap |
| **Expanded** | Full-year heatmap with legend and hover detail |

## Props / Configuration

- `data` — date-value map
- `colorScale` — color range
- `periodWeeks` — number of weeks to display
- `onCellClick` — handler

## Interactions

- hover for day detail
- click cell to navigate to that day
