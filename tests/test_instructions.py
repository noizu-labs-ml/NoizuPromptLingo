"""Tests for npl_mcp.instructions.instructions."""

import uuid
from unittest.mock import AsyncMock, MagicMock, patch

import pytest
import shortuuid

from npl_mcp.instructions.instructions import (
    instructions_active_version,
    instructions_create,
    instructions_get,
    instructions_update,
    instructions_versions,
)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _mock_pool_with_transaction():
    """Return (pool, conn) where pool.acquire() yields conn in a transaction.

    asyncpg's ``pool.acquire()`` and ``conn.transaction()`` are *sync* calls
    that return async context managers.  We must override them with
    ``MagicMock`` so they aren't turned into coroutines by ``AsyncMock``.
    """
    conn = AsyncMock()

    # conn.transaction() -> async CM (no-op)
    tx_cm = MagicMock()
    tx_cm.__aenter__ = AsyncMock(return_value=None)
    tx_cm.__aexit__ = AsyncMock(return_value=False)
    conn.transaction = MagicMock(return_value=tx_cm)

    # pool.acquire() -> async CM yielding conn
    acquire_cm = MagicMock()
    acquire_cm.__aenter__ = AsyncMock(return_value=conn)
    acquire_cm.__aexit__ = AsyncMock(return_value=False)

    pool = AsyncMock()
    pool.acquire = MagicMock(return_value=acquire_cm)

    return pool, conn


# ---------------------------------------------------------------------------
# Instructions.Create
# ---------------------------------------------------------------------------


class TestInstructionsCreate:
    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_create_returns_short_uuid(self, mock_get_pool):
        new_id = uuid.uuid4()
        pool, conn = _mock_pool_with_transaction()
        conn.fetchval.return_value = new_id
        mock_get_pool.return_value = pool

        result = await instructions_create("Title", "Desc", ["tag1"], "Body text")
        assert result["status"] == "ok"
        assert result["uuid"] == shortuuid.encode(new_id)
        assert result["version"] == 1
        conn.fetchval.assert_called_once()
        conn.execute.assert_called_once()

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_create_passes_tags(self, mock_get_pool):
        pool, conn = _mock_pool_with_transaction()
        conn.fetchval.return_value = uuid.uuid4()
        mock_get_pool.return_value = pool

        await instructions_create("T", "D", ["a", "b"], "body")
        # Tags are the 3rd positional arg after title and description
        call_args = conn.fetchval.call_args[0]
        assert call_args[3] == ["a", "b"]

    async def test_empty_title_rejected(self):
        result = await instructions_create("", "desc", [], "body")
        assert result["status"] == "error"

    async def test_empty_body_rejected(self):
        result = await instructions_create("title", "desc", [], "")
        assert result["status"] == "error"


# ---------------------------------------------------------------------------
# Instructions (get)
# ---------------------------------------------------------------------------


class TestInstructionsGet:
    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_get_active_version(self, mock_get_pool):
        uid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.side_effect = [
            {
                "id": uid,
                "title": "T",
                "description": "D",
                "tags": ["t"],
                "active_version": 1,
            },
            {
                "version": 1,
                "body": "content",
                "change_note": "Initial",
                "created_at": None,
            },
        ]
        mock_get_pool.return_value = pool

        # Accept both short and full UUID as input
        result = await instructions_get(shortuuid.encode(uid))
        assert result["status"] == "ok"
        assert result["body"] == "content"
        assert result["version"] == 1
        assert result["active_version"] == 1
        assert result["uuid"] == shortuuid.encode(uid)

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_get_with_full_uuid(self, mock_get_pool):
        uid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.side_effect = [
            {
                "id": uid,
                "title": "T",
                "description": "D",
                "tags": [],
                "active_version": 1,
            },
            {
                "version": 1,
                "body": "content",
                "change_note": "Initial",
                "created_at": None,
            },
        ]
        mock_get_pool.return_value = pool

        # Full UUID string should also work
        result = await instructions_get(str(uid))
        assert result["status"] == "ok"
        assert result["uuid"] == shortuuid.encode(uid)

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_get_specific_version(self, mock_get_pool):
        uid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.side_effect = [
            {
                "id": uid,
                "title": "T",
                "description": "D",
                "tags": [],
                "active_version": 2,
            },
            {
                "version": 1,
                "body": "old content",
                "change_note": "Initial",
                "created_at": None,
            },
        ]
        mock_get_pool.return_value = pool

        result = await instructions_get(str(uid), version=1)
        assert result["version"] == 1
        assert result["body"] == "old content"

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_not_found(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetchrow.return_value = None
        mock_get_pool.return_value = pool

        result = await instructions_get("00000000-0000-0000-0000-000000000000")
        assert result["status"] == "not_found"

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_version_not_found(self, mock_get_pool):
        uid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.side_effect = [
            {
                "id": uid,
                "title": "T",
                "description": "D",
                "tags": [],
                "active_version": 1,
            },
            None,  # version not found
        ]
        mock_get_pool.return_value = pool

        result = await instructions_get(str(uid), version=99)
        assert result["status"] == "error"
        assert "99" in result["message"]

    async def test_invalid_uuid(self):
        result = await instructions_get("!!invalid!!")
        assert result["status"] == "error"
        assert "UUID" in result["message"]


# ---------------------------------------------------------------------------
# Instructions.Update
# ---------------------------------------------------------------------------


class TestInstructionsUpdate:
    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_creates_new_version(self, mock_get_pool):
        uid = uuid.uuid4()
        pool, conn = _mock_pool_with_transaction()
        conn.fetchrow.side_effect = [
            {"id": uid, "active_version": 1, "description": "D", "tags": []},
            {"body": "old body"},
        ]
        mock_get_pool.return_value = pool

        result = await instructions_update(str(uid), "Changed body", body="new body")
        assert result["status"] == "ok"
        assert result["version"] == 2

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_carries_forward_body(self, mock_get_pool):
        uid = uuid.uuid4()
        pool, conn = _mock_pool_with_transaction()
        conn.fetchrow.side_effect = [
            {"id": uid, "active_version": 1, "description": "D", "tags": ["x"]},
            {"body": "carried body"},
        ]
        mock_get_pool.return_value = pool

        result = await instructions_update(str(uid), "Meta only change")
        assert result["status"] == "ok"
        assert result["version"] == 2
        # Verify body was carried forward (3rd positional arg in INSERT)
        insert_call = conn.execute.call_args_list[0]
        assert insert_call[0][3] == "carried body"

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_not_found(self, mock_get_pool):
        pool, conn = _mock_pool_with_transaction()
        conn.fetchrow.return_value = None
        mock_get_pool.return_value = pool

        result = await instructions_update(
            "00000000-0000-0000-0000-000000000000", "note"
        )
        assert result["status"] == "not_found"

    async def test_invalid_uuid(self):
        result = await instructions_update("!!invalid!!", "note")
        assert result["status"] == "error"


# ---------------------------------------------------------------------------
# Instructions.ActiveVersion
# ---------------------------------------------------------------------------


class TestInstructionsActiveVersion:
    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_rollback(self, mock_get_pool):
        uid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.return_value = {"version": 1}
        mock_get_pool.return_value = pool

        result = await instructions_active_version(str(uid), 1)
        assert result["status"] == "ok"
        assert result["active_version"] == 1
        assert result["uuid"] == shortuuid.encode(uid)
        pool.execute.assert_called_once()

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_version_not_found(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetchrow.return_value = None
        mock_get_pool.return_value = pool

        result = await instructions_active_version(
            "00000000-0000-0000-0000-000000000000", 99
        )
        assert result["status"] == "error"
        assert "99" in result["message"]

    async def test_invalid_uuid(self):
        result = await instructions_active_version("!!invalid!!", 1)
        assert result["status"] == "error"


# ---------------------------------------------------------------------------
# Instructions.Versions
# ---------------------------------------------------------------------------


class TestInstructionsVersions:
    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_list_versions(self, mock_get_pool):
        uid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.return_value = {"id": uid, "active_version": 2}
        pool.fetch.return_value = [
            {"version": 1, "change_note": "Initial", "created_at": None},
            {"version": 2, "change_note": "Updated", "created_at": None},
        ]
        mock_get_pool.return_value = pool

        result = await instructions_versions(str(uid))
        assert result["status"] == "ok"
        assert len(result["versions"]) == 2
        assert result["versions"][0]["is_active"] is False
        assert result["versions"][1]["is_active"] is True
        assert result["active_version"] == 2
        assert result["uuid"] == shortuuid.encode(uid)

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_not_found(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetchrow.return_value = None
        mock_get_pool.return_value = pool

        result = await instructions_versions("00000000-0000-0000-0000-000000000000")
        assert result["status"] == "not_found"

    async def test_invalid_uuid(self):
        result = await instructions_versions("!!invalid!!")
        assert result["status"] == "error"
