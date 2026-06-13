# Daily Timeline Grid

| Field | Value |
|-------|-------|
| **ID** | `daily-timeline` |
| **Category** | Domain-Specific |
| **Used In** | 03-Time Blocking |

## Description

Vertical hourly grid for a single day with time blocks, external event overlays, and now-line indicator

## Size Variants

| Variant | Description |
|---------|-------------|
| **Full_Page** | Full-page vertical timeline |

## Props / Configuration

- `startHour` — number
- `endHour` — number
- `blocks` — array of time blocks
- `externalEvents` — array
- `nowLine` — boolean

## Interactions

- drag items from sidebar onto timeline
- drop to create time block
- scroll through hours
- now-line auto-scrolls
