# Review: MCP Tool Exposure for Taskers

- **Story**: `project-management/user-stories/US-113-mcp-tool-exposure-for-taskers.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

All nine required tools are registered as FastMCP tools in `src/npl_mcp/launcher.py` and delegate to the real `executors/manager.py` and `executors/fabric.py` implementations (not stubs): Tasker.Spawn (launcher.py:1693), Tasker.Get (:1727), Tasker.List (:1741), Tasker.Touch (:1756), Tasker.Dismiss (:1768), Tasker.KeepAlive (:1782), Fabric.Apply (:1797), Fabric.Analyze (:1816), Fabric.ListPatterns (:1834). Tasker.Get handles the not-found path (`{"status": "not_found"}`, launcher.py:1736). One deviation from the letter of the criteria: there is no `unified.py` anywhere in `src/npl_mcp/` — registration lives in `launcher.py`, which satisfies the intent (all tools exposed through one registry) but not the literal filename. Note the naming differs from the story ("get_tasker"/"keep_alive_tasker" → Tasker.Get/Tasker.KeepAlive), which is cosmetic. Underlying lifecycle behavior inherits US-111's dormant-monitor gap.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Expose `spawn_tasker` as MCP tool | Met | `src/npl_mcp/launcher.py:1693-1725` → `executors.manager.spawn_tasker` |
| Expose `get_tasker` and `list_taskers` as MCP tools | Met | launcher.py:1727-1752 → `get_tasker` / `list_taskers` (with status/session filters) |
| Expose `dismiss_tasker` and `keep_alive_tasker` as MCP tools | Met | launcher.py:1768-1789 → `dismiss_tasker` / `keep_alive`; `touch_tasker` also exposed (superset) |
| Expose `apply_fabric_pattern` and `analyze_with_fabric` as MCP tools | Met | launcher.py:1797-1832 → `fabric.apply_fabric_pattern` / `analyze_with_patterns` |
| Expose `list_fabric_patterns` as MCP tool | Met | launcher.py:1834 → `fabric.list_patterns` (falls back to static `FABRIC_PATTERNS`) |
| All tools registered in unified.py | Partially Met | No `unified.py` exists (`grep -r unified src/npl_mcp/` finds nothing); all registrations are in `src/npl_mcp/launcher.py` — functionally equivalent single registry |

## Gaps / Risks

- Registration filename mismatch (`unified.py` vs `launcher.py`) — either rename the criterion in the story or note the actual location.
- Tool exposure does not fix US-111's core gap: with the lifecycle monitor never started, Tasker.Spawn returns a tasker that will never nag or time out at runtime.
- Tasker.List returns all taskers with no session/agent authz scoping beyond the optional `session_id` filter — any caller can enumerate every tasker.
- No tests assert tool registration or the launcher wrappers for these nine tools.

## BDD Scenario

```gherkin
Feature: Tasker and fabric management exposed as MCP tools

  Scenario: Claude spawns and manages an ephemeral agent
    Given the NPL MCP server is running
    When the client calls ToolCall("Tasker.Spawn", {"task": "review diff", "chat_room_id": 7, "patterns": ["analyze_logs"]})
    Then the response includes a tasker_id starting with "tsk-"
    When the client calls ToolCall("Tasker.Get", {"tasker_id": "<id>"})
    Then the tasker is returned with status "idle"
    When the client calls ToolCall("Tasker.KeepAlive", {"tasker_id": "<id>"})
    Then status stays "idle" and last_activity is refreshed
    When the client calls ToolCall("Tasker.Dismiss", {"tasker_id": "<id>", "reason": "done"})
    Then the tasker is terminated with reason "done"

  Scenario: Listing fabric patterns without fabric installed
    Given fabric is not installed
    When the client calls ToolCall("Fabric.ListPatterns", {})
    Then the response has success=false and includes the static common_patterns list
```
