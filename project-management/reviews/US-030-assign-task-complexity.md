# Review: Assign Task Complexity

- **Story**: `project-management/user-stories/US-030-assign-task-complexity.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

A real `task_assign_complexity` implementation exists at `src/npl_mcp/tasks/tasks.py:373-394`, registered as MCP tool `tasks_assign_complexity_tool` (`src/npl_mcp/launcher.py:804`), and complexity columns are also accepted at task creation via `task_create_in_queue` (`tasks.py:322-369`). Overwriting works (straight UPDATE) and non-existent tasks return `not_found`. However: there is no 1-5 range validation (any integer is accepted; the launcher docstring even advertises a "1-13 Fibonacci" scale, contradicting the story), no complexity→label mapping, no `persona` parameter recording who assigned it, `task_get` does not return complexity at all (its SELECT omits the columns, `tasks.py:96-98`), and no feed event is written — in fact no code anywhere inserts into `npl_task_events` (grep: zero INSERTs), so `task_feed` is always empty.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Assign numeric complexity score (1-5) | Partially Met | Assignable at `tasks.py:373-385` but no range validation; docstring says 1-13 Fibonacci (`launcher.py:785`) |
| Score automatically mapped to standard labels | Not Met | No label mapping anywhere in `src/` |
| Optional notes explaining reasoning | Met | `notes` → `complexity_notes` stored (`tasks.py:383-385`) |
| Persona identifier recorded with assignment | Not Met | Function has no `persona` param (`tasks.py:373-376`) |
| Score + label returned via `get_task` | Not Met | `task_get` SELECT omits complexity columns (`tasks.py:96-98`) |
| Assignment recorded in task feed with timestamp | Not Met | No `INSERT INTO npl_task_events` exists in `src/` (grep: zero hits); feeds read-only |
| Invalid scores (<1 or >5) rejected with error | Not Met | No validation |
| Reassigning overwrites previous value | Met | `UPDATE npl_tasks SET complexity = $1 ...` (`tasks.py:380-385`) |
| Task must exist before assignment | Met | `not_found` returned when row missing (`tasks.py:386-387`) |

## Gaps / Risks

- Scale mismatch (story 1-5 vs launcher docstring 1-13) must be reconciled before validation can be added.
- `task_feed`/`queue_feed` are write-orphaned: nothing in the codebase generates task events, so the story's feed requirement (and any consumer of feeds) silently sees empty history. Cross-cutting gap affecting US-032 too.
- Complexity invisible through `get_task` undermines the story's core "returned in task details" contract.

## BDD Scenario

```gherkin
Feature: Assign task complexity

  Scenario: Assign complexity with notes
    Given task 21 exists in a queue
    When the caller assigns complexity 3 with notes "cross-cutting but scoped"
    Then the task's complexity is stored as 3 and overwrites any prior value
    And assigning to a missing task returns not_found

  Scenario: Invalid score (not enforced today)
    When the caller assigns complexity 9
    Then the value is accepted as-is — no 1-5 validation exists

  Scenario: View complexity via get_task (not possible today)
    When the caller fetches task details
    Then complexity and label are absent from the response
```
