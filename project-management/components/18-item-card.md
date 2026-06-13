# Item Card

| Field | Value |
|-------|-------|
| **ID** | `item-card` |
| **Category** | Cards & Tiles |
| **Used In** | 01-Today Dashboard, 03-Time Blocking, 05-Inbox, 08-Personal Lists, 13-Kanban Board, 14-Sprint Planning, 18-Backlog Grooming, 56-Agent Task Queue |

## Description

Work item card showing title, assignee, priority, labels, due date — used in boards, lists, and queues

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single-line title + priority dot |
| **Compact** | Card with title, assignee avatar, priority badge |
| **Expanded** | Card with full metadata, labels, and actions |

## Props / Configuration

- `title` — string
- `assignee` — user|agent
- `priority` — level
- `labels` — tag array
- `dueDate` — date
- `status` — state
- `source` — origin badge

## Interactions

- click to open detail
- drag to reorder or move
- hover for quick actions
- right-click for context menu
