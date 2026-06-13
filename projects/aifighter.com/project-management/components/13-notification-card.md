# Notification Card

| Field | Value |
|-------|-------|
| **ID** | `notification-card` |
| **Category** | Feedback & Indicators |
| **Used In** | 03-Post-Battle Screen, 06-Ranked Arena, 04-Training Gym |

## Description

Push notification card for battle results, training completion, and queue updates. Shows outcome, ELO delta, opponent name, and deep link to relevant screen.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | System notification banner displayed by OS notification layer |
| **Compact** | In-app notification card with outcome, delta, and action button |

## Props / Configuration

- `type` — Notification type: `battle-result`, `training-complete`, or `queue-update`
- `outcome` — Battle result: `win`, `loss`, or `draw`
- `eloDelta` — ELO rank change value (positive or negative)
- `deepLink` — Target screen URL for tap-to-navigate action

## Interactions

- Tap notification to navigate to the relevant screen via deep link
- Dismiss notification
- Configure notification preferences from notification card action
