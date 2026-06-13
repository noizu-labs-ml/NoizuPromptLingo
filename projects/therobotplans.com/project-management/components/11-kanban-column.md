# Kanban Column

| Field | Value |
|-------|-------|
| **ID** | `kanban-column` |
| **Category** | Data Display |
| **Used In** | 13-Kanban Board, 14-Sprint Planning |

## Description

Vertical column of cards representing a workflow state with WIP limits and quick-add

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Collapsed column showing count only |
| **Expanded** | Full column with cards, WIP indicator, and quick-add |

## Props / Configuration

- `title` — state name
- `items` — card array
- `wipLimit` — number
- `onDrop` — drag handler
- `quickAdd` — boolean

## Interactions

- drag cards in/out
- quick-add at top
- WIP violation warning
- collapse/expand
