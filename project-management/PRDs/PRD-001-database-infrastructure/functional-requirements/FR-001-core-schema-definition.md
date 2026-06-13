# FR-001: Core Schema Definition

**Status**: Completed

## Description

Base schema with 15 tables covering artifacts, reviews, chat, sessions, tasks, and metadata tracking. Provides foundational data persistence layer for all higher-level features.

## Database Tables

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

## Interface

```python
class Database:
    """SQLite database wrapper with async operations."""

    async def connect(self, db_path: str) -> None:
        """Initialize database connection and apply schema."""

    async def execute(self, query: str, params: tuple = ()) -> None:
        """Execute SQL statement with optional parameters."""

    async def fetch_one(self, query: str, params: tuple = ()) -> dict:
        """Fetch single row as dictionary."""

    async def fetch_all(self, query: str, params: tuple = ()) -> list[dict]:
        """Fetch all rows as list of dictionaries."""
```

## Behavior

- **Given** server starts with no database file
- **When** Database.connect() is called
- **Then** schema.sql creates all 15 tables with indexes and foreign keys

- **Given** database exists with schema
- **When** queries execute via fetch_one/fetch_all
- **Then** results return as dictionaries with column names as keys

## Edge Cases

- **Empty database**: Schema initialization creates all tables atomically
- **Foreign key violations**: Constraints enforced when PRAGMA foreign_keys = ON
- **Concurrent reads**: aiosqlite enables multiple readers without blocking
- **Write serialization**: SQLite single-writer constraint handled by aiosqlite

## Related User Stories

- US-038
- US-041
- US-044
- US-045

## Test Coverage

Expected test count: 12-15 tests
Target coverage: 100% for schema initialization
Actual coverage: 82% (Database Layer)
