"""Tests for session management."""

import pytest
import pytest_asyncio
from pathlib import Path
import tempfile
import shutil

from npl_mcp.storage.db import Database
from npl_mcp.sessions.manager import SessionManager, generate_session_id
from npl_mcp.chat.rooms import ChatManager


@pytest.fixture
def temp_data_dir():
    """Create temporary data directory."""
    temp_dir = tempfile.mkdtemp()
    yield Path(temp_dir)
    shutil.rmtree(temp_dir)


@pytest_asyncio.fixture
async def db(temp_data_dir):
    """Create test database."""
    database = Database(data_dir=temp_data_dir)
    await database.connect()
    yield database
    await database.disconnect()


@pytest_asyncio.fixture
async def session_manager(db):
    """Create session manager."""
    return SessionManager(db)


@pytest_asyncio.fixture
async def chat_manager(db):
    """Create chat manager."""
    return ChatManager(db)


class TestSessionIdGeneration:
    """Test session ID generation."""

    def test_default_length(self):
        """Session ID has default length of 8."""
        sid = generate_session_id()
        assert len(sid) == 8

    def test_custom_length(self):
        """Custom length is respected."""
        sid = generate_session_id(length=12)
        assert len(sid) == 12

    def test_alphanumeric(self):
        """Session ID is alphanumeric lowercase."""
        sid = generate_session_id()
        assert sid.isalnum()
        assert sid == sid.lower()


class TestSessionLifecycle:
    """Test session CRUD operations."""

    @pytest.mark.asyncio
    async def test_create_session_auto_id(self, session_manager):
        """Create session with auto-generated ID."""
        result = await session_manager.create_session()

        assert "session_id" in result
        assert len(result["session_id"]) == 8
        assert result["status"] == "active"
        assert result["title"] is None

    @pytest.mark.asyncio
    async def test_create_session_with_title(self, session_manager):
        """Create session with title."""
        result = await session_manager.create_session(title="Test Session")

        assert result["title"] == "Test Session"
        assert result["status"] == "active"

    @pytest.mark.asyncio
    async def test_create_session_custom_id(self, session_manager):
        """Create session with custom ID."""
        result = await session_manager.create_session(session_id="custom123")

        assert result["session_id"] == "custom123"

    @pytest.mark.asyncio
    async def test_get_session(self, session_manager):
        """Get session by ID."""
        created = await session_manager.create_session(title="Test")
        sid = created["session_id"]

        session = await session_manager.get_session(sid)

        assert session is not None
        assert session["id"] == sid
        assert session["title"] == "Test"

    @pytest.mark.asyncio
    async def test_get_nonexistent_session(self, session_manager):
        """Getting nonexistent session returns None."""
        session = await session_manager.get_session("nonexistent")
        assert session is None

    @pytest.mark.asyncio
    async def test_list_sessions(self, session_manager):
        """List sessions ordered by most recent."""
        await session_manager.create_session(title="First")
        await session_manager.create_session(title="Second")
        await session_manager.create_session(title="Third")

        sessions = await session_manager.list_sessions()

        assert len(sessions) == 3
        # Most recent first
        assert sessions[0]["title"] == "Third"
        assert sessions[1]["title"] == "Second"
        assert sessions[2]["title"] == "First"

    @pytest.mark.asyncio
    async def test_list_sessions_with_status_filter(self, session_manager):
        """Filter sessions by status."""
        s1 = await session_manager.create_session(title="Active 1")
        await session_manager.create_session(title="Active 2")
        await session_manager.archive_session(s1["session_id"])

        active = await session_manager.list_sessions(status="active")
        archived = await session_manager.list_sessions(status="archived")

        assert len(active) == 1
        assert len(archived) == 1
        assert active[0]["title"] == "Active 2"
        assert archived[0]["title"] == "Active 1"

    @pytest.mark.asyncio
    async def test_update_session_title(self, session_manager):
        """Update session title."""
        created = await session_manager.create_session(title="Original")
        sid = created["session_id"]

        updated = await session_manager.update_session(sid, title="Updated")

        assert updated["title"] == "Updated"

    @pytest.mark.asyncio
    async def test_archive_session(self, session_manager):
        """Archive a session."""
        created = await session_manager.create_session()
        sid = created["session_id"]

        archived = await session_manager.archive_session(sid)

        assert archived["status"] == "archived"

    @pytest.mark.asyncio
    async def test_get_or_create_existing(self, session_manager):
        """get_or_create returns existing session."""
        created = await session_manager.create_session(title="Existing")
        sid = created["session_id"]

        result = await session_manager.get_or_create_session(session_id=sid)

        assert result["session_id"] == sid
        assert result["title"] == "Existing"

    @pytest.mark.asyncio
    async def test_get_or_create_new(self, session_manager):
        """get_or_create creates new session if not found."""
        result = await session_manager.get_or_create_session(
            session_id="newsession",
            title="New Session"
        )

        assert result["session_id"] == "newsession"
        assert result["title"] == "New Session"


class TestSessionContents:
    """Test session contents and associations."""

    @pytest.mark.asyncio
    async def test_session_contents_empty(self, session_manager):
        """New session has empty contents."""
        created = await session_manager.create_session()
        sid = created["session_id"]

        contents = await session_manager.get_session_contents(sid)

        assert contents["session"]["id"] == sid
        assert contents["chat_rooms"] == []
        assert contents["artifacts"] == []

    @pytest.mark.asyncio
    async def test_session_with_chat_room(self, session_manager, chat_manager):
        """Session shows associated chat rooms."""
        created = await session_manager.create_session(title="Test")
        sid = created["session_id"]

        # Create chat room in session
        await chat_manager.create_chat_room(
            name="test-room",
            members=["alice", "bob"],
            session_id=sid
        )

        contents = await session_manager.get_session_contents(sid)

        assert len(contents["chat_rooms"]) == 1
        assert contents["chat_rooms"][0]["name"] == "test-room"
        assert contents["chat_rooms"][0]["member_count"] == 2

    @pytest.mark.asyncio
    async def test_touch_session(self, session_manager):
        """Touch updates session timestamp."""
        created = await session_manager.create_session()
        sid = created["session_id"]
        original_updated = created["created_at"]

        await session_manager.touch_session(sid)

        session = await session_manager.get_session(sid)
        # Updated timestamp should be different (or equal if same moment)
        assert session["updated_at"] >= original_updated


class TestChatRoomWithSession:
    """Test chat room creation with session association."""

    @pytest.mark.asyncio
    async def test_create_room_with_session(self, chat_manager, session_manager):
        """Create chat room associated with session."""
        session = await session_manager.create_session(title="Test")
        sid = session["session_id"]

        room = await chat_manager.create_chat_room(
            name="session-room",
            members=["alice"],
            session_id=sid
        )

        assert room["session_id"] == sid

    @pytest.mark.asyncio
    async def test_create_room_without_session(self, chat_manager):
        """Create chat room without session association."""
        room = await chat_manager.create_chat_room(
            name="standalone-room",
            members=["alice"]
        )

        assert room["session_id"] is None

    @pytest.mark.asyncio
    async def test_session_lists_rooms(self, session_manager, chat_manager):
        """Session list shows room counts."""
        s1 = await session_manager.create_session()
        s2 = await session_manager.create_session()

        await chat_manager.create_chat_room("room1", ["alice"], session_id=s1["session_id"])
        await chat_manager.create_chat_room("room2", ["bob"], session_id=s1["session_id"])
        await chat_manager.create_chat_room("room3", ["charlie"], session_id=s2["session_id"])

        sessions = await session_manager.list_sessions()

        # Find sessions by ID
        s1_info = next(s for s in sessions if s["id"] == s1["session_id"])
        s2_info = next(s for s in sessions if s["id"] == s2["session_id"])

        assert s1_info["room_count"] == 2
        assert s2_info["room_count"] == 1
