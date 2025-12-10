"""Tests for web server."""

import pytest
import pytest_asyncio
from pathlib import Path
import tempfile
import shutil

from fastapi.testclient import TestClient

from npl_mcp.storage.db import Database
from npl_mcp.sessions.manager import SessionManager
from npl_mcp.chat.rooms import ChatManager
from npl_mcp.web.app import WebServer


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
async def web_server(db):
    """Create web server."""
    return WebServer(db)


@pytest_asyncio.fixture
async def client(web_server):
    """Create test client."""
    return TestClient(web_server.app)


@pytest_asyncio.fixture
async def session_manager(db):
    """Create session manager."""
    return SessionManager(db)


@pytest_asyncio.fixture
async def chat_manager(db):
    """Create chat manager."""
    return ChatManager(db)


class TestWebRoutes:
    """Test web routes."""

    @pytest.mark.asyncio
    async def test_index_empty(self, client):
        """Index page loads with no sessions."""
        response = client.get("/")
        assert response.status_code == 200
        assert "NPL MCP Sessions" in response.text
        assert "No sessions yet" in response.text

    @pytest.mark.asyncio
    async def test_index_with_sessions(self, client, session_manager):
        """Index page shows sessions."""
        await session_manager.create_session(title="Test Session")

        response = client.get("/")
        assert response.status_code == 200
        assert "Test Session" in response.text

    @pytest.mark.asyncio
    async def test_session_detail(self, client, session_manager):
        """Session detail page loads."""
        session = await session_manager.create_session(title="My Session")
        sid = session["session_id"]

        response = client.get(f"/session/{sid}")
        assert response.status_code == 200
        assert "My Session" in response.text

    @pytest.mark.asyncio
    async def test_session_not_found(self, client):
        """Session not found returns 404."""
        response = client.get("/session/nonexistent")
        assert response.status_code == 404

    @pytest.mark.asyncio
    async def test_chat_room_in_session(self, client, session_manager, chat_manager):
        """Chat room page loads within session context."""
        session = await session_manager.create_session(title="Chat Test")
        sid = session["session_id"]
        room = await chat_manager.create_chat_room(
            name="test-room",
            members=["alice", "bob"],
            session_id=sid
        )

        response = client.get(f"/session/{sid}/room/{room['room_id']}")
        assert response.status_code == 200
        assert "test-room" in response.text
        assert "alice" in response.text
        assert "bob" in response.text

    @pytest.mark.asyncio
    async def test_chat_room_standalone(self, client, chat_manager):
        """Standalone chat room page loads."""
        room = await chat_manager.create_chat_room(
            name="standalone",
            members=["charlie"]
        )

        response = client.get(f"/room/{room['room_id']}")
        assert response.status_code == 200
        assert "standalone" in response.text

    @pytest.mark.asyncio
    async def test_post_message(self, client, session_manager, chat_manager):
        """Post message to chat room."""
        session = await session_manager.create_session()
        sid = session["session_id"]
        room = await chat_manager.create_chat_room(
            name="msg-test",
            members=["alice"],
            session_id=sid
        )

        response = client.post(
            f"/session/{sid}/room/{room['room_id']}/message",
            data={"persona": "alice", "message": "Hello world!"},
            follow_redirects=False
        )
        assert response.status_code == 303  # Redirect after POST

        # Verify message was created
        feed = await chat_manager.get_chat_feed(room["room_id"])
        messages = [e for e in feed if e["event_type"] == "message"]
        assert len(messages) == 1
        assert messages[0]["data"]["message"] == "Hello world!"


class TestWebAPI:
    """Test web API endpoints."""

    @pytest.mark.asyncio
    async def test_api_list_sessions(self, client, session_manager):
        """API: List sessions."""
        await session_manager.create_session(title="API Test")

        response = client.get("/api/sessions")
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 1
        assert data[0]["title"] == "API Test"

    @pytest.mark.asyncio
    async def test_api_get_session(self, client, session_manager):
        """API: Get session details."""
        session = await session_manager.create_session(title="Detail Test")
        sid = session["session_id"]

        response = client.get(f"/api/session/{sid}")
        assert response.status_code == 200
        data = response.json()
        assert data["session"]["title"] == "Detail Test"

    @pytest.mark.asyncio
    async def test_api_chat_feed(self, client, chat_manager, session_manager):
        """API: Get chat feed."""
        session = await session_manager.create_session()
        room = await chat_manager.create_chat_room(
            name="feed-test",
            members=["alice"],
            session_id=session["session_id"]
        )
        await chat_manager.send_message(room["room_id"], "alice", "Test message")

        response = client.get(f"/api/room/{room['room_id']}/feed")
        assert response.status_code == 200
        data = response.json()
        # Should have join event and message event
        assert len(data) >= 2
