# Review: Mute a room or mute unless mentioned

- **Story**: `project-management/user-stories/US-019-mute-room-or-mute-unless-mentioned.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No mute functionality exists. The chat surface (`src/npl_mcp/chat/chat.py`, `Chat.*` tools in `src/npl_mcp/launcher.py:1200-1390`) has no per-persona room preference/mute mode, no mute indicator on room listings (`room_list`, `chat.py:9-25` returns no per-member settings), and no @-mention detection anywhere (message/event content is plain text + JSONB `data`; nothing parses mentions). The notification half is only a scaffold: `npl_chat_notifications` exists with readers `Chat.Notifications` / `Chat.ReadNotification` (`launcher.py:1363-1390`, `chat.py:318-379`), but **nothing in `src/` ever writes a notification** (no `INSERT INTO npl_chat_notifications`), so suppression logic has nothing to suppress. Grep for "mute" across `src/npl_mcp/` finds no relevant code. Confidence: high — full chat module, tool registrations, and schema changelogs reviewed.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Fully muted room generates no notifications until unmuted | Not Met | no mute setting or storage exists; moreover no notifications are generated at all (no writer to `npl_chat_notifications`) |
| Mute-unless-mentioned: no notification without @-mention; mention fires normally | Not Met | no mention detection in any code path; no per-persona mode logic; no evidence found |
| Muted room still shows full unfiltered history | Not Met | trivially unobservable — `message_list` is unfiltered, but there is no mute state to interact with |
| Mute setting persists and shows in room-list indicator | Not Met | `room_list`/`room_get` DTOs (`chat.py:112-132`) carry no per-member mute fields; no persistence of preferences |

## Gaps / Risks

- Two-layer blocker: the mute *preference* (per-persona room settings) and the *notification production* (nothing writes `npl_chat_notifications`) are both absent; implementing mute alone would be unobservable.
- US-021's "receive and clear" flow depends on this story's suppression logic per the story notes — the whole notification epic is currently scaffolding only.
- `npl_chat_room_members` (`changeset-017.enhanced-managers.yaml:11-45`) is the natural home for a `mute_mode` column; schema change required.

## BDD Scenario

```gherkin
Feature: Mute notification volume from a room

  Scenario: Operator fully mutes a noisy room
    Given Jordan is a member of a room
    When he attempts to set the room to muted
    Then no mute parameter exists on any Chat tool
    And his preference cannot be stored

  Scenario: A message mentions Jordan in a mute-unless-mentioned room
    Given no mention parsing exists in message handling
    When any message is posted to the room
    Then no notification is generated for anyone regardless of mute mode

  Scenario: Operator reloads the room list after changing mute settings
    When Chat rooms are listed
    Then no mute indicator field exists in the room DTO
    And the setting cannot persist because it cannot be set
```
