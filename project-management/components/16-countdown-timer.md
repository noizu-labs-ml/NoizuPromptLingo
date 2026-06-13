# Countdown Timer

| Field | Value |
|-------|-------|
| **ID** | `countdown-timer` |
| **Category** | Data Display |
| **Used In** | 15-Portfolio Dashboard, 24-Bug SLA Dashboard |

## Description

Live countdown to a deadline (SLA, milestone, sprint end) with urgency color coding

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Compact time remaining text with color |
| **Compact** | Timer badge with urgency indicator |

## Props / Configuration

- `deadline` — timestamp
- `urgencyThresholds` — color breakpoints
- `label` — string
- `onExpire` — callback

## Interactions

- color shifts as deadline approaches
- click to navigate to related item
