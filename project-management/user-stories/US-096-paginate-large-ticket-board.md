---
id: US-096
title: "Paginate Large Ticket Boards Without a Full Reload"
slug: "paginate-large-ticket-board"
personas: [P-003]
epic: "Performance & Scale"
priority: "must-have"
complexity: "M"
tags: [performance, pagination, ticket-board, scale]
---

# US-096: Paginate Large Ticket Boards Without a Full Reload

## User Story

**As** Priya Anand, the Delivery Lead (P-003),
**I want to** have the ticket board load and page through tickets incrementally rather than fetching the entire backlog at once,
**So that** the board stays responsive regardless of how large the project grows.

## Acceptance Criteria

- [ ] Given a project has more tickets than the initial page size, when Priya opens the board, then only the first page of tickets per column loads initially, with a visible "load more" or fetch-on-scroll affordance per column.
- [ ] Given Priya scrolls or requests the next page within a column, when it loads, then it appends without re-fetching or re-rendering already-loaded tickets and without resetting scroll position.
- [ ] Given a ticket is created, moved, or deleted while a paginated board is open, when the change is reflected, then column counts update correctly even though not all tickets are loaded client-side.
- [ ] Given a board with 10,000-plus tickets in a single column, when Priya opens it, then initial time-to-interactive stays within an agreed performance budget instead of degrading linearly with total ticket count.

## Notes

Must-have — the baseline scale story the epic is named for; US-097 is the analogous problem for chat. Pairs with US-089's dangling-link rendering since paginated cards must still handle broken links without extra round-trips.
