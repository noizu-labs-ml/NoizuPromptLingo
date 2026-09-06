# Review: Create Chat Room for Collaboration

- **Story**: `project-management/user-stories/US-007-create-chat-room.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

`Chat.CreateRoom` (`backend/lib/noizu_prompt_lingua/domains/chat/tools/create_room.ex`) implements the core: required `name`, optional `description` and `session_id`, org+project scoping, and it returns the room `id`, `slug`, and a browser `chatroom_url` (`create_room.ex:40-48` via `MCP.Urls.chat_room_url`, `backend/lib/noizu_prompt_lingua/mcp/urls.ex:72`). Rooms are immediately usable by `Chat.SendMessage` (shared slug/UUID resolver). `ChatRoom` changeset (`backend/lib/noizu_prompt_lingua/schema/chat_room.ex:22-33`) requires `name` and generates a unique slug per (org, project). The main gap: the tool has **no `members` parameter** — the story's "initial members list" criterion is not met at creation time; membership is added post-hoc via `Chat.AddMember` (`chat/tools/add_member.ex`, `chat.ex:557`). Also `name` uses only `validate_required`, so a whitespace-only name passes (no `validate_not_blank` like ChatMessage has). A separate `Chat.CreateDM` path (`chat.ex:235-258`) does handle multi-member creation with member rows. Tests: `backend/test/noizu_prompt_lingua/domains/chat/chat_room_resolve_test.exs`, `chat_test.exs`.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Create room with required `name` | Met | `create_room.ex:13`; `chat_room.ex:26` validate_required(:name) |
| Optional `description` | Met | `create_room.ex:14`; cast in `chat_room.ex:23` |
| Specify initial `members` list | Not Met | `create_room.ex` input has no members field; separate `Chat.AddMember` tool (`chat/tools/add_member.ex`) is the only member-add path |
| Associate room with optional `session_id` | Met | `create_room.ex:16,34`; `chat_room.ex:23` |
| Returns `room_id` for programmatic access | Met | `create_room.ex:41` (binary_id UUID) |
| Returns `web_url` for browser access | Met | `create_room.ex:44` chatroom_url via `mcp/urls.ex:72` |
| Room immediately available for send_message | Met | shared RoomResolver slug/UUID resolution used by SendMessage |
| Create room without session (standalone) | Met | session_id optional; organization required (superset constraint) |
| Name must be non-empty string | Partially Met | validate_required(:name) rejects nil/"" (`chat_room.ex:26`) but whitespace-only names pass — no validate_not_blank |
| Members default empty if not specified | Met | trivially true with no members param; rooms start with zero `chat_members` rows |

## Gaps / Risks

- Initial-members-at-creation is missing; an agent must make one `CreateRoom` call plus N `AddMember` calls — no atomicity between them.
- Whitespace-only room names accepted; also names are not length-capped in the changeset (DB column limit is the only guard).
- Slug collisions per (org, project) surface as changeset errors with a create/retry path (ADR-013 note, `chat_room.ex:30-32`) — documented but caller must retry.

## BDD Scenario

```gherkin
Feature: Create a chat room for collaboration

  Scenario: Agent spins up a room for a redesign discussion
    Given an organization with a project
    When an agent calls Chat.CreateRoom with organization, name="dashboard-redesign",
      description="Redesign discussion", session_id=null
    Then the response contains room id, slug, and a chatroom_url
    And Chat.SendMessage succeeds against that room immediately

  Scenario: Adding members after creation
    Given a room created with no members
    When Chat.AddMember is called for "sarah-designer" and "mike-developer"
    Then Chat.ListMembers returns both personas
    And future mentions notify them per the notification dispatch rules
```
