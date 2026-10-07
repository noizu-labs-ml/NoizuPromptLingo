# Review: Send a message with a threaded reply

- **Story**: `project-management/user-stories/US-016-send-message-with-threaded-reply.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

A threading primitive exists only at the chat-*event* layer: `npl_chat_events.reply_to_id` (plain INT, no FK — `liquibase/changelogs/changeset-017.enhanced-managers.yaml:70-73`), written by `event_create` (`src/npl_mcp/chat/chat.py:201-229`) and returned by `event_list` (`chat.py:232-274`). The user-facing message model has no parent link at all: `npl_chat_messages` is flat and `Chat.SendMessage` (`src/npl_mcp/launcher.py:1249-1256`) accepts only room/content/author. Critically, the registered MCP tool `Chat.CreateEvent` (`launcher.py:1291-1301`) does **not** expose the internal `reply_to_id` parameter, so an MCP agent cannot create a threaded reply at all today; only the internal function supports it. There is no reply count, no thread-expansion view, and no same-room validation of a parent id (cross-room links are silently accepted). Confidence: high — schema, module, and launcher registrations all read directly; there are no chat tests to contradict this.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Reply stored with parent-message link, renders nested under parent | Partially Met | `npl_chat_events.reply_to_id` + `event_create(reply_to_id=...)` exist (`chat.py:201-229`), but messages are unparented, `Chat.CreateEvent` does not expose `reply_to_id` (`launcher.py:1291-1301`), and no nested/thread render exists |
| Timeline shows reply count; thread expandable in chronological order | Not Met | `message_list` (`chat.py:62-92`) and `event_list` (`chat.py:232-274`) return flat lists; no reply-count aggregation anywhere |
| MCP-posted reply attributed to the persona | Met | `npl_chat_events.persona` NOT NULL (`changeset-017:59-62`); `event_create` requires `persona` (`chat.py:204-218`); `Chat.SendMessage` accepts a `persona` param (`launcher.py:1249-1256`) |
| Reply referencing a parent from a different room is rejected | Not Met | `reply_to_id` has no FK and `event_create` performs no same-room check (`chat.py:201-229`); a cross-room parent id would link silently |

## Gaps / Risks

- Threading is unreachable through the MCP surface: the one parameter that makes a reply a reply is not exposed by `Chat.CreateEvent`.
- `reply_to_id` without an FK or same-room check permits dangling and cross-room thread links (both AC violations and data-integrity risk).
- No test coverage for chat (`tests/` has no chat test file).
- Story depends on US-015 rooms — rooms exist (`Chat.CreateRoom`), so the dependency is satisfied.

## BDD Scenario

```gherkin
Feature: Threaded replies in chat rooms

  Scenario: Agent replies to a specific message
    Given a message exists in a room
    When the agent calls Chat.CreateEvent for that room
    Then the tool signature offers no way to reference the parent message id
    And the reply lands as an unparented top-level event

  Scenario: Operator browses the room timeline
    When Chat.ListMessages is called for the room
    Then every message appears flat with no reply counts
    And no thread expansion is available

  Scenario: Agent replies to a parent event in another room
    Given internal use of event_create with a reply_to_id owned by a different room
    When the reply is inserted
    Then no validation rejects the cross-room link
    And the thread spans two rooms silently
```
