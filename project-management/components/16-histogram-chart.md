# Histogram Chart

| Field | Value |
|-------|-------|
| **ID** | `histogram-chart` |
| **Category** | Data Display |
| **Used In** | 36-Freeball Confidence Histogram, 29-Custom Dashboard Builder |

## Description

Bar chart showing distribution of values across bucketed ranges. Primary use is freeball confidence distribution (10 buckets from 0.0-1.0). Supports split by category (runner model) and drill-through on bucket click.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Widget-sized for dashboard grid |
| **Expanded** | Primary visualization with scope toggle and model split |

## Props / Configuration

- `buckets` — Array of { range, count } or multi-series { range, counts: { [series]: count } }
- `splitBy` — Category for series split (e.g., runner model)
- `scope` — run-level | org-wide toggle
- `onBucketClick` — Drill-through callback

## Interactions

- Toggle between run-level and org-wide scope
- Click histogram bucket to drill into underlying nodes
- Compare distribution across series (runner models)
