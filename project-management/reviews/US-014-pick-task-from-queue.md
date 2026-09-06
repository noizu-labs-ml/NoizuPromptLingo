# Review: Pick Up Task from Queue

- **Story**: `project-management/user-stories/US-014-pick-task-from-queue.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Python MCP server implements the task-queue core this story targets. Queue discovery works (`TaskQueue.List` → `task_queue_list`, `src/npl_mcp/tasks/tasks.py:291-319`; `TaskQueue.Get` returns per-status counts, `:266-288`); claiming works via `Tasks.UpdateStatus` (`:166-219`); `Tasks.List` filters by status and `assigned_to` (`:111-163`); `Tasks.Get` returns details (`:88-108`); statuses match the story's workflow (`VALID_STATUSES` includes pending/in_progress/blocked/review/done, `:22`). Gaps against the story: `Tasks.List` cannot scope to a specific queue (no `queue_id` filter — only `Tasks.CreateInQueue` knows about queues), ordering is `created_at DESC` rather than priority, `Tasks.Get` omits the `acceptance_criteria` and `deadline` columns the story requires, and self-assignment is impossible — there is no `update_task` tool to set `assigned_to` after creation. The atomic-claim concurrency the story promises is also unimplemented: `task_update_status` is a read-then-update with no guard, so two agents can both "claim" the same task. Unit tests cover the basic CRUD paths (`tests/test_tasks.py`).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| List all task queues via `list_task_queues` | Met | `TaskQueue.List` (`tasks.py:291-319`, registered `launcher.py:744-754`) |
| List tasks in a specific queue filtered by status | Not Met | `task_list` filters status/assigned_to only — no `queue_id` parameter (`tasks.py:111-115`); queue-scoped reads limited to counts via `task_queue_get` (`:278-287`) |
| Filter tasks by assigned persona | Met | `assigned_to` exact-match filter (`tasks.py:140-143`) |
| Priority info returned; orderable by priority | Partially Met | `priority` is in every row (`:150-157`) but ordering is fixed `created_at DESC` — no priority sort option |
| Transition pending → in_progress via `update_task_status` | Met | `Tasks.UpdateStatus` validates against `VALID_STATUSES` and updates (`tasks.py:166-219`) |
| `get_task` returns title, description, acceptance_criteria, priority, deadline | Partially Met | `task_get` selects only id/title/description/status/priority/assigned_to/notes/timestamps (`:96-99`) — `acceptance_criteria` and `deadline` (written by `task_create_in_queue`, `:345-348`) are never read back |
| Ownership determinable via `assigned_to` | Met | `assigned_to` returned by both `task_get` and `task_list` |

## Gaps / Risks

- No self-assignment path: the story's Scenario 2 (`update_task(task_id, assigned_to=...)`) has no implementing tool — tasks are only assignable at creation time. Combined with no queue filter, the "agent finds and claims work" loop is not executable as written.
- Claim atomicity is fictional: `task_update_status` does `SELECT` then `UPDATE` with no precondition on prior status or assignee (`tasks.py:191-215`), so the story's concurrency guarantee ("only one agent's update succeeds") does not hold.
- Data written by `Tasks.CreateInQueue` (acceptance_criteria, deadline, complexity) is write-only through the read tools — agents cannot retrieve the context they are told to fetch before starting.
- Minor doc drift: `Tasks.CreateInQueue` docstring advertises a "cancelled" status (`launcher.py:780`) that is not in `VALID_STATUSES` (`tasks.py:22`).

## BDD Scenario

```gherkin
Feature: Agent picks up work from a task queue

  Scenario: Agent discovers available work
    When the agent calls TaskQueue.List then Tasks.List with status "pending" and assigned_to null
    Then pending unassigned tasks are returned with priority fields
    But results span all queues (no queue filter) and are ordered by creation, not priority

  Scenario: Agent claims the highest-priority task
    When the agent calls Tasks.UpdateStatus to move task 42 to in_progress
    Then the status transition succeeds
    But a second agent issuing the same update also succeeds (no atomic claim guard)
    And the agent cannot set assigned_to to record ownership (no update tool for assignment)

  Scenario: Agent reads full task details before starting
    When the agent calls Tasks.Get for task 42
    Then title, description, priority, and status are returned
    But acceptance_criteria and deadline are absent from the response
```
