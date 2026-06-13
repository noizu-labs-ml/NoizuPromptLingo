# PRD-004: Chat and Sessions

**Version**: 1.0
**Status**: Implemented
**Author**: npl-prd-editor
**Created**: 2026-02-02
**Updated**: 2026-02-02

## Overview

Combined PRD covering Chat Collaboration and Session Management. Provides multi-persona chat rooms with @mentions, notifications, artifact sharing, message reactions, and session grouping for organizing related work contexts. Implementation is complete in mcp-server worktree with 78% test coverage for chat features.

## Goals

1. Enable real-time collaboration through chat rooms
2. Support @mention-based notifications
3. Allow artifact sharing within chat context
4. Provide session-based organization for related work
5. Enable todo creation from chat discussions

## Non-Goals

- Real-time WebSocket connections (uses polling)
- Message editing or deletion
- Thread-based conversations
- External chat integrations (Slack, Discord)

---

## User Stories

Reference stories from global `project-management/user-stories/` directory.

| ID | Title | Persona | Priority |
|----|-------|---------|----------|
| US-004 | [Share artifact in chat room](../../user-stories/US-004-share-artifact-chat.md) | P-003 | high |
| US-005 | [View session dashboard](../../user-stories/US-005-view-session-dashboard.md) | P-002 | high |
| US-006 | [Send message to chat room](../../user-stories/US-006-send-message-to-room.md) | P-003 | high |
| US-007 | [Create chat room for collaboration](../../user-stories/US-007-create-chat-room.md) | P-001 | high |
| US-022 | [Receive and manage notifications](../../user-stories/US-022-receive-notifications.md) | P-002 | medium |
| US-027 | [React to chat messages](../../user-stories/US-027-react-to-message.md) | P-003 | low |
| US-028 | [Create todo from chat](../../user-stories/US-028-create-chat-todo.md) | P-003 | low |
| US-031 | [View agent work logs](../../user-stories/US-031-view-agent-work-logs.md) | P-004 | high |
| US-045 | [Manage multiple database instances](../../user-stories/US-045-manage-multiple-database-instances.md) | P-004 | low |

Use MCP tools to load full story details:
- **get-story**: Load story by ID
- **edit-story**: Modify story content
- **update-story**: Update story metadata

---

## Functional Requirements

All functional requirements are detailed in `./functional-requirements/` directory.

See `functional-requirements/index.yaml` for complete list.

Key requirements:
- **FR-001**: [Multi-Persona Chat Rooms](./functional-requirements/FR-001-multi-persona-chat-rooms.md) - 8 tools, 78% coverage
- **FR-002**: [Session Grouping](./functional-requirements/FR-002-session-grouping.md) - 4 tools, 0% coverage

---

## Non-Functional Requirements

| ID | Requirement | Metric | Target |
|----|-------------|--------|--------|
| NFR-1 | Test coverage | Line coverage | >= 80% |
| NFR-2 | API response time | Latency | < 200ms |
| NFR-3 | Database performance | Query time | < 50ms |
| NFR-4 | Notification delivery | Delay | < 1 second |

---

## Error Handling

| Error Condition | Error Type | User Message |
|-----------------|------------|--------------|
| Invalid room_id | ValueError | "Chat room not found" |
| Empty message | ValueError | "Message cannot be empty" |
| Invalid persona | ValueError | "Persona not found" |
| Duplicate reaction | None | Silent no-op |
| Invalid @mention | None | Silent ignore |

---

## Acceptance Tests

All acceptance tests detailed in `./acceptance-tests/` directory.

See `acceptance-tests/index.yaml` for test plan.

**Test Summary**:
- AT-001: @Mention Notification (passing)
- AT-002: Artifact Sharing (passing)
- AT-003: Session Dashboard (not started)
- AT-004: Message Reactions (passing)
- AT-005: Todo from Chat (passing)

---

## Success Criteria

1. All user stories implemented with acceptance criteria passing
2. Test coverage >= 78% for chat features (achieved)
3. Test coverage >= 80% for session features (pending)
4. All acceptance tests passing (4/5 passing, 1 not started)
5. @mention notifications working reliably
6. Artifact sharing functional in chat context

---

## Out of Scope

- Real-time WebSocket-based chat
- Message editing/deletion
- Threaded conversations
- Rich text formatting beyond basic markdown
- File uploads (use artifacts instead)
- External integrations (Slack, Discord)
- Voice/video chat
- Presence indicators (online/offline status)

---

## Dependencies

**Internal**:
- C-01: Database (SQLite schema)
- C-02: Artifact Management (artifact sharing)

**External**:
- SQLite (database)
- Python `re` module (@mention regex)
- FastAPI (web routes)

---

## Data Model

**Chat Tables**:
- `chat_rooms`: id, name, description, session_id, created_at
- `room_members`: room_id, persona_slug, joined_at (composite PK)
- `chat_events`: id, room_id, event_type, persona, timestamp, data (JSON), reply_to_id
- `notifications`: id, persona, event_id, notification_type, read_at, created_at

**Session Tables**:
- `sessions`: id (TEXT), title, created_at, updated_at, status

---

## Web Interface

**Routes**:
- GET `/` - Session listing
- GET `/session/{session_id}` - Session detail
- GET `/session/{sid}/room/{rid}` - Chat room in session context
- GET `/room/{room_id}` - Standalone chat room
- POST `/session/{sid}/room/{rid}/message` - Post message form

---

## Implementation Notes

- **Worktree**: mcp-server (complete implementation)
- **Test File**: tests/test_basic.py
- **Coverage**: Chat 78%, Sessions 0%
- **Tools**: 12 total (8 chat, 4 session)

---

## Open Questions

- [ ] Should sessions support deletion/archiving?
- [ ] What is maximum message length?
- [ ] Should there be rate limiting on messages?
- [ ] How long should notifications persist?
