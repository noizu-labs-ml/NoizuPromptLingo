"""Unit tests for npl_mcp.sessions.sessions (tier-C MVP, generic sessions)."""

from __future__ import annotations

import uuid
from datetime import datetime, timezone
from unittest.mock import AsyncMock, patch

import pytest
import shortuuid

from npl_mcp.sessions.sessions import (
    VALID_STATUSES,
    session_create,
    session_get,
    session_list,
    session_update,
)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _session_row(**overrides) -> dict:
    now = datetime(2026, 4, 21, 12, 0, 0, tzinfo=timezone.utc)
    sid = uuid.uuid4()
    base = {
        "id": sid,
        "title": "Sprint 12",
        "status": "active",
        "description": "Work tracking for sprint 12.",
        "created_by": None,
        "created_at": now,
        "updated_at": now,
    }
    base.update(overrides)
    return base


# ---------------------------------------------------------------------------
# session_create
# ---------------------------------------------------------------------------

class TestSessionCreate:
    async def test_rejects_invalid_status(self):
        result = await session_create(status="widget")
        assert result["status"] == "error"

    @patch("npl_mcp.sessions.sessions.get_pool")
    async def test_create_ok(self, mock_pool):
        row = _session_row(title="X")
        pool = AsyncMock()
        pool.fetchrow.return_value = row
        mock_pool.return_value = pool

        result = await session_create(title="X")
        assert result["status"] == "ok"
        assert result["title"] == "X"
        assert result["session_status"] == "active"
        assert result["uuid"] == shortuuid.encode(row["id"])


# ---------------------------------------------------------------------------
# session_get
# ---------------------------------------------------------------------------

class TestSessionGet:
    async def test_invalid_uuid_returns_not_found(self):
        result = await session_get("!!nope!!")
        assert result["status"] == "not_found"

    @patch("npl_mcp.sessions.sessions.get_pool")
    async def test_missing(self, mock_pool):
        pool = AsyncMock()
        pool.fetchrow.return_value = None
        mock_pool.return_value = pool

        sid = shortuuid.encode(uuid.uuid4())
        result = await session_get(sid)
        assert result["status"] == "not_found"

    @patch("npl_mcp.sessions.sessions.get_pool")
    async def test_found(self, mock_pool):
        row = _session_row(status="paused")
        pool = AsyncMock()
        pool.fetchrow.return_value = row
        mock_pool.return_value = pool

        result = await session_get(shortuuid.encode(row["id"]))
        assert result["status"] == "ok"
        assert result["session_status"] == "paused"
        assert result["title"] == "Sprint 12"


# ---------------------------------------------------------------------------
# session_list
# ---------------------------------------------------------------------------

class TestSessionList:
    async def test_rejects_invalid_status(self):
        result = await session_list(status="widget")
        assert result["status"] == "error"

    @patch("npl_mcp.sessions.sessions.get_pool")
    async def test_empty(self, mock_pool):
        pool = AsyncMock()
        pool.fetch.return_value = []
        mock_pool.return_value = pool

        result = await session_list()
        assert result["status"] == "ok"
        assert result["sessions"] == []
        assert result["count"] == 0

    @patch("npl_mcp.sessions.sessions.get_pool")
    async def test_status_filter(self, mock_pool):
        pool = AsyncMock()
        pool.fetch.return_value = [_session_row(status="completed")]
        mock_pool.return_value = pool

        result = await session_list(status="completed")
        assert result["count"] == 1
        assert result["sessions"][0]["session_status"] == "completed"
        sql, *args = pool.fetch.call_args[0]
        assert "status = $1" in sql
        assert args == ["completed", 50]

    @patch("npl_mcp.sessions.sessions.get_pool")
    async def test_limit_clamped(self, mock_pool):
        pool = AsyncMock()
        pool.fetch.return_value = []
        mock_pool.return_value = pool

        await session_list(limit=99999)
        _, *args = pool.fetch.call_args[0]
        assert args[-1] == 200

        await session_list(limit=0)
        _, *args = pool.fetch.call_args[0]
        assert args[-1] == 1


# ---------------------------------------------------------------------------
# session_update
# ---------------------------------------------------------------------------

class TestSessionUpdate:
    async def test_no_fields_returns_error(self):
        sid = shortuuid.encode(uuid.uuid4())
        result = await session_update(sid)
        assert result["status"] == "error"

    async def test_invalid_status_returns_error(self):
        sid = shortuuid.encode(uuid.uuid4())
        result = await session_update(sid, status="widget")
        assert result["status"] == "error"

    async def test_invalid_uuid_returns_not_found(self):
        result = await session_update("!!bad!!", title="X")
        assert result["status"] == "not_found"

    @patch("npl_mcp.sessions.sessions.get_pool")
    async def test_missing_session_returns_not_found(self, mock_pool):
        pool = AsyncMock()
        pool.fetchrow.return_value = None
        mock_pool.return_value = pool

        sid = shortuuid.encode(uuid.uuid4())
        result = await session_update(sid, title="X")
        assert result["status"] == "not_found"

    @patch("npl_mcp.sessions.sessions.get_pool")
    async def test_update_title_and_status(self, mock_pool):
        row = _session_row(title="Renamed", status="paused")
        pool = AsyncMock()
        pool.fetchrow.return_value = row
        mock_pool.return_value = pool

        result = await session_update(
            shortuuid.encode(row["id"]), title="Renamed", status="paused",
        )
        assert result["status"] == "ok"
        assert result["title"] == "Renamed"
        assert result["session_status"] == "paused"

        # Verify SQL placeholders line up (title at $1, status at $2, uuid at $3)
        sql, *args = pool.fetchrow.call_args[0]
        assert "title = $1" in sql
        assert "status = $2" in sql
        assert "WHERE id = $3" in sql
        assert args == ["Renamed", "paused", row["id"]]


class TestValidStatuses:
    def test_expected_statuses(self):
        assert VALID_STATUSES == {"active", "paused", "completed", "archived"}
