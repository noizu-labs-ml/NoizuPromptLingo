# Review: Update Task Status

- **Story**: `project-management/user-stories/US-018-update-task-status.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

A status-update path exists: `Tasks.UpdateStatus` (`src/npl_mcp/launcher.py:705-717`) → `task_update_status` (`src/npl_mcp/tasks/tasks.py:166-219`), which validates the target against `VALID_STATUSES = {pending, in_progress, blocked, review, done}` (`tasks.py:22`), refreshes `updated_at`, and optionally appends a deduplicated note. That is where conformance ends. The story is written against a Claude-Code-style task system (`TaskUpdate`/`TaskGet`/`TaskList` with `addBlockedBy`) that has no counterpart in this repo — no dependency/blocks/blockedBy model exists anywhere in `src/`. There is no "completed" or "deleted" status (story's model conflicts with the codebase's `done`), no transition graph, so any status can be set from any other with no linearity check, no staleness/version guard, and no audit trail of status changes (`updated_at` is overwritten; nothing writes `npl_task_events` — confirmed: no `INSERT INTO npl_task_events` in `src/`). Confidence: high — function body read line-by-line; `tests/test_tasks.py:193-260` covers only validation/not-found/note-append, and its `test_expected_statuses` enshrines the 5-status model that diverges from the story.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Update status pending → in_progress → completed | Partially Met | `Tasks.UpdateStatus` sets any of the 5 valid statuses (`tasks.py:166-184`); "completed" does not exist — nearest is "done" |
| Set status "deleted" to permanently remove task | Not Met | no "deleted" in `VALID_STATUSES` (`tasks.py:22`); no delete/soft-delete path for tasks |
| Linear transitions, no backwards movement | Not Met | no transition graph — `completed→pending` and any other move is accepted (`tasks.py:206-215` has no prior-state check) |
| Invalid transitions rejected | Not Met | same — only membership in `VALID_STATUSES` is checked |
| Blocked stays "in_progress" with addBlockedBy dependencies | Not Met | no dependency model in `src/` (grep for blockedBy/blocks: no hits); codebase instead has a literal "blocked" status, inverting the story's design |
| Status change recorded with timestamp | Partially Met | `updated_at = NOW()` on every update (`tasks.py:206-215`); but no per-change history/event record (`npl_task_events` never written) |
| Staleness check before update | Not Met | no version/updated_at precondition; caller *can* fetch via `Tasks.Get` first but nothing enforces or detects staleness |
| Update metadata along with status | Partially Met | notes can be appended with the status change (`tasks.py:199-204`); title/priority/assignee/queue fields cannot be updated — no general update tool exists |
| Set up blocks/blockedBy relationships | Not Met | no evidence found — no dependency tables, columns, or parameters |
| Only mark completed when fully done | Not Met | no completion gating of any kind; also "completed" status absent |

## Gaps / Risks

- Story and codebase model the lifecycle incompatibly (story: linear pending/in_progress/completed/deleted + dependency-based blocking; code: any-to-any over pending/in_progress/blocked/review/done). Either the story needs rewriting to PRD-005's model or transition enforcement + `deleted`/`completed` need implementing.
- No audit log: story's open question about status-change history is answered "no" by the code — `npl_task_events` exists but has no writer, so `Tasks.Feed` (`tasks.py:465-507`) always returns empty.
- Concurrent-update risk is real: two agents updating the same task last-writer-wins with no detection.

## BDD Scenario

```gherkin
Feature: Track task progress via status updates

  Scenario: Agent starts work on a task
    Given a task in "pending" status
    When the agent calls Tasks.UpdateStatus with status "in_progress"
    Then the task status changes and updated_at refreshes

  Scenario: Agent tries to move a done task backwards
    Given a task in "done" status
    When the agent calls Tasks.UpdateStatus with status "in_progress"
    Then the change is accepted — no transition rules reject backwards movement

  Scenario: Agent marks a task blocked by dependencies
    When the agent attempts to record blocking task dependencies
    Then no addBlockedBy parameter or dependency model exists
    And at best the agent sets the literal "blocked" status

  Scenario: Two agents update the same task concurrently
    Given both agents read the task's state
    When both call Tasks.UpdateStatus
    Then both succeed — the second silently overwrites the first
```
