# Ticket Card

| Field | Value |
|-------|-------|
| **ID** | `ticket-card` |
| **Category** | Cards & Tiles |
| **Used In** | 24-ticket-board |

## Description

The draggable summary card rendered inside each Board Column — status, assignee, and iteration badges on a compact ticket summary. Only named on the Ticket Board screen, but its interaction surface (drag-and-drop between columns, full keyboard-equivalent move, motion-reduced drop animation) is genuinely complex enough to warrant its own component rather than folding into a generic card.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Title + status/assignee/iteration badges |

## Props / Configuration

- `ticket` — id, title, status, assignee, iteration
- `draggable` — enables pointer drag between Board Columns
- `focusable` — enables keyboard move (focus + arrow/enter) as a drag equivalent

## Interactions

- User drags the card into another Board Column → ticket stage updates on drop
- Keyboard user focuses the card and uses arrow/enter shortcuts → same stage-move effect as a drag
- Move/drop animates unless `prefers-reduced-motion` is set, in which case the stage change applies instantly
