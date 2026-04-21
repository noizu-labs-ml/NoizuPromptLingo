#!/usr/bin/env python3
"""End-to-end tests for the NPL MCP server.

These tests connect to a running MCP server via its SSE endpoint and verify
that the real tool suite (ToolSummary, ToolSearch, ToolDefinition, NPLSpec)
is discoverable and callable end-to-end.

The server must be running before running these tests:
    uv run npl-mcp

Run with:
    uv run -m pytest tests/test_mcp_server.py -v

Tests skip automatically if the server is unreachable.
"""

import json
import os

import httpx
import pytest


HOST = os.environ.get("NPL_MCP_TEST_HOST", "127.0.0.1")
PORT = os.environ.get("NPL_MCP_TEST_PORT", "8765")
SSE_URL = f"http://{HOST}:{PORT}/sse"


# MCP tools that should always be visible on the npl-mcp launcher.
EXPECTED_MCP_TOOLS = {
    "NPLSpec",
    "NPLLoad",
    "ToolSummary",
    "ToolSearch",
    "ToolDefinition",
    "ToolHelp",
    "ToolCall",
    "ToolSession.Generate",
    "ToolSession",
    "Instructions",
    "Instructions.Create",
    "Instructions.List",
}


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _fastmcp_client():
    """Build a FastMCP SSE client, or skip if FastMCP is not installed."""
    try:
        from fastmcp import Client
        from fastmcp.client.transports import SSETransport
    except ImportError:
        pytest.skip("fastmcp not installed")
    return Client(SSETransport(SSE_URL))


def _tool_result_text(result) -> str:
    """Extract text from a FastMCP tool call result, regardless of version."""
    if hasattr(result, "content") and result.content:
        return result.content[0].text
    return str(result)


# ---------------------------------------------------------------------------
# HTTP liveness
# ---------------------------------------------------------------------------


def test_server_is_responding() -> None:
    """The server accepts HTTP requests on the configured port."""
    try:
        response = httpx.get(f"http://{HOST}:{PORT}/", timeout=2.0)
        assert response.status_code in (200, 404, 405), (
            f"Unexpected status: {response.status_code}"
        )
    except httpx.ConnectError:
        pytest.skip(f"Server not running at {HOST}:{PORT}")
    except httpx.TimeoutException:
        pytest.skip(f"Server timeout at {HOST}:{PORT}")


def test_sse_endpoint_exists() -> None:
    """The SSE endpoint is reachable."""
    try:
        response = httpx.get(SSE_URL, timeout=2.0)
        # FastMCP may return 307 (redirect to /sse/), 200, 403, or 426
        assert response.status_code in (200, 307, 403, 426), (
            f"SSE endpoint returned unexpected status: {response.status_code}"
        )
    except (httpx.ConnectError, httpx.TimeoutException):
        pytest.skip(f"Server not running at {SSE_URL}")


# ---------------------------------------------------------------------------
# MCP protocol handshake + tool discovery
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_list_tools_returns_expected_set() -> None:
    """The MCP server exposes the 11 expected tools via tools/list."""
    client = _fastmcp_client()
    try:
        async with client:
            tools = await client.list_tools()
            tool_names = {t.name for t in tools}
            missing = EXPECTED_MCP_TOOLS - tool_names
            assert not missing, (
                f"Missing expected MCP tools: {missing}. Got: {sorted(tool_names)}"
            )
    except (httpx.ConnectError, httpx.TimeoutException):
        pytest.skip(f"Could not connect to server at {SSE_URL}")


@pytest.mark.asyncio
async def test_error_handling_invalid_tool() -> None:
    """Calling a non-existent tool raises an error via the protocol."""
    client = _fastmcp_client()
    try:
        async with client:
            with pytest.raises(Exception):
                await client.call_tool("nonexistent_tool_12345", {})
    except (httpx.ConnectError, httpx.TimeoutException):
        pytest.skip(f"Could not connect to server at {SSE_URL}")


# ---------------------------------------------------------------------------
# Tool-call smoke tests (exercise real tools end-to-end)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_tool_summary_no_filter_returns_catalog() -> None:
    """ToolSummary without a filter returns the full catalog grouped by category."""
    client = _fastmcp_client()
    try:
        async with client:
            result = await client.call_tool("ToolSummary", {})
            text = _tool_result_text(result)
            assert text, "ToolSummary returned empty content"
            data = json.loads(text)
            # Expect a dict-shaped result with categories
            assert isinstance(data, dict)
            assert len(data) > 0, "ToolSummary returned empty dict"
    except (httpx.ConnectError, httpx.TimeoutException):
        pytest.skip(f"Could not connect to server at {SSE_URL}")


@pytest.mark.asyncio
async def test_tool_search_text_mode_finds_known_tool() -> None:
    """ToolSearch in text mode finds at least one tool matching 'ping'."""
    client = _fastmcp_client()
    try:
        async with client:
            result = await client.call_tool(
                "ToolSearch", {"query": "ping", "mode": "text", "limit": 5}
            )
            text = _tool_result_text(result)
            data = json.loads(text)
            assert "matches" in data
            names = {m["name"].lower() for m in data["matches"]}
            assert "ping" in names, f"Expected 'Ping' in matches, got: {names}"
    except (httpx.ConnectError, httpx.TimeoutException):
        pytest.skip(f"Could not connect to server at {SSE_URL}")


@pytest.mark.asyncio
async def test_tool_definition_returns_parameters() -> None:
    """ToolDefinition returns parameter definitions for a known tool."""
    client = _fastmcp_client()
    try:
        async with client:
            result = await client.call_tool("ToolDefinition", {"tools": ["Ping"]})
            text = _tool_result_text(result)
            data = json.loads(text)
            assert "definitions" in data
            assert len(data["definitions"]) == 1
            ping_def = data["definitions"][0]
            assert ping_def["name"] == "Ping"
            assert "parameters" in ping_def
            param_names = {p["name"] for p in ping_def["parameters"]}
            assert "url" in param_names
    except (httpx.ConnectError, httpx.TimeoutException):
        pytest.skip(f"Could not connect to server at {SSE_URL}")


@pytest.mark.asyncio
async def test_npl_spec_generates_definition() -> None:
    """NPLSpec generates an NPL definition block wrapped in ⌜NPL@...⌝ markers."""
    client = _fastmcp_client()
    try:
        async with client:
            # Empty components list → include all conventions
            result = await client.call_tool("NPLSpec", {})
            text = _tool_result_text(result)
            assert text.startswith("⌜NPL@"), (
                f"NPLSpec output did not start with NPL definition marker: {text[:80]}"
            )
            assert "⌞NPL@" in text, "NPLSpec output missing closing marker"
    except (httpx.ConnectError, httpx.TimeoutException):
        pytest.skip(f"Could not connect to server at {SSE_URL}")


@pytest.mark.asyncio
async def test_npl_load_expression_dsl() -> None:
    """NPLLoad accepts the expression DSL and returns matching NPL markdown."""
    client = _fastmcp_client()
    try:
        async with client:
            result = await client.call_tool(
                "NPLLoad", {"expression": "pumps#chain-of-thought"}
            )
            text = _tool_result_text(result)
            assert "chain-of-thought" in text.lower(), (
                f"NPLLoad did not return chain-of-thought content: {text[:120]}"
            )
    except (httpx.ConnectError, httpx.TimeoutException):
        pytest.skip(f"Could not connect to server at {SSE_URL}")
