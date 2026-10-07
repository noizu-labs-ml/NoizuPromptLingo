# Review: MCP Chat Collaboration Tools

- **Story**: `project-management/user-stories/US-115-mcp-chat-collaboration-tools.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Two implementations exist. Python MCP server (`src/npl_mcp/chat/chat.py`, tools in `src/npl_mcp/launcher.py`): persistent rooms, messages, member lists, events with reactions/todos/artifact-shares, and notification list/mark-read. However, rooms have no visibility controls, `message_create` has no threading (threading exists only on events via `reply_to_id`, chat.py:201-229), `npl_chat_notifications` has no writer anywhere in `src/` (grep finds only SELECT/UPDATE in notification_list/notification_mark_read, chat.py:318-379) so Python-side notifications can never fire, and members have no roles. The Elixir backend (noted: Elixir backend at /Users/keithbrings/Work/Space/Noizu/projects/NoizuPromptLingo/backend) is materially stronger: `Chat.Send` supports markdown + `parent_id` threading (domains/chat/tools/send_message.ex), `Chat.React`, `Chat.Attach` shares artifacts (chat_attach.ex), `Chat.AddMember` carries a member/admin role (add_member.ex:15), and notifications are actually dispatched via `NoizuPromptLingua.Domains.Notifications.Dispatch` (domains/chat/chat.ex:15-17,622). Visibility controls (public/private) are absent in both.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Create persistent chat rooms with visibility controls | Partially Met | Persistent rooms: `room_create` chat.py:28-39; Elixir `Chat.CreateRoom` (domains/chat/tools/create_room.ex, project-scoped). No visibility/public-private field exists in either implementation (grep for "visibility" across both codebases finds nothing) |
| Send messages with markdown and threading support | Met | Content is free-text markdown in both; threading via `parent_id` on Elixir backend `domains/chat/tools/send_message.ex` ("Parent message UUID to thread this reply under"). Python `message_create` (chat.py:95-109) has no reply/thread field — Met via Elixir backend only |
| Add emoji reactions to messages | Met | Python `react_to_event` chat.py:277-285 (reaction events with reply_to_id); Elixir backend `domains/chat/tools/chat_react.ex` |
| Share artifacts in chat rooms with previews | Partially Met | Share is an event carrying only `{"artifact_id", "revision"}` (chat.py:303-315; Elixir `Chat.Attach` chat_attach.ex). No preview generation/rendering found in either codebase |
| Create todos linked to messages and rooms | Partially Met | Python `create_todo` stores a todo as a room event with description/assignee (chat.py:288-300) — room link only, no message link; no todo tool on the Elixir chat surface |
| Receive notifications for mentions and updates | Partially Met | Read/mark-read exist (chat.py:318-379) but nothing in Python writes `npl_chat_notifications` (no INSERT anywhere in src/); Met on the Elixir backend via the notifications dispatch wired into chat.ex:15-17 — mention-level detection not verified |
| Manage role-based access for room members | Partially Met | Elixir backend `Chat.AddMember` supports role member/admin (domains/chat/tools/add_member.ex:15,27); Python `room_add_member` has no role concept (chat.py:150-174) and no access enforcement anywhere |

## Gaps / Risks

- Python notifications are read-only dead code: `Chat.Notifications` will always return an empty list because no code path inserts into `npl_chat_notifications`.
- No visibility controls on rooms in either codebase — any caller can list/join any room by id.
- No enforcement of member roles on the Python side; even on the Elixir backend, role checks inside send/mute/pin paths were not verified.
- Python message model lacks threading — threads only exist on the separate `npl_chat_events` table, so threaded replies are not first-class messages.
- Todo events have no completion toggle tool (created as `completed: false` with no tool to flip state).

## BDD Scenario

```gherkin
Feature: Collaborate through persistent chat rooms

  Scenario: Team coordinates in a room (Python MCP surface)
    Given the MCP server is connected
    When the agent calls ToolCall("Chat.CreateRoom", {"name": "deploy-war-room"})
    Then a persistent room row is created in npl_chat_rooms
    When the agent calls ToolCall("Chat.SendMessage", {"room_id": <id>, "content": "**rolling back**", "author": "team-lead"})
    Then the markdown body is stored verbatim in npl_chat_messages
    When the agent calls ToolCall("Chat.CreateTodo", {"room_id": <id>, "persona": "team-lead", "description": "verify health checks"})
    Then a todo event is created in the room
    When the agent calls ToolCall("Chat.ShareArtifact", {"room_id": <id>, "persona": "team-lead", "artifact_id": 12})
    Then an artifact_share event referencing artifact 12 is created

  Scenario: Threaded replies and notifications (Elixir backend surface)
    Given a room exists on the Elixir backend
    When a persona calls Chat.Send with content markdown and parent_id set to an earlier message UUID
    Then the reply is threaded under the parent message
    And the notifications dispatch is invoked so mentioned/assigned members receive notifications
    When the member list is managed via Chat.AddMember with role "admin"
    Then the member is stored with the admin role
```
