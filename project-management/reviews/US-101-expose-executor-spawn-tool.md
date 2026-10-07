# Review: Expose Executor Spawn Tool

- **Story**: `project-management/user-stories/US-101-expose-executor-spawn-tool.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

A tasker spawn MCP tool is registered as `Tasker.Spawn` (`src/npl_mcp/launcher.py:1691-1723`), delegating to `spawn_tasker` in `src/npl_mcp/executors/manager.py:75-126`, which inserts into the `npl_taskers` Postgres table and returns `{tasker_id, chat_room_id, status, ...}`. Chat-room nag/keep-alive integration is real: a lifecycle monitor (`manager.py:306-338`) sends nag messages into the linked chat room after idle threshold (`manager.py:341-366`) and terminates on nag timeout. However, the implemented signature diverges from the story: there is no `agent_type`, `context`, `auto_spawn`, `idle_timeout`, or `max_lifetime` parameter — instead `task`, `chat_room_id`, `timeout_minutes`, `nag_minutes`. Validation called for in the story (reject invalid agent types, validate timeouts) is absent; timeouts accept any integer with no range check or rejection path. No tests exist for the executor system (no `test_executor*`/`test_tasker*`/`test_fabric*` in `tests/`). The story's stated registration location `src/npl_mcp/unified.py` does not exist; tools register via `mcp_discoverable` in `launcher.py`.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `spawn_tasker` MCP tool registered | Met (renamed) | `launcher.py:1691` `Tasker.Spawn` → `manager.py:75` `spawn_tasker`; not in `unified.py` (file does not exist) |
| Tool accepts lifecycle parameters (agent_type, context, auto_spawn, idle_timeout) | Partially Met | `launcher.py:1697-1705` — `task`, `chat_room_id`, `timeout_minutes`, `nag_minutes` instead; `agent_type`/`auto_spawn`/`max_lifetime` absent |
| Tool returns executor ID, status, and chat_room_id | Met | `manager.py:117-126` returns `tasker_id`, `status`, `chat_room_id` |
| Integrated with chat system for nag messages (keep-alive pings) | Met | `manager.py:341-366` `_send_nag` posts to chat room via `message_create`; monitor loop `manager.py:306-338` |
| Tool validation: rejects invalid agent types, validates timeout values | Not Met | No agent_type param and no timeout range validation in `manager.py:75-103` |
| Test coverage 80%+ (spawn success, configuration validation) | Not Met | No executor tests found in `tests/` (grep for tasker/fabric/executor matches only NPL agent-definition tests, `tests/test_agents_module.py:80`) |
| Documentation updated with tool signature and usage examples | Partially Met | Tool stub entries exist in `src/npl_mcp/meta_tools/stub_catalog.py:707` (`spawn_tasker`); no usage examples or docs page found |

## Gaps / Risks

- No timeout-value validation: a caller can pass `timeout_minutes=0` or negative values, changing lifecycle behavior unpredictably (resource-exhaustion concern the story explicitly flags).
- `auto_spawn` behavior (respawn on timeout) is not implemented at all; timeout always terminates.
- Tasker IDs (`tsk-` + 8 random chars, `manager.py:25-27`) are unique in practice but uniqueness is not enforced by a DB constraint visible in the INSERT.
- Background lifecycle monitor uses in-memory `_contexts` state (`manager.py:52`); taskers spawned before a restart lose monitoring.

## BDD Scenario

```gherkin
Feature: Spawn an ephemeral tasker as an MCP tool

  Scenario: Agent spawns a tasker for a sub-task
    Given the NPL MCP server is running with the executors category registered
    When an agent calls Tasker.Spawn with task, chat_room_id, and default timeouts
    Then a row is inserted into npl_taskers with status "idle"
    And the tool returns a tasker_id, the chat_room_id, and the initial status

  Scenario: Idle tasker receives a nag message
    Given a spawned tasker linked to chat room 42 with nag_minutes=5
    When the tasker has no activity for 5 minutes
    Then the lifecycle monitor posts "@parent Still need me for '<task>'?" into room 42
    And the tasker status becomes "nagging"

  Scenario: Caller submits an invalid timeout (NOT yet rejected)
    When an agent calls Tasker.Spawn with timeout_minutes=-5
    Then the spawn proceeds without error because no timeout validation exists
```
