# Review: Move a ticket across kanban board stages

- **Story**: `project-management/user-stories/US-007-move-ticket-across-board-stages.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Stage support exists end-to-end at the schema and HTTP layer: `Ticket` carries `belongs_to :stage, BoardStage` with a `foreign_key_constraint(:stage_id)` (`backend/lib/noizu_prompt_lingua/schema/ticket.ex:28,58`); boards seed methodology-specific default stages (kanban: To Do / In Progress / Done) via `Queues.create` (`backend/lib/noizu_prompt_lingua/domains/tickets/queues.ex:13-68`); `PATCH /api/v1/organizations/:org_id/tickets/:id` accepts `stage_id` (`backend/lib/noizu_prompt_lingua_web/controllers/ticket_controller.ex:96`) and `Ticket.List` filters by `stage_id` (`ticket_controller.ex:23`), so column grouping can be reconstructed client-side. The VFS MCP surface also accepts `stage_id`/`iteration_id` on ticket update (`backend/lib/noizu_prompt_lingua/mcp/vfs/tickets.ex:1347`). However, the core `Ticket.Update` MCP tool does **not** expose `stage_id` (`backend/lib/noizu_prompt_lingua/domains/tickets/tools/ticket_update.ex:45` — extraction list omits it), no validation checks that a stage belongs to the ticket's board (any valid stage UUID passes the FK), there is **no activity log** for stage transitions (the queue/ticket feed tools are stubs returning "Activity feed not yet implemented", `queue_feed.ex:18-23` / `ticket_feed.ex`), and there is no optimistic-locking/concurrency evidence on the write path in this repo (TRP items carry a `lock_version` field in `trp/shapes.ex:48`, but NPL never sends it).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Move ticket In Progress → Done; stage field updates and renders in Done column on next board fetch | Partially Met | stage_id settable via HTTP PATCH (`ticket_controller.ex:96`) and VFS MCP (`mcp/vfs/tickets.ex:1347`); `Ticket.List` filter by stage_id (`ticket_controller.ex:23`) supports column grouping; but no backend board fetch returns tickets-per-column, and core MCP `Ticket.Update` cannot move stages |
| Move to a stage that doesn't exist on the board is rejected, ticket stays in prior stage | Partially Met | `schema/ticket.ex:58` FK constraint rejects a nonexistent stage_id (TRP path returns an error); but a stage belonging to a *different* board passes — no board-membership validation found |
| Timestamped activity-log entry records from-stage, to-stage, actor | Not Met | `queue_feed.ex:18-23` returns stub "Activity feed not yet implemented"; no audit/activity table written on ticket update anywhere in `domains/tickets/` |
| Concurrent moves end in one consistent stage, no corruption | Not Met | no evidence found: NPL update path passes no `lock_version`/optimistic-lock check; `lock_version` exists only as a TRP response field (`trp/shapes.ex:48`) |

## Gaps / Risks

- Stage moves are invisible: no activity feed, no audit trail, no actor attribution anywhere on the ticket path.
- Core MCP tool surface (`Ticket.Update`) cannot perform the story's primary action — agents must use the VFS facade or raw HTTP.
- Board-membership of stages unvalidated; a ticket can reference a stage from an unrelated board.
- Concurrency safety is asserted by TRP's API contract, not demonstrated in this codebase.

## BDD Scenario

```gherkin
Feature: Move a ticket across kanban board stages

  Scenario: Delivery lead moves a ticket to Done
    Given a board with kanban stages (todo, in_progress, done)
      And a ticket currently at stage in_progress
    When PATCH /api/v1/organizations/:org/tickets/:id sets stage_id=<done>
    Then the ticket's stage_id is <done>
    And Ticket.List filtered by stage_id=<done> includes the ticket
    And Ticket.List filtered by in_progress no longer includes it

  Scenario: Invalid stage reference
    When the update sets stage_id to a UUID that is not a stage
    Then the write is rejected (FK constraint) and the ticket keeps its prior stage

  Scenario: Audit gap
    When the move completes
    Then no activity-log entry is produced (Ticket.Queue.Feed is a stub)
```
