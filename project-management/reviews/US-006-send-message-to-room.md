# Review: Send Message to Chat Room

- **Story**: `project-management/user-stories/US-006-send-message-to-room.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Fully implemented on the Elixir backend (the story's "Implementation Status" section cites a legacy `worktrees/main/mcp-server` Python tree that no longer exists — the live surface is `Chat.SendMessage` MCP tool). `backend/lib/noizu_prompt_lingua/domains/chat/tools/send_message.ex:24-48` resolves the room by slug/UUID and posts via `Chat.send_message` (`backend/lib/noizu_prompt_lingua/domains/chat/chat.ex:284-290`), which inserts the message and dispatches notifications. `ChatMessage` changeset (`backend/lib/noizu_prompt_lingua/schema/chat_message.ex:42-56`) enforces required content/sender, max length, and an explicit whitespace-only rejection (`validate_not_blank`, lines 49-56). Mention handling is real: `notifications/dispatch.ex:75` extracts `@handle` mentions (`parse_mentions`, lines 414+, regex `@([A-Za-z0-9_.\-]+)`, with `@everyone` expanding to all members) and creates immediate `mention` notifications for non-muted members. Threading is supported via `parent_id` (`send_message.ex:16,32`; `chat.ex:343-349`). Messages are append-only; the response serializes id/content/sender/created_at (`serialize.ex:10-21`). Tests cover chat flows (`backend/test/noizu_prompt_lingua/domains/chat/chat_test.exs`, `chat_tools_test.exs`).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Send text message to any chat room by room ID | Met | `send_message.ex:9,25` (slug or UUID via RoomResolver) |
| Message attributed to sending persona | Met | `send_message.ex:15` (sender required); `chat_message.ex:42` validate_required(:sender); `serialize.ex:14` |
| Message appears in room's feed immediately | Met | `chat.ex:284-290` insert then `list_messages` (`chat.ex:305-315`) reads same table |
| Returns unique event ID | Met | binary_id UUID; `serialize.ex:12` returns `id` in response |
| @mentions syntax notifies participants | Met | `dispatch.ex:75,414+` mention detection + `kind: "mention"` notifications (lines ~97) |
| Markdown formatting supported | Met | content is free-text markdown, client-rendered (`send_message.ex:14` description); no server transform strips markdown |
| Timestamp captured automatically | Met | `timestamps()` in ChatMessage; `serialize.ex:15` created_at |
| Empty or whitespace-only messages rejected | Met | `chat_message.ex:43` validate_length + explicit `validate_not_blank` (lines 49-56) |

## Gaps / Risks

- `Chat.SendMessage` does not verify the sender is a room member — any persona slug can post (the old story note claimed member verification; not present in the current tool path).
- No server-side rate limiting or per-message length hint surfaced to clients beyond the changeset max.
- Mentions only notify personas that are room members at dispatch time; non-member @handles are silently ignored.

## BDD Scenario

```gherkin
Feature: Send a message to a chat room

  Scenario: Vibe coder posts an update with a mention
    Given a room "design-discussion" exists in the org
      And persona "sarah-designer" is a member
    When an agent calls Chat.SendMessage with room_id="design-discussion",
      sender="vibe-coder", content="Hey @sarah-designer, mockup uploaded"
    Then the response includes a unique message id and created_at timestamp
    And ListMessages on the room returns the message immediately
    And sarah-designer has a "mention" notification for the message

  Scenario: Blank message rejected
    When Chat.SendMessage is called with content="   "
    Then the call fails with a content "can't be blank" validation error
    And no message row is created
```
