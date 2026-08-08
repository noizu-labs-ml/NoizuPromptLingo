# Board Column

| Field | Value |
|-------|-------|
| **ID** | `board-column` |
| **Category** | Domain-Specific |
| **Used In** | 24-ticket-board |

## Description

A single kanban stage on the Ticket Board, holding its Ticket Cards and paginating them independently as the column grows. Only named on one screen, but the combination of drag-and-drop drop-target behavior, keyboard-equivalent card movement, and in-place per-column pagination makes it a genuinely complex, standalone interactive component rather than a plain container.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full column with header, card stack, and load-more control |

## Props / Configuration

- `stage` — the kanban stage this column represents
- `cards` — Ticket Cards currently in this stage
- `paginated` — loads additional cards in place rather than requiring a full board reload
- `isDropTarget` — highlights the column while a card drag is in progress over it

## Interactions

- User drops a dragged Ticket Card into the column → the ticket's stage updates to match
- Keyboard users move focus into the column and confirm → same stage-move effect as a drop
- User scrolls near the bottom of a long column → the next page of cards loads in place without reloading the board
