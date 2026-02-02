# PRD: Database Infrastructure

**PRD ID**: PRD-001
**Version**: 1.0
**Status**: Documented
**Documentation Source**: worktrees/main/mcp-server
**Last Updated**: 2026-02-02

## Executive Summary

The Database Infrastructure provides the foundational data persistence layer for the NPL MCP server. Built on SQLite with an aiosqlite async wrapper, this infrastructure encompasses schema definition, migration management, and database connection handling. It supports all higher-level features including artifacts, reviews, chat rooms, sessions, and task queues through 15 core tables with optimized indexing and foreign key relationships.

The system implements a versioned migration strategy that automatically applies schema updates on startup, tracks applied migrations, and ensures backward compatibility across server upgrades. All database operations use async patterns for non-blocking I/O, enabling efficient concurrent access patterns.

**Implementation Status**: ✅ Complete in mcp-server worktree

## Features Documented

### User Stories Addressed

- **US-038**: Apply database schema migration
- **US-039**: Backup and restore database
- **US-040**: Monitor database health and performance
- **US-041**: Prevent concurrent write conflicts
- **US-042**: Audit schema version compatibility
- **US-043**: Export and import data between databases
- **US-044**: Validate database integrity
- **US-045**: Manage multiple database instances
- **US-046**: Optimize database storage
- **US-047**: View database schema documentation

## Functional Requirements

### FR-001: Core Schema Definition

**Description**: Base schema with 15 tables covering artifacts, reviews, chat, sessions, tasks, and metadata tracking.

**Database Tables**:
- `artifacts` - Main artifact registry with name, type, current revision tracking
- `revisions` - Version history for artifacts with file paths and metadata
- `reviews` - Artifact review sessions with status and reviewer tracking
- `inline_comments` - Line-by-line or position-based review comments
- `review_overlays` - Image annotation overlay files for visual reviews
- `chat_rooms` - Collaboration spaces with name and description
- `room_members` - Persona membership in chat rooms (composite PK)
- `chat_events` - Event stream for all room activity (messages, reactions, shares, todos)
- `notifications` - User notifications from @mentions and events
- `sessions` - Session grouping for related work contexts
- `taskers` - Ephemeral executor agent tracking
- `task_queues` - Task queue registry with chat room integration
- `tasks` - Individual task records with full lifecycle
- `task_events` - Activity feed for task changes
- `task_artifacts` - Links between tasks and artifacts/branches
- `schema_version` - Migration tracking

**Implementation**:
- **Source**: `worktrees/main/mcp-server/src/npl_mcp/storage/schema.sql`
- **Database Wrapper**: `worktrees/main/mcp-server/src/npl_mcp/storage/db.py`
- **Test File**: `worktrees/main/mcp-server/tests/test_basic.py`

**Testing**: 82% coverage (Database Layer)

### FR-002: Schema Migration System

**Description**: Automatic migration system with version tracking and idempotent column additions. Applies migrations on startup and records applied versions.

**Migration Tracking**:
- `schema_version` table tracks: version, description, applied_at
- Migrations check for existence before ALTER TABLE operations
- All migrations are idempotent (safe to run multiple times)

**Migrations Applied**:
1. **Migration 1**: Add sessions table with indexes
2. **Migration 2**: Add session_id column to artifacts
3. **Migration 3**: Add session_id column to chat_rooms
4. **Migration 4**: Add taskers table for ephemeral agents
5. **Migration 5**: Add task queue system (queues, tasks, events, artifacts)

**Implementation**:
- **Source**: `worktrees/main/mcp-server/src/npl_mcp/storage/migrations.py`
- **Database**: `worktrees/main/mcp-server/src/npl_mcp/storage/schema.sql`

**Testing**: Part of 82% Database Layer coverage

**Example Usage**:
```python
# Automatic on database connection
applied = await run_migrations(conn)
# Returns: ['Add sessions table', 'Add session_id to artifacts', ...]
```

### FR-003: Performance Indexing Strategy

**Description**: Comprehensive indexing for query optimization across all tables.

**Indexes Created**:
- `idx_revisions_artifact` - Revision history queries
- `idx_reviews_artifact`, `idx_reviews_revision` - Review lookups
- `idx_inline_comments_review` - Comment retrieval
- `idx_chat_events_room`, `idx_chat_events_timestamp` - Event feed ordering
- `idx_notifications_persona`, `idx_notifications_read` - Notification queries
- `idx_sessions_updated`, `idx_sessions_status` - Session filtering and ordering
- `idx_artifacts_session`, `idx_chat_rooms_session` - Session relationships
- `idx_taskers_status`, `idx_taskers_session`, `idx_taskers_parent` - Tasker lookups
- `idx_task_queues_status`, `idx_task_queues_session` - Queue filtering
- `idx_tasks_queue`, `idx_tasks_status`, `idx_tasks_priority` - Task queries
- `idx_tasks_deadline`, `idx_tasks_assigned` - Task filtering
- `idx_task_events_task`, `idx_task_events_queue`, `idx_task_events_created` - Event feeds
- `idx_task_artifacts_task`, `idx_task_artifacts_artifact` - Artifact links

**Implementation**:
- **Source**: `worktrees/main/mcp-server/src/npl_mcp/storage/schema.sql`

**Testing**: Implicit (performance testing not in scope)

## Data Model

### Database Schema Summary

#### Core Tables

| Table | Purpose | Row Count (Typical) |
|-------|---------|---------------------|
| `artifacts` | Artifact registry | 10-1000 |
| `revisions` | Version history | 50-5000 |
| `reviews` | Review sessions | 20-2000 |
| `inline_comments` | Review feedback | 100-10000 |
| `review_overlays` | Image annotations | 5-500 |
| `chat_rooms` | Collaboration spaces | 5-100 |
| `room_members` | Membership tracking | 20-500 |
| `chat_events` | Message/event stream | 500-50000 |
| `notifications` | User alerts | 100-10000 |
| `sessions` | Work sessions | 10-200 |
| `taskers` | Ephemeral agents | 0-50 |
| `task_queues` | Task organization | 5-50 |
| `tasks` | Work items | 50-5000 |
| `task_events` | Task activity | 200-20000 |
| `task_artifacts` | Task-artifact links | 50-5000 |
| `schema_version` | Migration log | 5-10 |

#### Relationships

```
artifacts (1) -> (N) revisions
artifacts (1) -> (N) reviews
revisions (1) -> (N) reviews
reviews (1) -> (N) inline_comments
reviews (1) -> (N) review_overlays
chat_rooms (1) -> (N) room_members
chat_rooms (1) -> (N) chat_events
chat_events (1) -> (N) notifications
sessions (1) -> (N) artifacts
sessions (1) -> (N) chat_rooms
sessions (1) -> (N) task_queues
taskers (N) -> (1) sessions
taskers (N) -> (1) chat_rooms
task_queues (1) -> (N) tasks
tasks (1) -> (N) task_events
tasks (1) -> (N) task_artifacts
task_artifacts (N) -> (1) artifacts
```

## Dependencies

### Internal
- All MCP categories depend on this infrastructure layer
- No internal dependencies (foundational layer)

### External
- `aiosqlite` (>=0.19.0) - Async SQLite wrapper
- Python `sqlite3` module (built-in)

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
- **Status**: worktrees/main/mcp-server/PROJECT_STATUS.md (Database Layer section)
- **Category Brief**: `.tmp/mcp-server/categories/01-database-infrastructure.md`

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
