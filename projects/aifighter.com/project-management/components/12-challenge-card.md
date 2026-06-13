# Challenge Card

| Field | Value |
|-------|-------|
| **ID** | `challenge-card` |
| **Category** | Cards & Tiles |
| **Used In** | 11-Daily Challenge |

## Description

Card displaying a daily challenge with description, 24-hour expiry countdown, progress tracker, streak bonus indicators, and reward display.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Card with progress bar, expiry countdown, and reward amount |
| **Expanded** | Full card with streak history, bonus breakdown, and detailed progress |

## Props / Configuration

- `challenge` — Challenge definition (description, type, target metric)
- `expiresAt` — Countdown target timestamp for 24-hour expiry
- `progress` — Completion fraction (0.0–1.0)
- `streakDays` — Current consecutive completion streak count
- `reward` — Currency amount awarded on completion

## Interactions

- View challenge description and completion requirements
- Track progress toward completion threshold
- Collect reward on challenge completion
- View streak history and bonus multiplier in expanded state
