"""Tests for npl_mcp.tool_sessions.tool_sessions."""

import uuid
from datetime import datetime, timezone
from unittest.mock import AsyncMock, patch

import pytest
import shortuuid

from npl_mcp.tool_sessions.tool_sessions import (
    append_session_notes,
    tool_session,
    tool_session_generate,
)
from npl_mcp.tool_sessions.projects import project_uuid


# ---------------------------------------------------------------------------
# ToolSession.Generate
# ---------------------------------------------------------------------------


class TestToolSessionGenerate:
    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    @patch("npl_mcp.tool_sessions.tool_sessions.upsert_project")
    async def test_create_new_session(self, mock_upsert, mock_get_pool):
        new_id = uuid.uuid4()
        proj_id = project_uuid("test-project")
        mock_upsert.return_value = proj_id
        pool = AsyncMock()
        pool.fetchrow.return_value = None  # no existing
        pool.fetchval.return_value = new_id
        mock_get_pool.return_value = pool

        result = await tool_session_generate("agent-1", "Test brief", "task-1", project="test-project")
        assert result["status"] == "ok"
        assert result["action"] == "created"
        assert result["uuid"] == shortuuid.encode(new_id)
        assert result["project"] == "test-project"
        pool.fetchval.assert_called_once()

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    @patch("npl_mcp.tool_sessions.tool_sessions.upsert_project")
    async def test_create_with_notes(self, mock_upsert, mock_get_pool):
        new_id = uuid.uuid4()
        mock_upsert.return_value = project_uuid("test-project")
        pool = AsyncMock()
        pool.fetchrow.return_value = None
        pool.fetchval.return_value = new_id
        mock_get_pool.return_value = pool

        result = await tool_session_generate(
            "agent-1", "brief", "task-1", project="test-project", notes="initial note"
        )
        assert result["status"] == "ok"
        assert result["action"] == "created"
        # Verify notes was passed to INSERT
        call_args = pool.fetchval.call_args
        assert call_args[0][4] == "initial note"

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    @patch("npl_mcp.tool_sessions.tool_sessions.upsert_project")
    async def test_existing_session_returned(self, mock_upsert, mock_get_pool):
        existing_id = uuid.uuid4()
        mock_upsert.return_value = project_uuid("test-project")
        pool = AsyncMock()
        pool.fetchrow.return_value = {"id": existing_id, "notes": "old note"}
        mock_get_pool.return_value = pool

        result = await tool_session_generate("agent-1", "brief", "task-1", project="test-project")
        assert result["action"] == "existing"
        assert result["uuid"] == shortuuid.encode(existing_id)
        assert result["project"] == "test-project"
        pool.execute.assert_not_called()

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    @patch("npl_mcp.tool_sessions.tool_sessions.upsert_project")
    async def test_existing_notes_appended(self, mock_upsert, mock_get_pool):
        existing_id = uuid.uuid4()
        mock_upsert.return_value = project_uuid("test-project")
        pool = AsyncMock()
        pool.fetchrow.return_value = {"id": existing_id, "notes": "old note"}
        mock_get_pool.return_value = pool

        result = await tool_session_generate(
            "agent-1", "brief", "task-1", project="test-project", notes="new note"
        )
        assert result["action"] == "existing_updated"
        pool.execute.assert_called_once()
        # Verify combined notes
        update_args = pool.execute.call_args[0]
        assert "old note\nnew note" in update_args[1]

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    @patch("npl_mcp.tool_sessions.tool_sessions.upsert_project")
    async def test_existing_notes_substring_not_appended(self, mock_upsert, mock_get_pool):
        existing_id = uuid.uuid4()
        mock_upsert.return_value = project_uuid("test-project")
        pool = AsyncMock()
        pool.fetchrow.return_value = {"id": existing_id, "notes": "this is the note"}
        mock_get_pool.return_value = pool

        result = await tool_session_generate(
            "agent-1", "brief", "task-1", project="test-project", notes="the note"
        )
        assert result["action"] == "existing"
        pool.execute.assert_not_called()

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    @patch("npl_mcp.tool_sessions.tool_sessions.upsert_project")
    async def test_existing_null_notes_appended(self, mock_upsert, mock_get_pool):
        existing_id = uuid.uuid4()
        mock_upsert.return_value = project_uuid("test-project")
        pool = AsyncMock()
        pool.fetchrow.return_value = {"id": existing_id, "notes": None}
        mock_get_pool.return_value = pool

        result = await tool_session_generate(
            "agent-1", "brief", "task-1", project="test-project", notes="first note"
        )
        assert result["action"] == "existing_updated"
        update_args = pool.execute.call_args[0]
        assert update_args[1] == "first note"

    async def test_empty_agent_rejected(self):
        result = await tool_session_generate("", "brief", "task-1", project="test-project")
        assert result["status"] == "error"

    async def test_empty_task_rejected(self):
        result = await tool_session_generate("agent-1", "brief", "", project="test-project")
        assert result["status"] == "error"

    async def test_empty_project_rejected(self):
        result = await tool_session_generate("agent-1", "brief", "task-1", project="")
        assert result["status"] == "error"

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    @patch("npl_mcp.tool_sessions.tool_sessions.upsert_project")
    async def test_parent_resolved(self, mock_upsert, mock_get_pool):
        parent_id = uuid.uuid4()
        new_id = uuid.uuid4()
        mock_upsert.return_value = project_uuid("test-project")
        pool = AsyncMock()
        # fetchval for parent check returns the parent id
        pool.fetchval.side_effect = [parent_id, new_id]
        # fetchrow for session lookup returns None (new session)
        pool.fetchrow.return_value = None
        mock_get_pool.return_value = pool

        result = await tool_session_generate(
            "agent-1", "brief", "task-1",
            project="test-project",
            parent=shortuuid.encode(parent_id),
        )
        assert result["status"] == "ok"
        assert result["action"] == "created"

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    @patch("npl_mcp.tool_sessions.tool_sessions.upsert_project")
    async def test_parent_not_found(self, mock_upsert, mock_get_pool):
        mock_upsert.return_value = project_uuid("test-project")
        pool = AsyncMock()
        pool.fetchval.return_value = None  # parent doesn't exist
        mock_get_pool.return_value = pool

        fake_parent = shortuuid.encode(uuid.uuid4())
        result = await tool_session_generate(
            "agent-1", "brief", "task-1",
            project="test-project",
            parent=fake_parent,
        )
        assert result["status"] == "error"
        assert "Parent session not found" in result["message"]

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    @patch("npl_mcp.tool_sessions.tool_sessions.upsert_project")
    async def test_invalid_parent_uuid(self, mock_upsert, mock_get_pool):
        mock_upsert.return_value = project_uuid("test-project")
        pool = AsyncMock()
        mock_get_pool.return_value = pool

        result = await tool_session_generate(
            "agent-1", "brief", "task-1",
            project="test-project",
            parent="!!invalid!!",
        )
        assert result["status"] == "error"
        assert "Invalid parent UUID" in result["message"]


# ---------------------------------------------------------------------------
# ToolSession (get)
# ---------------------------------------------------------------------------


class TestToolSession:
    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    async def test_get_default(self, mock_get_pool):
        sid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.return_value = {"id": sid, "agent": "ag", "brief": "br", "project": "my-proj"}
        mock_get_pool.return_value = pool

        result = await tool_session(shortuuid.encode(sid))
        assert result["status"] == "ok"
        assert result["agent"] == "ag"
        assert result["brief"] == "br"
        assert result["project"] == "my-proj"
        assert result["uuid"] == shortuuid.encode(sid)
        assert "task" not in result

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    async def test_get_verbose(self, mock_get_pool):
        sid = uuid.uuid4()
        parent_id = uuid.uuid4()
        now = datetime.now(tz=timezone.utc)
        pool = AsyncMock()
        pool.fetchrow.return_value = {
            "id": sid,
            "agent": "ag",
            "brief": "br",
            "task": "tsk",
            "notes": "n",
            "parent_id": parent_id,
            "created_at": now,
            "updated_at": now,
            "project": "my-proj",
        }
        mock_get_pool.return_value = pool

        result = await tool_session(shortuuid.encode(sid), verbose=True)
        assert result["task"] == "tsk"
        assert result["notes"] == "n"
        assert result["parent"] == shortuuid.encode(parent_id)
        assert result["project"] == "my-proj"
        assert "created_at" in result

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    async def test_verbose_null_parent(self, mock_get_pool):
        sid = uuid.uuid4()
        now = datetime.now(tz=timezone.utc)
        pool = AsyncMock()
        pool.fetchrow.return_value = {
            "id": sid,
            "agent": "ag",
            "brief": "br",
            "task": "tsk",
            "notes": None,
            "parent_id": None,
            "created_at": now,
            "updated_at": now,
            "project": "my-proj",
        }
        mock_get_pool.return_value = pool

        result = await tool_session(shortuuid.encode(sid), verbose=True)
        assert result["parent"] is None

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    async def test_accepts_full_uuid(self, mock_get_pool):
        sid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.return_value = {"id": sid, "agent": "ag", "brief": "br", "project": "p"}
        mock_get_pool.return_value = pool

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


# ---------------------------------------------------------------------------
# append_session_notes
# ---------------------------------------------------------------------------


class TestAppendSessionNotes:
    async def test_empty_note_rejected(self):
        result = await append_session_notes(shortuuid.encode(uuid.uuid4()), "   ")
        assert result["status"] == "error"

    async def test_invalid_uuid(self):
        result = await append_session_notes("!!nope!!", "a note")
        assert result["status"] == "not_found"

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    async def test_session_missing(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetchrow.return_value = None
        mock_get_pool.return_value = pool

        result = await append_session_notes(shortuuid.encode(uuid.uuid4()), "hi")
        assert result["status"] == "not_found"

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    async def test_appends_new_note(self, mock_get_pool):
        sid = uuid.uuid4()
        parent = None
        now = datetime.now(tz=timezone.utc)
        pool = AsyncMock()
        pool.fetchrow.side_effect = [
            {
                "id": sid, "agent": "ag", "brief": "br", "task": "tk",
                "notes": "existing", "parent_id": parent,
                "created_at": now, "updated_at": now, "project": "proj",
            },
            {"updated_at": now},
        ]
        mock_get_pool.return_value = pool

        result = await append_session_notes(shortuuid.encode(sid), "new")
        assert result["status"] == "ok"
        assert result["action"] == "appended"
        assert result["notes"] == "existing\nnew"
        assert result["project"] == "proj"
        pool.execute.assert_called_once()

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    async def test_appends_to_empty_notes(self, mock_get_pool):
        sid = uuid.uuid4()
        now = datetime.now(tz=timezone.utc)
        pool = AsyncMock()
        pool.fetchrow.side_effect = [
            {
                "id": sid, "agent": "ag", "brief": "br", "task": "tk",
                "notes": None, "parent_id": None,
                "created_at": now, "updated_at": now, "project": "proj",
            },
            {"updated_at": now},
        ]
        mock_get_pool.return_value = pool

        result = await append_session_notes(shortuuid.encode(sid), "first")
        assert result["status"] == "ok"
        assert result["notes"] == "first"
        pool.execute.assert_called_once()

    @patch("npl_mcp.tool_sessions.tool_sessions.get_pool")
    async def test_dedupes_substring(self, mock_get_pool):
        sid = uuid.uuid4()
        now = datetime.now(tz=timezone.utc)
        pool = AsyncMock()
        pool.fetchrow.return_value = {
            "id": sid, "agent": "ag", "brief": "br", "task": "tk",
            "notes": "already here\nwith more", "parent_id": None,
            "created_at": now, "updated_at": now, "project": "proj",
        }
        mock_get_pool.return_value = pool

        result = await append_session_notes(shortuuid.encode(sid), "already here")
        assert result["status"] == "ok"
        assert result["action"] == "noop"
        assert result["notes"] == "already here\nwith more"
        pool.execute.assert_not_called()
