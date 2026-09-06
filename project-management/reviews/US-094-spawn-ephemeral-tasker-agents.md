# Review: Spawn Ephemeral Tasker Agents

- **Story**: `project-management/user-stories/US-094-spawn-ephemeral-tasker-agents.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The full tasker lifecycle is implemented in `src/npl_mcp/executors/manager.py` and — contrary to the story's "NOT exposed as MCP tools" note, which described the old `unified.py` layout — all six tools are registered and MCP-visible in this checkout: Tasker.Spawn/Get/List/Touch/Dismiss/KeepAlive (`src/npl_mcp/launcher.py:1688-1782`). `TaskerStatus` covers active/idle/nagging/terminated (`manager.py:19-23`), IDs are `tsk-` + 8 random chars (`manager.py:25-27`), spawn accepts task/chat_room_id/patterns/timeout (default 15m)/nag (default 5m) (`manager.py:36-41, 75-113`), the 30s-style monitor loop handles idle→nag and timeout→terminate transitions (`manager.py:318-381`), `keep_alive` resets nag state (`manager.py:167-175`, `:258`), and `dismiss_tasker` accepts an optional reason stored as `termination_reason` (`manager.py:226-247`). `command_history` is tracked per tasker (`manager.py:46`). Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Spawn tasker with task description and fabric patterns | Met | `launcher.py:1693-1724` (Tasker.Spawn) → `manager.py:75-113` (patterns column, JSON-encoded) |
| Unique `tsk-xxxxxxxx` ID | Met | `manager.py:25-27` (secrets.choice over 8 chars) |
| Lifecycle states IDLE/ACTIVE/NAGGING/TERMINATED | Met | `manager.py:19-23`; transitions at `:318-381` |
| Nag message to parent after idle (default 5 min) | Partially Met | idle→NAGGING transition + `nag_sent_at` (`manager.py:41, 45, 324-352`), but no chat-message dispatch to `chat_room_id` found — only the status flips |
| Parent responds `keep_alive` to extend timeout | Met | `manager.py:258` (keep_alive), `:167-175` (resets nag state, bumps last_activity); Tasker.KeepAlive at `launcher.py:1782` |
| Auto-terminate after timeout (default 15 min) | Met | `manager.py:40` (default 15), `:321-327` (timeout check), `:375-381` (termination) |
| Manual dismiss with reason | Met | `manager.py:226-247` (`dismiss_tasker(tasker_id, reason)`, stored `termination_reason`); Tasker.Dismiss at `launcher.py:1768` |
| Tasker context buffered for follow-up queries | Met | `command_history` per tasker (`manager.py:46`); returned via `get_tasker` (`:129-131`) |

## Gaps / Risks

- The nag is a status transition, not a delivered message: nothing in `manager.py` posts to the chat room, so a parent that isn't polling `Tasker.Get`/`Tasker.List` never learns of the nag. The story's "nag messages sent via chat system" is unimplemented.
- The `npl_taskers` table is created outside `src/npl_mcp/storage/` (no schema.sql there); first-run table creation depends on external migration — worth confirming deployment path.
- No test coverage found for the monitor loop transitions.

## BDD Scenario

```gherkin
Feature: Spawn ephemeral tasker agents

  Scenario: Delegate a subtask with lifecycle management
    When the parent calls Tasker.Spawn(task="analyze test failures", chat_room_id=42, patterns=["analyze_logs"])
    Then a tasker row is created with id "tsk-xxxxxxxx" and status "active"
    And after 5 idle minutes the monitor flips status to "nagging" and records nag_sent_at
    When the parent calls Tasker.KeepAlive("tsk-xxxxxxxx")
    Then last_activity is bumped and nag state resets
    But if the parent never polls, no chat-room nag message is actually delivered
    And at 15 total minutes the monitor terminates the tasker
    And the parent can call Tasker.Dismiss(id, reason="task_complete") at any point
```
