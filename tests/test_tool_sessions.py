"""Tests for npl_mcp.tool_sessions.tool_sessions."""

import uuid
from datetime import datetime, timezone
from unittest.mock import AsyncMock, patch

import pytest
import shortuuid

from npl_mcp.tool_sessions.tool_sessions import tool_session, tool_session_generate


# ---------------------------------------------------------------------------
# ToolSession.Generate
# ---------------------------------------------------------------------------


class TestToolSessionGenerate:
    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    async def test_create_new_session(self, mock_get_pool):
        new_id = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.return_value = None  # no existing
        pool.fetchval.return_value = new_id
        mock_get_pool.return_value = pool

        result = await tool_session_generate("agent-1", "Test brief", "task-1")
        assert result["status"] == "ok"
        assert result["action"] == "created"
        assert result["uuid"] == shortuuid.encode(new_id)
        pool.fetchval.assert_called_once()

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    async def test_create_with_notes(self, mock_get_pool):
        new_id = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.return_value = None
        pool.fetchval.return_value = new_id
        mock_get_pool.return_value = pool

        result = await tool_session_generate(
            "agent-1", "brief", "task-1", notes="initial note"
        )
        assert result["status"] == "ok"
        assert result["action"] == "created"
        # Verify notes was passed to INSERT
        call_args = pool.fetchval.call_args
        assert call_args[0][4] == "initial note"

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    async def test_existing_session_returned(self, mock_get_pool):
        existing_id = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.return_value = {"id": existing_id, "notes": "old note"}
        mock_get_pool.return_value = pool

        result = await tool_session_generate("agent-1", "brief", "task-1")
        assert result["action"] == "existing"
        assert result["uuid"] == shortuuid.encode(existing_id)
        pool.execute.assert_not_called()

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    async def test_existing_notes_appended(self, mock_get_pool):
        existing_id = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.return_value = {"id": existing_id, "notes": "old note"}
        mock_get_pool.return_value = pool

        result = await tool_session_generate(
            "agent-1", "brief", "task-1", notes="new note"
        )
        assert result["action"] == "existing_updated"
        pool.execute.assert_called_once()
        # Verify combined notes
        update_args = pool.execute.call_args[0]
        assert "old note\nnew note" in update_args[1]

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    async def test_existing_notes_substring_not_appended(self, mock_get_pool):
        existing_id = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.return_value = {"id": existing_id, "notes": "this is the note"}
        mock_get_pool.return_value = pool

        result = await tool_session_generate(
            "agent-1", "brief", "task-1", notes="the note"
        )
        assert result["action"] == "existing"
        pool.execute.assert_not_called()

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    async def test_existing_null_notes_appended(self, mock_get_pool):
        existing_id = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.return_value = {"id": existing_id, "notes": None}
        mock_get_pool.return_value = pool

        result = await tool_session_generate(
            "agent-1", "brief", "task-1", notes="first note"
        )
        assert result["action"] == "existing_updated"
        update_args = pool.execute.call_args[0]
        assert update_args[1] == "first note"

    async def test_empty_agent_rejected(self):
        result = await tool_session_generate("", "brief", "task-1")
        assert result["status"] == "error"

    async def test_empty_task_rejected(self):
        result = await tool_session_generate("agent-1", "brief", "")
        assert result["status"] == "error"


# ---------------------------------------------------------------------------
# ToolSession (get)
# ---------------------------------------------------------------------------


class TestToolSession:
    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    async def test_get_default(self, mock_get_pool):
        sid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.return_value = {"id": sid, "agent": "ag", "brief": "br"}
        mock_get_pool.return_value = pool

        # Accept both short and full UUID as input
        result = await tool_session(shortuuid.encode(sid))
        assert result["status"] == "ok"
        assert result["agent"] == "ag"
        assert result["brief"] == "br"
        assert result["uuid"] == shortuuid.encode(sid)
        assert "task" not in result

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    async def test_get_verbose(self, mock_get_pool):
        sid = uuid.uuid4()
        now = datetime.now(tz=timezone.utc)
        pool = AsyncMock()
        pool.fetchrow.return_value = {
            "id": sid,
            "agent": "ag",
            "brief": "br",
            "task": "tsk",
            "notes": "n",
            "created_at": now,
            "modified_at": now,
        }
        mock_get_pool.return_value = pool

        result = await tool_session(shortuuid.encode(sid), verbose=True)
        assert result["task"] == "tsk"
        assert result["notes"] == "n"
        assert "created_at" in result

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    async def test_accepts_full_uuid(self, mock_get_pool):
        sid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.return_value = {"id": sid, "agent": "ag", "brief": "br"}
        mock_get_pool.return_value = pool

        # Full UUID string should also work
        result = await tool_session(str(sid))
        assert result["status"] == "ok"
        assert result["uuid"] == shortuuid.encode(sid)

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    async def test_not_found(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetchrow.return_value = None
        mock_get_pool.return_value = pool

        result = await tool_session(shortuuid.encode(uuid.uuid4()))
        assert result["status"] == "not_found"

    async def test_invalid_uuid(self):
        result = await tool_session("!!invalid!!")
        assert result["status"] == "not_found"
