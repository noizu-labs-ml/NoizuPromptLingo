"""Tests for browser/secrets.py – secret_set, secret_get, get_secrets_batch."""

from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from npl_mcp.browser.secrets import (
    _validate_name,
    secret_set,
    secret_get,
    get_secrets_batch,
    _MAX_NAME_LEN,
    _MAX_VALUE_LEN,
)


# ── Validation ────────────────────────────────────────────────────────────

class TestValidateName:
    def test_valid_simple(self):
        assert _validate_name("API_KEY") is None

    def test_valid_underscore_start(self):
        assert _validate_name("_secret") is None

    def test_valid_single_char(self):
        assert _validate_name("x") is None

    def test_empty_string(self):
        assert _validate_name("") is not None

    def test_starts_with_digit(self):
        assert _validate_name("1abc") is not None

    def test_contains_dash(self):
        assert _validate_name("my-secret") is not None

    def test_contains_dot(self):
        assert _validate_name("my.secret") is not None

    def test_contains_space(self):
        assert _validate_name("my secret") is not None

    def test_too_long(self):
        assert _validate_name("a" * (_MAX_NAME_LEN + 1)) is not None

    def test_max_length_ok(self):
        assert _validate_name("a" * _MAX_NAME_LEN) is None

    def test_not_a_string(self):
        assert _validate_name(123) is not None  # type: ignore[arg-type]


# ── secret_set ────────────────────────────────────────────────────────────

class TestSecretSet:
    @pytest.fixture
    def mock_pool(self):
        pool = AsyncMock()
        return pool

    @patch("npl_mcp.browser.secrets.get_pool")
    async def test_create_new_secret(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetchrow.return_value = {"xmax": 0}
        mock_get_pool.return_value = pool

        result = await secret_set("MY_KEY", "secret_value")
        assert result == {"name": "MY_KEY", "action": "created", "status": "ok"}
        pool.fetchrow.assert_called_once()

    @patch("npl_mcp.browser.secrets.get_pool")
    async def test_update_existing_secret(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetchrow.return_value = {"xmax": 1}
        mock_get_pool.return_value = pool

        result = await secret_set("MY_KEY", "new_value")
        assert result == {"name": "MY_KEY", "action": "updated", "status": "ok"}

    async def test_invalid_name_rejected(self):
        result = await secret_set("1invalid", "value")
        assert result["status"] == "error"
        assert "must match" in result["message"]

    async def test_empty_name_rejected(self):
        result = await secret_set("", "value")
        assert result["status"] == "error"

    async def test_value_not_string(self):
        result = await secret_set("key", 123)  # type: ignore[arg-type]
        assert result["status"] == "error"
        assert "string" in result["message"]

    async def test_value_too_large(self):
        result = await secret_set("key", "x" * (_MAX_VALUE_LEN + 1))
        assert result["status"] == "error"
        assert "exceeds" in result["message"]

    @patch("npl_mcp.browser.secrets.get_pool")
    async def test_sql_uses_upsert(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetchrow.return_value = {"xmax": 0}
        mock_get_pool.return_value = pool

        await secret_set("test", "val")
        sql = pool.fetchrow.call_args[0][0]
        assert "ON CONFLICT" in sql
        assert "DO UPDATE" in sql


# ── secret_get ────────────────────────────────────────────────────────────

class TestSecretGet:
    @patch("npl_mcp.browser.secrets.get_pool")
    async def test_found(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetchrow.return_value = {"value": "my_secret_value"}
        mock_get_pool.return_value = pool

        result = await secret_get("MY_KEY")
        assert result == {"name": "MY_KEY", "value": "my_secret_value", "status": "ok"}

    @patch("npl_mcp.browser.secrets.get_pool")
    async def test_not_found(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetchrow.return_value = None
        mock_get_pool.return_value = pool

        result = await secret_get("MISSING")
        assert result == {"name": "MISSING", "status": "not_found"}

    async def test_invalid_name(self):
        result = await secret_get("bad-name")
        assert result["status"] == "error"


# ── get_secrets_batch ─────────────────────────────────────────────────────

class TestGetSecretsBatch:
    @patch("npl_mcp.browser.secrets.get_pool")
    async def test_returns_dict(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetch.return_value = [
            {"name": "A", "value": "val_a"},
            {"name": "B", "value": "val_b"},
        ]
        mock_get_pool.return_value = pool

        result = await get_secrets_batch(["A", "B"])
        assert result == {"A": "val_a", "B": "val_b"}

    @patch("npl_mcp.browser.secrets.get_pool")
    async def test_partial_results(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetch.return_value = [{"name": "A", "value": "val_a"}]
        mock_get_pool.return_value = pool

        result = await get_secrets_batch(["A", "B"])
        assert result == {"A": "val_a"}
        assert "B" not in result

    async def test_empty_list(self):
        result = await get_secrets_batch([])
        assert result == {}

    @patch("npl_mcp.browser.secrets.get_pool")
    async def test_uses_any_query(self, mock_get_pool):
        pool = AsyncMock()
        pool.fetch.return_value = []
        mock_get_pool.return_value = pool

        await get_secrets_batch(["X"])
        sql = pool.fetch.call_args[0][0]
        assert "ANY($1)" in sql
