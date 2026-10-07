# Review: Pin an important message in a room

- **Story**: `project-management/user-stories/US-017-pin-important-message-in-room.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No pin functionality exists in the codebase. The chat surface (`src/npl_mcp/chat/chat.py`, registered as `Chat.*` tools in `src/npl_mcp/launcher.py:1200-1390`) provides rooms, members, flat messages, events with reactions/todos/artifact-shares, and notifications — there is no pin/unpin action, no pinned-messages storage (nothing in `npl_chat_rooms`, `npl_chat_events`, or `npl_chat_messages` schema in `liquibase/changelogs/changeset-013.chat-tables.yaml` / `changeset-017.enhanced-managers.yaml`), no pinned panel, and no permission model whatsoever (any caller can send to any room; no moderator role exists). Confidence: high — full module read plus schema changelogs and tool registrations checked; grep for "pin" across `src/npl_mcp/` hits nothing relevant.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Pinning adds message to room's pinned list with persistent pinned panel for all members | Not Met | no pin action or pinned storage anywhere in `chat.py` or chat DDL; no evidence found |
| Multiple pins ordered most-recent-first; clear error on pin limit | Not Met | no pin list or limit logic exists |
| Unpin removes from list but keeps message in timeline | Not Met | no unpin action exists |
| Non-moderator pin attempts rejected with permissions error | Not Met | no permission model at all — rooms have members (`room_add_member`, `chat.py:150-174`) but no roles/permissions checks |

## Gaps / Risks

- Whole feature absent: schema, data layer, MCP tools, and UI all missing.
- Prerequisite messaging (US-015/US-016 rooms + messages) exists, so the only blocker is the pin feature itself.
- When implemented, a room-permission/moderator model must be designed first — it does not exist today and this AC depends on it.
- No test coverage for chat generally; pin tests would be net-new.

## BDD Scenario

```gherkin
Feature: Pinning messages in a room

  Scenario: Lead pins a key decision message
    Given a message exists in a room
    When Priya attempts to pin it via any MCP tool
    Then no pin action exists to call
    And the message cannot be surfaced persistently

  Scenario: Member without moderator rights tries to pin
    Given no permission model exists for rooms
    When any member sends any chat operation
    Then it is accepted without any permissions check
    And the story's rejection behavior cannot occur
```
