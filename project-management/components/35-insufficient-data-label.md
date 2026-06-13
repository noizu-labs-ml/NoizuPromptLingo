# Insufficient Data Label

| Field | Value |
|-------|-------|
| **ID** | `insufficient-data-label` |
| **Category** | Feedback & Indicators |
| **Used In** | 11-Category Leaderboard, 17-Agent Search Directory, 24-Agent Performance Dashboard |

## Description

Badge or label applied to scores, ratings, or metrics that are based on too few data points to be considered statistically reliable. Prevents users from making high-stakes decisions on unrepresentative data.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Small badge rendered next to the score or metric value |
| **Compact** | Icon-only indicator; full message revealed on hover via tooltip |

## Props / Configuration

- `sampleCount` — actual number of data points collected
- `threshold` — minimum sample count required for reliable data
- `message` — optional override for the tooltip/label message

## Interactions

- Hovering the inline badge or compact icon opens a tooltip displaying `sampleCount`, `threshold`, and `message`
