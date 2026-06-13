# Time Block Card

| Field | Value |
|-------|-------|
| **ID** | `time-block-card` |
| **Category** | Domain-Specific |
| **Used In** | 03-Time Blocking |

## Description

Visual block on a daily timeline representing a scheduled work item with resize handles

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Minimal block with title only |
| **Expanded** | Block with title, project badge, and duration |

## Props / Configuration

- `item` — work item reference
- `startTime` — time
- `duration` — minutes
- `resizable` — boolean
- `readonly` — boolean (for external events)

## Interactions

- drag to move in timeline
- resize edges for duration
- click to edit/remove
- distinguish from external calendar events
