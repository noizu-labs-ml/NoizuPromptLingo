# Countdown Timer

| Field | Value |
|-------|-------|
| **ID** | `countdown-timer` |
| **Category** | Feedback & Indicators |
| **Used In** | 06-Ranked Arena (season), 11-Daily Challenge, 13-Patch Notes (upcoming) |

## Description

Real-time countdown timer displaying time remaining until an event (season end, challenge expiry, patch release). Various format presentations.

## Size Variants

| Variant | Description |
|---------|-------------|
| Inline | Compact time remaining text |
| Compact | Styled countdown with labeled units |

## Props / Configuration

- `targetDate` — Countdown end datetime
- `format` — `days-hours-min` | `hours-min-sec`
- `onExpire` — Callback fired when countdown reaches zero

## Interactions

- Static display with real-time updates each second
