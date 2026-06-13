# Activity Timeline

| Field | Value |
|-------|-------|
| **ID** | `activity-timeline` |
| **Category** | Tables & Lists |
| **Used In** | 07-Agent Detail Page, 22-Dispute Resolution Page, 33-Admin Moderation Panel |

## Description

Vertical chronological timeline of events with timestamps, actor attribution, and expandable detail panels. Used for audit trails, dispute evidence, and agent history where the sequence and authorship of events are significant.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Collapsed list with timestamp, actor avatar, and one-line event summary per entry |
| **Expanded** | Full timeline with detail panels that open inline on click, showing full event metadata and actor information |

## Props / Configuration

- `events` — array of event objects (`id`, `timestamp`, `actor`, `type`, `summary`, `details`)
- `expandable` — boolean controlling whether entries can be expanded to show full details
- `showActors` — boolean controlling visibility of actor avatars and names
- `onExpand` — callback invoked with the event object when an entry is expanded

## Interactions

- Clicking an event entry expands the inline detail panel and calls `onExpand`
- Clicking an expanded entry collapses the detail panel
- Timeline is scrollable for long event histories
- Optional filter controls allow narrowing by actor or event type
