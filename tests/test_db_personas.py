"""Tests for npl_mcp.pm_tools.db_personas CRUD operations."""

import json
import uuid
from datetime import datetime, timezone
from unittest.mock import AsyncMock, patch

import pytest
import shortuuid

from npl_mcp.pm_tools.db_personas import (
    persona_create,
    persona_delete,
    persona_get,
    persona_list,
    persona_update,
)


def _encode(uid: uuid.UUID) -> str:
    return shortuuid.encode(uid)


def _make_row(
    *,
    id: uuid.UUID | None = None,
    project_id: uuid.UUID | None = None,
    name: str = "Test Persona",
    role: str | None = "Engineer",
    description: str | None = "A test persona",
    goals: str | None = "Ship features",
    pain_points: str | None = "Too many meetings",
    behaviors: str | None = "Writes tests first",
    physical_description: str | None = None,
    persona_image: str | None = None,
    demographics: str | None = None,
    created_by: uuid.UUID | None = None,
    created_at: datetime | None = None,
    updated_at: datetime | None = None,
) -> dict:
    now = datetime.now(tz=timezone.utc)
    return {
        "id": id or uuid.uuid4(),
        "project_id": project_id or uuid.uuid4(),
        "name": name,
        "role": role,
        "description": description,
        "goals": goals,
        "pain_points": pain_points,
        "behaviors": behaviors,
        "physical_description": physical_description,
        "persona_image": persona_image,
        "demographics": demographics,
        "created_by": created_by,
        "created_at": created_at or now,
        "updated_at": updated_at or now,
    }


# ---------------------------------------------------------------------------
# persona_create
# ---------------------------------------------------------------------------


class TestPersonaCreate:
    @patch("npl_mcp.pm_tools.db_personas.get_pool")
    async def test_success(self, mock_get_pool):
        proj_id = uuid.uuid4()
        persona_id = uuid.uuid4()

        pool = AsyncMock()
        pool.fetchval.return_value = persona_id
        mock_get_pool.return_value = pool

        result = await persona_create(
            project_id=_encode(proj_id),
            name="Alice",
            role="Designer",
        )

        assert result["status"] == "ok"
        assert result["uuid"] == _encode(persona_id)
        pool.fetchval.assert_called_once()
        call_args = pool.fetchval.call_args[0]
        assert call_args[1] == proj_id
        assert call_args[2] == "Alice"
        assert call_args[3] == "Designer"

    async def test_empty_name_returns_error(self):
        result = await persona_create(
            project_id=_encode(uuid.uuid4()),
            name="",
        )
        assert result["status"] == "error"
        assert "name" in result["message"].lower()

    async def test_invalid_project_id_returns_error(self):
        result = await persona_create(
            project_id="!!not-a-uuid!!",
            name="Bob",
        )
        assert result["status"] == "error"
        assert "project_id" in result["message"].lower() or "UUID" in result["message"]

    @patch("npl_mcp.pm_tools.db_personas.get_pool")
    async def test_with_demographics(self, mock_get_pool):
        proj_id = uuid.uuid4()
        persona_id = uuid.uuid4()

        pool = AsyncMock()
        pool.fetchval.return_value = persona_id
        mock_get_pool.return_value = pool

        demographics = {"age": "25-35", "location": "US"}
        result = await persona_create(
            project_id=_encode(proj_id),
            name="Carol",
            demographics=demographics,
        )

        assert result["status"] == "ok"
        # demographics is the 10th positional arg ($10)
        call_args = pool.fetchval.call_args[0]
        assert call_args[10] == json.dumps(demographics)


# ---------------------------------------------------------------------------
# persona_get
# ---------------------------------------------------------------------------


class TestPersonaGet:
    @patch("npl_mcp.pm_tools.db_personas.get_pool")
    async def test_success(self, mock_get_pool):
        pid = uuid.uuid4()
        proj_id = uuid.uuid4()
        now = datetime.now(tz=timezone.utc)

        row = _make_row(
            id=pid,
            project_id=proj_id,
            name="Dave",
            demographics='{"age": "25-35"}',
            created_at=now,
            updated_at=now,
        )

        pool = AsyncMock()
        pool.fetchrow.return_value = row
        mock_get_pool.return_value = pool

        result = await persona_get(_encode(pid))

        assert result["status"] == "ok"
        assert result["uuid"] == _encode(pid)
        assert result["name"] == "Dave"
        assert result["project_id"] == _encode(proj_id)
        assert result["demographics"] == {"age": "25-35"}
        assert result["created_at"] == now.isoformat()

    @patch("npl_mcp.pm_tools.db_personas.get_pool")
    async def test_not_found(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetchrow.return_value = None
        mock_get_pool.return_value = pool

        encoded = _encode(uuid.uuid4())
        result = await persona_get(encoded)

        assert result["status"] == "not_found"
        assert result["uuid"] == encoded

    async def test_invalid_uuid(self):
        result = await persona_get("!!invalid!!")
        assert result["status"] == "error"
        assert "UUID" in result["message"] or "Invalid" in result["message"]


# ---------------------------------------------------------------------------
# persona_update
# ---------------------------------------------------------------------------


class TestPersonaUpdate:
    @patch("npl_mcp.pm_tools.db_personas.get_pool")
    async def test_success(self, mock_get_pool):
        pid = uuid.uuid4()

        pool = AsyncMock()
        pool.fetchval.return_value = pid  # exists
        mock_get_pool.return_value = pool

        result = await persona_update(
            id=_encode(pid),
            name="Updated Name",
            role="Lead",
        )

        assert result["status"] == "ok"
        assert result["uuid"] == _encode(pid)
        pool.execute.assert_called_once()
        sql = pool.execute.call_args[0][0]
        assert "name = $1" in sql
        assert "role = $2" in sql

    @patch("npl_mcp.pm_tools.db_personas.get_pool")
    async def test_not_found(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetchval.return_value = None  # does not exist
        mock_get_pool.return_value = pool

        encoded = _encode(uuid.uuid4())
        result = await persona_update(id=encoded, name="Nope")

        assert result["status"] == "not_found"
        assert result["uuid"] == encoded
        pool.execute.assert_not_called()

    @patch("npl_mcp.pm_tools.db_personas.get_pool")
    async def test_no_fields(self, mock_get_pool):
        pid = uuid.uuid4()

        pool = AsyncMock()
        pool.fetchval.return_value = pid
        mock_get_pool.return_value = pool

        result = await persona_update(id=_encode(pid))

        assert result["status"] == "ok"
        assert "No fields" in result["message"]
        pool.execute.assert_not_called()

    @patch("npl_mcp.pm_tools.db_personas.get_pool")
    async def test_with_demographics(self, mock_get_pool):
        pid = uuid.uuid4()

        pool = AsyncMock()
        pool.fetchval.return_value = pid
        mock_get_pool.return_value = pool

        demographics = {"age": "30-40"}
        result = await persona_update(
            id=_encode(pid),
            demographics=demographics,
        )

        assert result["status"] == "ok"
        call_args = pool.execute.call_args[0]
        sql = call_args[0]
        assert "demographics" in sql
        assert "::jsonb" in sql
        # demographics JSON string is in the positional params
        assert json.dumps(demographics) in call_args[1:]

    async def test_invalid_uuid(self):
        result = await persona_update(id="!!invalid!!", name="X")
        assert result["status"] == "error"
        assert "UUID" in result["message"] or "Invalid" in result["message"]


# ---------------------------------------------------------------------------
# persona_delete
# ---------------------------------------------------------------------------


class TestPersonaDelete:
    @patch("npl_mcp.pm_tools.db_personas.get_pool")
    async def test_success(self, mock_get_pool):
        pid = uuid.uuid4()

        pool = AsyncMock()
        pool.execute.return_value = "UPDATE 1"
        mock_get_pool.return_value = pool

        result = await persona_delete(_encode(pid))

        assert result["status"] == "ok"
        assert result["uuid"] == _encode(pid)
        pool.execute.assert_called_once()

    @patch("npl_mcp.pm_tools.db_personas.get_pool")
    async def test_not_found(self, mock_get_pool):
        pool = AsyncMock()
        pool.execute.return_value = "UPDATE 0"
        mock_get_pool.return_value = pool

        encoded = _encode(uuid.uuid4())
        result = await persona_delete(encoded)

        assert result["status"] == "not_found"
        assert result["uuid"] == encoded

    async def test_invalid_uuid(self):
        result = await persona_delete("!!invalid!!")
        assert result["status"] == "error"
        assert "UUID" in result["message"] or "Invalid" in result["message"]


# ---------------------------------------------------------------------------
# persona_list
# ---------------------------------------------------------------------------


class TestPersonaList:
    @patch("npl_mcp.pm_tools.db_personas.get_pool")
    async def test_success(self, mock_get_pool):
        proj_id = uuid.uuid4()
        now = datetime.now(tz=timezone.utc)

        rows = [
            _make_row(project_id=proj_id, name="P1", demographics='{"age": "20-30"}', created_at=now, updated_at=now),
            _make_row(project_id=proj_id, name="P2", demographics=None, created_at=now, updated_at=now),
        ]

        pool = AsyncMock()
        pool.fetchval.return_value = 2
        pool.fetch.return_value = rows
        mock_get_pool.return_value = pool

        result = await persona_list(project_id=_encode(proj_id))

        assert result["status"] == "ok"
        assert result["total"] == 2
        assert result["page"] == 1
        assert result["page_size"] == 20
        assert len(result["personas"]) == 2
        assert result["personas"][0]["name"] == "P1"
        assert result["personas"][0]["demographics"] == {"age": "20-30"}
        assert result["personas"][1]["demographics"] is None

    @patch("npl_mcp.pm_tools.db_personas.get_pool")
    async def test_empty_list(self, mock_get_pool):
        proj_id = uuid.uuid4()

        pool = AsyncMock()
        pool.fetchval.return_value = 0
        pool.fetch.return_value = []
        mock_get_pool.return_value = pool

        result = await persona_list(project_id=_encode(proj_id))

        assert result["status"] == "ok"
        assert result["total"] == 0
        assert result["personas"] == []

    async def test_invalid_project_id(self):
        result = await persona_list(project_id="!!invalid!!")
        assert result["status"] == "error"
        assert "project_id" in result["message"].lower() or "UUID" in result["message"]

    @patch("npl_mcp.pm_tools.db_personas.get_pool")
    async def test_pagination(self, mock_get_pool):
        proj_id = uuid.uuid4()

        pool = AsyncMock()
        pool.fetchval.return_value = 50
        pool.fetch.return_value = []
        mock_get_pool.return_value = pool

        result = await persona_list(project_id=_encode(proj_id), page=3, page_size=10)

        assert result["page"] == 3
        assert result["page_size"] == 10
        # Verify offset = (3-1) * 10 = 20 was passed
        fetch_args = pool.fetch.call_args[0]
        assert fetch_args[2] == 10   # page_size / LIMIT
        assert fetch_args[3] == 20   # offset
