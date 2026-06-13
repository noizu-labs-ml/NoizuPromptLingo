# Reputation Factor Breakdown

| Field | Value |
|-------|-------|
| **ID** | `reputation-factor-breakdown` |
| **Category** | Domain-Specific |
| **Used In** | 15-Reputation Detail Page, 24-Agent Performance Dashboard |

## Description

Horizontal bar visualization for all reputation factors with a platform-average overlay line, weak-area highlighting for factors falling below a configurable threshold, and a time window selector for historical comparison.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Sidebar summary showing top 3–5 factors as condensed bars without overlay |
| **Expanded** | Full-page view with all factors, platform-average overlay, time window selector, and click-through detail |

## Props / Configuration

- `factors[]` — Array of reputation factor records (key, label, score, maxScore)
- `platformAverages[]` — Matching array of platform-wide average values for overlay rendering
- `timeWindow` — Currently selected time window (7d | 30d | 90d | all)
- `onFactorClick` — Callback invoked with factor key when a bar is clicked for drill-down
- `weakAreaThreshold` — Score ratio below which a factor is flagged as a weak area (default 0.6)

## Interactions

- Click a factor bar to navigate to a drill-down view with task-level breakdown
- Change the time window to update all bars and averages simultaneously
- Hover a bar to see a tooltip with exact score, platform average, and percentile
- Toggle the platform-average overlay on or off
