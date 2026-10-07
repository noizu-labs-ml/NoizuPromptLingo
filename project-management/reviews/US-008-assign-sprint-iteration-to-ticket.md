# Review: Assign a sprint/iteration to a ticket

- **Story**: `project-management/user-stories/US-008-assign-sprint-iteration-to-ticket.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Iterations (sprints/cycles) are modeled as `BoardIteration` (status planned | active | completed) attached to boards (`backend/lib/noizu_prompt_lingua/schema/board_iteration.ex:4-35`; CRUD in `backend/lib/noizu_prompt_lingua/domains/tickets/queues.ex:155-179`), managed via the boards API (`backend/lib/noizu_prompt_lingua_web/controllers/board_controller.ex:133-174`). Tickets carry `iteration_id` (`schema/ticket.ex`, FK), it is settable via HTTP PATCH (`ticket_controller.ex:96`) and the VFS MCP surface (`mcp/vfs/tickets.ex:1347`), filterable via `Ticket.List ?iteration_id=` (`ticket_controller.ex:24`), and `Queue.Get` exposes a board's iterations to agents (`queue_get.ex:45-47`). So assignment + filter-driven visibility work. What is missing: **no validation rejects assignment to a closed/completed iteration** (nothing consults `BoardIteration.status` on the ticket write path), there is **no "no sprint" filter** (the index filter accepts a concrete `iteration_id` only; empty string is dropped as nil via `maybe_opt`, `ticket_controller.ex:214-216`), and the core MCP `Ticket.Update` tool cannot set `iteration_id` at all (`ticket_update.ex:45`).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Assign ticket to open "Sprint 14"; appears when filtered by that sprint | Met | HTTP PATCH sets iteration_id (`ticket_controller.ex:96`); `Ticket.List ?iteration_id=` (`ticket_controller.ex:24`); VFS MCP also supports it (`mcp/vfs/tickets.ex:1347`). Core MCP `Ticket.Update` lacks the param (partial surface gap) |
| Reassignment: disappears from Sprint-13 filter, appears under Sprint-14 | Met | same filter path — iteration_id is overwritten on update; filters are read-time (`ticket_controller.ex:24`) |
| Assignment to a closed/archived sprint rejected with validation error | Not Met | no evidence found: no code checks `BoardIteration.status` before setting `ticket.iteration_id` (`ticket_controller.ex:96`, `mcp/vfs/tickets.ex:1347` both pass through) |
| Tickets with no sprint included under a "no sprint" filter | Not Met | only concrete `iteration_id` filtering exists (`ticket_controller.ex:24`); no negative/null filter, and blank values are stripped (`ticket_controller.ex:214-216`) |

## Gaps / Risks

- Closed-sprint guard absent — agents can silently backfill completed sprints, corrupting burndown/commitment data.
- No "unscheduled" bucket filter; PMs cannot easily triage sprint-less tickets via the API.
- MCP surface split-brain: `Ticket.Update` (core) vs the VFS facade vs HTTP all accept different field sets; stage/iteration moves are invisible to core-tool-only agents.
- Iteration belongs to a board; nothing validates the ticket's queue/iteration pairing.

## BDD Scenario

```gherkin
Feature: Assign a sprint/iteration to a ticket

  Scenario: Assign to the active sprint
    Given board B has iteration "Sprint 14" with status active
      And ticket T-101 has no iteration
    When PATCH /api/v1/organizations/:org/tickets/T-101 sets iteration_id=<sprint14>
    Then Ticket.List ?iteration_id=<sprint14> includes T-101

  Scenario: Reassign between sprints
    Given T-101 is assigned to Sprint 13
    When the iteration_id is updated to Sprint 14
    Then the Sprint-13 filter no longer returns T-101

  Scenario: Closed sprint (currently unguarded)
    Given iteration "Sprint 12" has status completed
    When iteration_id is set to Sprint 12
    Then the write succeeds today (no validation exists) — a spec violation
```
