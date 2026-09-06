# Review: React to Chat Messages

- **Story**: `project-management/user-stories/US-027-react-to-message.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

A real `react_to_event` implementation exists at `src/npl_mcp/chat/chat.py:277`, exposed both as an MCP tool (`chat_react`, `src/npl_mcp/launcher.py:1318`) and an HTTP route (`POST /chat/rooms/{room_id}/events/{event_id}/react`, `src/npl_mcp/api/router.py:2814`). It writes a `reaction`-type event carrying `emoji` and `target_event_id` with `reply_to_id` set, and reactions appear in the feed via `event_list` (`src/npl_mcp/chat/chat.py:232`). However, there is no idempotency (re-reacting duplicates), no `remove_reaction` anywhere in `src/`, and invalid event IDs do not return NOT_FOUND — `_event_room_id` (`chat.py:382`) returns `0`, causing a raw FK/insert failure instead of a clean error. No test coverage exists (`grep` for `react_to_event` in `tests/` finds nothing).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Add emoji reaction to any message by event ID | Met | `src/npl_mcp/chat/chat.py:277-285` |
| Reaction attributed to persona | Met | `persona` column written by `event_create` (`chat.py:196-219`) |
| Reaction appears in feed with event type "reaction" | Met | `chat.py:281`; returned by `event_list` (`chat.py:232`) |
| Multiple reactions per message supported | Met | Each reaction is an independent row; nothing prevents many per target |
| Same persona can add multiple different emojis | Met | No uniqueness constraint on (persona, target) |
| Same persona + same emoji is idempotent | Not Met | No dedupe check in `react_to_event`; no unique index evidence found |
| Common emojis (👍 👎 ❤️ 👀 🎉 ✅ ❌) work reliably | Met | Emoji stored as text in jsonb `data`; any Unicode passes through |
| Event includes event_id, persona, emoji, target_event_id | Met | `chat.py:282-283` plus returned `event_id`/`persona` (`chat.py:214-219`) |
| Invalid event IDs return NOT_FOUND error | Not Met | `_event_room_id` returns `0` on miss (`chat.py:382-384`); caller gets insert failure, not NOT_FOUND |
| Reactions removable by same persona | Not Met | No `remove_reaction` in `src/` (grep confirms zero hits) |

## Gaps / Risks

- No idempotency or uniqueness on (persona, emoji, target_event_id) — duplicate reactions accumulate.
- Invalid event ID path is a correctness bug: room_id=0 insert either violates FK (unhandled exception → 503) or succeeds against a non-existent room depending on schema constraints.
- No removal path; story explicitly lists it as MVP acceptance, not future enhancement.
- No tests for reactions at all.

## BDD Scenario

```gherkin
Feature: React to chat messages

  Scenario: React to a message with 👍
    Given a chat room exists with message event 101 by persona "alice"
    When persona "bob" calls react_to_message with event_id 101 and emoji "👍"
    Then a new chat event of type "reaction" is created with emoji "👍" and target_event_id 101
    And the reaction is attributed to persona "bob"
    And the reaction appears when the room feed is listed

  Scenario: Duplicate reaction is not idempotent today
    Given persona "bob" already reacted 👍 to event 101
    When persona "bob" reacts 👍 to event 101 again
    Then a second duplicate reaction event is created (no dedupe exists)

  Scenario: Invalid event ID fails ungracefully
    When persona "bob" reacts to event_id 999999 which does not exist
    Then the lookup returns room_id 0 and the insert fails with a raw database error
    And no clean NOT_FOUND error is returned
```
