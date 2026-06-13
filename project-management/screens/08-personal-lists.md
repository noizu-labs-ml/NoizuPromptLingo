# Personal Lists

| Field | Value |
|-------|-------|
| **ID** | `personal-lists` |
| **Type** | Primary |
| **Category** | Personal Productivity |
| **User Stories** | US-011, US-016, US-020 |

## Description

Personal todo lists, grocery lists, and errands with due dates, tags, recurrence, and simple checklist mode. Supports multiple lists with a sidebar selector. Items can be archived when complete.

## Key Components

- **List selector sidebar** — Navigate between personal lists (Todos, Groceries, Errands, custom)
- **Item list** — Checkbox-style items with due date and tags
- **Checklist mode toggle** — Simplified view for shopping/errand lists
- **Due date picker** — Inline date selector per item
- **Recurrence config** — Set items to repeat (daily, weekly, custom)
- **Tag input** — Add context tags to items
- **Archive toggle** — Show/hide completed items
- **Context filter** — Filter by domain (personal, home, errands)

## Interactions

- Create new list via sidebar action
- Add items with Enter key, set metadata inline
- Check off items → move to archive (configurable delay)
- Drag to reorder within a list
- Recurrence creates next instance on completion

## Navigation

- Accessible from: Main nav (personal section)
- Links to: Archive, Smart Lists, Today Dashboard
