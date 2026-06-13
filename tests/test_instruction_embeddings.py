"""Tests for npl_mcp.instructions.embeddings and npl_mcp.meta_tools.llm_client.embed_texts."""

import uuid
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from npl_mcp.instructions.embeddings import (
    extract_descriptive_phrases,
    generate_and_store_embeddings,
)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _mock_pool_with_transaction():
    """Return (pool, conn) where pool.acquire() yields conn in a transaction."""
    conn = AsyncMock()

    tx_cm = MagicMock()
    tx_cm.__aenter__ = AsyncMock(return_value=None)
    tx_cm.__aexit__ = AsyncMock(return_value=False)
    conn.transaction = MagicMock(return_value=tx_cm)

    acquire_cm = MagicMock()
    acquire_cm.__aenter__ = AsyncMock(return_value=conn)
    acquire_cm.__aexit__ = AsyncMock(return_value=False)

    pool = AsyncMock()
    pool.acquire = MagicMock(return_value=acquire_cm)

    return pool, conn


# ---------------------------------------------------------------------------
# extract_descriptive_phrases
# ---------------------------------------------------------------------------


class TestExtractDescriptivePhrases:
    @patch("npl_mcp.instructions.embeddings.chat_completion", new_callable=AsyncMock)
    async def test_extracts_phrases(self, mock_chat):
        mock_chat.return_value = {
            "choices": [
                {"message": {"content": '["phrase one", "phrase two", "phrase three"]'}}
            ]
        }
        phrases = await extract_descriptive_phrases("Title", "Desc", ["tag"], "Body")
        assert len(phrases) == 3
        assert all(isinstance(p, str) for p in phrases)
        mock_chat.assert_awaited_once()

    @patch("npl_mcp.instructions.embeddings.chat_completion", new_callable=AsyncMock)
    async def test_handles_markdown_fences(self, mock_chat):
        mock_chat.return_value = {
            "choices": [
                {"message": {"content": '```json\n["a", "b"]\n```'}}
            ]
        }
        phrases = await extract_descriptive_phrases("T", "D", [], "B")
        assert len(phrases) == 2
        assert phrases == ["a", "b"]

    @patch("npl_mcp.instructions.embeddings.chat_completion", new_callable=AsyncMock)
    async def test_caps_at_5_phrases(self, mock_chat):
        mock_chat.return_value = {
            "choices": [
                {"message": {"content": '["a","b","c","d","e","f","g"]'}}
            ]
        }
        phrases = await extract_descriptive_phrases("T", "D", [], "B")
        assert len(phrases) == 5

    @patch("npl_mcp.instructions.embeddings.chat_completion", new_callable=AsyncMock)
    async def test_raises_on_non_array(self, mock_chat):
        mock_chat.return_value = {
            "choices": [{"message": {"content": '{"not": "array"}'}}]
        }
        with pytest.raises(ValueError, match="Expected JSON array"):
            await extract_descriptive_phrases("T", "D", [], "B")

    @patch("npl_mcp.instructions.embeddings.chat_completion", new_callable=AsyncMock)
    async def test_handles_empty_tags(self, mock_chat):
        mock_chat.return_value = {
            "choices": [{"message": {"content": '["phrase"]'}}]
        }
        phrases = await extract_descriptive_phrases("T", "D", [], "Body")
        assert len(phrases) == 1
        # Verify the user message includes "(none)" for empty tags
        call_args = mock_chat.call_args[0][0]
        user_msg = call_args[1]["content"]
        assert "(none)" in user_msg

    @patch("npl_mcp.instructions.embeddings.chat_completion", new_callable=AsyncMock)
    async def test_truncates_body_at_2000_chars(self, mock_chat):
        mock_chat.return_value = {
            "choices": [{"message": {"content": '["phrase"]'}}]
        }
        long_body = "x" * 5000
        await extract_descriptive_phrases("T", "D", [], long_body)
        call_args = mock_chat.call_args[0][0]
        user_msg = call_args[1]["content"]
        # Body portion should be truncated
        assert len(user_msg) < 2200


# ---------------------------------------------------------------------------
# generate_and_store_embeddings
# ---------------------------------------------------------------------------


class TestGenerateAndStoreEmbeddings:
    @patch("npl_mcp.instructions.embeddings.get_pool")
    @patch("npl_mcp.instructions.embeddings.embed_texts", new_callable=AsyncMock)
    @patch("npl_mcp.instructions.embeddings.chat_completion", new_callable=AsyncMock)
    async def test_stores_embeddings(self, mock_chat, mock_embed, mock_get_pool):
        mock_chat.return_value = {
            "choices": [
                {"message": {"content": '["phrase 1", "phrase 2"]'}}
            ]
        }
        mock_embed.return_value = [[0.1] * 1536, [0.2] * 1536]

        pool, conn = _mock_pool_with_transaction()
        mock_get_pool.return_value = pool

        instruction_id = uuid.uuid4()
        await generate_and_store_embeddings(
            instruction_id, "Title", "Desc", ["tag"], "Body"
        )

        # Verify DELETE was called, then 2 INSERTs
        assert conn.execute.call_count == 3  # 1 DELETE + 2 INSERT
        # First call is DELETE
        delete_call = conn.execute.call_args_list[0]
        assert "DELETE" in delete_call[0][0]
        assert delete_call[0][1] == instruction_id
        # Subsequent calls are INSERTs
        insert_call_1 = conn.execute.call_args_list[1]
        assert "INSERT" in insert_call_1[0][0]
        assert insert_call_1[0][2] == "phrase 1"

    @patch("npl_mcp.instructions.embeddings.chat_completion", new_callable=AsyncMock)
    async def test_swallows_llm_failure(self, mock_chat):
        mock_chat.side_effect = Exception("LLM down")

        # Should not raise
        await generate_and_store_embeddings(
            uuid.uuid4(), "Title", "Desc", ["tag"], "Body"
        )

    @patch("npl_mcp.instructions.embeddings.get_pool")
    @patch("npl_mcp.instructions.embeddings.embed_texts", new_callable=AsyncMock)
    @patch("npl_mcp.instructions.embeddings.chat_completion", new_callable=AsyncMock)
    async def test_swallows_embed_failure(self, mock_chat, mock_embed, mock_get_pool):
        mock_chat.return_value = {
            "choices": [{"message": {"content": '["phrase"]'}}]
        }
        mock_embed.side_effect = Exception("Embed service down")

        # Should not raise
        await generate_and_store_embeddings(
            uuid.uuid4(), "Title", "Desc", ["tag"], "Body"
        )

    @patch("npl_mcp.instructions.embeddings.get_pool")
    @patch("npl_mcp.instructions.embeddings.embed_texts", new_callable=AsyncMock)
    @patch("npl_mcp.instructions.embeddings.chat_completion", new_callable=AsyncMock)
    async def test_skips_on_empty_phrases(self, mock_chat, mock_embed, mock_get_pool):
        mock_chat.return_value = {
            "choices": [{"message": {"content": "[]"}}]
        }

        await generate_and_store_embeddings(
            uuid.uuid4(), "Title", "Desc", ["tag"], "Body"
        )
        # embed_texts should not be called if no phrases
        mock_embed.assert_not_awaited()

    @patch("npl_mcp.instructions.embeddings.get_pool")
    @patch("npl_mcp.instructions.embeddings.embed_texts", new_callable=AsyncMock)
    @patch("npl_mcp.instructions.embeddings.chat_completion", new_callable=AsyncMock)
    async def test_swallows_db_failure(self, mock_chat, mock_embed, mock_get_pool):
        mock_chat.return_value = {
            "choices": [{"message": {"content": '["phrase"]'}}]
        }
        mock_embed.return_value = [[0.1] * 1536]

        pool, conn = _mock_pool_with_transaction()
        conn.execute.side_effect = Exception("DB error")
        mock_get_pool.return_value = pool

        # Should not raise
        await generate_and_store_embeddings(
            uuid.uuid4(), "Title", "Desc", ["tag"], "Body"
        )


# ---------------------------------------------------------------------------
# embed_texts (llm_client)
# ---------------------------------------------------------------------------


class TestEmbedTexts:
    @patch("npl_mcp.meta_tools.llm_client.httpx.AsyncClient")
    async def test_returns_vectors_in_order(self, mock_client_cls):
        from npl_mcp.meta_tools.llm_client import embed_texts

        mock_response = MagicMock()
        mock_response.json.return_value = {
            "data": [
                {"index": 1, "embedding": [0.2] * 10},
                {"index": 0, "embedding": [0.1] * 10},
            ]
        }
        mock_response.raise_for_status = MagicMock()

        mock_client = AsyncMock()
        mock_client.post.return_value = mock_response
        mock_client.__aenter__ = AsyncMock(return_value=mock_client)
        mock_client.__aexit__ = AsyncMock(return_value=False)
        mock_client_cls.return_value = mock_client

        vectors = await embed_texts(["hello", "world"])
        assert len(vectors) == 2
        # Should be sorted by index: index 0 first
        assert vectors[0] == [0.1] * 10
        assert vectors[1] == [0.2] * 10

    @patch("npl_mcp.meta_tools.llm_client.httpx.AsyncClient")
    async def test_calls_embeddings_endpoint(self, mock_client_cls):
        from npl_mcp.meta_tools.llm_client import embed_texts, LITELLM_BASE_URL

        mock_response = MagicMock()
        mock_response.json.return_value = {
            "data": [{"index": 0, "embedding": [0.1]}]
        }
        mock_response.raise_for_status = MagicMock()

        mock_client = AsyncMock()
        mock_client.post.return_value = mock_response
        mock_client.__aenter__ = AsyncMock(return_value=mock_client)
        mock_client.__aexit__ = AsyncMock(return_value=False)
        mock_client_cls.return_value = mock_client

        await embed_texts(["test"])
        call_args = mock_client.post.call_args
        assert call_args[0][0] == f"{LITELLM_BASE_URL}/embeddings"

    @patch("npl_mcp.meta_tools.llm_client.httpx.AsyncClient")
    async def test_uses_custom_model(self, mock_client_cls):
        from npl_mcp.meta_tools.llm_client import embed_texts

        mock_response = MagicMock()
        mock_response.json.return_value = {
            "data": [{"index": 0, "embedding": [0.1]}]
        }
        mock_response.raise_for_status = MagicMock()

        mock_client = AsyncMock()
        mock_client.post.return_value = mock_response
        mock_client.__aenter__ = AsyncMock(return_value=mock_client)
        mock_client.__aexit__ = AsyncMock(return_value=False)
        mock_client_cls.return_value = mock_client

        await embed_texts(["test"], model="custom/model")
        call_args = mock_client.post.call_args
        assert call_args[1]["json"]["model"] == "custom/model"
