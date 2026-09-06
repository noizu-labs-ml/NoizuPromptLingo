# Review: Implement Chat Room Role-Based Access

- **Story**: `project-management/user-stories/US-069-implement-chat-room-role-based-access.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Elixir backend chat domain has a membership role field, but only two values: `ChatMember.role` with `validate_inclusion(:role, ~w(member admin))` (`backend/lib/noizu_prompt_lingua/schema/chat_member.ex:11,23`), settable via `Chat.AddMember` (`domains/chat/tools/add_member.ex:15,27`). There is no `owner`, `contributor`, or `observer` role, and — critically — the write-path tools do not check roles: `Chat.SendMessage` (`domains/chat/tools/send_message.ex:21-56`) resolves the room and posts without consulting membership or role, and `delete_room`/`create_event`/react paths likewise show no role gating. Platform-level `ToolGuard` authz (`mcp/tool_guard.ex`) gates calls by key identity/scope, not by chat role. The Python repo's chat module (`src/npl_mcp/chat/chat.py`) has no role concept at all. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Rooms support roles: owner, admin, contributor, observer | Not Met | only `member` and `admin` exist — `backend/lib/noizu_prompt_lingua/schema/chat_member.ex:23` |
| Owners can assign/revoke roles and delete rooms | Partially Met | roles can be assigned at add time (`domains/chat/tools/add_member.ex:27`); `Chat.DeleteRoom` exists (`domains/chat/tools/delete_room.ex`) but has no ownership check; no role-revoke tool found (no evidence found for revoke) |
| Admins can manage members and moderate content | Partially Met | `add_member` accepts `admin` role but no code distinguishes admin vs member capability anywhere in the tool layer (grep across `domains/chat/tools/` finds role only in add_member) |
| Contributors can send messages and react | Partially Met | any caller passing tool-level authz can send/react — `send_message.ex:26` takes `sender` as a plain string arg with no membership/role validation |
| Observers can read but not post | Not Met | no observer role and no post-blocking path |
| MCP tools enforce role checks before send_message, share_artifact, create_todo | Not Met | `send_message.ex`, `create_event.ex`, `chat_attach.ex` contain no role or membership checks (verified by reading call bodies) |

## Gaps / Risks

- Security-relevant: `sender` is caller-asserted in `Chat.SendMessage` — combined with no role checks, any authenticated key can post as any persona. This overlaps US-068/US-070 concerns.
- Python MCP chat (`src/npl_mcp/chat/chat.py:150` `room_add_member`) also lacks a role parameter entirely — parity gap if the Python server is still a supported surface.
- Story's "UI updates" item (role badges) has no corresponding frontend evidence checked in this review.

## BDD Scenario

```gherkin
Feature: Chat room role-based access

  Scenario: Admin adds a member (exists today)
    Given a room and an admin persona
    When Chat.AddMember is called with role="admin"
    Then the membership row is stored with role "admin" (chat_member.ex validate_inclusion member|admin)

  Scenario: Observer blocked from posting (NOT YET POSSIBLE)
    Given an observer-role member in a room
    When they call Chat.SendMessage
    Then the call is not blocked — no observer role exists and SendMessage performs no role check

  Scenario: Role check before create_todo/share_artifact (NOT YET POSSIBLE)
    When any authenticated caller invokes Chat.CreateEvent or Chat.ShareArtifact
    Then no membership or role verification runs before the write
```
