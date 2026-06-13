# Priority Sorted List

| Field | Value |
|-------|-------|
| **ID** | `priority-sorted-list` |
| **Category** | Data Display |
| **Used In** | 01-Today Dashboard, 02-Morning Planning, 03-Time Blocking, 05-Inbox, 08-Personal Lists, 14-Sprint Planning, 18-Backlog Grooming, 56-Agent Task Queue |

## Description

Ranked list of items sorted by urgency/importance with drag-drop reorder and context badges

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Single-line items with priority indicator and badge |
| **Expanded** | Items with metadata row (due date, project, assignee) |
| **Full_Page** | Full scrollable list with filters and bulk actions |

## Props / Configuration

- `items` — array of ranked items
- `onReorder` — drag-drop callback
- `groupBy` — optional grouping field
- `showBadges` — boolean
- `selectable` — multi-select mode

## Interactions

- drag-drop reorder
- click to expand/navigate
- multi-select for bulk actions
- keyboard arrow navigation
