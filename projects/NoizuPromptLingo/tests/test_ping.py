"""Tests for the Ping tool (browser/ping.py)."""

import re
from unittest.mock import AsyncMock, patch

import httpx
import pytest

from npl_mcp.browser.ping import (
    _evaluate_sentinel,
    _sentinel_regex,
    _sentinel_xpath,
    ping,
)


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

SAMPLE_HTML = """\
<html>
<head><title>Test Page</title></head>
<body>
  <h1 id="main-title">Hello World</h1>
  <p class="content">Version 2.5.1 released on 2025-01-15</p>
  <ul>
    <li>Item A</li>
    <li>Item B</li>
    <li>Item C</li>
  </ul>
</body>
</html>
"""


def _make_response(status_code=200, text=SAMPLE_HTML):
    """Build a mock httpx.Response."""
    resp = httpx.Response(
        status_code=status_code,
        text=text,
        request=httpx.Request("GET", "https://example.com"),
    )
    return resp


# ---------------------------------------------------------------------------
# Basic ping (no sentinel)
# ---------------------------------------------------------------------------


class TestPingBasic:
    async def test_successful_head_request(self):
        resp = _make_response(200)

        async def _mock_send(self, request, **kwargs):
            return resp

        with patch.object(httpx.AsyncClient, "send", _mock_send):
            result = await ping("https://example.com")

        assert result["url"] == "https://example.com"
        assert result["status_code"] == 200
        assert isinstance(result["response_time_ms"], (int, float))
        assert result["response_time_ms"] >= 0
        assert "sentinel" not in result

    async def test_404_response(self):
        resp = _make_response(404)

        async def _mock_send(self, request, **kwargs):
            return resp

        with patch.object(httpx.AsyncClient, "send", _mock_send):
            result = await ping("https://example.com/missing")

        assert result["status_code"] == 404
        assert "error" not in result

    async def test_timeout_error(self):
        async def _mock_send(self, request, **kwargs):
            raise httpx.ReadTimeout("timed out")

        with patch.object(httpx.AsyncClient, "send", _mock_send):
            result = await ping("https://example.com", timeout=0.1)

        assert result["status_code"] is None
        assert result["error"] == "timeout"

    async def test_connection_error(self):
        async def _mock_send(self, request, **kwargs):
            raise httpx.ConnectError("connection refused")

        with patch.object(httpx.AsyncClient, "send", _mock_send):
            result = await ping("https://unreachable.example.com")

        assert result["status_code"] is None
        assert "ConnectError" in result["error"]

    async def test_uses_head_without_sentinel(self):
        """Without sentinel, should use HEAD (lighter request)."""
        captured_methods = []

        async def _mock_send(self, request, **kwargs):
            captured_methods.append(request.method)
            return _make_response(200)

        with patch.object(httpx.AsyncClient, "send", _mock_send):
            await ping("https://example.com")

        assert captured_methods[0] == "HEAD"

    async def test_uses_get_with_sentinel(self):
        """With sentinel, should use GET to fetch body."""
        captured_methods = []

        async def _mock_send(self, request, **kwargs):
            captured_methods.append(request.method)
            return _make_response(200)

        with patch.object(httpx.AsyncClient, "send", _mock_send):
            await ping("https://example.com", sentinel="regex:test")

        assert captured_methods[0] == "GET"


# ---------------------------------------------------------------------------
# XPath sentinel
# ---------------------------------------------------------------------------


class TestSentinelXPath:
    def test_element_match(self):
        result = _sentinel_xpath("//h1[@id='main-title']", SAMPLE_HTML)
        assert result["type"] == "xpath"
        assert result["pass"] is True
        assert "Hello World" in result["matches"][0]

    def test_element_no_match(self):
        result = _sentinel_xpath("//h1[@id='nonexistent']", SAMPLE_HTML)
        assert result["type"] == "xpath"
        assert result["pass"] is False
        assert result["matches"] == []

    def test_text_extraction(self):
        result = _sentinel_xpath("//title/text()", SAMPLE_HTML)
        assert result["pass"] is True
        assert "Test Page" in result["matches"]

    def test_boolean_expression(self):
        result = _sentinel_xpath("boolean(//h1)", SAMPLE_HTML)
        assert result["type"] == "xpath"
        assert result["pass"] is True
        assert result["value"] is True

    def test_boolean_false(self):
        result = _sentinel_xpath("boolean(//h99)", SAMPLE_HTML)
        assert result["pass"] is False
        assert result["value"] is False

    def test_count_expression(self):
        result = _sentinel_xpath("count(//li)", SAMPLE_HTML)
        assert result["pass"] is True
        assert result["value"] == 3.0

    def test_count_zero(self):
        result = _sentinel_xpath("count(//table)", SAMPLE_HTML)
        assert result["pass"] is False
        assert result["value"] == 0.0

    def test_multiple_elements(self):
        result = _sentinel_xpath("//li", SAMPLE_HTML)
        assert result["pass"] is True
        assert len(result["matches"]) == 3

    def test_invalid_xpath(self):
        result = _sentinel_xpath("[[[invalid", SAMPLE_HTML)
        assert result["pass"] is False
        assert "error" in result

    def test_bad_html(self):
        result = _sentinel_xpath("//h1", "not valid html <<<>>>")
        # lxml is lenient, should still parse
        assert result["type"] == "xpath"

    def test_string_value_match(self):
        result = _sentinel_xpath("string(//h1)", SAMPLE_HTML)
        assert result["type"] == "xpath"
        assert result["pass"] is True
        assert result["value"] == "Hello World"

    def test_string_value_empty(self):
        result = _sentinel_xpath("string(//h99)", SAMPLE_HTML)
        assert result["type"] == "xpath"
        assert result["pass"] is False
        assert result["value"] == ""


# ---------------------------------------------------------------------------
# Regex sentinel
# ---------------------------------------------------------------------------


class TestSentinelRegex:
    def test_simple_match(self):
        result = _sentinel_regex(r"Hello\s+World", SAMPLE_HTML)
        assert result["type"] == "regex"
        assert result["pass"] is True
        assert result["total_matches"] >= 1

    def test_no_match(self):
        result = _sentinel_regex(r"Goodbye\s+World", SAMPLE_HTML)
        assert result["pass"] is False
        assert result["total_matches"] == 0

    def test_capture_groups(self):
        result = _sentinel_regex(r"Version (\d+\.\d+\.\d+)", SAMPLE_HTML)
        assert result["pass"] is True
        assert "2.5.1" in result["matches"]

    def test_multiple_matches(self):
        result = _sentinel_regex(r"Item [A-C]", SAMPLE_HTML)
        assert result["pass"] is True
        assert result["total_matches"] == 3

    def test_invalid_regex(self):
        result = _sentinel_regex(r"[invalid(", SAMPLE_HTML)
        assert result["pass"] is False
        assert "error" in result

    def test_cap_at_50_matches(self):
        body = "x " * 100
        result = _sentinel_regex(r"x", body)
        assert len(result["matches"]) <= 50
        assert result["total_matches"] == 100


# ---------------------------------------------------------------------------
# LLM sentinel
# ---------------------------------------------------------------------------


class TestSentinelLLM:
    async def test_llm_true(self):
        mock_resp = {
            "choices": [{"message": {"content": "TRUE - The page contains a greeting"}}]
        }
        with patch(
            "npl_mcp.meta_tools.llm_client.chat_completion",
            new_callable=AsyncMock,
            return_value=mock_resp,
        ):
            result = await _evaluate_sentinel("llm:Does the page contain a greeting?", SAMPLE_HTML)

        assert result["type"] == "llm"
        assert result["pass"] is True
        assert "TRUE" in result["detail"]

    async def test_llm_false(self):
        mock_resp = {
            "choices": [{"message": {"content": "FALSE - No login form found"}}]
        }
        with patch(
            "npl_mcp.meta_tools.llm_client.chat_completion",
            new_callable=AsyncMock,
            return_value=mock_resp,
        ):
            result = await _evaluate_sentinel("llm:Does the page have a login form?", SAMPLE_HTML)

        assert result["type"] == "llm"
        assert result["pass"] is False

    async def test_llm_error_handling(self):
        with patch(
            "npl_mcp.meta_tools.llm_client.chat_completion",
            new_callable=AsyncMock,
            side_effect=httpx.TimeoutException("LLM timeout"),
        ):
            result = await _evaluate_sentinel("llm:check something", SAMPLE_HTML)

        assert result["type"] == "llm"
        assert result["pass"] is False
        assert "error" in result

    async def test_llm_truncates_long_body(self):
        long_body = "x" * 20_000
        captured_messages = []

        async def _capture_chat(messages, **kwargs):
            captured_messages.append(messages)
            return {"choices": [{"message": {"content": "TRUE - ok"}}]}

        with patch("npl_mcp.meta_tools.llm_client.chat_completion", side_effect=_capture_chat):
            await _evaluate_sentinel("llm:is it ok?", long_body)

        user_msg = captured_messages[0][1]["content"]
        assert "truncated" in user_msg
        assert len(user_msg) < 20_000


# ---------------------------------------------------------------------------
# Sentinel dispatch
# ---------------------------------------------------------------------------


class TestSentinelDispatch:
    async def test_unknown_prefix(self):
        result = await _evaluate_sentinel("unknown:test", SAMPLE_HTML)
        assert "error" in result
        assert "Unknown sentinel prefix" in result["error"]

    async def test_xpath_dispatch(self):
        result = await _evaluate_sentinel("xpath://h1", SAMPLE_HTML)
        assert result["type"] == "xpath"

    async def test_regex_dispatch(self):
        result = await _evaluate_sentinel("regex:Hello", SAMPLE_HTML)
        assert result["type"] == "regex"


# ---------------------------------------------------------------------------
# Integration: ping + sentinel
# ---------------------------------------------------------------------------


class TestPingWithSentinel:
    async def test_ping_with_xpath(self):
        resp = _make_response(200)

        async def _mock_send(self, request, **kwargs):
            return resp

        with patch.object(httpx.AsyncClient, "send", _mock_send):
            result = await ping("https://example.com", sentinel="xpath://h1")

        assert result["status_code"] == 200
        assert result["sentinel"]["type"] == "xpath"
        assert result["sentinel"]["pass"] is True

    async def test_ping_with_regex(self):
        resp = _make_response(200)

        async def _mock_send(self, request, **kwargs):
            return resp

        with patch.object(httpx.AsyncClient, "send", _mock_send):
            result = await ping("https://example.com", sentinel="regex:Version \\d+")

        assert result["status_code"] == 200
        assert result["sentinel"]["type"] == "regex"
        assert result["sentinel"]["pass"] is True

    async def test_ping_with_llm(self):
        resp = _make_response(200)
        mock_llm = {
            "choices": [{"message": {"content": "TRUE - page has heading"}}]
        }

        async def _mock_send(self, request, **kwargs):
            return resp

        with (
            patch.object(httpx.AsyncClient, "send", _mock_send),
            patch(
                "npl_mcp.meta_tools.llm_client.chat_completion",
                new_callable=AsyncMock,
                return_value=mock_llm,
            ),
        ):
            result = await ping("https://example.com", sentinel="llm:has heading?")

        assert result["status_code"] == 200
        assert result["sentinel"]["type"] == "llm"
        assert result["sentinel"]["pass"] is True

    async def test_ping_timeout_skips_sentinel(self):
        async def _mock_send(self, request, **kwargs):
            raise httpx.ReadTimeout("timed out")

        with patch.object(httpx.AsyncClient, "send", _mock_send):
            result = await ping("https://example.com", sentinel="xpath://h1")

        assert result["error"] == "timeout"
        assert "sentinel" not in result
