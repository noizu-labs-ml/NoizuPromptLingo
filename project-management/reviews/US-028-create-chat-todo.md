# Review: Create Todo from Chat

- **Story**: `project-management/user-stories/US-028-create-chat-todo.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

`create_todo` exists at `src/npl_mcp/chat/chat.py:288-300` and is registered as MCP tool `chat_create_todo` (`src/npl_mcp/launcher.py:1329`) and HTTP route (`POST /chat/...todo`, `src/npl_mcp/api/router.py:2828-2831`). It writes a chat event of type `todo` with `description`, `assigned_to`, and `completed: False` in the jsonb payload, so todos appear in the room feed via `event_list`. Core creation works, but the implementation diverges from the story in several ways: event type is `todo` (not `todo_created`), there is no separate `todo_id` (only the event id), no explicit `status: "pending"` field, no empty-description validation, no clean invalid-room error (raw FK failure), and no `complete_todo` command exists anywhere (grep confirms zero hits), so the pending→completed transition is impossible.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Required fields: room_id, persona, description | Met | `chat.py:288-293` |
| Optional `assigned_to` | Met | `chat.py:292`, stored at `chat.py:299` |
| Todo appears as `todo_created` event in feed | Partially Met | Event type is `"todo"`, not `todo_created` (`chat.py:297`) |
| Event includes todo_id, description, creator, assigned_to, timestamp | Partially Met | description/assigned_to/persona/created_at present; no distinct `todo_id` (event id serves) |
| Creator recorded and immutable | Met | `persona` set at insert; no update path for events |
| Returns `todo_id` | Partially Met | Returns `event_id` only (`chat.py:218`) |
| Initial status `"pending"` | Partially Met | Stored as `completed: False`, no `status` field (`chat.py:299`) |
| Status transitions pending → completed | Not Met | No `complete_todo` command in `src/` (grep: zero hits) |
| Empty/whitespace description rejected | Not Met | No validation in `create_todo` |
| Invalid room_id returns error | Not Met | `event_create` (`chat.py:196`) lets the FK violation surface as a raw exception |
| Visible in chat feed via `get_chat_feed` | Met | Returned by `event_list` (`chat.py:232-274`) |

## Gaps / Risks

- No todo lifecycle at all: once created, a todo can never be completed, so the feature is capture-only.
- Validation gaps (empty description, bad room) produce unhandled DB exceptions rather than typed errors.
- Naming drift (`todo` vs `todo_created`, `event_id` vs `todo_id`) will break clients built to the story contract.
- No tests reference `create_todo` or chat events.

## BDD Scenario

```gherkin
Feature: Create todo from chat

  Scenario: Create and assign a todo
    Given chat room 9 exists
    When persona "bob" calls create_todo in room 9 with description "Review the design spec" and assigned_to "alice"
    Then a chat event of type "todo" is created carrying description, assigned_to "alice", and completed=false
    And the event is visible when listing the room feed

  Scenario: Complete a todo (not possible today)
    Given a todo event exists in room 9
    When the caller attempts to complete the todo
    Then the command fails — no complete_todo tool exists in the system

  Scenario: Invalid input
    When create_todo is called with an empty description or a non-existent room_id
    Then no clean validation error is returned — the insert either succeeds with empty data or fails with a raw database exception
```
