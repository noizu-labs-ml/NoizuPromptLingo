"""Tests for database migrations."""

import pytest
import pytest_asyncio
from pathlib import Path
import tempfile
import shutil
import aiosqlite

from npl_mcp.storage.db import Database
from npl_mcp.storage.migrations import (
    run_migrations,
    get_schema_version,
    column_exists,
    table_exists
)


@pytest.fixture
def temp_data_dir():
    """Create temporary data directory."""
    temp_dir = tempfile.mkdtemp()
    yield Path(temp_dir)
    shutil.rmtree(temp_dir)


class TestMigrations:
    """Test migration system."""

    @pytest.mark.asyncio
    async def test_fresh_database_gets_all_migrations(self, temp_data_dir):
        """Fresh database has all migrations applied."""
        db = Database(data_dir=temp_data_dir)
        await db.connect()

        version = await get_schema_version(db.connection)
        assert version == 3  # All migrations applied

        # Check sessions table exists
        assert await table_exists(db.connection, "sessions")

        # Check session_id columns exist
        assert await column_exists(db.connection, "artifacts", "session_id")
        assert await column_exists(db.connection, "chat_rooms", "session_id")

        await db.disconnect()

    @pytest.mark.asyncio
    async def test_migration_on_legacy_database(self, temp_data_dir):
        """Migrations work on database without session support."""
        db_path = temp_data_dir / "npl-mcp.db"

        # Create a "legacy" database without sessions
        async with aiosqlite.connect(db_path) as conn:
            await conn.executescript("""
                CREATE TABLE artifacts (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL UNIQUE,
                    type TEXT NOT NULL,
                    created_at TEXT NOT NULL DEFAULT (datetime('now')),
                    current_revision_id INTEGER
                );

                CREATE TABLE chat_rooms (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL UNIQUE,
                    created_at TEXT NOT NULL DEFAULT (datetime('now')),
                    description TEXT
                );

                -- Insert some test data
                INSERT INTO artifacts (name, type) VALUES ('test-doc', 'document');
                INSERT INTO chat_rooms (name) VALUES ('test-room');
            """)
            await conn.commit()

        # Now connect with Database class (should run migrations)
        db = Database(data_dir=temp_data_dir)
        await db.connect()

        # Check migrations were applied
        version = await get_schema_version(db.connection)
        assert version == 3

        # Check columns were added
        assert await column_exists(db.connection, "artifacts", "session_id")
        assert await column_exists(db.connection, "chat_rooms", "session_id")

        # Check existing data is preserved
        artifact = await db.fetchone("SELECT * FROM artifacts WHERE name = 'test-doc'")
        assert artifact is not None
        assert artifact["session_id"] is None  # New column, NULL for existing rows

        room = await db.fetchone("SELECT * FROM chat_rooms WHERE name = 'test-room'")
        assert room is not None
        assert room["session_id"] is None

        await db.disconnect()

    @pytest.mark.asyncio
    async def test_migrations_idempotent(self, temp_data_dir):
        """Running migrations multiple times is safe."""
        db = Database(data_dir=temp_data_dir)
        await db.connect()

        # Manually run migrations again
        applied = await run_migrations(db.connection)
        assert applied == []  # No new migrations

        version = await get_schema_version(db.connection)
        assert version == 3

        await db.disconnect()

    @pytest.mark.asyncio
    async def test_session_functionality_after_migration(self, temp_data_dir):
        """Session features work after migration from legacy DB."""
        db_path = temp_data_dir / "npl-mcp.db"

        # Create legacy database
        async with aiosqlite.connect(db_path) as conn:
            await conn.executescript("""
                CREATE TABLE artifacts (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL UNIQUE,
                    type TEXT NOT NULL,
                    created_at TEXT NOT NULL DEFAULT (datetime('now')),
                    current_revision_id INTEGER
                );

                CREATE TABLE chat_rooms (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL UNIQUE,
                    created_at TEXT NOT NULL DEFAULT (datetime('now')),
                    description TEXT
                );

                CREATE TABLE room_members (
                    room_id INTEGER NOT NULL,
                    persona_slug TEXT NOT NULL,
                    joined_at TEXT NOT NULL DEFAULT (datetime('now')),
                    PRIMARY KEY (room_id, persona_slug)
                );

                CREATE TABLE chat_events (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    room_id INTEGER NOT NULL,
                    event_type TEXT NOT NULL,
                    persona TEXT NOT NULL,
                    timestamp TEXT NOT NULL DEFAULT (datetime('now')),
                    data TEXT NOT NULL,
                    reply_to_id INTEGER
                );
            """)
            await conn.commit()

        # Connect and migrate
        db = Database(data_dir=temp_data_dir)
        await db.connect()

        # Use session manager
        from npl_mcp.sessions import SessionManager
        from npl_mcp.chat import ChatManager

        session_mgr = SessionManager(db)
        chat_mgr = ChatManager(db)

        # Create session and room
        session = await session_mgr.create_session(title="Post-Migration Test")
        room = await chat_mgr.create_chat_room(
            name="migrated-room",
            members=["alice"],
            session_id=session["session_id"]
        )

        assert room["session_id"] == session["session_id"]

        # Verify session contents
        contents = await session_mgr.get_session_contents(session["session_id"])
        assert len(contents["chat_rooms"]) == 1

        await db.disconnect()
