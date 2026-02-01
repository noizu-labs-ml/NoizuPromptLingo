#!/usr/bin/env python3
"""Tests for the NPL MCP server.

These tests connect to a running MCP server via its SSE endpoint and
verify that the tools are callable and return expected results.

The server must be running before running these tests:
    uv run npl-mcp

Run with:
    uv run pytest tests/
    uv run pytest tests/test_mcp_server.py -v
"""

import asyncio
import os
import sys
from typing import Any

import pytest
import httpx


# MCP endpoint configuration (can be overridden via env vars)
HOST = os.environ.get("NPL_MCP_TEST_HOST", "127.0.0.1")
PORT = os.environ.get("NPL_MCP_TEST_PORT", "8765")
SSE_URL = f"http://{HOST}:{PORT}/sse"


def test_server_is_responding() -> None:
    """Verify the server is responding to HTTP requests."""
    try:
        response = httpx.get(f"http://{HOST}:{PORT}/", timeout=2.0)
        assert response.status_code in (200, 404, 405), f"Unexpected status: {response.status_code}"
    except httpx.ConnectError:
        pytest.skip(f"Server not running at {HOST}:{PORT}")
    except httpx.TimeoutException:
        pytest.skip(f"Server timeout at {HOST}:{PORT}")


def test_sse_endpoint_exists() -> None:
    """Verify the SSE endpoint is accessible."""
    try:
        response = httpx.get(SSE_URL, timeout=2.0)
        # fastmcp 2.x may return 307 (redirect to /sse/), 403, 426, or 200
        assert response.status_code in (200, 307, 403, 426), f"SSE endpoint returned unexpected status: {response.status_code}"
    except (httpx.ConnectError, httpx.TimeoutException):
        pytest.skip(f"Server not running at {SSE_URL}")


@pytest.mark.asyncio
async def test_hello_tool_via_fastmcp_client() -> None:
    """Test the hello tool via FastMCP Client."""
    try:
        from fastmcp import Client
        from fastmcp.client.transports import SSETransport
    except ImportError:
        pytest.skip("fastmcp not installed")

    client = Client(SSETransport(SSE_URL))

    call_result = None
    try:
        async with client:
            # List tools to verify hello-world exists
            tools = await client.list_tools()
            tool_names = {t.name for t in tools}
            assert "hello-world" in tool_names, "Tool 'hello-world' not found in server"

            # Call the hello-world tool
            result = await client.call_tool("hello-world", {})
            assert len(result.content) > 0, "No content returned from hello-world tool"

            tool_output = result.content[0]
            output_text = tool_output.text
            call_result = output_text

            # Verify greeting
            assert "hello" in output_text, f"Expected greeting, got: {output_text}"
    except (httpx.ConnectError, httpx.TimeoutException):
        pytest.skip(f"Could not connect to server at {SSE_URL}")
    except Exception as e:
        pytest.fail(f"Failed to call hello tool: {e}", call_result)


@pytest.mark.asyncio
async def test_echo_tool_via_fastmcp_client() -> None:
    """Test the echo tool via FastMCP Client."""
    try:
        from fastmcp import Client
        from fastmcp.client.transports import SSETransport
    except ImportError:
        pytest.skip("fastmcp not installed")

    client = Client(SSETransport(SSE_URL))

    try:
        async with client:
            tools = await client.list_tools()
            tool_names = {t.name for t in tools}
            assert "echo" in tool_names, "Tool 'echo' not found in server"

            test_message = "Test message from pytest"
            result = await client.call_tool("echo", {"text": test_message})
            assert len(result.content) > 0

            output_text = result.content[0].text
            assert test_message in output_text, f"Expected '{test_message}' in output, got: {output_text}"
    except (httpx.ConnectError, httpx.TimeoutException):
        pytest.skip(f"Could not connect to server at {SSE_URL}")
    except Exception as e:
        pytest.fail(f"Failed to call echo tool: {e}")


@pytest.mark.asyncio
async def test_list_tools() -> None:
    """Verify we can list all tools from the server."""
    try:
        from fastmcp import Client
        from fastmcp.client.transports import SSETransport
    except ImportError:
        pytest.skip("fastmcp not installed")

    client = Client(SSETransport(SSE_URL))

    try:
        async with client:
            tools = await client.list_tools()
            assert len(tools) >= 2, f"Expected at least 2 tools, got {len(tools)}"

            # Verify expected tools exist
            tool_names = {t.name for t in tools}
            required_tools = {"hello-world", "echo"}
            missing_tools = required_tools - tool_names
            assert not missing_tools, f"Missing required tools: {missing_tools}"
    except (httpx.ConnectError, httpx.TimeoutException):
        pytest.skip(f"Could not connect to server at {SSE_URL}")
    except Exception as e:
        pytest.fail(f"Failed to list tools: {e}")


@pytest.mark.asyncio
async def test_error_handling_invalid_tool() -> None:
    """Test that calling a non‑existent tool raises an appropriate error."""
    try:
        from fastmcp import Client
        from fastmcp.client.transports import SSETransport
    except ImportError:
        pytest.skip("fastmcp not installed")

    client = Client(SSETransport(SSE_URL))

    try:
        async with client:
            try:
                await client.call_tool("nonexistent_tool_12345", {})
                pytest.fail("Expected an exception when calling nonexistent tool")
            except Exception:
                pass  # Expected: tool not found
    except (httpx.ConnectError, httpx.TimeoutException):
        pytest.skip(f"Could not connect to server at {SSE_URL}")