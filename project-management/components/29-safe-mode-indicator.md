# Safe Mode Indicator

| Field | Value |
|-------|-------|
| **ID** | `safe-mode-indicator` |
| **Category** | Feedback & Indicators |
| **Used In** | 10-Education Portal, 09-Settings |

## Description

Persistent visual indicator that Safe Mode or Family Mode is active. Shown in student HUD and settings. Tied to content filtering and chat suppression.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Small badge in HUD showing active mode |
| **Compact** | Settings toggle with PIN protection controls |

## Props / Configuration

- `enabled` — Whether safe/family mode is currently active
- `pinProtected` — Require PIN entry to toggle the mode
- `mode` — Active mode type (safe | family)

## Interactions

- Toggle safe/family mode on or off (with PIN verification if `pinProtected` is true)
- View persistent indicator when mode is active
