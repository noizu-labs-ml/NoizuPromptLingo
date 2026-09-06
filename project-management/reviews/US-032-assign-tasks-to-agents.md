# Review: Assign Tasks to Specific Agents

- **Story**: `project-management/user-stories/US-032-assign-tasks-to-agents.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The thin slice that exists is a freeform `assigned_to` string on tasks: accepted at creation (`task_create`, `src/npl_mcp/tasks/tasks.py:47`; wired through `POST /tasks` at `src/npl_mcp/api/router.py:1824-1825` and `task_create_in_queue`), stored (`npl_tasks.assigned_to`), returned by `task_get` (`tasks.py:35`), and filterable in `task_list` (`tasks.py:111,140-142`). Everything beyond that is missing: there is no reassignment path (the only `UPDATE npl_tasks` statements set status/notes at `tasks.py:207` and complexity at `tasks.py:381` — none touch `assigned_to`), no agent pools or recognized agent types, no workload indicator, no assignment notifications, no validation of assignee existence, and no assignment history (no code writes `npl_task_events`, so feeds are always empty). No tests exercise assignment.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Direct assignment via `agent_id` parameter | Partially Met | `assigned_to` accepted at create (`tasks.py:47`, `router.py:1824`), but freeform string, no agent-ID validation |
| Pool assignment to agent type with auto-routing | Not Met | no evidence found |
| Workload awareness before assignment | Not Met | no evidence found |
| Reassignment via `update_task` with new `assigned_to` | Not Met | No update path sets `assigned_to` (`tasks.py:207`, `tasks.py:381` are the only UPDATEs) |
| Assignment history in task feed with timestamp + initiator | Not Met | No `INSERT INTO npl_task_events` anywhere in `src/` |
| Notification to agent on assignment | Not Met | Chat notification helpers exist (`chat.py:318+`) but nothing links them to task assignment |
| Response returns task_id, assigned_to, agent_type | Partially Met | task_id + assigned_to returned; no `agent_type`/`routed_to`/workload fields |
| Clear error for invalid agent ID / unsupported type | Not Met | Any string accepted as `assigned_to` |
| Assignment visible via `get_task` with history | Partially Met | Current `assigned_to` visible (`tasks.py:35`); no history |
| Supported agent types recognized (`tdd-coder`, etc.) | Not Met | No agent-type registry in `src/` |

## Gaps / Risks

- The story's "pool" semantics (route to next available agent of a type) presuppose an agent-orchestration registry that does not exist in this repo's runtime.
- Reassignment is impossible today — once created with or without an assignee, `assigned_to` is frozen. This is the highest-value small fix (extend the existing update path).
- Feed orphan (no event writes) means assignment history will be empty even after reassignment exists unless event emission is added at the same time.

## BDD Scenario

```gherkin
Feature: Assign tasks to agents

  Scenario: Assign at creation
    Given a project with tasks
    When the PM creates a task with assigned_to "agent-tdd-coder-003"
    Then the task stores the assignee and get_task returns it
    (Any string is accepted — no validation of agent existence)

  Scenario: Reassign a task (not possible today)
    Given task 42 exists assigned to "agent-a"
    When the PM calls update_task with assigned_to "agent-b"
    Then the command has no effect on the assignee — no update path exists

  Scenario: Pool routing (not implemented)
    When the PM assigns a task to pool "tdd-coder"
    Then the system routes it to the next available coder agent and notifies both parties
```
