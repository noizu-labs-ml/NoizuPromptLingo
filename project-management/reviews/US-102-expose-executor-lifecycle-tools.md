# Review: Expose Executor Lifecycle Tools

- **Story**: `project-management/user-stories/US-102-expose-executor-lifecycle-tools.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

All five lifecycle operations are registered as MCP tools in `src/npl_mcp/launcher.py:1725-1789` (`Tasker.Get`, `Tasker.List`, `Tasker.Touch`, `Tasker.Dismiss`, `Tasker.KeepAlive`) and implemented in `src/npl_mcp/executors/manager.py`: `get_tasker` (:129), `list_taskers` (:138, with status/session filters), `touch_tasker` (:166), `dismiss_tasker` (:226), `keep_alive` (:258). Status states are `active/idle/nagging/terminated` (`manager.py:18-22`) — the story's `spawned/running/failed` states do not exist. Not-found behavior is inconsistent: `Tasker.Get` returns a `not_found` dict (`launcher.py:1735-1736`), `keep_alive`/`dismiss_tasker` return error dicts, but `touch_tasker` on a non-existent ID silently issues an UPDATE that affects zero rows and reports success (`manager.py:166-181`) — the story's "Touch non-existent executor (error)" scenario fails. The DB is PostgreSQL (`npl_taskers`), not the story's SQLite `taskers` table, and column semantics differ (no `expires_at`; expiry is `timeout_minutes` from creation). No tests exist for any lifecycle operation. Integration with `manager.py` is verified by reading the delegation code — all five tools call the manager functions directly.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `get_tasker` MCP tool registered | Met | `launcher.py:1725-1737` → `manager.py:129-135`; handles missing executor via `not_found` dict |
| `list_taskers` MCP tool registered | Met | `launcher.py:1739-1752` → `manager.py:138-163`; status + session filters, ordered by created_at DESC |
| `touch_tasker` MCP tool registered | Met | `launcher.py:1754-1764` → `manager.py:166-181`; updates last_activity and resets nag state |
| `dismiss_tasker` MCP tool registered | Met | `launcher.py:1766-1778` → `manager.py:226-255`; records termination reason, handles already-terminated |
| `keep_alive_tasker` MCP tool registered | Met (variant) | `launcher.py:1780-1789` → `manager.py:258-279`; resets nag/idle but does NOT extend expiration by N seconds (no `extend_by`, no `expires_at` column) |
| Status commands working (active, idle, terminated, failed states) | Partially Met | `manager.py:18-22` has active/idle/nagging/terminated; no `spawned`, no `failed` (unexpected exit is never detected — monitor only terminates on timeouts) |
| Test coverage 80%+ for all lifecycle operations | Not Met | No executor lifecycle tests in `tests/` |
| Tool integration with executor manager.py verified | Met (code-level) | All five `launcher.py` tools delegate to `manager.py` functions; no test verifies behavior at runtime |

## Gaps / Risks

- `touch_tasker` succeeds silently on unknown IDs — callers cannot detect a typo'd or terminated tasker via touch.
- `keep_alive` does not implement the `extend_by` expiration-extension semantics from the story; lifetime is a hard `timeout_minutes` from creation that keep-alive cannot extend.
- No `failed` state: a crashed executor is only reaped by timeout/nag-timeout, never marked failed.
- In-memory `_contexts` map means dismiss/keep_alive error-handling degrades for taskers whose context was lost to a restart (dismiss on a DB-only tasker returns "already_terminated" even if it never terminated).

## BDD Scenario

```gherkin
Feature: Manage tasker lifecycle via MCP tools

  Scenario: Agent inspects a running tasker
    Given a tasker "tsk-ab12cd34" was spawned and is active
    When an agent calls Tasker.Get with that tasker_id
    Then the tool returns full metadata: task, patterns, status, timestamps, chat_room_id

  Scenario: Agent lists idle taskers
    Given taskers exist in mixed states
    When an agent calls Tasker.List with status="idle"
    Then only idle taskers are returned, newest first

  Scenario: Agent keeps a nagging tasker alive
    Given tasker "tsk-ab12cd34" is in status "nagging"
    When the agent calls Tasker.KeepAlive
    Then status returns to "idle" and last_activity is refreshed

  Scenario: Agent dismisses a tasker
    When the agent calls Tasker.Dismiss with reason "work complete"
    Then the tasker is marked terminated with the reason and terminated_at recorded
    And the response includes duration and tasks_completed counts

  Scenario: Touch a non-existent tasker (gap)
    When the agent calls Tasker.Touch with an unknown tasker_id
    Then the tool reports success anyway because the UPDATE matches zero rows
```
