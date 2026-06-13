# Conflict Warning

| Field | Value |
|-------|-------|
| **ID** | `conflict-warning` |
| **Category** | Feedback & Indicators |
| **Used In** | 01-Today Dashboard, 03-Time Blocking, 13-Kanban Board, 16-Gantt View, 20-Cross-Project Dependencies, 24-Bug SLA Dashboard, 56-Agent Task Queue |

## Description

Visual alert for scheduling conflicts, WIP violations, dependency blocks, or SLA breaches

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Red icon or border highlight |
| **Compact** | Warning banner with message |
| **Expanded** | Warning card with detail and resolution actions |

## Props / Configuration

- `type` — conflict|wip|dependency|sla
- `message` — string
- `severity` — warning|error
- `resolution` — optional action

## Interactions

- click for detail
- dismiss if resolved
- navigate to conflicting item
