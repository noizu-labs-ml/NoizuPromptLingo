# Activity Timeline

| Field | Value |
|-------|-------|
| **ID** | `activity-timeline` |
| **Category** | Data Display |
| **Used In** | 01-Today Dashboard, 23-Bug Detail, 33-Incident Detail, 38-Post-Incident Review, 49-OKR Check-In, 55-Agent Audit Log, 61-Prompt Version Timeline, 67-Prompt Audit Trail |

## Description

Chronological feed of events/actions with expandable entries, timestamps, and actor attribution

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Compact single-line entries in a sidebar |
| **Compact** | Card-style entries with actor + action + timestamp |
| **Expanded** | Full timeline with expandable detail per entry |
| **Full_Page** | Audit log view with filters and export |

## Props / Configuration

- `entries` — array of timeline events
- `filters` — filter configuration
- `expandable` — boolean
- `showActorAvatar` — boolean
- `groupByDate` — boolean

## Interactions

- scroll through chronologically
- expand entries for detail
- filter by actor/type/date
- export filtered results
