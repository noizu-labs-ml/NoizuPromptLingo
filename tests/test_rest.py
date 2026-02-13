"""Tests for browser/rest.py – HTTP client with secret injection."""

from unittest.mock import AsyncMock, patch, MagicMock

import httpx
import pytest

from npl_mcp.browser.rest import (
    rest,
    _collect_secret_refs,
    _inject_secrets,
    _ALLOWED_METHODS,
    _MAX_BODY_INPUT,
    _MAX_RESPONSE_BODY,
)


# ── Helper tests ──────────────────────────────────────────────────────────

class TestCollectSecretRefs:
    def test_no_secrets(self):
        assert _collect_secret_refs("plain text") == []

    def test_single_secret(self):
        assert _collect_secret_refs("Bearer ${secret.API_KEY}") == ["API_KEY"]

    def test_multiple_secrets(self):
        refs = _collect_secret_refs(
            "${secret.USER}:${secret.PASS}", "${secret.TOKEN}"
        )
        assert sorted(refs) == ["PASS", "TOKEN", "USER"]

    def test_deduplicates(self):
        refs = _collect_secret_refs("${secret.X} ${secret.X}")
        assert refs == ["X"]

    def test_none_input(self):
        assert _collect_secret_refs(None, None) == []

    def test_underscore_names(self):
        refs = _collect_secret_refs("${secret._private}")
        assert refs == ["_private"]


class TestInjectSecrets:
    def test_replaces_placeholder(self):
        result = _inject_secrets("Bearer ${secret.TOKEN}", {"TOKEN": "abc123"})
        assert result == "Bearer abc123"

    def test_multiple_replacements(self):
        result = _inject_secrets(
            "${secret.A}:${secret.B}",
            {"A": "foo", "B": "bar"},
        )
        assert result == "foo:bar"

    def test_no_placeholders(self):
        result = _inject_secrets("plain text", {})
        assert result == "plain text"


# ── Method validation ─────────────────────────────────────────────────────

class TestRestMethodValidation:
    @patch("npl_mcp.browser.rest.get_secrets_batch", new_callable=AsyncMock)
    async def test_invalid_method(self, mock_batch):
        result = await rest("https://example.com", method="INVALID")
        assert result["status"] == "error"
        assert "Unsupported" in result["message"]

    @patch("npl_mcp.browser.rest.get_secrets_batch", new_callable=AsyncMock)
    async def test_all_valid_methods_accepted(self, mock_batch):
        """Verify all allowed methods don't trigger validation error."""
        for method in _ALLOWED_METHODS:
            # We don't actually make the request, just check method validation passes
            # by mocking httpx
            with patch("npl_mcp.browser.rest.httpx.AsyncClient") as mock_client:
                mock_response = MagicMock()
                mock_response.status_code = 200
                mock_response.headers = {}
                mock_response.text = "ok"
                mock_ctx = AsyncMock()
                mock_ctx.__aenter__.return_value = mock_ctx
                mock_ctx.request.return_value = mock_response
                mock_client.return_value = mock_ctx

                result = await rest("https://example.com", method=method)
                assert "status" not in result or result.get("status_code") == 200, \
                    f"Method {method} should be accepted"


# ── Body size limits ──────────────────────────────────────────────────────

class TestRestBodyLimits:
    @patch("npl_mcp.browser.rest.get_secrets_batch", new_callable=AsyncMock)
    async def test_body_too_large(self, mock_batch):
        result = await rest(
            "https://example.com",
            method="POST",
            body="x" * (_MAX_BODY_INPUT + 1),
        )
        assert result["status"] == "error"
        assert "exceeds" in result["message"]


# ── Secret injection ─────────────────────────────────────────────────────

class TestRestSecretInjection:
    @patch("npl_mcp.browser.rest.httpx.AsyncClient")
    @patch("npl_mcp.browser.rest.get_secrets_batch", new_callable=AsyncMock)
    async def test_header_injection(self, mock_batch, mock_client):
        mock_batch.return_value = {"API_KEY": "sk-123"}
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.headers = {}
        mock_response.text = "ok"
        mock_ctx = AsyncMock()
        mock_ctx.__aenter__.return_value = mock_ctx
        mock_ctx.request.return_value = mock_response
        mock_client.return_value = mock_ctx

        result = await rest(
            "https://api.example.com",
            headers={"Authorization": "Bearer ${secret.API_KEY}"},
        )
        assert result["status_code"] == 200
        assert result["secrets_injected"] == ["API_KEY"]
        # Verify the actual header was injected
        call_kwargs = mock_ctx.request.call_args
        sent_headers = call_kwargs.kwargs.get("headers") or call_kwargs[1].get("headers")
        assert sent_headers["Authorization"] == "Bearer sk-123"

    @patch("npl_mcp.browser.rest.httpx.AsyncClient")
    @patch("npl_mcp.browser.rest.get_secrets_batch", new_callable=AsyncMock)
    async def test_body_injection(self, mock_batch, mock_client):
        mock_batch.return_value = {"TOKEN": "xyz"}
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.headers = {}
        mock_response.text = "ok"
        mock_ctx = AsyncMock()
        mock_ctx.__aenter__.return_value = mock_ctx
        mock_ctx.request.return_value = mock_response
        mock_client.return_value = mock_ctx

        result = await rest(
            "https://api.example.com",
            method="POST",
            body='{"token": "${secret.TOKEN}"}',
        )
        assert result["secrets_injected"] == ["TOKEN"]
        call_kwargs = mock_ctx.request.call_args
        sent_content = call_kwargs.kwargs.get("content") or call_kwargs[1].get("content")
        assert b'"token": "xyz"' in sent_content

    @patch("npl_mcp.browser.rest.get_secrets_batch", new_callable=AsyncMock)
    async def test_missing_secret_aborts(self, mock_batch):
        mock_batch.return_value = {}  # secret not found

        result = await rest(
            "https://api.example.com",
            headers={"Authorization": "Bearer ${secret.MISSING}"},
        )
        assert result["status"] == "error"
        assert "Missing secrets" in result["message"]
        assert "MISSING" in result["message"]

    @patch("npl_mcp.browser.rest.httpx.AsyncClient")
    @patch("npl_mcp.browser.rest.get_secrets_batch", new_callable=AsyncMock)
    async def test_no_secrets_no_batch_call(self, mock_batch, mock_client):
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.headers = {}
        mock_response.text = "ok"
        mock_ctx = AsyncMock()
        mock_ctx.__aenter__.return_value = mock_ctx
        mock_ctx.request.return_value = mock_response
        mock_client.return_value = mock_ctx

        result = await rest("https://example.com")
        mock_batch.assert_not_called()
        assert "secrets_injected" not in result


# ── Accept / encoding defaults ────────────────────────────────────────────

class TestRestHeaderDefaults:
    @patch("npl_mcp.browser.rest.httpx.AsyncClient")
    @patch("npl_mcp.browser.rest.get_secrets_batch", new_callable=AsyncMock)
    async def test_accept_default(self, mock_batch, mock_client):
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.headers = {}
        mock_response.text = ""
        mock_ctx = AsyncMock()
        mock_ctx.__aenter__.return_value = mock_ctx
        mock_ctx.request.return_value = mock_response
        mock_client.return_value = mock_ctx

        await rest("https://example.com", accept="application/json")
        call_kwargs = mock_ctx.request.call_args
        sent_headers = call_kwargs.kwargs.get("headers") or call_kwargs[1].get("headers")
        assert sent_headers["Accept"] == "application/json"

    @patch("npl_mcp.browser.rest.httpx.AsyncClient")
    @patch("npl_mcp.browser.rest.get_secrets_batch", new_callable=AsyncMock)
    async def test_accept_no_override(self, mock_batch, mock_client):
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.headers = {}
        mock_response.text = ""
        mock_ctx = AsyncMock()
        mock_ctx.__aenter__.return_value = mock_ctx
        mock_ctx.request.return_value = mock_response
        mock_client.return_value = mock_ctx

        await rest(
            "https://example.com",
            headers={"Accept": "text/html"},
            accept="application/json",
        )
        call_kwargs = mock_ctx.request.call_args
        sent_headers = call_kwargs.kwargs.get("headers") or call_kwargs[1].get("headers")
        assert sent_headers["Accept"] == "text/html"


# ── Error handling ────────────────────────────────────────────────────────

class TestRestErrors:
    @patch("npl_mcp.browser.rest.httpx.AsyncClient")
    @patch("npl_mcp.browser.rest.get_secrets_batch", new_callable=AsyncMock)
    async def test_timeout(self, mock_batch, mock_client):
        mock_ctx = AsyncMock()
        mock_ctx.__aenter__.return_value = mock_ctx
        mock_ctx.request.side_effect = httpx.TimeoutException("timed out")
        mock_client.return_value = mock_ctx

        result = await rest("https://slow.example.com")
        assert result["error"] == "timeout"
        assert result["status_code"] is None

    @patch("npl_mcp.browser.rest.httpx.AsyncClient")
    @patch("npl_mcp.browser.rest.get_secrets_batch", new_callable=AsyncMock)
    async def test_connection_error(self, mock_batch, mock_client):
        mock_ctx = AsyncMock()
        mock_ctx.__aenter__.return_value = mock_ctx
        mock_ctx.request.side_effect = httpx.ConnectError("refused")
        mock_client.return_value = mock_ctx

        result = await rest("https://down.example.com")
        assert "ConnectError" in result["error"]
        assert result["status_code"] is None


# ── Response truncation ───────────────────────────────────────────────────

class TestRestResponseTruncation:
    @patch("npl_mcp.browser.rest.httpx.AsyncClient")
    @patch("npl_mcp.browser.rest.get_secrets_batch", new_callable=AsyncMock)
    async def test_large_response_truncated(self, mock_batch, mock_client):
        big_body = "x" * (_MAX_RESPONSE_BODY + 1000)
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.headers = {}
        mock_response.text = big_body
        mock_ctx = AsyncMock()
        mock_ctx.__aenter__.return_value = mock_ctx
        mock_ctx.request.return_value = mock_response
        mock_client.return_value = mock_ctx

        result = await rest("https://example.com")
        assert result["body_truncated"] is True
        assert len(result["body"]) == _MAX_RESPONSE_BODY

    @patch("npl_mcp.browser.rest.httpx.AsyncClient")
    @patch("npl_mcp.browser.rest.get_secrets_batch", new_callable=AsyncMock)
    async def test_normal_response_not_truncated(self, mock_batch, mock_client):
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.headers = {}
        mock_response.text = "short response"
        mock_ctx = AsyncMock()
        mock_ctx.__aenter__.return_value = mock_ctx
        mock_ctx.request.return_value = mock_response
        mock_client.return_value = mock_ctx

        result = await rest("https://example.com")
        assert "body_truncated" not in result
        assert result["body"] == "short response"


# ── Full request flow ─────────────────────────────────────────────────────

class TestRestFullFlow:
    @patch("npl_mcp.browser.rest.httpx.AsyncClient")
    @patch("npl_mcp.browser.rest.get_secrets_batch", new_callable=AsyncMock)
    async def test_get_request(self, mock_batch, mock_client):
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.headers = {"content-type": "application/json"}
        mock_response.text = '{"ok": true}'
        mock_ctx = AsyncMock()
        mock_ctx.__aenter__.return_value = mock_ctx
        mock_ctx.request.return_value = mock_response
        mock_client.return_value = mock_ctx

        result = await rest("https://api.example.com/data")
        assert result["url"] == "https://api.example.com/data"
        assert result["method"] == "GET"
        assert result["status_code"] == 200
        assert "response_time_ms" in result
        assert result["body"] == '{"ok": true}'
        assert result["response_headers"]["content-type"] == "application/json"

    @patch("npl_mcp.browser.rest.httpx.AsyncClient")
    @patch("npl_mcp.browser.rest.get_secrets_batch", new_callable=AsyncMock)
    async def test_post_with_body(self, mock_batch, mock_client):
        mock_response = MagicMock()
        mock_response.status_code = 201
        mock_response.headers = {}
        mock_response.text = '{"id": 1}'
        mock_ctx = AsyncMock()
        mock_ctx.__aenter__.return_value = mock_ctx
        mock_ctx.request.return_value = mock_response
        mock_client.return_value = mock_ctx

        result = await rest(
            "https://api.example.com/items",
            method="POST",
            body='{"name": "test"}',
            headers={"Content-Type": "application/json"},
        )
        assert result["status_code"] == 201
        call_kwargs = mock_ctx.request.call_args
        assert call_kwargs[0][0] == "POST"

    @patch("npl_mcp.browser.rest.httpx.AsyncClient")
    @patch("npl_mcp.browser.rest.get_secrets_batch", new_callable=AsyncMock)
    async def test_method_case_insensitive(self, mock_batch, mock_client):
        mock_response = MagicMock()
        mock_response.status_code = 204
        mock_response.headers = {}
        mock_response.text = ""
        mock_ctx = AsyncMock()
        mock_ctx.__aenter__.return_value = mock_ctx
        mock_ctx.request.return_value = mock_response
        mock_client.return_value = mock_ctx

        result = await rest("https://example.com/item/1", method="delete")
        assert result["method"] == "DELETE"
        assert result["status_code"] == 204
