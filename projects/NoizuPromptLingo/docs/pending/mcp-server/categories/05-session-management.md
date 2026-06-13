# Category: Session Management

**Category ID**: C-05
**Tool Count**: 4
**Status**: Documented
**Source**: worktrees/main/mcp-server
**Documentation Source Date**: 2026-02-02

## Overview

Session Management provides organizational containers for grouping related chat rooms and artifacts into logical work sessions. Sessions enable users to organize collaborative work into distinct contexts (e.g., "Q4 Planning", "Bug Fix Session", "Feature Design"), making it easier to track and resume work across multiple artifacts, conversations, and personas. Each session maintains a lifecycle with status tracking (active/archived) and automatic timestamp updates for activity monitoring.

Sessions act as first-class organizational primitives in the NPL MCP system, allowing artifacts and chat rooms to be associated with a common context. This enables features like session-based views in the web UI, bulk operations on related resources, and historical tracking of work sessions.

## Features Implemented

### Feature 1: Session Creation and Retrieval

**Description**: Create new work sessions with optional custom IDs and human-readable titles. Sessions are automatically assigned unique 8-character alphanumeric IDs if not provided. Supports retrieving session details including metadata and all associated resources (chat rooms, artifacts).

**MCP Tools**:
- `create_session(title, session_id)` - Create new session with optional custom ID
- `get_session(session_id)` - Retrieve session details including associated chat rooms and artifacts

**Database Tables**:
- `sessions` - Primary session registry with id (TEXT PRIMARY KEY), title, created_at, updated_at, status
- `artifacts` - Contains session_id foreign key linking artifacts to sessions
- `chat_rooms` - Contains session_id foreign key linking chat rooms to sessions

**Web Routes**:
- `GET /session/{session_id}` - Session detail view with chat rooms and artifacts
- `GET /api/session/{id}` - JSON API for session details

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/sessions/manager.py`
- Database: `worktrees/main/mcp-server/src/npl_mcp/storage/migrations.py` (Migration 1)
- MCP Tools: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 347-359)
- Tests: Not specifically tested in test suite

**Test Coverage**: 0% (untested)

**Example Usage**:
```python
# Create a session with auto-generated ID
session = await create_session(title="Q4 Planning Session")
# Returns: {
#   "session_id": "a7f3k9m2",
#   "title": "Q4 Planning Session",
#   "created_at": "2025-10-09T14:30:00+00:00",
#   "status": "active",
#   "web_url": "http://127.0.0.1:8765/session/a7f3k9m2"
# }

# Create with custom ID
session = await create_session(
    title="Bug Triage",
    session_id="bug-triage-2025-10"
)

# Retrieve session with all contents
details = await get_session(session_id="a7f3k9m2")
# Returns: {
#   "session": {...session metadata...},
#   "chat_rooms": [{room_id: 1, event_count: 15, ...}],
#   "artifacts": [{artifact_id: 2, revision_count: 3, ...}],
#   "web_url": "http://127.0.0.1:8765/session/a7f3k9m2"
# }
```

### Feature 2: Session Listing and Filtering

**Description**: List recent sessions ordered by most recent activity, with optional filtering by status (active/archived). Includes summary counts of associated chat rooms and artifacts for each session, enabling quick overview of session contents.

**MCP Tools**:
- `list_sessions(status, limit)` - List sessions with optional status filter and limit

**Database Tables**:
- `sessions` - Primary session data
- `chat_rooms` - Counted via subquery for room_count
- `artifacts` - Counted via subquery for artifact_count

**Web Routes**:
- `GET /` - Index page showing sessions list
- `GET /api/sessions` - JSON API for sessions list

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/sessions/manager.py` (lines 90-130)
- MCP Tools: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 361-367)

**Test Coverage**: 0% (untested)

**Example Usage**:
```python
# List all active sessions (default limit 20)
active = await list_sessions(status="active", limit=10)
# Returns: [
#   {
#     "id": "a7f3k9m2",
#     "title": "Q4 Planning Session",
#     "created_at": "2025-10-09T14:30:00",
#     "updated_at": "2025-10-09T16:45:00",
#     "status": "active",
#     "room_count": 3,
#     "artifact_count": 5,
#     "web_url": "http://127.0.0.1:8765/session/a7f3k9m2"
#   },
#   ...
# ]

# List all sessions (active and archived)
all_sessions = await list_sessions(limit=50)

# List archived sessions only
archived = await list_sessions(status="archived", limit=20)
```

### Feature 3: Session Metadata Updates

**Description**: Update session title and status with automatic timestamp tracking. Supports archiving sessions to mark them as completed or inactive. The updated_at timestamp is automatically maintained to track last modification time.

**MCP Tools**:
- `update_session(session_id, title, status)` - Update session metadata (title and/or status)

**Database Tables**:
- `sessions` - Updated with new title/status and updated_at timestamp

**Web Routes**:
- None (API-only feature)

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/sessions/manager.py` (lines 132-176)
- MCP Tools: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 369-374)
- Helper: `archive_session()` method (line 261) wraps update_session for status="archived"

**Test Coverage**: 0% (untested)

**Example Usage**:
```python
# Update session title
result = await update_session(
    session_id="a7f3k9m2",
    title="Q4 Planning - Final Review"
)

# Archive a session
result = await update_session(
    session_id="a7f3k9m2",
    status="archived"
)

# Update both title and status
result = await update_session(
    session_id="a7f3k9m2",
    title="Q4 Planning - Completed",
    status="archived"
)
# Returns: {
#   "id": "a7f3k9m2",
#   "title": "Q4 Planning - Completed",
#   "status": "archived",
#   "created_at": "2025-10-09T14:30:00",
#   "updated_at": "2025-10-09T18:00:00"  # Auto-updated
# }
```

### Feature 4: Session Activity Tracking

**Description**: Internal mechanisms for tracking session activity through timestamp updates. Chat rooms and artifacts can be associated with sessions, triggering automatic updated_at timestamp refreshes to maintain accurate "most recently active" sorting.

**MCP Tools**:
- None (internal only via `touch_session()` and `get_or_create_session()`)

**Database Tables**:
- `sessions` - updated_at column maintained automatically

**Implementation Methods** (not exposed as MCP tools):
- `touch_session(session_id)` - Update session's updated_at timestamp
- `get_or_create_session(session_id, title)` - Idempotent session creation/retrieval
- `associate_artifact(session_id, artifact_id)` - Link artifact to session and touch timestamp

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/sessions/manager.py` (lines 178-283)
- Usage: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 383-396 in create_chat_room)

**Test Coverage**: 0% (untested)

**Example Usage** (internal API):
```python
# Used when creating chat rooms with session_id
session = await _session_manager.get_or_create_session(
    session_id="a7f3k9m2",
    title="Q4 Planning"
)

# Touch session when activity occurs
await _session_manager.touch_session("a7f3k9m2")

# Associate artifact with session
await _session_manager.associate_artifact(
    session_id="a7f3k9m2",
    artifact_id=42
)
```

## MCP Tools Reference

### Tool Signatures

```python
create_session(title: Optional[str] = None, session_id: Optional[str] = None) -> dict

get_session(session_id: str) -> dict

list_sessions(status: Optional[str] = None, limit: int = 20) -> list

update_session(session_id: str, title: Optional[str] = None, status: Optional[str] = None) -> dict
```

### Tool Descriptions

**create_session**: Create a new session to group chat rooms and artifacts. Accepts optional title for human-readable identification and optional custom session_id. If session_id is not provided, generates a random 8-character alphanumeric ID. Returns session metadata including web_url for browser access.

**get_session**: Get session details and contents. Retrieves full session information including metadata, all associated chat rooms (with event/member counts), and all associated artifacts (with revision counts). Returns structured dict with nested chat_rooms and artifacts arrays.

**list_sessions**: List recent sessions ordered by most recent activity (updated_at DESC). Supports optional status filter ('active' or 'archived') and configurable limit (default 20, max 50). Each session includes room_count and artifact_count computed via subqueries. Returns array of session summary objects with web URLs.

**update_session**: Update session metadata including title and/or status. Automatically updates the updated_at timestamp. Validates session exists before update. Returns updated session object. Commonly used to archive sessions by setting status='archived'.

## Database Model

### Tables

- `sessions`: Primary session registry
  - `id` (TEXT PRIMARY KEY) - Unique session identifier (8-char alphanumeric or custom)
  - `title` (TEXT) - Human-readable session title (optional)
  - `created_at` (TEXT) - ISO 8601 timestamp of creation
  - `updated_at` (TEXT) - ISO 8601 timestamp of last activity
  - `status` (TEXT DEFAULT 'active') - Session lifecycle status ('active', 'archived')

- `artifacts`: Artifact registry (defined in schema.sql)
  - `session_id` (TEXT) - Foreign key to sessions.id (nullable, added in migration 2)

- `chat_rooms`: Chat room registry (defined in schema.sql)
  - `session_id` (TEXT) - Foreign key to sessions.id (nullable, added in migration 3)

### Relationships

- **One session to many chat rooms**: `chat_rooms.session_id` → `sessions.id`
- **One session to many artifacts**: `artifacts.session_id` → `sessions.id`

### Indexes

- `idx_sessions_updated` - Index on updated_at DESC for efficient listing by activity
- `idx_sessions_status` - Index on status for filtered queries
- `idx_artifacts_session` - Index on artifacts.session_id for join performance
- `idx_chat_rooms_session` - Index on chat_rooms.session_id for join performance

## User Stories Mapping

This category addresses:
- US-008: Session Management (implied from feature set)
- US-009: Organize artifacts by context (implied)
- US-010: Track work session lifecycle (implied)

Note: Explicit user story IDs not found in documentation, inferred from feature descriptions.

## Suggested PRD Mapping

- PRD-05: Session Lifecycle Management
- PRD-06: Resource Organization and Grouping
- PRD-07: Activity Tracking and Timestamps

## API Documentation

### MCP Tools

#### create_session

**Signature**: `create_session(title: Optional[str] = None, session_id: Optional[str] = None) -> dict`

**Parameters**:
- `title` (Optional[str]): Human-readable title for the session
- `session_id` (Optional[str]): Custom session ID (auto-generated if not provided)

**Returns**: Dict with keys:
- `session_id` (str): The session identifier
- `title` (str | None): Session title
- `created_at` (str): ISO 8601 timestamp
- `status` (str): Always 'active' for new sessions
- `web_url` (str): Browser URL for session view

**Errors**:
- Generates new ID if provided session_id already exists (collision handling)

#### get_session

**Signature**: `get_session(session_id: str) -> dict`

**Parameters**:
- `session_id` (str): The session identifier to retrieve

**Returns**: Dict with keys:
- `session` (dict): Session metadata (id, title, created_at, updated_at, status)
- `chat_rooms` (list): Array of chat room dicts with event_count, member_count
- `artifacts` (list): Array of artifact dicts with revision_count
- `web_url` (str): Browser URL for session view

**Errors**:
- Raises `ValueError` if session not found

#### list_sessions

**Signature**: `list_sessions(status: Optional[str] = None, limit: int = 20) -> list`

**Parameters**:
- `status` (Optional[str]): Filter by status ('active', 'archived', or None for all)
- `limit` (int): Maximum sessions to return (default 20)

**Returns**: Array of dicts, each with keys:
- `id` (str): Session identifier
- `title` (str | None): Session title
- `created_at` (str): Creation timestamp
- `updated_at` (str): Last activity timestamp
- `status` (str): Session status
- `room_count` (int): Number of associated chat rooms
- `artifact_count` (int): Number of associated artifacts
- `web_url` (str): Browser URL

**Ordering**: Descending by updated_at (most recent first)

#### update_session

**Signature**: `update_session(session_id: str, title: Optional[str] = None, status: Optional[str] = None) -> dict`

**Parameters**:
- `session_id` (str): Session identifier
- `title` (Optional[str]): New title (omit to keep current)
- `status` (Optional[str]): New status (omit to keep current)

**Returns**: Updated session dict with keys:
- `id` (str): Session identifier
- `title` (str | None): Current title
- `created_at` (str): Creation timestamp
- `updated_at` (str): Updated timestamp (automatically refreshed)
- `status` (str): Current status
- `web_url` (str): Browser URL

**Errors**:
- Raises `ValueError` if session not found

### Web Endpoints

- `GET /session/{session_id}` - Session detail view
  - Query params: None
  - Returns: HTML page with session info, chat rooms, and artifacts

- `GET /api/session/{id}` - Session details JSON API
  - Query params: None
  - Returns: JSON with session metadata and contents

- `GET /api/sessions` - Sessions list JSON API
  - Query params: status (optional), limit (optional)
  - Returns: JSON array of sessions

## Dependencies

**Internal**:
- Database (storage.db.Database) - SQLite connection and query execution
- Chat System - Chat rooms can be linked to sessions
- Artifact Management - Artifacts can be linked to sessions
- Task Queues - Task queues can be linked to sessions (migration 5)

**External**:
- secrets - Cryptographically secure random ID generation
- datetime - Timestamp generation with timezone support
- aiosqlite - Async SQLite database operations

## Testing

- **Test Files**: None (feature implemented but untested)
- **Coverage**: 0%
- **Key Test Cases**:
  - Session creation with auto-generated ID
  - Session creation with custom ID
  - Session creation with ID collision handling
  - Retrieve session with contents
  - List sessions with status filtering
  - Update session title
  - Update session status (archiving)
  - Touch session timestamp
  - Associate artifacts with session
  - Associate chat rooms with session

## Documentation References

- **README**: worktrees/main/mcp-server/README.md (lines 78-82 for Session Management tools)
- **USAGE**: Not covered in USAGE.md (no session workflow examples)
- **PRD**: Not found (no docs/PRD.md file)
- **Status**: worktrees/main/mcp-server/PROJECT_STATUS.md (no specific coverage metrics)

## Implementation Notes

**Session ID Generation**: Uses `secrets.choice()` with lowercase letters and digits for cryptographically secure random IDs. Default length is 8 characters, but extends to 12 on collision. This provides good uniqueness (36^8 ≈ 2.8 trillion combinations) while remaining URL-friendly.

**Timestamp Management**: All timestamps use `datetime.now(timezone.utc).isoformat()` for consistent ISO 8601 format with UTC timezone. The `updated_at` field is automatically refreshed on any update operation, enabling proper activity-based sorting.

**Migration Strategy**: Sessions table is added via migration system (migration 1) rather than base schema, allowing existing databases to be upgraded. Migrations 2 and 3 add session_id foreign keys to artifacts and chat_rooms respectively, using column existence checks to support idempotent migration runs.

**Lazy Association**: Chat rooms and artifacts can be created with or without sessions. Association can happen at creation time (via session_id parameter) or later (via associate_artifact method). This supports flexible workflows where session context is determined after resource creation.

**Web UI Integration**: All MCP tools return `web_url` fields pointing to the FastAPI web UI routes. Session URLs use the pattern `/session/{session_id}` for detail views and `/session/{session_id}/room/{room_id}` for room-in-session views.

**Status Field**: Currently supports 'active' (default) and 'archived' values. No validation enforced at database level, relying on application logic. Future migrations could add CHECK constraint if needed.

**Untested Coverage**: While the feature is fully implemented and documented, no test suite coverage exists. Integration tests recommended for session lifecycle, association logic, and timestamp behavior.
