# User Story: Send Message to Chat Room

**ID**: US-006
**Persona**: P-003 (Vibe Coder)
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a **vibe coder**,
I want to **send a quick message to a chat room**,
So that **I can communicate updates, questions, or ideas to my team without formal documentation**.

## Acceptance Criteria

- [ ] Can send text message to any chat room by room ID
- [ ] Message attributed to sending persona (agent or user)
- [ ] Message appears in room's chat feed immediately
- [ ] Returns unique event ID for message tracking (enables reactions, threading)
- [ ] Supports @mentions syntax to notify specific participants
- [ ] Messages support markdown formatting (code blocks, links, emphasis)
- [ ] Message timestamp captured automatically
- [ ] Empty or whitespace-only messages rejected

## Notes

- This is the primary communication channel for informal updates and collaboration
- Should be fast - minimal overhead, immediate delivery
- Event ID enables future features: reactions (US-027), threading, message editing
- Markdown rendering happens client-side for performance
- Messages are append-only (immutable once sent)

## Dependencies

- US-007: Chat room must exist before messages can be sent

## Open Questions

- Should @mentions trigger notifications automatically? (Likely yes, see US-022)
- Maximum message length limit? (Suggest 10,000 characters for chat messages)
- Should message delivery be confirmed with acknowledgment?
- Rate limiting to prevent spam?

## Implementation Status

**Status**: ✅ Implemented in mcp-server worktree

### MCP Tools
- `send_message(room_id, persona, message, reply_to_id)` - Send message with @mention detection
- `get_chat_feed(room_id, since, limit)` - Retrieve message feed
- `get_notifications(persona, unread_only)` - View notifications from @mentions
- `mark_notification_read(notification_id)` - Mark notification as read

### Database Tables
- `chat_events` - Event stream (messages, reactions, shares, todos)
- `notifications` - @mention notifications (persona, event_id, notification_type, read_at)
- `room_members` - Member verification for posting

### Web Routes
- `GET /room/{room_id}` - Chat room UI
- `GET /session/{session_id}/room/{room_id}` - Room in session
- `GET /api/room/{id}/feed` - Feed API

### Source Files
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/chat/rooms.py` (lines 80-142)
- Database: `worktrees/main/mcp-server/src/npl_mcp/storage/schema.sql`
- Tests: `worktrees/main/mcp-server/tests/test_basic.py` (test_chat_workflow)

### Test Coverage
78% (chat system module)

### Example Usage
```python
# Send message with @mention
message = await send_message(
    room_id=1,
    persona="sarah-designer",
    message="Hey @mike-developer, I've uploaded the latest mockup."
)
# Returns: {"event_id": 1, "mentions": ["mike-developer"], "notifications": [...]}
```

### Features Implemented
- ✅ @mention detection (regex `@([a-zA-Z0-9_-]+)`)
- ✅ Automatic notification creation for mentions
- ✅ Threaded replies via `reply_to_id`
- ✅ Persona verification (must be room member)
- ✅ Markdown support (client-side rendering)

### Documentation
- Category Brief: `.tmp/mcp-server/categories/04-chat-collaboration.md`
- README: `worktrees/main/mcp-server/README.md`
- USAGE: `worktrees/main/mcp-server/USAGE.md`

## Related Commands

- `send_message` (Chat Tools) - Primary command for this story
- `get_chat_feed` (Chat Tools) - View messages after sending
- `react_to_message` (Chat Tools) - Interact with sent messages (US-027)
