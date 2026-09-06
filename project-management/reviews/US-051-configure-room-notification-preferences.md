# Review: Configure Notification Preferences for a Room

- **Story**: `project-management/user-stories/US-051-configure-room-notification-preferences.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented in the Elixir backend. Per-room, per-persona mute preferences are set via the `Chat.MuteRoom` MCP tool (`backend/lib/noizu_prompt_lingua/domains/chat/tools/mute_room.ex:1-60`), exposing both `muted` (silence all) and `mute_unless_mentioned`; `Chat.mute_room/3` upserts the membership row and persists both flags (`backend/lib/noizu_prompt_lingua/domains/chat/chat.ex:575-584`, creating membership if absent). Delivery honors the flags at dispatch time: `Notifications.Dispatch` skips muted members entirely and delivers to `mute_unless_mentioned` members only when the message mentions them (`backend/lib/noizu_prompt_lingua/domains/notifications/dispatch.ex:56-117`, predicates at `:469-470`); mention-path sends skip muted members (`:77-85`). Because preferences live on the persisted membership row, they survive reloads and new sessions. The VFS chat surface also round-trips the flags (`backend/lib/noizu_prompt_lingua/mcp/vfs/chat.ex:774-775, 1357-1358`). Note the story's UI framing ("room's settings panel") maps to an MCP tool + VFS flags today, not a web settings panel.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Muting a room stops alerts for it; other rooms unaffected | Met | `Chat.MuteRoom` sets per-room `muted` (`mute_room.ex:16,37-42`); dispatch skips muted members per-room (`dispatch.ex:85,114`) — flags are per membership row, so other rooms are untouched |
| "Mentions only": non-mention messages generate nothing; mentions do | Met | `mute_unless_mentioned` honored in dispatch (`dispatch.ex:60,117,470`); mention-path immediate delivery bypasses the flag (`:77-85`) |
| Preferences persist across reloads and new sessions | Met | flags persisted on the chat membership record via `Chat.mute_room/3` (`chat.ex:578-584`) and read back in VFS member JSON (`vfs/chat.ex:1357-1358`) |

## Gaps / Risks

- No REST/web settings-panel endpoint was found — configuration is via the MCP tool (`Chat.MuteRoom`, hidden from generic listings, `mute_room.ex:4`) or VFS flags. If the story intends a GUI panel, that surface does not exist yet.
- Delivery semantics verified by reading dispatch code; no dedicated test file for mute behavior was located in `backend/test/`.

## BDD Scenario

```gherkin
Feature: Per-room notification preferences

  Scenario: Mute a room
    Given Jordan is a member of a busy room and a quiet room
    When he calls Chat.MuteRoom with muted=true for the busy room
    Then notifications from the busy room stop
    And the quiet room's notifications are unaffected

  Scenario: Mentions-only room
    Given the room is set to mute_unless_mentioned for Jordan
    When a member posts without @-mentioning him
    Then no notification is generated
    When a member posts @-mentioning him
    Then a notification is generated immediately

  Scenario: Persistence
    Given customized mute settings across several rooms
    When Jordan reconnects in a new session
    Then the membership rows still carry his flags and dispatch applies them identically
```
