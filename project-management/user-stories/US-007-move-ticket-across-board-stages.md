---
id: US-007
title: "Move a ticket across kanban board stages"
slug: "move-ticket-across-board-stages"
personas: [P-003]
epic: "Tickets & Boards"
priority: "must-have"
complexity: "S"
tags: [tickets, kanban, board, workflow]
---

# US-007: Move a ticket across kanban board stages

## User Story

**As a** Delivery Lead (P-003),
**I want to** move a ticket from one kanban stage to another,
**So that** the board reflects real delivery progress and the team can see what's actually in flight versus done.

## Acceptance Criteria

- [ ] Given a ticket in the "In Progress" stage of a board, when Priya moves it to "Done", then the ticket's stage field updates to "Done" and it renders in the "Done" column on the next board fetch.
- [ ] Given a board with a defined set of stages, when a ticket is moved to a stage that doesn't exist on that board, then the move is rejected with a validation error and the ticket remains in its prior stage.
- [ ] Given a ticket moved between stages, when the move completes, then a timestamped activity-log entry records the from-stage, to-stage, and actor.
- [ ] Given two clients attempting to move the same ticket to different stages concurrently, when both requests are processed, then the ticket ends in a single consistent stage matching whichever write was applied last, with no data corruption.

## Notes

Feeds the queue activity feed in US-013; stage transitions are the core interaction of the kanban view.
