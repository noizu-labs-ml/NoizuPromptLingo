"""Unit tests for npl_mcp.artifacts.artifacts (tier-C MVP)."""

from __future__ import annotations

from datetime import datetime, timezone
from unittest.mock import AsyncMock, patch

import pytest

from npl_mcp.artifacts.artifacts import (
    VALID_KINDS,
    artifact_add_revision,
    artifact_create,
    artifact_get,
    artifact_list,
    artifact_list_revisions,
)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _artifact_row(**overrides) -> dict:
    now = datetime(2026, 4, 21, 12, 0, 0, tzinfo=timezone.utc)
    base = {
        "id": 7,
        "title": "Draft PRD",
        "kind": "markdown",
        "description": "Initial draft",
        "created_by": "npl-prd-editor",
        "latest_revision": 1,
        "created_at": now,
        "updated_at": now,
    }
    base.update(overrides)
    return base


def _revision_row(**overrides) -> dict:
    now = datetime(2026, 4, 21, 12, 0, 0, tzinfo=timezone.utc)
    base = {
        "id": 101,
        "artifact_id": 7,
        "revision": 1,
        "content": "# Draft\n\nBody.",
        "notes": None,
        "created_by": "npl-prd-editor",
        "created_at": now,
    }
    base.update(overrides)
    return base


# ---------------------------------------------------------------------------
# artifact_create
# ---------------------------------------------------------------------------

class TestArtifactCreate:
    async def test_rejects_empty_title(self):
        result = await artifact_create("   ", content="body")
        assert result["status"] == "error"

    async def test_rejects_none_content(self):
        result = await artifact_create("title", content=None)  # type: ignore[arg-type]
        assert result["status"] == "error"

    async def test_rejects_invalid_kind(self):
        result = await artifact_create("title", content="body", kind="widget")
        assert result["status"] == "error"
        assert "widget" in result["message"]

    @patch("npl_mcp.artifacts.artifacts.get_pool")
    async def test_create_returns_artifact_plus_revision(self, mock_pool):
        pool = AsyncMock()
        pool.fetchrow.side_effect = [_artifact_row(), _revision_row()]
        mock_pool.return_value = pool

        result = await artifact_create("Draft PRD", content="# Draft\n\nBody.")
        assert result["status"] == "ok"
        assert result["id"] == 7
        assert result["latest_revision"] == 1
        assert result["revision"]["revision"] == 1
        assert result["revision"]["content"] == "# Draft\n\nBody."

    @patch("npl_mcp.artifacts.artifacts.get_pool")
    async def test_create_trims_title(self, mock_pool):
        pool = AsyncMock()
        pool.fetchrow.side_effect = [_artifact_row(title="Trim me"), _revision_row()]
        mock_pool.return_value = pool

        await artifact_create("   Trim me   ", content="body")
        call_args = pool.fetchrow.call_args_list[0][0]
        assert call_args[1] == "Trim me"


# ---------------------------------------------------------------------------
# artifact_add_revision
# ---------------------------------------------------------------------------

class TestArtifactAddRevision:
    async def test_rejects_non_integer_id(self):
        result = await artifact_add_revision("abc", "body")  # type: ignore[arg-type]
        assert result["status"] == "error"

    async def test_rejects_none_content(self):
        result = await artifact_add_revision(1, None)  # type: ignore[arg-type]
        assert result["status"] == "error"

    @patch("npl_mcp.artifacts.artifacts.get_pool")
    async def test_not_found(self, mock_pool):
        pool = AsyncMock()
        pool.fetchrow.return_value = None
        mock_pool.return_value = pool

        result = await artifact_add_revision(99, "body")
        assert result["status"] == "not_found"

    @patch("npl_mcp.artifacts.artifacts.get_pool")
    async def test_appends_new_revision(self, mock_pool):
        pool = AsyncMock()
        pool.fetchrow.side_effect = [
            {"id": 7, "latest_revision": 3},              # existence + latest lookup
            _revision_row(revision=4, content="new"),     # insert revision
            _artifact_row(latest_revision=4),              # update artifact
        ]
        mock_pool.return_value = pool

        result = await artifact_add_revision(7, "new")
        assert result["status"] == "ok"
        assert result["latest_revision"] == 4
        assert result["revision"]["revision"] == 4

        # Second fetchrow is the INSERT revision call — verify args
        insert_args = pool.fetchrow.call_args_list[1][0]
        assert insert_args[1] == 7    # artifact_id
        assert insert_args[2] == 4    # new revision number
        assert insert_args[3] == "new"


# ---------------------------------------------------------------------------
# artifact_get
# ---------------------------------------------------------------------------

class TestArtifactGet:
    async def test_rejects_non_integer_id(self):
        result = await artifact_get("bad")  # type: ignore[arg-type]
        assert result["status"] == "error"

    @patch("npl_mcp.artifacts.artifacts.get_pool")
    async def test_not_found(self, mock_pool):
        pool = AsyncMock()
        pool.fetchrow.return_value = None
        mock_pool.return_value = pool
        result = await artifact_get(99)
        assert result["status"] == "not_found"

    @patch("npl_mcp.artifacts.artifacts.get_pool")
    async def test_get_latest_by_default(self, mock_pool):
        pool = AsyncMock()
        pool.fetchrow.side_effect = [
            _artifact_row(latest_revision=3),
            _revision_row(revision=3, content="latest body"),
        ]
        mock_pool.return_value = pool

        result = await artifact_get(7)
        assert result["status"] == "ok"
        assert result["revision"]["revision"] == 3
        assert result["revision"]["content"] == "latest body"
        # Verify the revision lookup used revision=3
        rev_args = pool.fetchrow.call_args_list[1][0]
        assert rev_args[1] == 7  # artifact id
        assert rev_args[2] == 3  # revision

    @patch("npl_mcp.artifacts.artifacts.get_pool")
    async def test_get_specific_revision(self, mock_pool):
        pool = AsyncMock()
        pool.fetchrow.side_effect = [
            _artifact_row(latest_revision=3),
            _revision_row(revision=1, content="original body"),
        ]
        mock_pool.return_value = pool

        result = await artifact_get(7, revision=1)
        assert result["status"] == "ok"
        assert result["revision"]["revision"] == 1
        assert result["revision"]["content"] == "original body"

    @patch("npl_mcp.artifacts.artifacts.get_pool")
    async def test_missing_revision_returns_error(self, mock_pool):
        pool = AsyncMock()
        pool.fetchrow.side_effect = [
            _artifact_row(latest_revision=1),
            None,  # revision 99 does not exist
        ]
        mock_pool.return_value = pool

        result = await artifact_get(7, revision=99)
        assert result["status"] == "error"
        assert "99" in result["message"]


# ---------------------------------------------------------------------------
# artifact_list
# ---------------------------------------------------------------------------

class TestArtifactList:
    async def test_rejects_invalid_kind(self):
        result = await artifact_list(kind="widget")
        assert result["status"] == "error"

    @patch("npl_mcp.artifacts.artifacts.get_pool")
    async def test_empty(self, mock_pool):
        pool = AsyncMock()
        pool.fetch.return_value = []
        mock_pool.return_value = pool
        result = await artifact_list()
        assert result["status"] == "ok"
        assert result["artifacts"] == []
        assert result["count"] == 0

    @patch("npl_mcp.artifacts.artifacts.get_pool")
    async def test_filter_by_kind(self, mock_pool):
        pool = AsyncMock()
        pool.fetch.return_value = [_artifact_row(id=1, kind="json")]
        mock_pool.return_value = pool

        result = await artifact_list(kind="json")
        assert result["count"] == 1
        sql, *args = pool.fetch.call_args[0]
        assert "kind = $1" in sql
        assert args == ["json", 100]

    @patch("npl_mcp.artifacts.artifacts.get_pool")
    async def test_limit_clamped(self, mock_pool):
        pool = AsyncMock()
        pool.fetch.return_value = []
        mock_pool.return_value = pool

        await artifact_list(limit=99999)
        _, *args = pool.fetch.call_args[0]
        assert args[-1] == 500

        await artifact_list(limit=0)
        _, *args = pool.fetch.call_args[0]
        assert args[-1] == 1


# ---------------------------------------------------------------------------
# artifact_list_revisions
# ---------------------------------------------------------------------------

class TestArtifactListRevisions:
    async def test_rejects_non_integer_id(self):
        result = await artifact_list_revisions("nope")  # type: ignore[arg-type]
        assert result["status"] == "error"

    @patch("npl_mcp.artifacts.artifacts.get_pool")
    async def test_not_found(self, mock_pool):
        pool = AsyncMock()
        pool.fetchval.return_value = None
        mock_pool.return_value = pool
        result = await artifact_list_revisions(99)
        assert result["status"] == "not_found"

    @patch("npl_mcp.artifacts.artifacts.get_pool")
    async def test_returns_revision_summaries(self, mock_pool):
        pool = AsyncMock()
        pool.fetchval.return_value = 7  # existence
        pool.fetch.return_value = [
            _revision_row(id=100, revision=1),
            _revision_row(id=101, revision=2, notes="refinement"),
        ]
        mock_pool.return_value = pool

        result = await artifact_list_revisions(7)
        assert result["status"] == "ok"
        assert result["count"] == 2
        assert result["revisions"][0]["revision"] == 1
        assert result["revisions"][1]["notes"] == "refinement"
        # Summaries must not include the body content field
        assert "content" not in result["revisions"][0]


class TestValidKinds:
    def test_expected_kinds_set(self):
        assert VALID_KINDS == {"markdown", "json", "yaml", "code", "text", "other"}
