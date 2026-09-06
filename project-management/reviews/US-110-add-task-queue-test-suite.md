# Review: Add Task Queue Test Suite (0% → 80%)

- **Story**: `project-management/user-stories/US-110-add-task-queue-test-suite.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

A task test suite now exists, superseding the story's "0% coverage" premise: `tests/test_tasks.py` (18 tests) covers create validation (empty title, invalid status), create success/envelope/field-trimming, get (found/not-found/non-integer id), list (empty, status+assignee filters, limit clamping), update_status (invalid status, non-integer id, not-found, notes append, substring dedupe), and the expected status set (`tests/test_tasks.py:260`). The implementation under test provides 13 MCP tools (`src/npl_mcp/launcher.py:618-883`) over `src/npl_mcp/tasks/tasks.py` using Postgres tables `npl_tasks`/`npl_task_queues` — not the story's four-table schema (`task_events`/`task_artifacts` tables do not exist; artifact links are rows via `task_add_artifact` :401, and feeds derive activity from task rows :465-520). However, the suite stops at the core four operations: artifact linking, complexity assignment, feeds, and concurrency have no tests. Workflow transition rules do not exist to test — `task_update_status` (`tasks.py:166-224`) accepts any member of the flat `VALID_STATUSES` set, so the story's flagship scenario "cannot transition pending → done" fails by design. The 80% threshold is not validated by any coverage gate or report.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| All 13 task tools have 80%+ test coverage | Partially Met | Tests cover 4 of 13 tools' paths (`tests/test_tasks.py`); complexity/artifact/feed/queue tools untested; threshold unmeasured |
| Workflow states tested (pending → in_progress → review → done/blocked) | Not Met | Status set membership tested (`tests/test_tasks.py:260`) but no transition-order rules exist (`tasks.py:166-181` validates membership only); pending → done is permitted |
| Priority and complexity scoring tested with multiple scenarios | Not Met | `task_assign_complexity` exists (`tasks.py:373`) with no tests; no priority-setting tool exists at all |
| Artifact linking to tasks tested (create, update, retrieve) | Not Met | `task_add_artifact`/`task_list_artifacts` (`tasks.py:401-463`) untested |
| Activity feeds and comments tested (creation, filtering, ordering) | Not Met | `task_feed`/`queue_feed` (`tasks.py:465-520`) untested; no comment tool exists |
| Concurrent task updates handled and tested | Not Met | No locking/conflict handling in `tasks.py` and no concurrency tests |
| Test suite passes in CI/CD with coverage report validation | Partially Met | Suite is in the pytest tree; no coverage-report gate found in repo config |

## Gaps / Risks

- The story's central workflow-validation requirement (no pending → done) is unimplemented in the product, not just untested — a test-only fix cannot satisfy this criterion.
- All tests mock the asyncpg pool; schema relationships (queue→task FK behavior, cascade on queue delete) are unvalidated.
- No concurrency control: simultaneous claims/updates are last-write-wins, and the story flags concurrent assignment as a critical scenario.
- Story's schema and tool inventory drift from implementation (missing task_events/task_artifacts tables; missing assign/priority/comment/dismiss tools) — needs re-baselining before 80%-coverage tracking is meaningful.

## BDD Scenario

```gherkin
Feature: Task queue test coverage

  Scenario: Task creation is validated
    When Tasks.Create is called with an empty title
    Then an error result is returned
    When Tasks.Create is called with a valid title and status
    Then the task is created with trimmed fields and an ok envelope

  Scenario: Status updates append deduplicated notes
    Given a task with existing notes
    When Tasks.UpdateStatus adds a note already present as a substring
    Then the note is not duplicated
    And the status change is persisted

  Scenario: Workflow guard (NOT implemented)
    When a task in "pending" is set directly to "done"
    Then the update succeeds, because no transition rules restrict status order

  Scenario: Artifact linking (implemented, untested)
    When Tasks.AddArtifact links artifact 7 to a task
    Then the link is stored and Tasks.ListArtifacts returns it
    And no automated test currently exercises this path
```
