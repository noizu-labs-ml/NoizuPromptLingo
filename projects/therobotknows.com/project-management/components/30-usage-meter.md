# Usage Meter

| Field | Value |
|-------|-------|
| **ID** | `usage-meter` |
| **Category** | Billing / Usage |
| **Used In** | S13 AI Settings, S11 Generation Studio Header, S22 Account Settings |

## Description

Visual budget gauge displaying current credit/token consumption against the plan limit for the current billing period. Renders a segmented progress bar with color transitions at defined warning thresholds (75% = amber, 100% = red). Supports both session-scoped and period-scoped views. Used in the generation studio header as a persistent budget awareness widget, and in settings for detailed plan consumption.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Single progress bar + percentage label; used in studio header toolbar |
| **Expanded** | Progress bar + used/limit figures + reset date + optional upgrade CTA |

## Props / Configuration

- `used` — Number; credits or tokens consumed in current period
- `limit` — Number; plan cap for the period
- `unit` — `credits | tokens`; determines label formatting
- `periodResetDate` — ISO date string; shown in expanded variant as "Resets on {date}"
- `warnAt` — Number 0–1; fraction at which bar turns amber; defaults to `0.75`
- `dangerAt` — Number 0–1; fraction at which bar turns red; defaults to `1.0`
- `showUpgradeCta` — Boolean; when true and usage exceeds `warnAt`, renders "Upgrade Plan" link
- `size` — `compact | expanded`

## Interactions

- Hovering the bar shows tooltip: exact used/limit figures and reset date
- "Upgrade Plan" CTA navigates to billing / plan selection
- Bar animates fill on mount; respects `prefers-reduced-motion`
- When limit is exceeded, bar overflows into a distinct red cap segment rather than clamping at 100%
