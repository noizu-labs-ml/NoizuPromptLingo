# Review: Implement MCP Task Queue System

- **Story**: `project-management/user-stories/US-082-implement-mcp-task-queue-system.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Substantially implemented in the Python repo: `src/npl_mcp/tasks/tasks.py` (553 lines) provides flat tasks plus queues with enhanced fields, exposed as MCP tools `Tasks.Create/Get/List/UpdateStatus`, `TaskQueue.Create/Get/List`, `Tasks.CreateInQueue` (priority, deadline, complexity, acceptance criteria), `Tasks.AssignComplexity`, `Tasks.AddArtifact/ListArtifacts`, and activity feeds (`Tasks.Feed`, `TaskQueue.Feed` — launcher registrations at `src/npl_mcp/launcher.py:618-878`). Tests cover the core task ops (`tests/test_tasks.py`). The queue *lifecycle* the story centers on, however, is absent: there is no `claim_task` (no lease/timeout, no distributed locking — `tasks.py:1-6` explicitly says queues/leases are out of MVP scope), no `retry_task` with backoff, no `cancel_task` with cleanup, and no per-task audit trail beyond the events feed tables. Statuses are `pending/in_progress/blocked/review/done` (`tasks.py:22`) — the story's started/paused/completed/failed vocabulary differs. Confidence: high on both what exists and what's missing.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `enqueue_task` accepts description, priority, deadline, metadata | Met | `Tasks.CreateInQueue` → `task_create_in_queue` (`src/npl_mcp/tasks/tasks.py:322-370`) takes description, priority, deadline, acceptance_criteria, complexity, notes |
| `claim_task` assigns next available task with lease/timeout | Not Met | no claim function in `tasks.py`; module docstring (`tasks.py:1-6`) states leases/locking intentionally omitted; assignment is a manual `assigned_to` field |
| `update_task_status` records progress (started, paused, completed, failed) | Partially Met | `task_update_status` (`tasks.py:166-219`) works and appends notes; but status vocabulary is pending/in_progress/blocked/review/done (`tasks.py:22`) — no paused/failed states |
| `list_tasks` filters by status, assignee, room, with pagination | Partially Met | `task_list` (`tasks.py:111-163`) filters status + assigned_to with clamped limit; no room filter and no offset/cursor pagination (limit only) |
| `retry_task` requeues failed tasks with exponential backoff | Not Met | no retry function or backoff logic anywhere in `src/npl_mcp/tasks/` |
| `cancel_task` stops in-progress tasks with cleanup | Not Met | no cancel function; no cleanup hooks |
| System maintains audit trail and per-task logs | Partially Met | `npl_task_events` feed via `task_feed`/`queue_feed` (`tasks.py:465-553`) is event-log-shaped; but nothing writes events automatically on status changes, and no per-task log storage |

## Gaps / Risks

- Without claiming/leases, two agents can both "work" the same task — the story's distributed-locking dependency is explicitly deferred (`tasks.py:1-6`), making parallel orchestration unsafe on this substrate.
- Feeds read but nothing writes: unless callers manually insert `npl_task_events`, the audit trail stays empty — audit-by-convention.
- `deadline` is stored as free-form string cast to timestamptz (`tasks.py:348`) — malformed values fail at insert with a raw DB error, not a validation message.

## BDD Scenario

```gherkin
Feature: MCP task queue system
  Scenario: Agent enqueues and tracks a task (works today)
    When the agent calls Tasks.CreateInQueue with title, priority 2, deadline, and acceptance criteria
    Then the task is stored in the queue and appears in Tasks.List filtered by status/assignee
    And Tasks.UpdateStatus transitions it through pending → in_progress → done
  Scenario: Second agent claims the next task
    When an agent calls claim_task
    Then no such tool exists today — no lease is taken, and two agents could both pick the same task (gap)
  Scenario: Task fails and is retried
    When an agent marks a task failed and calls retry_task
    Then no retry/backoff mechanism exists today (gap)
  Scenario: Audit trail
    When a task's status changes
    Then no event is automatically recorded — the feed shows only manually inserted events (gap)
```
