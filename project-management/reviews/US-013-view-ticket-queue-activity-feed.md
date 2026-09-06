# Review: View a ticket queue's feed of recent activity

- **Story**: `project-management/user-stories/US-013-view-ticket-queue-activity-feed.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The surface exists but is an explicit stub. `Ticket.Queue.Feed` (`backend/lib/noizu_prompt_lingua/domains/tickets/tools/queue_feed.ex:26-36`) accepts a queue slug and limit, then unconditionally returns `events: [], hint: "Activity feed not yet implemented."` — no query, no event source, no persistence read. The per-ticket `Ticket.Feed` is stubbed identically (`backend/lib/noizu_prompt_lingua/domains/tickets/tools/ticket_feed.ex:28-36`), so even the upstream events this story says it would aggregate (stage moves, comments, assignments) have no feed producer at the ticket level either. Queue CRUD itself is implemented (`queue_create.ex`, `queue_get.ex`, `queue_list.ex`), so the "queue" half of the story is real, but the activity-feed half has zero behavior. The Python MCP server has a working `queue_feed` over `npl_task_events` (`src/npl_mcp/tasks/tasks.py:510-553`), but that is the PRD-005 flat task-queue system, not the ticket queues this story's epic refers to, and it has no authorization model. No evidence of feed events, ordering, pagination, or authz specific to ticket queues was found anywhere.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Feed lists events newest-first with actor, ticket ref, human-readable description | Not Met | `queue_feed.ex:29-35` returns a hardcoded empty list with a "not yet implemented" hint |
| Stage move appears in feed within the same request/response cycle | Not Met | No event is written or read anywhere for ticket stage moves; `Ticket.Feed` producer is also a stub (`ticket_feed.ex:28-36`) |
| Pagination loads older events without duplication or gaps | Not Met | No query, hence no pagination |
| Unauthorized queue access rejected with authorization error | Not Met | `QueueFeed` declares no `authz` meta; per `backend/lib/noizu_prompt_lingua/mcp/tool_guard.ex:60-66`, tools without authz get no role check (OAuth PDP only) — there is no queue-level authorization to reject with |

## Gaps / Risks

- This is the one story in the batch with no behavioral implementation at all behind its named tool — the response even documents its own absence ("Activity feed not yet implemented."), which is honest but means Delivery Leads have no oversight surface.
- When the feed is built, the authz gap must be closed simultaneously: as with other ticket tools in this batch, `QueueFeed` currently skips the role ladder entirely.
- The story assumes events exist from US-007/US-008/US-009/US-010; no ticket event-log table or write path was found (ticket comments exist as entities, but no event emission tied to stage moves or links), so the aggregation premise itself is unbuilt.
- The identically-named-but-different `queue_feed` in the Python server (`tasks.py:510`) is a likely source of confusion during planning: it satisfies grep searches but belongs to the other (task-queue) domain.

## BDD Scenario

```gherkin
Feature: Ticket queue activity feed

  Scenario: Delivery lead opens a queue's feed
    Given a queue with 20 tickets and recent stage moves and comments
    When Priya calls Ticket.Queue.Feed with the queue slug
    Then the response contains zero events and the hint "Activity feed not yet implemented."

  Scenario: Delivery lead requests a queue she cannot access
    When Priya calls Ticket.Queue.Feed for a queue outside her membership
    Then no authorization check runs (the tool has no authz metadata)
    And the same empty stub response is returned regardless of access
```
