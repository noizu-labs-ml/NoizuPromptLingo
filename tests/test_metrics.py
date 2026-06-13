"""Unit tests for npl_mcp.storage.metrics and /api/metrics endpoints."""

from __future__ import annotations

from datetime import datetime, timezone
from unittest.mock import AsyncMock, patch

import pytest

from npl_mcp.storage.metrics import (
    list_llm_calls,
    list_tool_calls,
    record_llm_call,
    record_tool_call,
)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

_NOW = datetime(2026, 4, 22, 12, 0, 0, tzinfo=timezone.utc)


def _tool_call_row(**overrides) -> dict:
    base = {
        "id": 1,
        "tool_name": "Ping",
        "session_id": "sess-abc",
        "response_time_ms": 42,
        "error": None,
        "called_at": _NOW,
    }
    base.update(overrides)
    return base


def _llm_call_row(**overrides) -> dict:
    base = {
        "id": 1,
        "model": "claude-3-5-haiku",
        "purpose": "intent_search",
        "prompt_tokens": 100,
        "completion_tokens": 50,
        "latency_ms": 320,
        "session_id": "sess-xyz",
        "called_at": _NOW,
    }
    base.update(overrides)
    return base


class _FakeConn:
    """Minimal async context manager that records execute calls and returns
    canned rows from fetch."""

    def __init__(self, rows=None):
        self.executed = []
        self._rows = rows or []

    async def execute(self, sql, *args):
        self.executed.append((sql, args))

    async def fetch(self, sql, *args):
        return self._rows

    async def __aenter__(self):
        return self

    async def __aexit__(self, *exc):
        pass


class _FakePool:
    def __init__(self, conn):
        self._conn = conn

    def acquire(self):
        return self._conn


# ---------------------------------------------------------------------------
# record_tool_call
# ---------------------------------------------------------------------------


class TestRecordToolCall:
    @patch("npl_mcp.storage.metrics.get_pool")
    async def test_inserts_row(self, mock_pool):
        conn = _FakeConn()
        pool = _FakePool(conn)
        mock_pool.return_value = pool

        await record_tool_call(
            "Ping",
            arguments='{"url": "https://example.com"}',
            result_summary="ok",
            response_time_ms=42,
            session_id="sess-1",
        )

        assert len(conn.executed) == 1
        sql, args = conn.executed[0]
        assert "INSERT INTO npl_tool_calls" in sql
        assert args[0] == "Ping"
        assert args[1] == "sess-1"

    @patch("npl_mcp.storage.metrics.get_pool")
    async def test_inserts_with_error(self, mock_pool):
        conn = _FakeConn()
        pool = _FakePool(conn)
        mock_pool.return_value = pool

        await record_tool_call(
            "Ping",
            error="Connection refused",
            response_time_ms=100,
        )

        assert len(conn.executed) == 1
        _, args = conn.executed[0]
        assert args[5] == "Connection refused"

    @patch("npl_mcp.storage.metrics.get_pool")
    async def test_swallows_db_errors(self, mock_pool):
        mock_pool.side_effect = RuntimeError("DB down")
        # Should not raise
        await record_tool_call("Ping")


# ---------------------------------------------------------------------------
# record_llm_call
# ---------------------------------------------------------------------------


class TestRecordLLMCall:
    @patch("npl_mcp.storage.metrics.get_pool")
    async def test_inserts_row(self, mock_pool):
        conn = _FakeConn()
        pool = _FakePool(conn)
        mock_pool.return_value = pool

        await record_llm_call(
            "claude-3-5-haiku",
            purpose="intent_search",
            prompt_tokens=100,
            completion_tokens=50,
            total_tokens=150,
            latency_ms=320,
            session_id="sess-2",
        )

        assert len(conn.executed) == 1
        sql, args = conn.executed[0]
        assert "INSERT INTO npl_llm_calls" in sql
        assert args[0] == "claude-3-5-haiku"
        assert args[1] == "intent_search"
        assert args[2] == 100

    @patch("npl_mcp.storage.metrics.get_pool")
    async def test_swallows_db_errors(self, mock_pool):
        mock_pool.side_effect = RuntimeError("DB down")
        await record_llm_call("gpt-4o")


# ---------------------------------------------------------------------------
# list_tool_calls
# ---------------------------------------------------------------------------


class TestListToolCalls:
    @patch("npl_mcp.storage.metrics.get_pool")
    async def test_returns_metric_list_result(self, mock_pool):
        rows = [_tool_call_row(id=1), _tool_call_row(id=2, error="timeout")]
        conn = _FakeConn(rows=rows)
        pool = _FakePool(conn)
        mock_pool.return_value = pool

        result = await list_tool_calls(limit=10)

        assert "items" in result
        assert "count" in result
        assert result["count"] == 2
        assert result["items"][0]["id"] == 1
        assert result["items"][0]["status"] == "ok"
        assert result["items"][1]["status"] == "error"
        assert result["items"][0]["created_at"] == "2026-04-22T12:00:00+00:00Z"

    @patch("npl_mcp.storage.metrics.get_pool")
    async def test_returns_empty_when_no_rows(self, mock_pool):
        conn = _FakeConn(rows=[])
        pool = _FakePool(conn)
        mock_pool.return_value = pool

        result = await list_tool_calls()
        assert result == {"items": [], "count": 0}


# ---------------------------------------------------------------------------
# list_llm_calls
# ---------------------------------------------------------------------------


class TestListLLMCalls:
    @patch("npl_mcp.storage.metrics.get_pool")
    async def test_returns_metric_list_result(self, mock_pool):
        rows = [_llm_call_row(id=10)]
        conn = _FakeConn(rows=rows)
        pool = _FakePool(conn)
        mock_pool.return_value = pool

        result = await list_llm_calls(limit=5)

        assert result["count"] == 1
        item = result["items"][0]
        assert item["id"] == 10
        assert item["model"] == "claude-3-5-haiku"
        assert item["purpose"] == "intent_search"
        assert item["tokens_in"] == 100
        assert item["tokens_out"] == 50
        assert item["duration_ms"] == 320

    @patch("npl_mcp.storage.metrics.get_pool")
    async def test_returns_empty_when_no_rows(self, mock_pool):
        conn = _FakeConn(rows=[])
        pool = _FakePool(conn)
        mock_pool.return_value = pool

        result = await list_llm_calls()
        assert result == {"items": [], "count": 0}
