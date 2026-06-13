# Phase 1: Quick Python MCP Server Scaffold

Complete, runnable Python MCP server using FastMCP v3.2.4 with stdio transport. Copy these files, run `uv sync && python server.py`.

> For spec design before scaffolding, see **trl-mcp-architect** (`references/specification-checklist.md`).

## Files

### server.py

```python
# server.py
"""MCP server scaffold -- Phase 1 quick prototype."""

from datetime import datetime, timezone
from zoneinfo import ZoneInfo
from collections import Counter

from fastmcp import FastMCP

mcp = FastMCP(
    name="my-mcp-server",
    version="0.1.0",
)


@mcp.tool()
def get_timestamp(timezone_name: str = "UTC") -> dict:
    """Returns the current date and time, optionally in a specific timezone.

    Args:
        timezone_name: IANA timezone name (e.g., 'America/New_York'). Defaults to UTC.
    """
    try:
        tz = ZoneInfo(timezone_name)
    except KeyError:
        return {"error": f"Unknown timezone: {timezone_name}"}

    now = datetime.now(tz)
    return {
        "timezone": timezone_name,
        "formatted": now.strftime("%Y-%m-%d %H:%M:%S %Z"),
        "iso": now.isoformat(),
        "epoch": int(now.timestamp()),
    }


@mcp.tool()
def string_stats(text: str, include_frequency: bool = False) -> dict:
    """Analyzes a string and returns character count, word count, and line count.

    Args:
        text: The text to analyze.
        include_frequency: Include character frequency analysis. Defaults to False.
    """
    chars = len(text)
    words = len(text.split()) if text.strip() else 0
    lines = text.count("\n") + 1

    result: dict = {
        "characters": chars,
        "words": words,
        "lines": lines,
    }

    if include_frequency:
        freq = Counter(ch for ch in text.lower() if ch.isalnum())
        result["character_frequency"] = dict(freq.most_common())

    return result


if __name__ == "__main__":
    mcp.run(transport="stdio")
```

### pyproject.toml

```toml
# pyproject.toml
[project]
name = "my-mcp-server"
version = "0.1.0"
description = "MCP server scaffold -- Phase 1 quick prototype"
requires-python = ">=3.11"
dependencies = [
    "fastmcp>=3.2.4,<4.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "pytest-asyncio>=0.24.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.pytest.ini_options]
asyncio_mode = "auto"
```

### test_smoke.py

```python
# test_smoke.py
"""Smoke tests for MCP server."""

import pytest
from fastmcp import Client


@pytest.fixture
def client():
    """Create a test client connected to the server."""
    from server import mcp
    return Client(mcp)


@pytest.mark.asyncio
async def test_list_tools(client):
    """Server should list available tools."""
    async with client:
        tools = await client.list_tools()
    tool_names = [t.name for t in tools]
    assert "get_timestamp" in tool_names
    assert "string_stats" in tool_names


@pytest.mark.asyncio
async def test_get_timestamp(client):
    """get_timestamp should return valid timestamp data."""
    async with client:
        result = await client.call_tool("get_timestamp", {"timezone_name": "UTC"})
    # FastMCP Client.call_tool returns the content directly
    assert isinstance(result, (str, list))
    text = result if isinstance(result, str) else str(result)
    assert "UTC" in text
    assert "epoch" in text


@pytest.mark.asyncio
async def test_string_stats(client):
    """string_stats should return correct counts."""
    async with client:
        result = await client.call_tool(
            "string_stats",
            {"text": "hello world", "include_frequency": True},
        )
    text = result if isinstance(result, str) else str(result)
    assert "11" in text  # characters
    assert "2" in text   # words
```

### .env.example

```bash
# .env.example
# Server configuration
MCP_SERVER_NAME=my-mcp-server
MCP_SERVER_VERSION=0.1.0

# Add your API keys and secrets below
# API_KEY=your-api-key-here
```

### README.md

````markdown
# my-mcp-server

MCP server scaffold -- Phase 1 quick prototype (Python / FastMCP).

## Prerequisites

- Python >= 3.11
- uv (recommended) or pip

## Setup

```bash
# With uv (recommended)
uv sync

# Or with pip
pip install -e ".[dev]"
```

## Run

```bash
python server.py
```

The server communicates over stdio. Connect it to an MCP client by adding it to your client configuration.

### Claude Desktop Configuration

Add to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "my-mcp-server": {
      "command": "python",
      "args": ["/absolute/path/to/server.py"]
    }
  }
}
```

## Development

```bash
pytest              # Run smoke tests
pytest -v           # Verbose output
```

## Tools

| Tool | Description |
|------|-------------|
| `get_timestamp` | Returns current date/time with optional timezone |
| `string_stats` | Analyzes text: character count, word count, line count |
````
