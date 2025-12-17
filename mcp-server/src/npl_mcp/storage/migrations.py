"""Database migrations for NPL MCP.

Simple migration system that tracks applied migrations in a `schema_version` table.
Migrations are applied in order on startup.
"""

from typing import List, Tuple
import aiosqlite


# Migration definitions: (version, description, sql)
# Each migration runs once and version is recorded
MIGRATIONS: List[Tuple[int, str, str]] = [
    (1, "Add sessions table and session_id columns", """
        -- Sessions table
        CREATE TABLE IF NOT EXISTS sessions (
            id TEXT PRIMARY KEY,
            title TEXT,
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now')),
            status TEXT DEFAULT 'active'
        );

        CREATE INDEX IF NOT EXISTS idx_sessions_updated ON sessions(updated_at DESC);
        CREATE INDEX IF NOT EXISTS idx_sessions_status ON sessions(status);

        -- Add session_id to artifacts if not exists
        -- SQLite doesn't support ADD COLUMN IF NOT EXISTS, so we check first
    """),

    (2, "Add session_id to chat_rooms", """
        -- This runs as a separate migration to handle the ALTER TABLE
    """),
]


async def get_schema_version(conn: aiosqlite.Connection) -> int:
    """Get current schema version from database.

    Returns:
        Current version number, or 0 if no migrations applied
    """
    # Check if schema_version table exists
    cursor = await conn.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='schema_version'"
    )
    if not await cursor.fetchone():
        return 0

    cursor = await conn.execute("SELECT MAX(version) FROM schema_version")
    row = await cursor.fetchone()
    return row[0] if row and row[0] else 0


async def record_migration(conn: aiosqlite.Connection, version: int, description: str):
    """Record that a migration was applied."""
    await conn.execute(
        "INSERT INTO schema_version (version, description, applied_at) VALUES (?, ?, datetime('now'))",
        (version, description)
    )
    await conn.commit()


async def column_exists(conn: aiosqlite.Connection, table: str, column: str) -> bool:
    """Check if a column exists in a table."""
    cursor = await conn.execute(f"PRAGMA table_info({table})")
    columns = await cursor.fetchall()
    return any(col[1] == column for col in columns)


async def table_exists(conn: aiosqlite.Connection, table: str) -> bool:
    """Check if a table exists."""
    cursor = await conn.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        (table,)
    )
    return await cursor.fetchone() is not None


async def run_migrations(conn: aiosqlite.Connection) -> List[str]:
    """Run all pending migrations.

    Args:
        conn: Database connection

    Returns:
        List of applied migration descriptions
    """
    applied = []

    # Ensure schema_version table exists
    await conn.execute("""
        CREATE TABLE IF NOT EXISTS schema_version (
            version INTEGER PRIMARY KEY,
            description TEXT,
            applied_at TEXT NOT NULL
        )
    """)
    await conn.commit()

    current_version = await get_schema_version(conn)

    # Migration 1: Sessions table
    if current_version < 1:
        # Create sessions table
        await conn.execute("""
            CREATE TABLE IF NOT EXISTS sessions (
                id TEXT PRIMARY KEY,
                title TEXT,
                created_at TEXT NOT NULL DEFAULT (datetime('now')),
                updated_at TEXT NOT NULL DEFAULT (datetime('now')),
                status TEXT DEFAULT 'active'
            )
        """)
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_sessions_updated ON sessions(updated_at DESC)")
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_sessions_status ON sessions(status)")
        await conn.commit()

        await record_migration(conn, 1, "Add sessions table")
        applied.append("Add sessions table")

    # Migration 2: Add session_id to artifacts
    if current_version < 2:
        if await table_exists(conn, "artifacts"):
            if not await column_exists(conn, "artifacts", "session_id"):
                await conn.execute("ALTER TABLE artifacts ADD COLUMN session_id TEXT REFERENCES sessions(id)")
                await conn.execute("CREATE INDEX IF NOT EXISTS idx_artifacts_session ON artifacts(session_id)")
                await conn.commit()

        await record_migration(conn, 2, "Add session_id to artifacts")
        applied.append("Add session_id to artifacts")

    # Migration 3: Add session_id to chat_rooms
    if current_version < 3:
        if await table_exists(conn, "chat_rooms"):
            if not await column_exists(conn, "chat_rooms", "session_id"):
                await conn.execute("ALTER TABLE chat_rooms ADD COLUMN session_id TEXT REFERENCES sessions(id)")
                await conn.execute("CREATE INDEX IF NOT EXISTS idx_chat_rooms_session ON chat_rooms(session_id)")
                await conn.commit()

        await record_migration(conn, 3, "Add session_id to chat_rooms")
        applied.append("Add session_id to chat_rooms")

    # Migration 4: Add taskers table for ephemeral executor agents
    if current_version < 4:
        await conn.execute("""
            CREATE TABLE IF NOT EXISTS taskers (
                id TEXT PRIMARY KEY,
                parent_agent_id TEXT NOT NULL,
                session_id TEXT REFERENCES sessions(id),
                chat_room_id INTEGER REFERENCES chat_rooms(id),
                task TEXT NOT NULL,
                patterns TEXT,
                status TEXT DEFAULT 'active',
                timeout_minutes INTEGER DEFAULT 15,
                nag_minutes INTEGER DEFAULT 5,
                created_at TEXT NOT NULL,
                last_activity TEXT NOT NULL,
                terminated_at TEXT,
                termination_reason TEXT
            )
        """)
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_taskers_status ON taskers(status)")
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_taskers_session ON taskers(session_id)")
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_taskers_parent ON taskers(parent_agent_id)")
        await conn.commit()

        await record_migration(conn, 4, "Add taskers table")
        applied.append("Add taskers table")

    # Migration 5: Add task_queues and related tables
    if current_version < 5:
        # Task queues - each queue has an associated chat room for Q&A
        await conn.execute("""
            CREATE TABLE IF NOT EXISTS task_queues (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL UNIQUE,
                description TEXT,
                chat_room_id INTEGER REFERENCES chat_rooms(id),
                session_id TEXT REFERENCES sessions(id),
                created_at TEXT NOT NULL DEFAULT (datetime('now')),
                updated_at TEXT NOT NULL DEFAULT (datetime('now')),
                status TEXT DEFAULT 'active'
            )
        """)
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_task_queues_status ON task_queues(status)")
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_task_queues_session ON task_queues(session_id)")

        # Tasks within queues
        await conn.execute("""
            CREATE TABLE IF NOT EXISTS tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                queue_id INTEGER NOT NULL REFERENCES task_queues(id),
                title TEXT NOT NULL,
                description TEXT,
                acceptance_criteria TEXT,
                priority INTEGER DEFAULT 0,
                deadline TEXT,
                complexity INTEGER,
                complexity_notes TEXT,
                status TEXT DEFAULT 'pending',
                created_by TEXT,
                assigned_to TEXT,
                created_at TEXT NOT NULL DEFAULT (datetime('now')),
                updated_at TEXT NOT NULL DEFAULT (datetime('now'))
            )
        """)
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_tasks_queue ON tasks(queue_id)")
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status)")
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_tasks_priority ON tasks(priority DESC)")
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_tasks_deadline ON tasks(deadline)")
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_tasks_assigned ON tasks(assigned_to)")

        # Task events for activity feed
        await conn.execute("""
            CREATE TABLE IF NOT EXISTS task_events (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                task_id INTEGER NOT NULL REFERENCES tasks(id),
                queue_id INTEGER NOT NULL REFERENCES task_queues(id),
                event_type TEXT NOT NULL,
                persona TEXT,
                data TEXT NOT NULL,
                created_at TEXT NOT NULL DEFAULT (datetime('now'))
            )
        """)
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_task_events_task ON task_events(task_id)")
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_task_events_queue ON task_events(queue_id)")
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_task_events_created ON task_events(created_at)")

        # Task artifacts - linking artifacts/git branches to tasks
        await conn.execute("""
            CREATE TABLE IF NOT EXISTS task_artifacts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                task_id INTEGER NOT NULL REFERENCES tasks(id),
                artifact_id INTEGER REFERENCES artifacts(id),
                artifact_type TEXT NOT NULL,
                git_branch TEXT,
                description TEXT,
                created_by TEXT,
                created_at TEXT NOT NULL DEFAULT (datetime('now'))
            )
        """)
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_task_artifacts_task ON task_artifacts(task_id)")
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_task_artifacts_artifact ON task_artifacts(artifact_id)")

        await conn.commit()

        await record_migration(conn, 5, "Add task queues and related tables")
        applied.append("Add task queues and related tables")

    return applied
