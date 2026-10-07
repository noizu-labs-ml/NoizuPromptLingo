# Review: View Task Queue Progress

- **Story**: `project-management/user-stories/US-015-view-task-progress.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The server-side read surface in the Python MCP server covers the queue-summary and feed portions: `TaskQueue.Get` returns per-status task counts (`src/npl_mcp/tasks/tasks.py:266-288`), `TaskQueue.Feed` returns queue events from `npl_task_events` with timestamp, persona (actor), event_type (action), and task_id (`queue_feed`, `:510-553`, registered `src/npl_mcp/launcher.py:869-876`), and `Tasks.List` supports status and assignee filtering with full row fields (`:111-163`). However, there is no way to list a single queue's tasks (no `queue_id` filter anywhere on `task_list`), no computed totals/completion percentage, no dependency model (so blockedBy cannot exist), and no web dashboard: `src/npl_mcp/web/` contains only a `.gitignore` and `src/npl_mcp/api/router.py` has no SSE endpoints — all four UI criteria are unimplemented. Feed ordering is also inconsistent (newest-first without `since`, ascending with `since`, `:517-537`), which breaks naive cursor pagination.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `get_task_queue` summary with counts by status | Met | `task_queue_get` groups `npl_tasks` by status (`tasks.py:278-287`) |
| Summary includes total count, completion %, active count | Partially Met | Raw per-status counts only; no total/completion%/active computation in `task_queue_get` (`:285-288`) |
| List all tasks in a queue with status filtering | Not Met | `task_list` has status/assigned_to filters but no `queue_id` (`tasks.py:111-115`); only counts are queue-scoped |
| Task list returns ID, title, status, assigned_to, priority, created_at, updated_at | Met | `_row_to_dict` includes all listed fields (`tasks.py:27-39`) |
| Activity feed via `get_task_queue_feed` | Met | `TaskQueue.Feed` / `queue_feed` reads `npl_task_events` by queue (`tasks.py:510-553`) |
| Feed entries include timestamp, actor, action type, affected task | Met | `created_at`, `persona`, `event_type`, `task_id` mapped (`:538-553`) |
| Web UI dashboard with visual status breakdown | Not Met | `src/npl_mcp/web/` is empty (only `.gitignore`); no dashboard code anywhere |
| Blocked tasks highlighted with blockedBy dependencies shown | Not Met | No dependency columns/tables on `npl_tasks`; nothing models blockedBy |
| Filter task list by assigned persona (agent vs human workload) | Met | `assigned_to` exact-match filter (`tasks.py:140-143`) |
| Dashboard auto-refresh via SSE | Not Met | No SSE implementation in `src/npl_mcp/api/router.py` or `src/npl_mcp/web/` |

## Gaps / Risks

- The headline UI promise (this is the PM's "main project tracking interface") does not exist; what a PM can actually use today is tool-call JSON with counts and raw events.
- No producer for `npl_task_events` was found in the tasks module (only readers) — check whether any write path populates queue events; if none does, the working feed reads an empty table.
- Pagination hazard: `queue_feed` orders DESC for the first page but ASC when `since` is supplied (`tasks.py:517-537`), so "next page" requests interleave incorrectly; there is no cursor.
- Same-named surface confusion as in sibling US-013: the backend's `Ticket.Queue.Feed` (Elixir) is an unrelated stub, and Claude Code's built-in Task tools are distinct — the story's own Context section anticipates only the latter confusion.

## BDD Scenario

```gherkin
Feature: PM views task queue progress

  Scenario: PM opens a queue summary
    When the PM calls TaskQueue.Get for queue 5
    Then counts by status (pending/in_progress/blocked/review/done) are returned
    And total, completion percentage, and active count must be derived by hand

  Scenario: PM lists a queue's tasks
    When the PM calls Tasks.List with status "in_progress"
    Then matching tasks across ALL queues are returned (no queue_id filter exists)

  Scenario: PM watches the activity feed
    When the PM calls TaskQueue.Feed for queue 5
    Then events arrive with timestamp, persona, event_type, and task_id
    But the first page is newest-first while since-filtered pages are oldest-first

  Scenario: PM opens the web dashboard
    When the PM browses for the queue dashboard
    Then no dashboard exists (src/npl_mcp/web/ is empty and no SSE endpoint is served)
```
