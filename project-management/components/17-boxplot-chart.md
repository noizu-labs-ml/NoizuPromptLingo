# Boxplot Chart

| Field | Value |
|-------|-------|
| **ID** | `boxplot-chart` |
| **Category** | Data Display |
| **Used In** | 27-Cohort Dashboard, 29-Custom Dashboard Builder |

## Description

Statistical boxplot showing score distribution per agent or per persona within a cohort. Displays median, quartiles, and outliers for comparing score spread across entities.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Widget-sized for dashboard grid |
| **Expanded** | Full visualization in Cohort Dashboard |

## Props / Configuration

- `groups` — Array of { label, min, q1, median, q3, max, outliers }
- `groupBy` — agent | persona
- `yAxisLabel` — Score label

## Interactions

- Hover for exact values (median, Q1, Q3)
- Click group to drill into runs for that entity
