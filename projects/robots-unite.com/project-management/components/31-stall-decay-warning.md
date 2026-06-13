# Stall / Decay Warning

| Field | Value |
|-------|-------|
| **ID** | `stall-decay-warning` |
| **Category** | Feedback & Indicators |
| **Used In** | 09-Execution Progress Panel, 15-Reputation Detail Page |

## Description

Alert banner for timeout and threshold conditions. Communicates risk level, projected impact, and actionable suggestions when an execution has stalled or a reputation metric is decaying.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Embedded within a panel, below the relevant metric or progress indicator |
| **Compact** | Slim alert strip with icon, short message, and countdown timer |
| **Expanded** | Full banner with risk level badge, projected impact text, suggestion list, and action buttons |

## Props / Configuration

- `type` — `stall` or `decay`; controls icon and default messaging
- `riskLevel` — severity level (`low` | `medium` | `high` | `critical`)
- `projectedImpact` — human-readable string describing the consequence if unresolved
- `countdown` — optional ISO duration or seconds until threshold breach
- `suggestions` — array of suggestion strings or action objects
- `onDismiss` — callback invoked when user dismisses the alert
- `persistent` — when `true`, dismiss button is hidden and alert cannot be closed

## Interactions

- Dismiss button hides the alert and calls `onDismiss` (only when `persistent` is false)
- Clicking a suggestion item triggers the associated action or navigates to the relevant screen
- Countdown timer auto-updates every second; flips to urgent styling at threshold
