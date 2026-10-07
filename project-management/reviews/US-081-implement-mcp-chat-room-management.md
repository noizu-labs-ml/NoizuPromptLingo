# Review: Implement MCP Chat Room Management Tools

- **Story**: `project-management/user-stories/US-081-implement-mcp-chat-room-management.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented in the Python repo across `src/npl_mcp/chat/chat.py` and MCP registrations in `src/npl_mcp/launcher.py:1190-1390`. Present: `Chat.CreateRoom` (name + description), `Chat.ListRooms` (limit only — no filters), `Chat.GetRoom` (metadata + message count + last activity), `Chat.AddMember`/`Chat.ListMembers`, plus messaging/events/notifications tools. Missing: `join_room` (AddMember has no password/token auth), `room_info` access-control view, `update_room` (no settings/member-permission management), `delete_room` (no removal or history archival anywhere in `chat.py`), and any notion of privacy settings. Role-based access control (owner/moderator/member/viewer) does not exist — members are flat `persona_slug` rows (`chat.py:150-174`) with no role column or check. Confidence: high; the gaps are structural (schema has no fields to support them), not just missing wrappers.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `create_room` with name, description, privacy settings | Partially Met | `src/npl_mcp/chat/chat.py:28-39` (name + description only); no privacy field in schema or tool (`src/npl_mcp/launcher.py:1201-1210`) |
| `join_room` with optional password/token auth | Partially Met | `Chat.AddMember` adds a persona with no auth (`chat.py:150-174`); no password/token parameter anywhere |
| `list_rooms` with filtering options | Partially Met | `chat.py:9-25` supports only `limit`; no name/status/member filters |
| `room_info` returns metadata, members, access control info | Partially Met | `Chat.GetRoom` returns metadata + counts (`chat.py:42-59`); members are a separate `Chat.ListMembers` call (`chat.py:177-198`); no access-control info exists to return |
| `update_room` manages settings and member permissions | Not Met | no update function in `chat.py`; no settings or permission columns |
| `delete_room` removes room and archives chat history | Not Met | no delete/archive function found in `chat.py` or launcher registrations |
| Role-based access control (owner, moderator, member, viewer) | Not Met | `npl_chat_room_members` holds persona_slug + joined_at only (`chat.py:155-158`); no role concept in schema, tools, or enforcement |

## Gaps / Risks

- Any member can add any persona to any room and read any room's messages — with no ACL layer, room "privacy" is currently honor-system (relevant given the story's compliance/audit note).
- No room deletion also means no cleanup path; orphaned rooms accumulate.
- Story mentions audit logging; chat events exist (`chat.py:201-229`) but room *administration* actions are not logged.

## BDD Scenario

```gherkin
Feature: Chat room management via MCP
  Scenario: Agent creates and lists rooms (works today)
    When the agent calls Chat.CreateRoom with name "sprint-42" and description
    Then the room is created and appears in Chat.ListRooms with message_count and last_activity
  Scenario: Agent joins a room
    When the agent calls Chat.AddMember with room_id and persona_slug
    Then the persona becomes a member — but no password/token is requested or checked (gap)
  Scenario: Owner updates room privacy
    When an owner attempts to set the room to private and assign a moderator
    Then no such operation exists today (gap)
  Scenario: Owner deletes a room
    When a room is deleted
    Then no delete tool exists today; history is never archived (gap)
```
