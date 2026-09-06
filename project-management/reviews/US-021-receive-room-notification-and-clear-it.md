# Review: Receive Room Notification and Clear It

- **Story**: `project-management/user-stories/US-021-receive-room-notification-and-clear-it.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented in the Elixir backend (per the dual-codebase guidance; Python `src/npl_mcp/chat/` is read-side only). Posting a chat message dispatches notifications: `dispatch_chat_message/1` is wired at `backend/lib/noizu_prompt_lingua/domains/chat/chat.ex:287` into `Notifications.Dispatch.chat_message/2` (`backend/lib/noizu_prompt_lingua/domains/notifications/dispatch.ex:65`), which creates structured per-recipient notifications for mentions (immediate), watchers, and thread replies, with `muted` recipients skipped and `chat_digest` senders coalesced on a 5-minute `dedup_key` upsert. The notification domain (`backend/lib/noizu_prompt_lingua/domains/notifications/notifications.ex`) supports get/poll (PubSub long-poll, rate-limited), `mark_read`/`mark_seen`/`ack` with ids or `:all` (`:308-320`), and kind filtering. On the Python MCP side, `chat.py` exposes `notification_list` (`src/npl_mcp/chat/chat.py:318`, with `unread_only` and structured room_id/event data) and `notification_mark_read` (`:363`), giving agents a surface to receive and clear room notifications. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Posting a room message generates notifications for members | Met | `chat.ex:287` → `dispatch.ex:65` (watchers/mentions/thread replies) |
| Muted members do not get pinged | Met | mute gating in `dispatch.ex` (muted skipped; mute_unless_mentioned) |
| Agent can list unread notifications with room context | Met | `notifications.ex` get/poll + kind filters; Python read side `chat.py:318` |
| Agent can mark one (and all) read | Met | `notifications.ex:308-320` (ids or `:all`); `chat.py:363` mark_read |
| Digest coalescing avoids ping storms | Met | `chat_digest` 5-min coalesced upsert on `dedup_key chat_digest:<room_id>` (`dispatch.ex:65`) |

## Gaps / Risks

- Python-side surface is read-only; creation/generation lives exclusively in the Elixir backend — fine architecturally, but the Python chat module cannot originate notifications (see US-026 task-message gap).
- `ack` and `mark_read` are distinct operations; confirm the frontend/agent flows use the intended one to avoid "cleared but not acked" states.

## BDD Scenario

```gherkin
Feature: Receive and clear a room notification
  Scenario: Mentioned agent gets pinged, then clears it
    Given two agents in a chat room, one mentioned in a new message
    When the message is posted
    Then a structured notification for the mention is created for the mentioned agent
    And the muted third member receives nothing
    When the mentioned agent lists unread notifications
    Then the notification appears with room_id and event payload
    When it calls notification_mark_read
    Then the notification no longer appears as unread
```
