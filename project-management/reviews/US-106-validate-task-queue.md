# Review: Validate Task Queue Implementation

- **Story**: `project-management/user-stories/US-106-validate-task-queue.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Task orchestration is substantially implemented: 13 `Tasks.*`/`TaskQueue.*` MCP tools are registered in `src/npl_mcp/launcher.py:618-883` (Create, Get, List, UpdateStatus, TaskQueue Create/Get/List, CreateInQueue, AssignComplexity, AddArtifact, ListArtifacts, Tasks.Feed, TaskQueue.Feed) over `src/npl_mcp/tasks/tasks.py` (PostgreSQL via asyncpg, tables `npl_tasks`/`npl_task_queues` — not the story's four-table SQLite schema). Status transitions validate against `VALID_STATUSES = {pending, in_progress, blocked, review, done}` (`tasks.py:22`) but are a flat enum — there is no workflow rule preventing `pending → done` (story/US-110's key scenario fails). A dedicated test suite exists (`tests/test_tasks.py`, 18 tests) covering validation, filters, notes append/dedupe, and status sets — the story's "0% coverage, CRITICAL" figure is outdated, though 80% is unverified. Web routes exist (`GET/POST /tasks`, `GET /tasks/{task_id}` at `src/npl_mcp/api/router.py:1790-1901`). Several story-listed tools are missing: `assign_task` (list filters by assignee but no assignment tool), `set_task_priority` (priority column exists with default, no setter), `add_task_comment` (notes-appending on status update is the nearest analog), `get_task_artifact` (ListArtifacts replaces it), `create_task_activity` (Feed provides the read side). No performance baseline evidence exists.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| All 13 task tools enumerated, documented, functional | Partially Met | 13 tools registered (`launcher.py:618-883`) but the set differs from the story's list — assign, priority, dismiss, comments, activity-create missing; stub catalog entries exist (`src/npl_mcp/meta_tools/stub_catalog.py`) |
| Database schema validated (task_queues, tasks, task_events, task_artifacts) | Partially Met | `npl_tasks`/`npl_task_queues` in use (`tasks.py`); task-artifact linking via `task_add_artifact` (:401); no `task_events` table — feeds derive from task rows |
| Web routes working for task operations | Met | `api/router.py:1790-1901` — GET/POST /tasks, GET /tasks/{task_id} functional |
| Test coverage gap identified and documented (currently 0%) | Partially Met | `tests/test_tasks.py` (18 tests) now exists; the 0% figure is stale; no documented coverage measurement |
| Prioritized test implementation plan created (US-097) | Partially Met | Story US-097 exists; actual suite covers core CRUD paths but not artifacts/concurrency |
| Task workflow states tested (pending → in_progress → review → done/blocked) | Partially Met | Status set enforced (`tasks.py:22`, `:177-181`) and tested (`tests/test_tasks.py:260`); no transition-order rules exist or are tested |
| Artifact linking to tasks validated | Partially Met | `task_add_artifact`/`task_list_artifacts` (`tasks.py:401-463`) implemented; linking tests absent from `tests/test_tasks.py` |

## Gaps / Risks

- No workflow transition validation: any status can follow any other, so "review" can be skipped entirely.
- No concurrency control: two agents updating the same task do last-write-wins with no optimistic locking.
- Priority exists as a column and list-sort input but cannot be set via any tool; `assign_task` is absent despite filters assuming assignment.
- The story's schema (4 tables incl. task_events, task_artifacts) does not match the implementation; reviews of dependent stories should use the real schema.

## BDD Scenario

```gherkin
Feature: Task queue orchestration

  Scenario: Create a queue and add a task
    When an agent calls TaskQueue.Create with a name
    Then the queue is created
    When Tasks.CreateInQueue adds a task to it
    Then the task is created with status "pending" and default priority

  Scenario: Move a task through states
    When Tasks.UpdateStatus sets the task to "in_progress"
    Then the status change is accepted and recorded
    When Tasks.UpdateStatus sets the task directly from "pending" to "done"
    Then the change is accepted too, because no transition rules exist

  Scenario: Link an artifact to a task
    When Tasks.AddArtifact links artifact 7 to the task
    Then Tasks.ListArtifacts returns the linked artifact

  Scenario: Filter tasks by status and assignee
    Given tasks exist in mixed states
    When Tasks.List is called with status and assignee filters
    Then only matching tasks are returned with a clamped limit

  Scenario: Comment on a task (gap)
    When an agent wants a discussion thread on a task
    Then no comment tool exists; only notes-appending via status updates
```
