# Review: Create Task in Queue

- **Story**: `project-management/user-stories/US-016-create-task.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

`Tasks.CreateInQueue` is a real, registered MCP tool (`src/npl_mcp/launcher.py:762-801`) backed by `task_create_in_queue` (`src/npl_mcp/tasks/tasks.py:322-370`), which inserts into `npl_tasks` with `queue_id`, `acceptance_criteria`, `deadline` (cast via `$8::timestamptz`), `priority`, and `assigned_to`. However, the `created_by` parameter is absent from both the core function and the MCP tool signature; the response returns `"id"` rather than `task_id` and provides no `web_url` (no `web_url` is produced anywhere in `src/npl_mcp/`); invalid `queue_id` is never validated, so a bad id surfaces as an unhandled asyncpg FK-violation exception (`fk_tasks_queue`, `liquibase/changelogs/changeset-017.enhanced-managers.yaml:425-431`) instead of a clean error. `Tasks.List` (`launcher.py:684`, `tasks.py:111-163`) cannot filter by `queue_id`, and `Tasks.Get` (`tasks.py:88-108`) SELECTs only the flat-task columns, omitting `queue_id`/`acceptance_criteria`/`deadline` from the returned details. Confidence: high — implementation and DDL read directly; the enhanced queue path has no unit tests (`tests/test_tasks.py` covers only the flat-task MVP).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Required fields: queue_id, title, description | Met | `src/npl_mcp/tasks/tasks.py:322-370`; `src/npl_mcp/launcher.py:762-801` |
| Priority level settable | Partially Met | `tasks.py:47` (default 1) accepts any int; no 1-5 range validation; launcher docstring says 1-5 but nothing enforces it |
| Optional `assigned_to` | Met | `tasks.py:328`, `launcher.py:773` |
| `acceptance_criteria` text field | Met | `tasks.py:329,346-351` |
| Optional `deadline` (ISO 8601) | Met | `tasks.py:348` (`$8::timestamptz`) |
| `created_by` parameter for attribution | Not Met | param absent from `task_create_in_queue` and `Tasks.CreateInQueue`; `npl_tasks` has no `created_by` column |
| Initial status `pending` | Met | `_DEFAULT_STATUS = "pending"`, `tasks.py:23,326`; validated against `VALID_STATUSES` |
| Response returns `task_id`, `queue_id`, `web_url` | Partially Met | returns `id` + `queue_id` (`tasks.py:363-370`); key named `id` not `task_id`; no `web_url` anywhere in `src/` |
| Clear error if `queue_id` invalid/missing | Not Met | no existence check in `tasks.py:322-370`; bad id raises unhandled asyncpg FK exception (`fk_tasks_queue`) |
| Visible in `list_tasks` for the queue | Not Met | `task_list` filters by status/assigned_to only, no queue filter (`tasks.py:111-163`); `TaskQueue.Get` gives counts, not tasks |
| Details retrievable via `get_task` | Partially Met | `Tasks.Get` works by id (`tasks.py:88-108`) but omits `queue_id`, `acceptance_criteria`, `deadline` from the SELECT/DTO |

## Gaps / Risks

- Unhandled DB exception on invalid `queue_id` — violates the module's own `{"status": "ok"|"error"|...}` envelope convention (`tasks.py:8-12`); same exposure in `task_add_artifact` for bad `task_id`.
- No test coverage at all for the enhanced queue path (`task_create_in_queue`, `task_queue_*`).
- `created_by` attribution missing despite being the story's explicit audit requirement.
- Priority scale mismatch: story defines 1=highest..5=lowest; launcher docstring for flat `Tasks.Create` says 0=low..3=urgent (`launcher.py:633`) — two conflicting conventions, neither enforced.

## BDD Scenario

```gherkin
Feature: Create a task in a task queue

  Scenario: Agent captures a work item with full detail
    Given a task queue with id 5 exists
    When the agent calls Tasks.CreateInQueue with title "Add dark mode",
      description, acceptance_criteria, priority 2, and an ISO deadline
    Then the task row is stored in npl_tasks with status "pending"
    And the response contains the new task id and queue_id

  Scenario: Agent tries to attribute the task to itself
    When the agent calls Tasks.CreateInQueue with a created_by parameter
    Then the tool rejects the unknown parameter (or silently drops it)
    And the created task has no creator attribution

  Scenario: Agent references a queue that does not exist
    When the agent calls Tasks.CreateInQueue with queue_id 99999
    Then the insert violates fk_tasks_queue
    And the MCP caller receives an unhandled database exception instead of a structured error
```
