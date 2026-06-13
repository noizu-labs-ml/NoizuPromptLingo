# Category: Chat and Collaboration

**Category ID**: C-04
**Tool Count**: 8
**Status**: Documented
**Source**: worktrees/main/mcp-server
**Documentation Source Date**: 2026-02-02

## Overview

The Chat and Collaboration category provides a comprehensive multi-persona collaboration system enabling real-time communication, artifact sharing, task coordination, and notification management. This system supports team-based workflows where multiple AI personas or users can collaborate in organized chat rooms with @mention notifications, emoji reactions, artifact sharing, and todo tracking.

The chat system is built on an event-driven architecture where all interactions (messages, reactions, artifact shares, todos) are stored as events in a chronological feed. Notifications are automatically generated for @mentions and task assignments, creating a seamless collaboration experience similar to Slack or Discord but optimized for AI-assisted workflows.

## Features Implemented

### Feature 1: Multi-Persona Chat Rooms
**Description**: Create and manage chat rooms where multiple personas can collaborate, send messages, and track conversations.

**MCP Tools**:
- `create_chat_room(name, members, description, session_id, session_title)` - Create a new chat room with specified members
- `send_message(room_id, persona, message, reply_to_id)` - Send a message with automatic @mention detection
- `get_chat_feed(room_id, since, limit)` - Retrieve chronological event stream

**Database Tables**:
- `chat_rooms` - Room registry with name, description, session association
- `room_members` - Persona membership tracking with join timestamps
- `chat_events` - Event stream for all room activity (messages, reactions, shares, todos)

**Web Routes**:
- `GET /room/{room_id}` - Standalone chat room view
- `GET /session/{session_id}/room/{room_id}` - Chat room in session context
- `GET /api/room/{id}/feed` - Get chat room feed via API

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/chat/rooms.py`
- Database: `worktrees/main/mcp-server/src/npl_mcp/storage/schema.sql` (lines 62-90)
- Tests: `worktrees/main/mcp-server/tests/test_basic.py` (test_chat_workflow, test_artifact_sharing_in_chat)

**Test Coverage**: 78%

**Example Usage**:
```python
# Create a chat room
room = await create_chat_room(
    name="dashboard-redesign",
    members=["sarah-designer", "mike-developer", "alex-pm"],
    description="Discussion for dashboard redesign project"
)
# Returns: {"room_id": 1, "name": "dashboard-redesign", "members": [...]}

# Send message with @mention
message = await send_message(
    room_id=1,
    persona="sarah-designer",
    message="Hey @mike-developer, I've uploaded the latest mockup."
)
# Returns: {"event_id": 1, "mentions": ["mike-developer"], "notifications": [...]}

# Get chat feed
feed = await get_chat_feed(room_id=1, limit=50)
# Returns: [{"event_type": "message", "persona": "sarah-designer", ...}, ...]
```

### Feature 2: @Mention Notifications
**Description**: Automatic notification system that detects @mentions in messages and creates notifications for mentioned personas.

**MCP Tools**:
- `send_message(room_id, persona, message, reply_to_id)` - Automatically extracts @mentions and creates notifications
- `get_notifications(persona, unread_only)` - Retrieve notifications for a persona
- `mark_notification_read(notification_id)` - Mark notification as read

**Database Tables**:
- `notifications` - Notification registry with persona, event reference, type, read status

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/chat/rooms.py` (lines 80-142, 371-435)
- Database: `worktrees/main/mcp-server/src/npl_mcp/storage/schema.sql` (lines 92-101)
- Tests: `worktrees/main/mcp-server/tests/test_basic.py` (test_chat_workflow)

**Test Coverage**: 78%

**Example Usage**:
```python
# Send message creates notifications automatically
message = await send_message(
    room_id=1,
    persona="alice",
    message="Hey @bob, check the new mockup!"
)
# bob gets automatic notification

# Check notifications
notifications = await get_notifications(
    persona="bob",
    unread_only=True
)
# Returns: [{"notification_id": 1, "notification_type": "mention", ...}]

# Mark as read
await mark_notification_read(notification_id=1)
```

### Feature 3: Emoji Reactions
**Description**: Add emoji reactions to any chat event (messages, artifact shares, todos) for lightweight feedback.

**MCP Tools**:
- `react_to_message(event_id, persona, emoji)` - Add emoji reaction to an event

**Database Tables**:
- `chat_events` - Stores reaction events with emoji in data field

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/chat/rooms.py` (lines 144-190)
- Tests: Not yet tested (implemented but untested)

**Test Coverage**: 0% (implemented, untested)

**Example Usage**:
```python
# React to a message
reaction = await react_to_message(
    event_id=1,
    persona="alex-pm",
    emoji="👍"
)
# Returns: {"event_id": 2, "emoji": "👍", "target_event_id": 1}
```

### Feature 4: Artifact Sharing
**Description**: Share artifacts directly in chat rooms with optional revision specification.

**MCP Tools**:
- `share_artifact(room_id, persona, artifact_id, revision)` - Share artifact in chat

**Database Tables**:
- `chat_events` - Stores artifact_share events with artifact details

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/chat/rooms.py` (lines 192-253)
- Tests: `worktrees/main/mcp-server/tests/test_basic.py` (test_artifact_sharing_in_chat)

**Test Coverage**: 78%

**Example Usage**:
```python
# Share an artifact
share = await share_artifact(
    room_id=1,
    persona="mike-developer",
    artifact_id=1,
    revision=1
)
# Returns: {"event_id": 3, "artifact_id": 1, "revision_num": 1}
```

### Feature 5: Shared Todo Items
**Description**: Create shared todo items in chat rooms with optional assignment to specific personas.

**MCP Tools**:
- `create_todo(room_id, persona, description, assigned_to)` - Create shared todo

**Database Tables**:
- `chat_events` - Stores todo_create events with description and assignment

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/chat/rooms.py` (lines 255-310)
- Tests: `worktrees/main/mcp-server/tests/test_basic.py` (test_todo_creation)

**Test Coverage**: 78%

**Example Usage**:
```python
# Create a todo
todo = await create_todo(
    room_id=1,
    persona="alex-pm",
    description="Update API documentation",
    assigned_to="mike-developer"
)
# Returns: {"event_id": 4, "description": "Update API documentation", "assigned_to": "mike-developer"}
```

## MCP Tools Reference

### Tool Signatures

```python
create_chat_room(
    name: str,
    members: List[str],
    description: Optional[str] = None,
    session_id: Optional[str] = None,
    session_title: Optional[str] = None
) -> dict

send_message(
    room_id: int,
    persona: str,
    message: str,
    reply_to_id: Optional[int] = None
) -> dict

react_to_message(
    event_id: int,
    persona: str,
    emoji: str
) -> dict

share_artifact(
    room_id: int,
    persona: str,
    artifact_id: int,
    revision: Optional[int] = None
) -> dict

create_todo(
    room_id: int,
    persona: str,
    description: str,
    assigned_to: Optional[str] = None
) -> dict

get_chat_feed(
    room_id: int,
    since: Optional[str] = None,
    limit: int = 50
) -> list

get_notifications(
    persona: str,
    unread_only: bool = True
) -> list

mark_notification_read(
    notification_id: int
) -> dict
```

### Tool Descriptions

**create_chat_room**: Creates a new chat room with specified members. If session_id is provided, associates the room with that session. If session_id is not provided but session_title is, creates a new session first. All members receive persona_join events in the chat feed.

**send_message**: Sends a message to a chat room. Automatically extracts @mentions (e.g., "@mike-developer") and creates notifications for mentioned personas. Supports threaded replies via reply_to_id parameter.

**react_to_message**: Adds an emoji reaction to any chat event. Creates a new emoji_reaction event in the feed. Multiple personas can react to the same event with different emojis.

**share_artifact**: Shares an artifact in the chat room. If revision is not specified, shares the current revision. Creates an artifact_share event with artifact details and web URL.

**create_todo**: Creates a shared todo item in the chat. If assigned_to is specified, creates a notification for the assigned persona. Todo events appear in the chat feed.

**get_chat_feed**: Retrieves the chronological event stream for a chat room. Supports pagination via since (ISO timestamp) and limit parameters. Events include messages, reactions, artifact shares, todos, and persona joins.

**get_notifications**: Retrieves notifications for a persona. By default shows only unread notifications. Notifications are created for @mentions, todo assignments, and artifact shares.

**mark_notification_read**: Marks a notification as read by setting the read_at timestamp. Returns updated notification status.

## Database Model

### Tables

- **chat_rooms**: Room registry with id, name, description, created_at, session_id (optional)
- **room_members**: Membership tracking with room_id, persona_slug, joined_at (composite PK on room_id + persona_slug)
- **chat_events**: Event stream with id, room_id, event_type, persona, timestamp, data (JSON), reply_to_id (optional)
- **notifications**: Notification registry with id, persona, event_id, notification_type, read_at, created_at

### Relationships

- chat_rooms.session_id → sessions.id (optional, links room to session)
- room_members.room_id → chat_rooms.id (one-to-many)
- chat_events.room_id → chat_rooms.id (one-to-many)
- chat_events.reply_to_id → chat_events.id (self-referential for threads)
- notifications.event_id → chat_events.id (many-to-one)

### Indexes

- idx_chat_events_room: room_id for fast feed retrieval
- idx_chat_events_timestamp: timestamp for chronological ordering
- idx_notifications_persona: persona for notification retrieval
- idx_notifications_read: (persona, read_at) for unread filtering

## User Stories Mapping

This category addresses:
- US-058: Facilitate multi-persona consensus
- US-059: Chain multi-agent workflows with dependencies
- US-063: Multi-perspective artifact review
- US-064: Agent handoff protocol
- US-065: Parallel agent synthesis

## Suggested PRD Mapping

- PRD-04: Chat and Collaboration System
  - Multi-persona chat rooms
  - @mention notifications
  - Event-driven architecture
  - Artifact sharing integration

## API Documentation

### MCP Tools

**create_chat_room**
- **Parameters**:
  - name (str, required): Unique room name
  - members (List[str], required): Persona slugs
  - description (str, optional): Room description
  - session_id (str, optional): Existing session ID
  - session_title (str, optional): New session title (creates session if session_id not provided)
- **Returns**: dict with room_id, session_id, name, description, members, web_url
- **Raises**: ValueError if room name already exists

**send_message**
- **Parameters**:
  - room_id (int, required): Room ID
  - persona (str, required): Sender persona slug
  - message (str, required): Message content
  - reply_to_id (int, optional): Event ID being replied to
- **Returns**: dict with event_id, room_id, persona, message, mentions, notifications
- **Raises**: ValueError if room not found or persona not a member

**react_to_message**
- **Parameters**:
  - event_id (int, required): Event ID to react to
  - persona (str, required): Reacting persona slug
  - emoji (str, required): Emoji character
- **Returns**: dict with event_id, emoji, target_event_id, room_id

**share_artifact**
- **Parameters**:
  - room_id (int, required): Room ID
  - persona (str, required): Sharing persona slug
  - artifact_id (int, required): Artifact ID
  - revision (int, optional): Revision number (defaults to current)
- **Returns**: dict with event_id, artifact_id, artifact_name, revision_num, web_url

**create_todo**
- **Parameters**:
  - room_id (int, required): Room ID
  - persona (str, required): Creator persona slug
  - description (str, required): Todo description
  - assigned_to (str, optional): Assignee persona slug
- **Returns**: dict with event_id, description, assigned_to, notifications

**get_chat_feed**
- **Parameters**:
  - room_id (int, required): Room ID
  - since (str, optional): ISO timestamp for pagination
  - limit (int, optional): Max events (default 50)
- **Returns**: list of event dicts with event_type, persona, timestamp, data

**get_notifications**
- **Parameters**:
  - persona (str, required): Persona slug
  - unread_only (bool, optional): Filter for unread (default True)
- **Returns**: list of notification dicts with notification_id, notification_type, event_data, read_at

**mark_notification_read**
- **Parameters**:
  - notification_id (int, required): Notification ID
- **Returns**: dict with notification_id, read_at

### Web Endpoints

**GET /room/{room_id}**
- Standalone chat room view
- Parameters: room_id (path)
- Returns: HTML chat room interface

**GET /session/{session_id}/room/{room_id}**
- Chat room view in session context
- Parameters: session_id (path), room_id (path)
- Returns: HTML chat room interface with session navigation

**GET /api/room/{id}/feed**
- Get chat room feed via HTTP
- Parameters: id (path), since (query), limit (query)
- Returns: JSON event list

## Dependencies

### Internal
- **C-01 (Script Tools)**: Not directly dependent
- **C-02 (Artifact Management)**: share_artifact references artifacts
- **C-03 (Session Management)**: Rooms can be associated with sessions
- **Database Layer**: storage.db.Database for all persistence

### External
- **SQLite**: Database backend with WAL mode
- **Python re module**: @mention pattern matching
- **Python json module**: Event data serialization
- **Python datetime**: Timestamp generation

## Testing

### Test Files
- `worktrees/main/mcp-server/tests/test_basic.py` (lines for test_chat_workflow, test_artifact_sharing_in_chat, test_todo_creation)

### Coverage: 78%

**Lines covered**: Chat room creation, message sending, @mention detection, notification creation, artifact sharing, todo creation, feed retrieval, notification retrieval

**Lines not covered**:
- Emoji reaction flow (implemented but untested)
- Reply threading (reply_to_id parameter)
- Edge cases for invalid room/persona combinations

### Key Test Cases
1. **test_chat_workflow**: Create room → send message with @mention → verify notification → retrieve feed → mark notification read
2. **test_artifact_sharing_in_chat**: Create room → share artifact → verify event in feed
3. **test_todo_creation**: Create room → create todo with assignment → verify notification

## Documentation References

- **README**: worktrees/main/mcp-server/README.md (Chat System section, lines 84-93)
- **USAGE**: worktrees/main/mcp-server/USAGE.md (Multi-Persona Chat Workflow, lines 133-207)
- **PRD**: Not yet created (suggested: PRD-04 Chat and Collaboration)
- **Status**: worktrees/main/mcp-server/PROJECT_STATUS.md (Chat System section, lines 63-73, coverage 78%)

## Implementation Notes

### Event-Driven Architecture
All chat interactions are stored as events in the `chat_events` table. This provides:
- Complete audit trail of all room activity
- Time-ordered feed for chronological replay
- Extensible event types (new event types can be added without schema changes)
- Support for threaded replies via reply_to_id

### @Mention Detection
The system uses regex pattern `@([a-zA-Z0-9_-]+)` to extract mentions from messages. Mentioned personas receive notifications automatically if they are members of the room.

### Notification System
Notifications are created for:
- @mentions in messages
- Todo assignments (when assigned_to is specified)
- Future: artifact shares (not yet implemented in notification creation)

### Session Integration
Chat rooms can be created within sessions, enabling session-scoped collaboration. The web UI provides session-aware navigation when viewing rooms in session context.

### Persona Verification
All message sends, reactions, and artifact shares verify that the persona is a member of the room before creating events. This prevents unauthorized posting to rooms.

### JSON Data Storage
Event data is stored as JSON in the `data` TEXT column, allowing flexible event payloads without schema changes. Common fields include:
- message events: {message, mentions}
- emoji_reaction events: {emoji, target_event_id}
- artifact_share events: {artifact_id, artifact_name, revision_num, web_url}
- todo_create events: {description, assigned_to}

### Future Enhancements
- Real-time updates via WebSocket (currently polling-based)
- Notification preferences per persona
- Message editing and deletion
- File uploads in chat
- Chat room archival
- Export chat logs
