# PRD: Chat and Sessions

**PRD ID**: PRD-004
**Version**: 1.0
**Status**: Documented
**Documentation Source**: worktrees/main/mcp-server
**Last Updated**: 2026-02-02

## Executive Summary

Combined PRD covering Chat Collaboration (C-04) and Session Management (C-05). Provides multi-persona chat rooms with @mentions, notifications, artifact sharing, and session grouping for organizing related work contexts.

**Implementation Status**: ✅ Complete in mcp-server worktree

## Features Documented

### User Stories Addressed
**Chat**:
- **US-004**: Share artifact in chat room
- **US-005**: View session dashboard
- **US-006**: Send message to chat room
- **US-007**: Create chat room for collaboration
- **US-022**: Receive and manage notifications
- **US-027**: React to chat messages
- **US-028**: Create todo from chat

**Sessions**:
- **US-031**: View agent work logs
- **US-045**: Manage multiple database instances

## Functional Requirements (Chat)

### FR-001: Multi-Persona Chat Rooms (8 tools)
**Tools**: `create_chat_room`, `send_message`, `react_to_message`, `share_artifact`, `create_todo`, `get_chat_feed`, `get_notifications`, `mark_notification_read`
**Test Coverage**: 78%

**create_chat_room**:
```python
room = await create_chat_room(
    name="dashboard-redesign",
    members=["sarah", "mike", "alex"],
    session_id="ses-123"
)
```

**send_message** (auto @mention detection):
```python
await send_message(
    room_id=1,
    persona="sarah",
    message="Hey @mike, check the mockup!"
)
```

## Functional Requirements (Sessions)

### FR-002: Session Grouping (4 tools)
**Tools**: `create_session`, `get_session`, `list_sessions`, `update_session`
**Test Coverage**: 0%

**create_session**:
```python
session = await create_session(
    title="Q4 Planning",
    session_id="q4-2025"  # optional
)
```

## Data Model

**Chat Tables**:
- chat_rooms: id, name, description, session_id, created_at
- room_members: room_id, persona_slug, joined_at (composite PK)
- chat_events: id, room_id, event_type, persona, timestamp, data (JSON), reply_to_id
- notifications: id, persona, event_id, notification_type, read_at, created_at

**Session Tables**:
- sessions: id (TEXT), title, created_at, updated_at, status

## Web Interface

**Routes**:
- GET / - Session listing
- GET /session/{session_id} - Session detail
- GET /session/{sid}/room/{rid} - Chat room in session context
- GET /room/{room_id} - Standalone chat room
- POST /session/{sid}/room/{rid}/message - Post message form

## Dependencies
- **Internal**: Artifacts (C-02), Database (C-01)
- **External**: SQLite, Python re (for @mentions)

## Testing
- **Chat**: 78% coverage (tests/test_basic.py)
- **Sessions**: 0% coverage (implemented, untested)

## Documentation References
- **Category Briefs**: `.tmp/mcp-server/categories/04-chat-collaboration.md`, `.tmp/mcp-server/categories/05-session-management.md`
- **Tool Specs**: `.tmp/mcp-server/tools/by-category/chat-tools.yaml`, `session-tools.yaml`
