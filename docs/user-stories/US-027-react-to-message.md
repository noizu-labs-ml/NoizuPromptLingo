# User Story: React to Chat Messages

**ID**: US-027
**Persona**: P-003 (Vibe Coder)
**Priority**: Low
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a **vibe coder**,
I want to **add emoji reactions to chat messages**,
So that **I can acknowledge messages quickly without writing a reply**.

## Acceptance Criteria

- [ ] Can add emoji reaction to any message by event ID
- [ ] Reaction attributed to persona (agent or user)
- [ ] Reaction appears in chat feed with event type "reaction"
- [ ] Multiple reactions per message supported (many personas, many emoji types)
- [ ] Same persona can add multiple different emojis to same message
- [ ] Same persona adding same emoji twice is idempotent (no duplicate)
- [ ] Common emojis work reliably (👍 👎 ❤️ 👀 🎉 ✅ ❌)
- [ ] Reaction event includes: event_id, persona, emoji, target event_id
- [ ] Invalid event IDs return error (NOT_FOUND)
- [ ] Reactions can be removed by same persona who added them

## Notes

- Quick acknowledgment reduces message noise
- Common use cases:
  - 👍 for agreement or approval
  - 👀 for "looking into it" or acknowledging reading
  - ❤️ for appreciation or emphasis
  - 🎉 for celebrating completion or good news
  - ✅ for confirmation or marking as resolved
  - ❌ for disagreement or marking as invalid
- Reaction counts aggregated by emoji type for display
- Supports any valid Unicode emoji character
- Reactions are lightweight events (no notifications by default)

## Dependencies

- US-006: Send Message to Chat Room (messages must exist before reactions)
- US-007: Create Chat Room for Collaboration (chat rooms must exist)

## Technical Details

### Request Format
```json
{
  "event_id": 101,
  "persona": "bob",
  "emoji": "👍"
}
```

### Response Format
```json
{
  "status": "ok",
  "result": {
    "event_id": 102,
    "type": "reaction",
    "persona": "bob",
    "emoji": "👍",
    "target_event_id": 101
  }
}
```

### Removing Reactions
To remove a reaction, call `remove_reaction` with same event_id and emoji (future enhancement, not in MVP).

### Notification Behavior
- Reactions do NOT trigger notifications by default (low-noise design)
- Future enhancement: optional notification settings per user preference

## Related Commands

- `react_to_message` (Chat Tools) - Add emoji reaction to message
- `get_chat_feed` (Chat Tools) - View messages and reactions in feed
- `send_message` (Chat Tools) - Create messages that can be reacted to
