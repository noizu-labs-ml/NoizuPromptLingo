# Queue Status Panel

| Field | Value |
|-------|-------|
| **ID** | `queue-status-panel` |
| **Category** | Feedback & Indicators |
| **Used In** | 06-Ranked Arena |

## Description

Real-time queue status showing estimated wait time (10-second refresh), tier-segmented queue depth visualization, and search window widening notifications.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Wait time badge only |
| **Expanded** | Full panel with per-tier queue depth bars and search window status |

## Props / Configuration

- `estimatedWait` — Estimated wait time in seconds
- `queueDepth` — Per-tier player counts for depth visualization
- `searchWindowWidened` — Boolean flag indicating matchmaking range has expanded
- `maxConcurrent` — Maximum number of simultaneous queue slots allowed

## Interactions

- View current estimated wait time (auto-refreshes every 10 seconds)
- Cancel active queue entry
- Monitor search window widening notification when matchmaking expands range
