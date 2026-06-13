"""Tests for npl_mcp.pm_tools.db_projects."""

import uuid
from datetime import datetime, timezone
from unittest.mock import AsyncMock, patch

import pytest
import shortuuid

from npl_mcp.pm_tools.db_projects import project_create, project_get, project_list


# ---------------------------------------------------------------------------
# project_create
# ---------------------------------------------------------------------------


class TestProjectCreate:
    @patch("npl_mcp.pm_tools.db_projects.get_pool")
    async def test_create_success(self, mock_get_pool):
        new_id = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchval.return_value = new_id
        mock_get_pool.return_value = pool

        result = await project_create("My Project", description="A description")
        assert result["status"] == "ok"
        assert result["uuid"] == shortuuid.encode(new_id)
        pool.fetchval.assert_called_once()
        call_args = pool.fetchval.call_args[0]
        assert call_args[1] == "My Project"
        assert call_args[2] == "A description"

    @patch("npl_mcp.pm_tools.db_projects.get_pool")
    async def test_create_without_description(self, mock_get_pool):
        new_id = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchval.return_value = new_id
        mock_get_pool.return_value = pool

        result = await project_create("Bare Project")
        assert result["status"] == "ok"
        assert result["uuid"] == shortuuid.encode(new_id)
        call_args = pool.fetchval.call_args[0]
        assert call_args[2] is None

    async def test_empty_name_rejected(self):
        result = await project_create("")
        assert result["status"] == "error"
        assert "name" in result["message"].lower()

    async def test_none_name_rejected(self):
        result = await project_create(None)
        assert result["status"] == "error"


# ---------------------------------------------------------------------------
# project_get
# ---------------------------------------------------------------------------


class TestProjectGet:
    @patch("npl_mcp.pm_tools.db_projects.get_pool")
    async def test_get_success(self, mock_get_pool):
        pid = uuid.uuid4()
        now = datetime.now(tz=timezone.utc)
        pool = AsyncMock()
        pool.fetchrow.return_value = {
            "id": pid,
            "name": "Test Project",
            "description": "desc",
            "created_at": now,
            "updated_at": now,
        }
        mock_get_pool.return_value = pool

        result = await project_get(shortuuid.encode(pid))
        assert result["status"] == "ok"
        assert result["uuid"] == shortuuid.encode(pid)
        assert result["name"] == "Test Project"
        assert result["description"] == "desc"
        assert result["created_at"] == now.isoformat()
        assert result["updated_at"] == now.isoformat()

    @patch("npl_mcp.pm_tools.db_projects.get_pool")
    async def test_get_accepts_full_uuid(self, mock_get_pool):
        pid = uuid.uuid4()
        now = datetime.now(tz=timezone.utc)
        pool = AsyncMock()
        pool.fetchrow.return_value = {
            "id": pid,
            "name": "P",
            "description": None,
            "created_at": now,
            "updated_at": now,
        }
        mock_get_pool.return_value = pool

        result = await project_get(str(pid))
        assert result["status"] == "ok"
        assert result["uuid"] == shortuuid.encode(pid)

    @patch("npl_mcp.pm_tools.db_projects.get_pool")
    async def test_get_not_found(self, mock_get_pool):
        pid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.return_value = None
        mock_get_pool.return_value = pool

        encoded = shortuuid.encode(pid)
        result = await project_get(encoded)
        assert result["status"] == "not_found"
        assert result["uuid"] == encoded

    async def test_get_invalid_uuid(self):
        result = await project_get("!!invalid!!")
        assert result["status"] == "error"
        assert result["uuid"] == "!!invalid!!"
        assert "Invalid UUID" in result["message"]


# ---------------------------------------------------------------------------
# project_list
# ---------------------------------------------------------------------------


class TestProjectList:
    @patch("npl_mcp.pm_tools.db_projects.get_pool")
    async def test_list_success(self, mock_get_pool):
        pid1 = uuid.uuid4()
        pid2 = uuid.uuid4()
        now = datetime.now(tz=timezone.utc)
        pool = AsyncMock()
        pool.fetchval.return_value = 2
        pool.fetch.return_value = [
            {"id": pid1, "name": "P1", "description": "d1", "created_at": now},
            {"id": pid2, "name": "P2", "description": None, "created_at": now},
        ]
        mock_get_pool.return_value = pool

        result = await project_list()
        assert result["status"] == "ok"
        assert result["total"] == 2
        assert result["page"] == 1
        assert result["page_size"] == 20
        assert len(result["projects"]) == 2
        assert result["projects"][0]["uuid"] == shortuuid.encode(pid1)
        assert result["projects"][0]["name"] == "P1"
        assert result["projects"][1]["uuid"] == shortuuid.encode(pid2)

    @patch("npl_mcp.pm_tools.db_projects.get_pool")
    async def test_list_empty(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetchval.return_value = 0
        pool.fetch.return_value = []
        mock_get_pool.return_value = pool

        result = await project_list()
        assert result["status"] == "ok"
        assert result["total"] == 0
        assert result["projects"] == []

    @patch("npl_mcp.pm_tools.db_projects.get_pool")
    async def test_list_pagination_params(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetchval.return_value = 50
        pool.fetch.return_value = []
        mock_get_pool.return_value = pool

        result = await project_list(page=3, page_size=10)
        assert result["page"] == 3
        assert result["page_size"] == 10
        # Verify LIMIT and OFFSET args: LIMIT=10, OFFSET=20
        fetch_args = pool.fetch.call_args[0]
        assert fetch_args[1] == 10  # page_size
        assert fetch_args[2] == 20  # offset = (3-1)*10

    @patch("npl_mcp.pm_tools.db_projects.get_pool")
    async def test_list_page_zero_clamps_to_one(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetchval.return_value = 0
        pool.fetch.return_value = []
        mock_get_pool.return_value = pool

        result = await project_list(page=0, page_size=5)
        fetch_args = pool.fetch.call_args[0]
        assert fetch_args[2] == 0  # offset = (max(1,0)-1)*5 = 0
