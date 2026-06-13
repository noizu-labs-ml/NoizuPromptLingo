"""Unit tests for npl_mcp.tasks.tasks (tier-C MVP)."""

from __future__ import annotations

from datetime import datetime, timezone
from unittest.mock import AsyncMock, patch

import pytest

from npl_mcp.tasks.tasks import (
    VALID_STATUSES,
    task_create,
    task_get,
    task_list,
    task_update_status,
)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _task_row(**overrides) -> dict:
    now = datetime(2026, 4, 21, 12, 0, 0, tzinfo=timezone.utc)
    base = {
        "id": 42,
        "title": "Write PRD",
        "description": "Describe the new feature",
        "status": "pending",
        "priority": 1,
        "assigned_to": None,
        "notes": None,
        "created_at": now,
        "updated_at": now,
    }
    base.update(overrides)
    return base


# ---------------------------------------------------------------------------
# task_create
# ---------------------------------------------------------------------------

class TestTaskCreate:
    async def test_rejects_empty_title(self):
        result = await task_create("   ")
        assert result["status"] == "error"
        assert "title" in result["message"].lower()

    async def test_rejects_invalid_status(self):
        result = await task_create("valid title", status="widget")
        assert result["status"] == "error"
        assert "widget" in result["message"]

    @patch("npl_mcp.tasks.tasks.get_pool")
    async def test_create_success_returns_task_envelope(self, mock_pool):
        pool = AsyncMock()
        pool.fetchrow.return_value = _task_row(title="Ship US-225")
        mock_pool.return_value = pool

        result = await task_create("Ship US-225")
        assert result["status"] == "ok"
        assert result["id"] == 42
        assert result["title"] == "Ship US-225"
        assert result["task_status"] == "pending"
        assert result["priority"] == 1

    @patch("npl_mcp.tasks.tasks.get_pool")
    async def test_create_trims_title_and_passes_all_fields(self, mock_pool):
        pool = AsyncMock()
        pool.fetchrow.return_value = _task_row(
            title="Build docs",
            description="Regenerate npl-full.md",
            status="in_progress",
            priority=2,
            assigned_to="npl-tdd-coder",
            notes="kick-off note",
        )
        mock_pool.return_value = pool

        result = await task_create(
            "   Build docs   ",
            description="Regenerate npl-full.md",
            status="in_progress",
            priority=2,
            assigned_to="npl-tdd-coder",
            notes="kick-off note",
        )
        assert result["status"] == "ok"
        call_args = pool.fetchrow.call_args[0]
        # Positional args: sql, title, description, status, priority, assigned_to, notes
        assert call_args[1] == "Build docs"  # trimmed
        assert call_args[3] == "in_progress"
        assert call_args[6] == "kick-off note"


# ---------------------------------------------------------------------------
# task_get
# ---------------------------------------------------------------------------

class TestTaskGet:
    async def test_rejects_non_integer_id(self):
        result = await task_get("not-a-number")  # type: ignore[arg-type]
        assert result["status"] == "error"

    @patch("npl_mcp.tasks.tasks.get_pool")
    async def test_not_found(self, mock_pool):
        pool = AsyncMock()
        pool.fetchrow.return_value = None
        mock_pool.return_value = pool

        result = await task_get(999)
        assert result["status"] == "not_found"
        assert result["id"] == 999

    @patch("npl_mcp.tasks.tasks.get_pool")
    async def test_found(self, mock_pool):
        pool = AsyncMock()
        pool.fetchrow.return_value = _task_row(id=7, title="Doc review")
        mock_pool.return_value = pool

        result = await task_get(7)
        assert result["status"] == "ok"
        assert result["id"] == 7
        assert result["title"] == "Doc review"


# ---------------------------------------------------------------------------
# task_list
# ---------------------------------------------------------------------------

class TestTaskList:
    async def test_rejects_invalid_status(self):
        result = await task_list(status="widget")
        assert result["status"] == "error"

    @patch("npl_mcp.tasks.tasks.get_pool")
    async def test_empty(self, mock_pool):
        pool = AsyncMock()
        pool.fetch.return_value = []
        mock_pool.return_value = pool

        result = await task_list()
        assert result["status"] == "ok"
        assert result["tasks"] == []
        assert result["count"] == 0

    @patch("npl_mcp.tasks.tasks.get_pool")
    async def test_filters_by_status_and_assignee(self, mock_pool):
        pool = AsyncMock()
        pool.fetch.return_value = [
            _task_row(id=1, status="in_progress", assigned_to="alice"),
            _task_row(id=2, status="in_progress", assigned_to="alice"),
        ]
        mock_pool.return_value = pool

        result = await task_list(status="in_progress", assigned_to="alice")
        assert result["status"] == "ok"
        assert result["count"] == 2
        # Verify the SQL call had both filters and the limit at the end
        sql, *args = pool.fetch.call_args[0]
        assert "status = $1" in sql
        assert "assigned_to = $2" in sql
        assert args == ["in_progress", "alice", 100]

    @patch("npl_mcp.tasks.tasks.get_pool")
    async def test_limit_clamped_to_range(self, mock_pool):
        pool = AsyncMock()
        pool.fetch.return_value = []
        mock_pool.return_value = pool

        # Above max
        await task_list(limit=99999)
        sql, *args = pool.fetch.call_args[0]
        assert args[-1] == 500

        # Below min
        await task_list(limit=0)
        sql, *args = pool.fetch.call_args[0]
        assert args[-1] == 1

        # Garbage → default
        await task_list(limit="garbage")  # type: ignore[arg-type]
        sql, *args = pool.fetch.call_args[0]
        assert args[-1] == 100


# ---------------------------------------------------------------------------
# task_update_status
# ---------------------------------------------------------------------------

class TestTaskUpdateStatus:
    async def test_rejects_invalid_status(self):
        result = await task_update_status(1, "widget")
        assert result["status"] == "error"

    async def test_rejects_non_integer_id(self):
        result = await task_update_status("abc", "done")  # type: ignore[arg-type]
        assert result["status"] == "error"

    @patch("npl_mcp.tasks.tasks.get_pool")
    async def test_not_found(self, mock_pool):
        pool = AsyncMock()
        pool.fetchrow.return_value = None  # existing lookup
        mock_pool.return_value = pool

        result = await task_update_status(99, "done")
        assert result["status"] == "not_found"

    @patch("npl_mcp.tasks.tasks.get_pool")
    async def test_updates_status_without_notes(self, mock_pool):
        pool = AsyncMock()
        pool.fetchrow.side_effect = [
            {"id": 1, "notes": "existing"},  # existence check
            _task_row(id=1, status="done", notes="existing"),  # returning row
        ]
        mock_pool.return_value = pool

        result = await task_update_status(1, "done")
        assert result["status"] == "ok"
        assert result["task_status"] == "done"
        assert result["notes"] == "existing"  # unchanged

    @patch("npl_mcp.tasks.tasks.get_pool")
    async def test_appends_note(self, mock_pool):
        pool = AsyncMock()
        pool.fetchrow.side_effect = [
            {"id": 1, "notes": "prior"},
            _task_row(id=1, status="done", notes="prior\nstarted"),
        ]
        mock_pool.return_value = pool

        result = await task_update_status(1, "done", notes="started")
        assert result["status"] == "ok"
        assert result["notes"] == "prior\nstarted"
        # Verify UPDATE SQL was called with appended notes
        update_args = pool.fetchrow.call_args_list[1][0]
        # Positional: sql, status, new_notes, tid
        assert update_args[1] == "done"
        assert update_args[2] == "prior\nstarted"
        assert update_args[3] == 1

    @patch("npl_mcp.tasks.tasks.get_pool")
    async def test_dedupes_substring_note(self, mock_pool):
        pool = AsyncMock()
        pool.fetchrow.side_effect = [
            {"id": 1, "notes": "already here"},
            _task_row(id=1, status="done", notes="already here"),
        ]
        mock_pool.return_value = pool

        result = await task_update_status(1, "done", notes="already here")
        assert result["status"] == "ok"
        # UPDATE SQL called with new_notes = existing (unchanged)
        update_args = pool.fetchrow.call_args_list[1][0]
        assert update_args[2] == "already here"


class TestValidStatuses:
    def test_expected_statuses(self):
        assert VALID_STATUSES == {"pending", "in_progress", "blocked", "review", "done"}
