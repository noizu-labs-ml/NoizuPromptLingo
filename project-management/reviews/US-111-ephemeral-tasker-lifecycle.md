# Review: Ephemeral Tasker Lifecycle Management

- **Story**: `project-management/user-stories/US-111-ephemeral-tasker-lifecycle.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Python MCP server has a complete tasker lifecycle module at `src/npl_mcp/executors/manager.py` (ported from main's TaskerManager): spawn/get/list/touch/dismiss/keep_alive functions, an in-memory `_TaskerContext` cache mirrored into the `npl_taskers` Postgres table (DDL via `liquibase/changelogs/changeset-016.taskers-table.yaml`), and a background `_lifecycle_loop` that sends nags and terminates on timeout (manager.py:306-338). Context buffering for follow-up queries exists via `store_context`/`get_context` (manager.py:184-223). The critical gap: `start_lifecycle_monitor()` is only exported from `src/npl_mcp/executors/__init__.py:13` — nothing in `src/npl_mcp/launcher.py` ever calls it, so nagging and auto-termination never run in the live server. Context history is in-memory only (lost on restart), and the module has no tests (`tests/` has no tasker coverage).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Taskers spawn with configurable timeout (default 15 minutes) | Met | `src/npl_mcp/executors/manager.py:75-103` (`timeout_minutes=15` default, persisted to `npl_taskers`) |
| Taskers send nag messages after idle period (default 5 minutes) | Partially Met | Nag logic + chat-room message at `src/npl_mcp/executors/manager.py:331,341-366`; monitor never started at server startup (no call site outside `__init__.py` exports), so nags never fire in practice |
| Taskers auto-terminate after timeout if no activity | Partially Met | `_terminate_tasker` on timeout/nag_timeout at `src/npl_mcp/executors/manager.py:327-338,369-386`; dormant for same reason (monitor not started) |
| Lifecycle states: IDLE, ACTIVE, NAGGING, TERMINATED | Met | `TaskerStatus` enum `src/npl_mcp/executors/manager.py:18-23`; transitions in touch/keep_alive/nag/terminate |
| Context buffering for follow-up queries | Met | `store_context`/`get_context` `src/npl_mcp/executors/manager.py:184-223` (bounded 10-entry command history, last output/analysis) |
| In-memory state cache with persistent DB storage | Met | `_contexts` dict `src/npl_mcp/executors/manager.py:52`; asyncpg INSERT/UPDATE against `npl_taskers` `manager.py:89-103`; table DDL `liquibase/changelogs/changeset-016.taskers-table.yaml:11` |

## Gaps / Risks

- `start_lifecycle_monitor()` is never invoked from `src/npl_mcp/launcher.py` — the entire nag/timeout machinery is dead code in the running server. This is the single highest-impact gap.
- Context cache is process-local: after a server restart, in-memory contexts vanish while DB rows survive, so `dismiss_tasker` reports "already_terminated" only for terminated rows and `store_context` silently no-ops (manager.py:192-194) for restarted taskers.
- The lifecycle loop swallows all exceptions with a bare `print` (manager.py:313-314) — inconsistent with the repo's structured logging.
- No unit/integration tests for any tasker function; `tests/` has no tasker/fabric coverage (only unrelated `npl-tasker-*` agent-name fixtures).
- Taskers themselves are stateless records — nothing actually executes the sub-task; "spawn" only creates a row + context (execution orchestration is out of this module).

## BDD Scenario

```gherkin
Feature: Ephemeral tasker lifecycle management

  Scenario: Spawn a tasker with defaults and keep it alive
    Given the NPL MCP server is connected to the Postgres pool
    When the agent calls ToolCall("Tasker.Spawn", {"task": "summarize logs", "chat_room_id": 42})
    Then a row is inserted into npl_taskers with status "idle", timeout_minutes 15, nag_minutes 5
    And an in-memory context is registered under the returned tasker_id
    When the agent calls ToolCall("Tasker.Touch", {"tasker_id": "<id>"})
    Then last_activity is refreshed and status becomes "active"

  Scenario: Idle tasker is nagged then terminated
    Given a tasker spawned 16 minutes ago with no activity
    When the lifecycle monitor loop runs _check_taskers
    Then a nag message "@<parent_agent_id> Still need me..." is posted to chat room 42
    And the tasker status becomes "nagging"
    When the agent calls ToolCall("Tasker.KeepAlive", {"tasker_id": "<id>"})
    Then status returns to "idle" and the idle timer resets
    But when the agent does not respond within 2 minutes of the nag
    Then the tasker is terminated with reason "nag_timeout"
    # NOTE: this scenario cannot occur in production today because
    # start_lifecycle_monitor() is never called at server startup.
```
