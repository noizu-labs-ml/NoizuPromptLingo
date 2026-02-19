"""Tests for npl_mcp.instructions.instructions."""

import uuid
from unittest.mock import AsyncMock, MagicMock, patch

import pytest
import shortuuid

from npl_mcp.instructions.instructions import (
    instructions_active_version,
    instructions_create,
    instructions_get,
    instructions_list,
    instructions_update,
    instructions_versions,
)

# All create/update tests need to mock the embedding pipeline
_EMBED_PATCH = "npl_mcp.instructions.embeddings.generate_and_store_embeddings"


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
    @patch(_EMBED_PATCH, new_callable=AsyncMock)
    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_create_returns_short_uuid(self, mock_get_pool, mock_embed):
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
        mock_embed.assert_awaited_once()

    @patch(_EMBED_PATCH, new_callable=AsyncMock)
    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_create_passes_tags(self, mock_get_pool, mock_embed):
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

    @patch(_EMBED_PATCH, new_callable=AsyncMock)
    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_create_with_valid_session(self, mock_get_pool, mock_embed):
        """Session ID is stored when a valid session is provided."""
        new_id = uuid.uuid4()
        session_id = uuid.uuid4()

        # Main pool for the transaction
        pool, conn = _mock_pool_with_transaction()
        conn.fetchval.return_value = new_id

        # The _validate_session helper also calls get_pool
        # It needs a pool that returns session_id for fetchval
        validation_pool = AsyncMock()
        validation_pool.fetchval.return_value = session_id

        # get_pool is called twice: once by _validate_session, once by instructions_create
        mock_get_pool.side_effect = [validation_pool, pool]

        result = await instructions_create(
            "Title", "Desc", ["tag"], "Body",
            session=shortuuid.encode(session_id),
        )
        assert result["status"] == "ok"
        assert result["session"] == shortuuid.encode(session_id)

        # Verify session_id was passed to INSERT (4th positional arg: $4)
        insert_args = conn.fetchval.call_args[0]
        assert insert_args[4] == session_id

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_create_with_invalid_session(self, mock_get_pool):
        """Invalid session UUID format returns error."""
        result = await instructions_create(
            "Title", "Desc", ["tag"], "Body",
            session="!!invalid!!",
        )
        assert result["status"] == "error"
        assert "Invalid session UUID" in result["message"]

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_create_with_nonexistent_session(self, mock_get_pool):
        """Session UUID that doesn't exist in DB returns error."""
        pool = AsyncMock()
        pool.fetchval.return_value = None  # session not found
        mock_get_pool.return_value = pool

        result = await instructions_create(
            "Title", "Desc", ["tag"], "Body",
            session=shortuuid.encode(uuid.uuid4()),
        )
        assert result["status"] == "error"
        assert "Session not found" in result["message"]


# ---------------------------------------------------------------------------
# Instructions (get)
# ---------------------------------------------------------------------------


class TestInstructionsGet:
    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_get_returns_markdown_by_default(self, mock_get_pool):
        uid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.side_effect = [
            {
                "id": uid,
                "title": "My Title",
                "description": "D",
                "tags": ["t"],
                "active_version": 1,
                "session_id": None,
            },
            {
                "version": 1,
                "body": "content body",
                "change_note": "Initial",
                "created_at": None,
            },
        ]
        mock_get_pool.return_value = pool

        result = await instructions_get(shortuuid.encode(uid))
        assert isinstance(result, str)
        assert result == "# My Title\n---\n\ncontent body"

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_get_json_flag_returns_dict(self, mock_get_pool):
        uid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.side_effect = [
            {
                "id": uid,
                "title": "T",
                "description": "D",
                "tags": ["t"],
                "active_version": 1,
                "session_id": None,
            },
            {
                "version": 1,
                "body": "content",
                "change_note": "Initial",
                "created_at": None,
            },
        ]
        mock_get_pool.return_value = pool

        result = await instructions_get(shortuuid.encode(uid), json=True)
        assert isinstance(result, dict)
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
                "session_id": None,
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
        result = await instructions_get(str(uid), json=True)
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
                "session_id": None,
            },
            {
                "version": 1,
                "body": "old content",
                "change_note": "Initial",
                "created_at": None,
            },
        ]
        mock_get_pool.return_value = pool

        result = await instructions_get(str(uid), version=1, json=True)
        assert result["version"] == 1
        assert result["body"] == "old content"

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_get_specific_version_markdown(self, mock_get_pool):
        uid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.side_effect = [
            {
                "id": uid,
                "title": "Doc",
                "description": "D",
                "tags": [],
                "active_version": 2,
                "session_id": None,
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
        assert isinstance(result, str)
        assert result == "# Doc\n---\n\nold content"

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
                "session_id": None,
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

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_get_with_session_validation(self, mock_get_pool):
        """Valid session passes and instruction is returned."""
        uid = uuid.uuid4()
        session_id = uuid.uuid4()

        # Validation pool (for _validate_session)
        validation_pool = AsyncMock()
        validation_pool.fetchval.return_value = session_id

        # Main pool (for instructions_get queries)
        main_pool = AsyncMock()
        main_pool.fetchrow.side_effect = [
            {
                "id": uid,
                "title": "T",
                "description": "D",
                "tags": [],
                "active_version": 1,
                "session_id": session_id,
            },
            {
                "version": 1,
                "body": "content",
                "change_note": "Initial",
                "created_at": None,
            },
        ]

        mock_get_pool.side_effect = [validation_pool, main_pool]

        result = await instructions_get(
            str(uid), json=True, session=shortuuid.encode(session_id)
        )
        assert result["status"] == "ok"
        assert result["session"] == shortuuid.encode(session_id)

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_get_with_invalid_session(self, mock_get_pool):
        """Invalid session UUID format returns error before fetching instruction."""
        uid = uuid.uuid4()
        result = await instructions_get(
            str(uid), session="!!invalid!!"
        )
        assert result["status"] == "error"
        assert "Invalid session UUID" in result["message"]

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_get_json_includes_session_when_present(self, mock_get_pool):
        """JSON response includes session field when instruction has one."""
        uid = uuid.uuid4()
        session_id = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.side_effect = [
            {
                "id": uid,
                "title": "T",
                "description": "D",
                "tags": [],
                "active_version": 1,
                "session_id": session_id,
            },
            {
                "version": 1,
                "body": "content",
                "change_note": "Initial",
                "created_at": None,
            },
        ]
        mock_get_pool.return_value = pool

        result = await instructions_get(str(uid), json=True)
        assert result["session"] == shortuuid.encode(session_id)

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_get_json_no_session_field_when_null(self, mock_get_pool):
        """JSON response omits session field when instruction has none."""
        uid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetchrow.side_effect = [
            {
                "id": uid,
                "title": "T",
                "description": "D",
                "tags": [],
                "active_version": 1,
                "session_id": None,
            },
            {
                "version": 1,
                "body": "content",
                "change_note": "Initial",
                "created_at": None,
            },
        ]
        mock_get_pool.return_value = pool

        result = await instructions_get(str(uid), json=True)
        assert "session" not in result


# ---------------------------------------------------------------------------
# Instructions.Update
# ---------------------------------------------------------------------------


class TestInstructionsUpdate:
    @patch(_EMBED_PATCH, new_callable=AsyncMock)
    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_creates_new_version(self, mock_get_pool, mock_embed):
        uid = uuid.uuid4()
        pool, conn = _mock_pool_with_transaction()
        conn.fetchrow.side_effect = [
            {"id": uid, "title": "T", "active_version": 1, "description": "D", "tags": []},
            {"body": "old body"},
        ]
        mock_get_pool.return_value = pool

        result = await instructions_update(str(uid), "Changed body", body="new body")
        assert result["status"] == "ok"
        assert result["version"] == 2
        mock_embed.assert_awaited_once()

    @patch(_EMBED_PATCH, new_callable=AsyncMock)
    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_carries_forward_body(self, mock_get_pool, mock_embed):
        uid = uuid.uuid4()
        pool, conn = _mock_pool_with_transaction()
        conn.fetchrow.side_effect = [
            {"id": uid, "title": "T", "active_version": 1, "description": "D", "tags": ["x"]},
            {"body": "carried body"},
        ]
        mock_get_pool.return_value = pool

        result = await instructions_update(str(uid), "Meta only change")
        assert result["status"] == "ok"
        assert result["version"] == 2
        # Verify body was carried forward (3rd positional arg in INSERT)
        insert_call = conn.execute.call_args_list[0]
        assert insert_call[0][3] == "carried body"

    @patch(_EMBED_PATCH, new_callable=AsyncMock)
    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_not_found(self, mock_get_pool, mock_embed):
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


# ---------------------------------------------------------------------------
# Instructions.List
# ---------------------------------------------------------------------------


def _make_instruction_row(uid=None, title="Test", description="Desc",
                          tags=None, session_id=None):
    """Helper to build a mock instruction row dict."""
    return {
        "id": uid or uuid.uuid4(),
        "title": title,
        "description": description,
        "tags": tags or ["t1"],
        "active_version": 1,
        "session_id": session_id,
        "created_at": None,
        "updated_at": None,
    }


class TestInstructionsList:
    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_list_all_returns_instructions(self, mock_get_pool):
        uid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetch.return_value = [_make_instruction_row(uid=uid)]
        mock_get_pool.return_value = pool

        result = await instructions_list(mode="all")
        assert result["status"] == "ok"
        assert result["mode"] == "all"
        assert len(result["instructions"]) == 1
        assert result["instructions"][0]["uuid"] == shortuuid.encode(uid)

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_list_all_with_tag_filter(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetch.return_value = [_make_instruction_row(tags=["setup"])]
        mock_get_pool.return_value = pool

        result = await instructions_list(mode="all", tags=["setup"])
        assert result["status"] == "ok"
        # Verify the tag-filtered query was used (has 2 args: tags + limit)
        call_args = pool.fetch.call_args[0]
        assert call_args[1] == ["setup"]

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_text_search(self, mock_get_pool):
        uid = uuid.uuid4()
        pool = AsyncMock()
        pool.fetch.return_value = [
            _make_instruction_row(uid=uid, title="Agent Setup Guide"),
        ]
        mock_get_pool.return_value = pool

        result = await instructions_list(query="agent", mode="text")
        assert result["status"] == "ok"
        assert result["mode"] == "text"
        assert result["query"] == "agent"
        assert len(result["instructions"]) == 1

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_text_search_with_tags(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetch.return_value = []
        mock_get_pool.return_value = pool

        result = await instructions_list(query="agent", mode="text", tags=["setup"])
        assert result["status"] == "ok"
        assert result["total"] == 0

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_list_with_valid_session(self, mock_get_pool):
        session_id = uuid.uuid4()
        validation_pool = AsyncMock()
        validation_pool.fetchval.return_value = session_id

        main_pool = AsyncMock()
        main_pool.fetch.return_value = []

        mock_get_pool.side_effect = [validation_pool, main_pool]

        result = await instructions_list(
            session=shortuuid.encode(session_id), mode="all"
        )
        assert result["status"] == "ok"

    async def test_list_with_invalid_session(self):
        result = await instructions_list(session="!!invalid!!")
        assert result["status"] == "error"
        assert "Invalid session UUID" in result["message"]

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_list_with_nonexistent_session(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetchval.return_value = None
        mock_get_pool.return_value = pool

        result = await instructions_list(
            session=shortuuid.encode(uuid.uuid4()), mode="all"
        )
        assert result["status"] == "error"
        assert "Session not found" in result["message"]

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_limit_clamped_to_max(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetch.return_value = []
        mock_get_pool.return_value = pool

        await instructions_list(mode="all", limit=500)
        # Verify limit was clamped to 100
        call_args = pool.fetch.call_args[0]
        assert call_args[1] == 100

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_limit_clamped_to_min(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetch.return_value = []
        mock_get_pool.return_value = pool

        await instructions_list(mode="all", limit=-5)
        call_args = pool.fetch.call_args[0]
        assert call_args[1] == 1

    @patch("npl_mcp.meta_tools.llm_client.embed_texts", new_callable=AsyncMock)
    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_intent_search_with_results(self, mock_get_pool, mock_embed):
        uid = uuid.uuid4()
        mock_embed.return_value = [[0.1] * 1536]

        pool = AsyncMock()
        row = _make_instruction_row(uid=uid)
        row["score"] = 0.15
        pool.fetch.return_value = [row]
        mock_get_pool.return_value = pool

        result = await instructions_list(query="setup agents", mode="intent")
        assert result["status"] == "ok"
        assert result["mode"] == "intent"
        assert len(result["instructions"]) == 1
        assert result["instructions"][0]["similarity"] == round(1.0 - 0.15, 4)

    @patch("npl_mcp.meta_tools.llm_client.embed_texts", new_callable=AsyncMock)
    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_intent_search_falls_back_on_embed_failure(
        self, mock_get_pool, mock_embed
    ):
        mock_embed.side_effect = Exception("Embed service down")

        pool = AsyncMock()
        pool.fetch.return_value = []
        mock_get_pool.return_value = pool

        result = await instructions_list(query="test", mode="intent")
        assert result["mode"] == "intent"
        assert result["fallback"] is True
        assert "Embed service down" in result["fallback_reason"]

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_no_query_defaults_to_list_all(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetch.return_value = []
        mock_get_pool.return_value = pool

        result = await instructions_list(mode="text")  # text mode but no query
        assert result["mode"] == "all"

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_row_to_dict_includes_session(self, mock_get_pool):
        session_id = uuid.uuid4()
        pool = AsyncMock()
        pool.fetch.return_value = [
            _make_instruction_row(session_id=session_id),
        ]
        mock_get_pool.return_value = pool

        result = await instructions_list(mode="all")
        assert "session" in result["instructions"][0]
        assert result["instructions"][0]["session"] == shortuuid.encode(session_id)

    @patch("npl_mcp.instructions.instructions.get_pool")
    async def test_row_to_dict_omits_session_when_null(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetch.return_value = [_make_instruction_row(session_id=None)]
        mock_get_pool.return_value = pool

        result = await instructions_list(mode="all")
        assert "session" not in result["instructions"][0]
