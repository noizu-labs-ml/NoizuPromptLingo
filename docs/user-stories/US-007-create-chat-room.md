# User Story: Create Chat Room for Collaboration

**ID**: US-007
**Persona**: P-001 (AI Agent)
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As an **AI agent**,
I want to **create a chat room for collaboration on a specific topic**,
So that **discussions, artifacts, and todos related to a feature or task are organized together**.

## Acceptance Criteria

- [ ] Can create a new chat room with required `name` parameter
- [ ] Can specify optional `description` for the room
- [ ] Can specify initial `members` list (persona identifiers)
- [ ] Can associate room with a `session_id` (optional)
- [ ] Returns `room_id` (integer) for programmatic access
- [ ] Returns `web_url` for browser-based access
- [ ] Room is immediately available for `send_message` operations
- [ ] Can create room without session (standalone mode)
- [ ] Name must be non-empty string
- [ ] Members list defaults to empty if not specified

## Technical Details

**MCP Tool**: `create_chat_room` (Chat Tools)

**Parameters**:
- `name` (string, required): Room display name
- `members` (array, optional): List of persona identifiers (e.g., `["alice", "bob"]`)
- `description` (string, optional): Room purpose or topic
- `session_id` (string, optional): Associate room with a session for organization
- `session_title` (string, optional): Display title for session context

**Returns**:
```json
{
  "room_id": 9,
  "name": "Design Discussion",
  "web_url": "http://127.0.0.1:8765/session/sess-123/room/9"
}
```

## Notes

- Rooms are lightweight - easy to create for any discussion
- Consider auto-creating a room when starting work on a task
- Web URL allows non-technical users to join via browser
- Rooms without `session_id` are standalone and accessible via direct room URL

## Prerequisites

**Required Knowledge**:
- Persona identifiers (P-001, P-002, etc.) from `docs/personas/index.yaml`
- Session IDs if organizing rooms under sessions (see US-005)

**System Requirements**:
- MCP server running (provides Chat Tools)
- Database initialized (stores room metadata)

**Optional**:
- Session context for organization (see US-005: View Session Dashboard)

## Implementation Notes

**Database Schema**:
- Rooms stored in `chat_rooms` table with columns: `id`, `name`, `description`, `session_id`, `created_at`
- Members tracked separately (future enhancement for member management)

**URL Format**:
- With session: `http://{host}:{port}/session/{session_id}/room/{room_id}`
- Standalone: `http://{host}:{port}/room/{room_id}` (future enhancement)

**Future Enhancements**:
- Private/public visibility settings
- Add/remove members after creation
- Room permissions and access control
- Room archival and deletion

## Related MCP Tools

- `create_chat_room` (Chat Tools) - Main tool for this story
- `send_message` (Chat Tools) - Follow-up action after room creation
- `get_chat_feed` (Chat Tools) - Verify room is operational
- `share_artifact` (Chat Tools) - Share work in the room
