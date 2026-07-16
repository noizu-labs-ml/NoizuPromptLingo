# Ticket Board

| Field | Value |
|-------|-------|
| **ID** | `ticket-board` |
| **Type** | Primary |
| **Category** | Core Work |
| **User Stories** | US-007, US-008, US-091, US-095, US-096 |

## Description

Kanban board at `/app/[orgId]/boards/[boardId]` for moving tickets across stages and assigning sprints/iterations. Fully keyboard-navigable, paginates large boards without a full reload, and respects reduced-motion preferences for card animations.

## Key Components

- **Board Column** — a kanban stage holding ticket cards (US-007)
- **Ticket Card** — draggable summary card with status/assignee/iteration badges (US-007, US-008)
- **Iteration Selector** — assigns a sprint/iteration to a ticket (US-008)
- **Keyboard Navigation Focus Ring** — visible focus state enabling full keyboard board control (US-091)
- **Column Pagination Control** — loads additional cards per column without a full reload (US-096)

## Interactions

- User drags a Ticket Card between Board Columns → ticket stage updates; keyboard users move focus and use arrow/enter shortcuts for the same action (US-007, US-091)
- User assigns an iteration via the Iteration Selector on a card → badge updates (US-008)
- User scrolls a long column → Column Pagination Control fetches the next page in place (US-096)
- Card move/drop animations respect prefers-reduced-motion, substituting an instant state change (US-095)

## Navigation

- Accessible from: Tickets List (25), Org Dashboard (17)
- Links to: Ticket Detail (26)
