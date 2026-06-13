# Usage Meter

| Field | Value |
|-------|-------|
| **ID** | `usage-meter` |
| **Category** | Feedback & Indicators |
| **Used In** | 23-Agent Configuration, 24-Agent Cost Controls |

## Description

Progress bar visualization showing current usage against configured limits. Color-coded warning thresholds (green → yellow → red).

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Thin progress bar with label |
| **Compact** — Progress bar + current/limit values |
| **Expanded** | Progress bar + values + warning message + threshold markers |

## Props / Configuration

- `current` — Current usage value
- `limit` — Maximum allowed value
- `warningThreshold` — Yellow threshold (default 80%)
- `criticalThreshold` — Red threshold (default 95%)
- `unit` — Unit label (requests, tokens, $)

## Interactions

- Visual progress indication; color changes at thresholds
