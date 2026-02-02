# Category: Database Infrastructure

**Category ID**: C-01
**Tool Count**: N/A (Infrastructure layer, not MCP tools)
**Status**: Documented
**Source**: worktrees/main/mcp-server
**Documentation Source Date**: 2026-02-02

## Overview

The Database Infrastructure provides the foundational data persistence layer for the NPL MCP server. Built on SQLite with an aiosqlite async wrapper, this category encompasses the complete schema definition, migration system, and database connection management. It supports all higher-level features including artifacts, revisions, reviews, chat rooms, sessions, and task queues.

The infrastructure implements a simple migration system that automatically applies schema updates on startup, tracks applied migrations in a `schema_version` table, and ensures backward compatibility across server upgrades. The database uses 12 core tables with appropriate foreign key relationships and performance-optimized indexes.

## Features Implemented

### Feature 1: Core Schema Definition
**Description**: Base schema with 9 tables covering artifacts, reviews, chat, and collaboration

**Database Tables**:
- `artifacts` - Main artifact registry with name, type, current revision tracking
- `revisions` - Version history for artifacts with file paths and metadata
- `reviews` - Artifact review sessions with status and reviewer tracking
- `inline_comments` - Line-by-line or position-based review comments
- `review_overlays` - Image annotation overlay files for visual reviews
- `chat_rooms` - Collaboration spaces with name and description
- `room_members` - Persona membership in chat rooms
- `chat_events` - All events in chat rooms (messages, reactions, artifact shares, todos)
- `notifications` - User notifications from @mentions and events

**Source Files**:
- Schema: `worktrees/main/mcp-server/src/npl_mcp/storage/schema.sql`
- Database wrapper: `worktrees/main/mcp-server/src/npl_mcp/storage/db.py`

**Test Coverage**: 82% (Database Layer)

**Example Usage**:
```sql
-- artifacts table
CREATE TABLE artifacts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    type TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    current_revision_id INTEGER,
    FOREIGN KEY (current_revision_id) REFERENCES revisions(id)
);
```

### Feature 2: Schema Migration System
**Description**: Automatic migration system with version tracking and conditional column additions

**Database Tables**:
- `schema_version` - Tracks applied migrations with version, description, applied_at

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/storage/migrations.py`

**Test Coverage**: Part of 82% Database Layer coverage

**Migrations Applied**:
1. Migration 1: Add sessions table
2. Migration 2: Add session_id to artifacts
3. Migration 3: Add session_id to chat_rooms
4. Migration 4: Add taskers table (ephemeral executor agents)
5. Migration 5: Add task queues and related tables (tasks, task_events, task_artifacts)

**Example Usage**:
```python
# Automatic on database connection
applied = await run_migrations(conn)
# Returns: ['Add sessions table', 'Add session_id to artifacts', ...]
```

### Feature 3: Session Management Tables
**Description**: Session grouping for related chat rooms and artifacts

**Database Tables**:
- `sessions` - Session registry with id, title, created_at, updated_at, status
- Foreign keys: `artifacts.session_id`, `chat_rooms.session_id`, `task_queues.session_id`

**Indexes**:
- `idx_sessions_updated` - For listing sessions by activity
- `idx_sessions_status` - For filtering by status
- `idx_artifacts_session` - For artifact-session queries
- `idx_chat_rooms_session` - For chat room-session queries

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/storage/migrations.py` (migrations 1-3)
- Database: `worktrees/main/mcp-server/src/npl_mcp/storage/schema.sql`

**Test Coverage**: Covered by session management tests

**Example Usage**:
```sql
-- Create session
INSERT INTO sessions (id, title, status)
VALUES ('abc123', 'Sprint Planning', 'active');

-- Link chat room to session
UPDATE chat_rooms SET session_id = 'abc123' WHERE id = 1;
```

### Feature 4: Task Queue Tables
**Description**: Task management with queues, events, and artifact linking

**Database Tables**:
- `task_queues` - Queue registry with chat_room_id for Q&A, session association
- `tasks` - Individual tasks with title, description, acceptance criteria, priority, deadline, complexity, status, assignment
- `task_events` - Activity feed for task lifecycle events
- `task_artifacts` - Links artifacts and git branches to tasks

**Indexes**:
- `idx_task_queues_status` - Active queue filtering
- `idx_task_queues_session` - Queue-session queries
- `idx_tasks_queue` - Tasks by queue
- `idx_tasks_status` - Task status filtering
- `idx_tasks_priority` - Priority-based sorting (DESC)
- `idx_tasks_deadline` - Deadline queries
- `idx_tasks_assigned` - Assignment tracking
- `idx_task_events_task` - Event lookup by task
- `idx_task_events_queue` - Event feed by queue
- `idx_task_events_created` - Chronological event ordering
- `idx_task_artifacts_task` - Artifacts by task
- `idx_task_artifacts_artifact` - Tasks by artifact

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/storage/migrations.py` (migration 5)

**Test Coverage**: Implemented but untested (future enhancement)

**Example Usage**:
```sql
-- Create task queue with chat room
INSERT INTO task_queues (name, description, chat_room_id, session_id)
VALUES ('Sprint 1', 'Tasks for sprint 1', 1, 'abc123');

-- Add task to queue
INSERT INTO tasks (queue_id, title, description, priority, status)
VALUES (1, 'Implement auth', 'Add JWT authentication', 1, 'pending');
```

### Feature 5: Ephemeral Tasker Tracking
**Description**: Track ephemeral executor agents for timeout and nag operations

**Database Tables**:
- `taskers` - Ephemeral agent registry with parent_agent_id, session_id, chat_room_id, task, patterns, status, timeout_minutes, nag_minutes, created_at, last_activity, terminated_at, termination_reason

**Indexes**:
- `idx_taskers_status` - Active tasker queries
- `idx_taskers_session` - Session-based filtering
- `idx_taskers_parent` - Parent agent lookup

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/storage/migrations.py` (migration 4)

**Test Coverage**: Implemented but untested (future enhancement)

**Example Usage**:
```sql
-- Register ephemeral tasker
INSERT INTO taskers (id, parent_agent_id, session_id, task, status, timeout_minutes)
VALUES ('tasker-001', 'main-agent', 'abc123', 'Run tests', 'active', 15);

-- Update activity timestamp
UPDATE taskers SET last_activity = datetime('now') WHERE id = 'tasker-001';
```

### Feature 6: Performance Indexes
**Description**: Comprehensive indexing strategy for query optimization

**Indexes Created**:
- `idx_revisions_artifact` - Revision history queries
- `idx_reviews_artifact` - Reviews by artifact
- `idx_reviews_revision` - Reviews by revision
- `idx_inline_comments_review` - Comments by review
- `idx_chat_events_room` - Events by chat room
- `idx_chat_events_timestamp` - Chronological event ordering
- `idx_notifications_persona` - Notifications by persona
- `idx_notifications_read` - Unread notification queries

**Source Files**:
- Schema: `worktrees/main/mcp-server/src/npl_mcp/storage/schema.sql`

**Test Coverage**: Implicit (performance testing not in scope)

## Database Schema Summary

### All Tables

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| `artifacts` | Artifact registry | id, name, type, current_revision_id, session_id |
| `revisions` | Version history | id, artifact_id, revision_num, file_path, meta_path |
| `reviews` | Review sessions | id, artifact_id, revision_id, reviewer_persona, status |
| `inline_comments` | Review comments | id, review_id, location, comment, persona |
| `review_overlays` | Image annotations | id, review_id, overlay_file |
| `chat_rooms` | Collaboration spaces | id, name, description, session_id |
| `room_members` | Chat membership | room_id, persona_slug, joined_at |
| `chat_events` | Event feed | id, room_id, event_type, persona, data, reply_to_id |
| `notifications` | User notifications | id, persona, event_id, notification_type, read_at |
| `sessions` | Session grouping | id, title, created_at, updated_at, status |
| `taskers` | Ephemeral agents | id, parent_agent_id, session_id, task, status, timeout_minutes |
| `task_queues` | Task queues | id, name, chat_room_id, session_id, status |
| `tasks` | Task items | id, queue_id, title, priority, deadline, complexity, status, assigned_to |
| `task_events` | Task activity | id, task_id, queue_id, event_type, persona, data |
| `task_artifacts` | Task-artifact links | id, task_id, artifact_id, git_branch |
| `schema_version` | Migration tracking | version, description, applied_at |

### Relationships

```
artifacts (1) -> (*) revisions
artifacts (1) -> (*) reviews
revisions (1) -> (*) reviews
reviews (1) -> (*) inline_comments
reviews (1) -> (*) review_overlays
chat_rooms (1) -> (*) room_members
chat_rooms (1) -> (*) chat_events
chat_events (1) -> (*) notifications
sessions (1) -> (*) artifacts
sessions (1) -> (*) chat_rooms
sessions (1) -> (*) task_queues
task_queues (1) -> (*) tasks
tasks (1) -> (*) task_events
tasks (1) -> (*) task_artifacts
```

## User Stories Mapping

This category addresses:
- US-038: Apply database schema migration
- US-039: Backup and restore database
- US-040: Monitor database health and performance
- US-041: Prevent concurrent write conflicts
- US-042: Audit schema version compatibility
- US-043: Export and import data between databases
- US-044: Validate database integrity
- US-045: Manage multiple database instances
- US-046: Optimize database storage
- US-047: View database schema documentation

## Suggested PRD Mapping

Database section from PRD.md:
- FR-014: Schema Migration System
- FR-015: Sessions Table Migration

## Dependencies

- **Internal**: All categories depend on this infrastructure
- **External**:
  - `aiosqlite` (>=0.19.0) - Async SQLite wrapper
  - Python sqlite3 module (built-in)

## Testing

- **Test Files**: `worktrees/main/mcp-server/tests/test_basic.py`
- **Coverage**: 82% (Database Layer - excellent)
- **Key Test Cases**:
  - Database initialization
  - Connection management
  - Query execution
  - Path helpers for artifact storage

## Documentation References

- **README**: worktrees/main/mcp-server/README.md (Database section)
- **USAGE**: worktrees/main/mcp-server/USAGE.md (Database examples)
- **PRD**: worktrees/main/mcp-server/docs/PRD.md (FR-014, FR-015)
- **Status**: worktrees/main/mcp-server/PROJECT_STATUS.md (Database Layer section)

## Implementation Notes

### Migration Safety
- All migrations check for table/column existence before ALTER TABLE
- SQLite doesn't support `ADD COLUMN IF NOT EXISTS`, so explicit checks via `PRAGMA table_info()` are required
- Migrations are idempotent - can be run multiple times safely

### Connection Management
- Database uses aiosqlite for async operations
- Connection lifecycle managed via FastMCP lifespan context
- WAL mode recommended for concurrent reads/writes (not enforced in code)

### Performance Considerations
- All foreign key columns are indexed
- Timestamp columns indexed for chronological queries
- Compound indexes on `(persona, read_at)` for notification queries

### Limitations
- SQLite single-writer constraint - concurrent writes will serialize
- No built-in replication or clustering
- File-based database - backup requires file copy (no hot backup built-in)
- Foreign key constraints must be enabled explicitly (`PRAGMA foreign_keys = ON`)

### Future Enhancements
- WAL mode enforcement
- Automatic VACUUM scheduling
- Connection pooling for unified HTTP mode
- Database backup/restore MCP tools
- Schema validation tools
- Database health monitoring tools
