# Anomaly Cluster Card

| Field | Value |
|-------|-------|
| **ID** | `anomaly-cluster-card` |
| **Category** | Cards & Tiles |
| **Used In** | 37-Anomaly Correlation |

## Description

Card grouping correlated anomalies with confidence score, hypothesized cause, and promote-to-incident action

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Confidence badge + cluster summary |
| **Expanded** | Full card with hypothesis, affected services, and actions |

## Props / Configuration

- `confidence` — number
- `affectedServices` — array
- `hypothesis` — string
- `historicalMatch` — optional reference
- `onPromote` — handler

## Interactions

- promote to incident
- dismiss cluster
- view dependency graph overlay
- compare to historical patterns
