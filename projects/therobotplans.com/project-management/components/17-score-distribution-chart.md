# Score Distribution Chart

| Field | Value |
|-------|-------|
| **ID** | `score-distribution-chart` |
| **Category** | Data Display |
| **Used In** | 51-OKR Scoring, 52-Goal Retrospective, 70-Eval Dashboard |

## Description

Histogram or distribution chart showing spread of scores across a population

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Mini histogram in a card |
| **Expanded** | Full histogram with percentile markers |

## Props / Configuration

- `data` — array of scores
- `bins` — number of bins
- `highlights` — percentile markers
- `label` — string

## Interactions

- hover bins for count
- click bin to filter to those items
