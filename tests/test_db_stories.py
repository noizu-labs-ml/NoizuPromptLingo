"""Tests for npl_mcp.pm_tools.db_stories."""

import json
import uuid
from datetime import datetime, timezone
from unittest.mock import AsyncMock, patch

import pytest
import shortuuid

from npl_mcp.pm_tools.db_stories import (
    story_create,
    story_delete,
    story_get,
    story_list,
    story_update,
)


def _make_row(
    story_id=None,
    project_id=None,
    persona_ids=None,
    title="Test Story",
    story_text="As a user I want to do X",
    description="A story description",
    priority="medium",
    status="draft",
    story_points=3,
    acceptance_criteria=None,
    tags=None,
    created_by=None,
    created_at=None,
    updated_at=None,
):
    now = datetime.now(tz=timezone.utc)
    return {
        "id": story_id or uuid.uuid4(),
        "project_id": project_id or uuid.uuid4(),
        "persona_ids": persona_ids or [],
        "title": title,
        "story_text": story_text,
        "description": description,
        "priority": priority,
        "status": status,
        "story_points": story_points,
        "acceptance_criteria": acceptance_criteria,
        "tags": tags or [],
        "created_by": created_by,
        "created_at": created_at or now,
        "updated_at": updated_at or now,
    }


# ---------------------------------------------------------------------------
# story_create
# ---------------------------------------------------------------------------


class TestStoryCreate:
    @patch("npl_mcp.pm_tools.db_stories.get_pool")
    async def test_create_success(self, mock_get_pool):
        new_id = uuid.uuid4()
        proj_id = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchval.return_value = new_id
        mock_get_pool.return_value = pool

        result = await story_create(
            project_id=shortuuid.encode(proj_id),
            title="My Story",
            story_text="As a user I want X",
            description="desc",
        )
        assert result["status"] == "ok"
        assert result["uuid"] == shortuuid.encode(new_id)
        pool.fetchval.assert_called_once()
        call_args = pool.fetchval.call_args[0]
        assert call_args[1] == proj_id
        assert call_args[3] == "My Story"
        assert call_args[4] == "As a user I want X"
        assert call_args[5] == "desc"
        assert call_args[6] == "medium"
        assert call_args[7] == "draft"

    async def test_create_empty_title(self):
        result = await story_create(project_id=str(uuid.uuid4()), title="")
        assert result["status"] == "error"
        assert "title" in result["message"].lower()

    async def test_create_invalid_project_id(self):
        result = await story_create(project_id="!!bad!!", title="A Story")
        assert result["status"] == "error"
        assert "project_id" in result["message"]

    async def test_create_invalid_priority(self):
        result = await story_create(
            project_id=str(uuid.uuid4()),
            title="Story",
            priority="urgent",
        )
        assert result["status"] == "error"
        assert "priority" in result["message"].lower()

    async def test_create_invalid_status(self):
        result = await story_create(
            project_id=str(uuid.uuid4()),
            title="Story",
            status="pending",
        )
        assert result["status"] == "error"
        assert "status" in result["message"].lower()

    async def test_create_invalid_persona_uuid(self):
        result = await story_create(
            project_id=str(uuid.uuid4()),
            title="Story",
            persona_ids=["not-a-uuid"],
        )
        assert result["status"] == "error"
        assert "persona UUID" in result["message"]

    @patch("npl_mcp.pm_tools.db_stories.get_pool")
    async def test_create_with_acceptance_criteria_and_tags(self, mock_get_pool):
        new_id = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchval.return_value = new_id
        mock_get_pool.return_value = pool

        ac = [{"given": "X", "when": "Y", "then": "Z"}]
        tags = ["auth", "backend"]

        result = await story_create(
            project_id=str(uuid.uuid4()),
            title="Story with AC",
            acceptance_criteria=ac,
            tags=tags,
        )
        assert result["status"] == "ok"
        call_args = pool.fetchval.call_args[0]
        assert call_args[9] == json.dumps(ac)
        assert call_args[10] == tags

    @patch("npl_mcp.pm_tools.db_stories.get_pool")
    async def test_create_with_persona_ids(self, mock_get_pool):
        new_id = uuid.uuid4()
        persona1 = uuid.uuid4()
        persona2 = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchval.return_value = new_id
        mock_get_pool.return_value = pool

        result = await story_create(
            project_id=str(uuid.uuid4()),
            title="Story",
            persona_ids=[str(persona1), shortuuid.encode(persona2)],
        )
        assert result["status"] == "ok"
        call_args = pool.fetchval.call_args[0]
        assert call_args[2] == [persona1, persona2]


# ---------------------------------------------------------------------------
# story_get
# ---------------------------------------------------------------------------


class TestStoryGet:
    @patch("npl_mcp.pm_tools.db_stories.get_pool")
    async def test_get_success_without_include(self, mock_get_pool):
        sid = uuid.uuid4()
        pid = uuid.uuid4()
        persona = uuid.uuid4()
        now = datetime.now(tz=timezone.utc)
        row = _make_row(
            story_id=sid,
            project_id=pid,
            persona_ids=[persona],
            acceptance_criteria='[{"given": "X"}]',
            created_at=now,
            updated_at=now,
        )
        pool = AsyncMock()
        pool.fetchrow.return_value = row
        mock_get_pool.return_value = pool

        result = await story_get(shortuuid.encode(sid))
        assert result["status"] == "ok"
        assert result["uuid"] == shortuuid.encode(sid)
        assert result["project_id"] == shortuuid.encode(pid)
        assert result["persona_ids"] == [shortuuid.encode(persona)]
        assert result["title"] == "Test Story"
        assert result["created_at"] == now.isoformat()
        assert "acceptance_criteria" not in result

    @patch("npl_mcp.pm_tools.db_stories.get_pool")
    async def test_get_success_with_acceptance_criteria(self, mock_get_pool):
        sid = uuid.uuid4()
        ac_json = json.dumps([{"given": "X", "when": "Y", "then": "Z"}])
        row = _make_row(story_id=sid, acceptance_criteria=ac_json)
        pool = AsyncMock()
        pool.fetchrow.return_value = row
        mock_get_pool.return_value = pool

        result = await story_get(shortuuid.encode(sid), include="acceptance-criteria")
        assert result["status"] == "ok"
        assert result["acceptance_criteria"] == [{"given": "X", "when": "Y", "then": "Z"}]

    @patch("npl_mcp.pm_tools.db_stories.get_pool")
    async def test_get_not_found(self, mock_get_pool):
        sid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.return_value = None
        mock_get_pool.return_value = pool

        encoded = shortuuid.encode(sid)
        result = await story_get(encoded)
        assert result["status"] == "not_found"
        assert result["uuid"] == encoded

    async def test_get_invalid_uuid(self):
        result = await story_get("!!invalid!!")
        assert result["status"] == "error"
        assert result["uuid"] == "!!invalid!!"
        assert "Invalid UUID" in result["message"]


# ---------------------------------------------------------------------------
# story_update
# ---------------------------------------------------------------------------


class TestStoryUpdate:
    @patch("npl_mcp.pm_tools.db_stories.get_pool")
    async def test_update_success(self, mock_get_pool):
        sid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchval.return_value = sid
        pool.execute.return_value = "UPDATE 1"
        mock_get_pool.return_value = pool

        result = await story_update(
            id=shortuuid.encode(sid),
            title="Updated Title",
            priority="high",
        )
        assert result["status"] == "ok"
        assert result["uuid"] == shortuuid.encode(sid)
        pool.execute.assert_called_once()
        sql = pool.execute.call_args[0][0]
        assert "title = $1" in sql
        assert "priority = $2" in sql

    @patch("npl_mcp.pm_tools.db_stories.get_pool")
    async def test_update_not_found(self, mock_get_pool):
        sid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchval.return_value = None
        mock_get_pool.return_value = pool

        encoded = shortuuid.encode(sid)
        result = await story_update(id=encoded, title="New")
        assert result["status"] == "not_found"
        assert result["uuid"] == encoded

    async def test_update_invalid_priority(self):
        result = await story_update(id=str(uuid.uuid4()), priority="urgent")
        assert result["status"] == "error"
        assert "priority" in result["message"].lower()

    async def test_update_invalid_status(self):
        result = await story_update(id=str(uuid.uuid4()), status="pending")
        assert result["status"] == "error"
        assert "status" in result["message"].lower()

    @patch("npl_mcp.pm_tools.db_stories.get_pool")
    async def test_update_no_fields(self, mock_get_pool):
        sid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchval.return_value = sid
        mock_get_pool.return_value = pool

        result = await story_update(id=shortuuid.encode(sid))
        assert result["status"] == "ok"
        assert "No fields to update" in result["message"]
        pool.execute.assert_not_called()

    async def test_update_invalid_uuid(self):
        result = await story_update(id="!!bad!!", title="X")
        assert result["status"] == "error"
        assert "Invalid UUID" in result["message"]

    @patch("npl_mcp.pm_tools.db_stories.get_pool")
    async def test_update_with_acceptance_criteria_and_tags(self, mock_get_pool):
        sid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchval.return_value = sid
        pool.execute.return_value = "UPDATE 1"
        mock_get_pool.return_value = pool

        ac = [{"given": "A", "then": "B"}]
        result = await story_update(
            id=shortuuid.encode(sid),
            acceptance_criteria=ac,
            tags=["new-tag"],
        )
        assert result["status"] == "ok"
        call_args = pool.execute.call_args[0]
        sql = call_args[0]
        assert "acceptance_criteria" in sql
        assert "tags" in sql
        assert json.dumps(ac) in call_args[1:]
        assert ["new-tag"] in call_args[1:]

    @patch("npl_mcp.pm_tools.db_stories.get_pool")
    async def test_update_invalid_persona_uuid(self, mock_get_pool):
        sid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchval.return_value = sid
        mock_get_pool.return_value = pool

        result = await story_update(
            id=shortuuid.encode(sid),
            persona_ids=["not-valid"],
        )
        assert result["status"] == "error"
        assert "persona UUID" in result["message"]


# ---------------------------------------------------------------------------
# story_delete
# ---------------------------------------------------------------------------


class TestStoryDelete:
    @patch("npl_mcp.pm_tools.db_stories.get_pool")
    async def test_delete_success(self, mock_get_pool):
        sid = uuid.uuid4()
        pool = AsyncMock()
        pool.execute.return_value = "UPDATE 1"
        mock_get_pool.return_value = pool

        result = await story_delete(shortuuid.encode(sid))
        assert result["status"] == "ok"
        assert result["uuid"] == shortuuid.encode(sid)
        pool.execute.assert_called_once()

    @patch("npl_mcp.pm_tools.db_stories.get_pool")
    async def test_delete_not_found(self, mock_get_pool):
        sid = uuid.uuid4()
        pool = AsyncMock()
        pool.execute.return_value = "UPDATE 0"
        mock_get_pool.return_value = pool

        encoded = shortuuid.encode(sid)
        result = await story_delete(encoded)
        assert result["status"] == "not_found"
        assert result["uuid"] == encoded

    async def test_delete_invalid_uuid(self):
        result = await story_delete("!!bad!!")
        assert result["status"] == "error"
        assert "Invalid UUID" in result["message"]


# ---------------------------------------------------------------------------
# story_list
# ---------------------------------------------------------------------------


class TestStoryList:
    @patch("npl_mcp.pm_tools.db_stories.get_pool")
    async def test_list_success(self, mock_get_pool):
        proj_id = uuid.uuid4()
        s1 = uuid.uuid4()
        s2 = uuid.uuid4()
        now = datetime.now(tz=timezone.utc)
        pool = AsyncMock()
        pool.fetchval.return_value = 2
        pool.fetch.return_value = [
            _make_row(story_id=s1, project_id=proj_id, title="S1", created_at=now, updated_at=now),
            _make_row(story_id=s2, project_id=proj_id, title="S2", created_at=now, updated_at=now),
        ]
        mock_get_pool.return_value = pool

        result = await story_list(project_id=shortuuid.encode(proj_id))
        assert result["status"] == "ok"
        assert result["total"] == 2
        assert result["page"] == 1
        assert result["page_size"] == 20
        assert len(result["stories"]) == 2
        assert result["stories"][0]["uuid"] == shortuuid.encode(s1)
        assert result["stories"][0]["title"] == "S1"
        assert "acceptance_criteria" not in result["stories"][0]

    @patch("npl_mcp.pm_tools.db_stories.get_pool")
    async def test_list_with_persona_id_filter(self, mock_get_pool):
        proj_id = uuid.uuid4()
        persona_id = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchval.return_value = 0
        pool.fetch.return_value = []
        mock_get_pool.return_value = pool

        result = await story_list(
            project_id=shortuuid.encode(proj_id),
            persona_id=shortuuid.encode(persona_id),
        )
        assert result["status"] == "ok"
        count_sql = pool.fetchval.call_args[0][0]
        assert "persona_ids @> ARRAY[$2]::uuid[]" in count_sql
        count_params = pool.fetchval.call_args[0]
        assert count_params[1] == proj_id
        assert count_params[2] == persona_id

    @patch("npl_mcp.pm_tools.db_stories.get_pool")
    async def test_list_with_status_filter(self, mock_get_pool):
        proj_id = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchval.return_value = 0
        pool.fetch.return_value = []
        mock_get_pool.return_value = pool

        result = await story_list(
            project_id=shortuuid.encode(proj_id),
            status="ready",
        )
        assert result["status"] == "ok"
        count_sql = pool.fetchval.call_args[0][0]
        assert "status = $2" in count_sql

    @patch("npl_mcp.pm_tools.db_stories.get_pool")
    async def test_list_with_priority_filter(self, mock_get_pool):
        proj_id = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchval.return_value = 0
        pool.fetch.return_value = []
        mock_get_pool.return_value = pool

        result = await story_list(
            project_id=shortuuid.encode(proj_id),
            priority="high",
        )
        assert result["status"] == "ok"
        count_sql = pool.fetchval.call_args[0][0]
        assert "priority = $2" in count_sql

    @patch("npl_mcp.pm_tools.db_stories.get_pool")
    async def test_list_with_tags_filter(self, mock_get_pool):
        proj_id = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchval.return_value = 0
        pool.fetch.return_value = []
        mock_get_pool.return_value = pool

        result = await story_list(
            project_id=shortuuid.encode(proj_id),
            tags=["auth"],
        )
        assert result["status"] == "ok"
        count_sql = pool.fetchval.call_args[0][0]
        assert "tags && $2" in count_sql

    @patch("npl_mcp.pm_tools.db_stories.get_pool")
    async def test_list_empty_results(self, mock_get_pool):
        proj_id = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchval.return_value = 0
        pool.fetch.return_value = []
        mock_get_pool.return_value = pool

        result = await story_list(project_id=shortuuid.encode(proj_id))
        assert result["status"] == "ok"
        assert result["total"] == 0
        assert result["stories"] == []

    async def test_list_invalid_project_id(self):
        result = await story_list(project_id="!!bad!!")
        assert result["status"] == "error"
        assert "project_id" in result["message"]

    @patch("npl_mcp.pm_tools.db_stories.get_pool")
    async def test_list_pagination(self, mock_get_pool):
        proj_id = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchval.return_value = 50
        pool.fetch.return_value = []
        mock_get_pool.return_value = pool

        result = await story_list(
            project_id=shortuuid.encode(proj_id),
            page=3,
            page_size=10,
        )
        assert result["page"] == 3
        assert result["page_size"] == 10
        fetch_args = pool.fetch.call_args[0]
        assert fetch_args[-2] == 10   # page_size (LIMIT)
        assert fetch_args[-1] == 20   # offset = (3-1)*10
