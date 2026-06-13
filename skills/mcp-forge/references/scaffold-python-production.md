# Phase 2: Production Python MCP Server Scaffold

Complete, runnable Python MCP server with FastMCP v3.2.4, tests, Docker, CI/CD, rate limiting, and structured logging.

> For spec design before scaffolding, see **trl-mcp-architect** (`references/specification-checklist.md`).

## Project Structure

```
my-mcp-server/
  src/
    __init__.py
    server.py             # FastMCP initialization, lifespan
    tools/
      __init__.py          # Tool registry
      example.py           # Example tool with error handling
    middleware/
      __init__.py
      rate_limiter.py      # Token bucket rate limiter
      logger.py            # Structured JSON logging
    config.py              # pydantic-settings based config
  tests/
    __init__.py
    conftest.py            # Shared fixtures
    test_tools.py          # Unit tests
    test_server.py         # Integration tests
  pyproject.toml
  Dockerfile
  docker-compose.yml
  .github/workflows/ci.yml
  .env.example
  README.md
```

## Files

### src/__init__.py

```python
# src/__init__.py
```

### src/config.py

```python
# src/config.py
"""Environment-based configuration with pydantic-settings."""

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Server configuration loaded from environment variables."""

    mcp_server_name: str = "my-mcp-server"
    mcp_server_version: str = "0.1.0"
    mcp_transport: str = "stdio"  # "stdio" or "streamable-http"
    mcp_http_port: int = 3000
    mcp_http_host: str = "0.0.0.0"

    log_level: str = "info"

    rate_limit_max_tokens: int = 100
    rate_limit_refill_rate: int = 10
    rate_limit_refill_interval_seconds: float = 1.0

    model_config = {"env_prefix": "", "case_sensitive": False}


_settings: Settings | None = None


def get_settings() -> Settings:
    global _settings
    if _settings is None:
        _settings = Settings()
    return _settings


def reset_settings() -> None:
    global _settings
    _settings = None
```

### src/middleware/__init__.py

```python
# src/middleware/__init__.py
```

### src/middleware/logger.py

```python
# src/middleware/logger.py
"""Structured JSON logging for MCP tool calls."""

import json
import sys
import time
import hashlib
from typing import Any

from src.config import get_settings

LOG_LEVELS = {"debug": 0, "info": 1, "warn": 2, "error": 3}


def _should_log(level: str) -> bool:
    settings = get_settings()
    return LOG_LEVELS.get(level, 1) >= LOG_LEVELS.get(settings.log_level, 1)


def _hash_params(params: dict[str, Any]) -> str:
    raw = json.dumps(params, sort_keys=True, default=str)
    return hashlib.md5(raw.encode()).hexdigest()[:8]


def _emit(entry: dict[str, Any]) -> None:
    level = entry.get("level", "info")
    if not _should_log(level):
        return
    # Write to stderr; stdout is reserved for MCP protocol
    print(json.dumps(entry), file=sys.stderr, flush=True)


def log_tool_call(
    tool: str,
    params: dict[str, Any],
    start_time: float,
    error: Exception | None = None,
) -> None:
    """Log a tool call with duration and optional error."""
    duration_ms = (time.time() - start_time) * 1000
    entry: dict[str, Any] = {
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
        "level": "error" if error else "info",
        "message": f"Tool call {'failed' if error else 'completed'}: {tool}",
        "tool": tool,
        "duration_ms": round(duration_ms, 2),
        "params_hash": _hash_params(params),
    }
    if error:
        entry["error"] = str(error)
    _emit(entry)


def log(level: str, message: str, **extra: Any) -> None:
    """Emit a structured log entry."""
    entry = {
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
        "level": level,
        "message": message,
        **extra,
    }
    _emit(entry)
```

### src/middleware/rate_limiter.py

```python
# src/middleware/rate_limiter.py
"""Token bucket rate limiter."""

import time
from dataclasses import dataclass, field

from src.config import get_settings


@dataclass
class TokenBucket:
    tokens: float
    last_refill: float = field(default_factory=time.time)


_buckets: dict[str, TokenBucket] = {}


def _refill(bucket: TokenBucket) -> None:
    settings = get_settings()
    now = time.time()
    elapsed = now - bucket.last_refill
    intervals = elapsed / settings.rate_limit_refill_interval_seconds
    if intervals >= 1:
        bucket.tokens = min(
            settings.rate_limit_max_tokens,
            bucket.tokens + intervals * settings.rate_limit_refill_rate,
        )
        bucket.last_refill = now


def check_rate_limit(key: str = "global") -> tuple[bool, float | None]:
    """Check if a request is allowed under the rate limit.

    Returns:
        Tuple of (allowed, retry_after_seconds).
        If allowed is True, retry_after_seconds is None.
    """
    settings = get_settings()

    if key not in _buckets:
        _buckets[key] = TokenBucket(tokens=settings.rate_limit_max_tokens)

    bucket = _buckets[key]
    _refill(bucket)

    if bucket.tokens >= 1:
        bucket.tokens -= 1
        return True, None

    return False, settings.rate_limit_refill_interval_seconds


def reset_rate_limiter() -> None:
    """Clear all rate limit buckets."""
    _buckets.clear()
```

### src/tools/__init__.py

```python
# src/tools/__init__.py
"""Tool registry -- imports and exposes all tools for registration."""

from src.tools.example import register_example_tools


def register_all_tools(mcp) -> None:
    """Register all tools with the MCP server."""
    register_example_tools(mcp)
```

### src/tools/example.py

```python
# src/tools/example.py
"""Example tools with full error handling."""

import time
from datetime import datetime
from zoneinfo import ZoneInfo
from collections import Counter
from typing import Any

from src.middleware.logger import log_tool_call
from src.middleware.rate_limiter import check_rate_limit


# --- Exportable handler logic (testable in isolation) ---

def handle_get_timestamp(timezone_name: str = "UTC") -> dict[str, Any]:
    """Core logic for get_timestamp tool."""
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


def handle_string_stats(
    text: str, include_frequency: bool = False
) -> dict[str, Any]:
    """Core logic for string_stats tool."""
    result: dict[str, Any] = {
        "characters": len(text),
        "words": len(text.split()) if text.strip() else 0,
        "lines": text.count("\n") + 1,
    }

    if include_frequency:
        freq = Counter(ch for ch in text.lower() if ch.isalnum())
        result["character_frequency"] = dict(freq.most_common())

    return result


# --- Tool registration with middleware ---

def register_example_tools(mcp) -> None:
    """Register example tools with rate limiting and logging middleware."""

    @mcp.tool()
    def get_timestamp(timezone_name: str = "UTC") -> dict:
        """Returns the current date and time, optionally in a specific timezone.

        Args:
            timezone_name: IANA timezone name (e.g., 'America/New_York'). Defaults to UTC.
        """
        start = time.time()
        params = {"timezone_name": timezone_name}

        allowed, retry_after = check_rate_limit("get_timestamp")
        if not allowed:
            log_tool_call("get_timestamp", params, start, RuntimeError("Rate limited"))
            return {"error": "Rate limited", "retry_after_seconds": retry_after}

        try:
            result = handle_get_timestamp(timezone_name)
            log_tool_call("get_timestamp", params, start)
            return result
        except Exception as e:
            log_tool_call("get_timestamp", params, start, e)
            return {"error": str(e)}

    @mcp.tool()
    def string_stats(text: str, include_frequency: bool = False) -> dict:
        """Analyzes a string and returns character count, word count, and line count.

        Args:
            text: The text to analyze.
            include_frequency: Include character frequency analysis. Defaults to False.
        """
        start = time.time()
        params = {"text": text[:50], "include_frequency": include_frequency}

        allowed, retry_after = check_rate_limit("string_stats")
        if not allowed:
            log_tool_call("string_stats", params, start, RuntimeError("Rate limited"))
            return {"error": "Rate limited", "retry_after_seconds": retry_after}

        try:
            result = handle_string_stats(text, include_frequency)
            log_tool_call("string_stats", params, start)
            return result
        except Exception as e:
            log_tool_call("string_stats", params, start, e)
            return {"error": str(e)}
```

### src/server.py

```python
# src/server.py
"""MCP server initialization and entry point."""

from contextlib import asynccontextmanager
from collections.abc import AsyncIterator

from fastmcp import FastMCP

from src.config import get_settings
from src.tools import register_all_tools
from src.middleware.logger import log


@asynccontextmanager
async def lifespan(server: FastMCP) -> AsyncIterator[dict]:
    """Server lifespan manager -- setup and teardown."""
    settings = get_settings()
    log("info", f"Starting {settings.mcp_server_name} v{settings.mcp_server_version}")
    # Place startup logic here (DB connections, API clients, etc.)
    context = {}
    try:
        yield context
    finally:
        log("info", "Shutting down server")
        # Place cleanup logic here


def create_server() -> FastMCP:
    """Create and configure the MCP server."""
    settings = get_settings()

    mcp = FastMCP(
        name=settings.mcp_server_name,
        version=settings.mcp_server_version,
    )

    register_all_tools(mcp)
    return mcp


# Module-level server instance for direct import
mcp = create_server()


if __name__ == "__main__":
    settings = get_settings()
    transport = settings.mcp_transport

    if transport == "streamable-http":
        mcp.run(
            transport="streamable-http",
            host=settings.mcp_http_host,
            port=settings.mcp_http_port,
        )
    else:
        mcp.run(transport="stdio")
```

### tests/__init__.py

```python
# tests/__init__.py
```

### tests/conftest.py

```python
# tests/conftest.py
"""Shared test fixtures."""

import pytest
from fastmcp import Client


@pytest.fixture
def mcp_server():
    """Create a fresh MCP server instance."""
    from src.server import create_server
    return create_server()


@pytest.fixture
def client(mcp_server):
    """Create a test client connected to the server."""
    return Client(mcp_server)
```

### tests/test_tools.py

```python
# tests/test_tools.py
"""Unit tests for tool handler logic."""

import pytest
from src.tools.example import handle_get_timestamp, handle_string_stats


class TestGetTimestamp:
    def test_utc_default(self):
        result = handle_get_timestamp()
        assert result["timezone"] == "UTC"
        assert "iso" in result
        assert isinstance(result["epoch"], int)

    def test_specific_timezone(self):
        result = handle_get_timestamp("America/New_York")
        assert result["timezone"] == "America/New_York"
        assert result["formatted"]

    def test_invalid_timezone(self):
        result = handle_get_timestamp("Invalid/Zone")
        assert "error" in result


class TestStringStats:
    def test_basic_counts(self):
        result = handle_string_stats("hello world")
        assert result["characters"] == 11
        assert result["words"] == 2
        assert result["lines"] == 1

    def test_empty_string(self):
        result = handle_string_stats("")
        assert result["characters"] == 0
        assert result["words"] == 0
        assert result["lines"] == 1

    def test_multiline(self):
        result = handle_string_stats("line1\nline2\nline3")
        assert result["lines"] == 3

    def test_frequency_enabled(self):
        result = handle_string_stats("hello", include_frequency=True)
        assert "character_frequency" in result
        assert result["character_frequency"]["l"] == 2

    def test_frequency_disabled(self):
        result = handle_string_stats("hello")
        assert "character_frequency" not in result
```

### tests/test_server.py

```python
# tests/test_server.py
"""Integration tests via MCP protocol."""

import pytest
from fastmcp import Client


@pytest.fixture
def client():
    from src.server import create_server
    return Client(create_server())


@pytest.mark.asyncio
async def test_list_tools(client):
    """Server lists all registered tools."""
    async with client:
        tools = await client.list_tools()
    assert len(tools) >= 2
    names = [t.name for t in tools]
    assert "get_timestamp" in names
    assert "string_stats" in names


@pytest.mark.asyncio
async def test_tool_descriptions(client):
    """All tools have non-empty descriptions."""
    async with client:
        tools = await client.list_tools()
    for tool in tools:
        assert tool.description, f"Tool {tool.name} has no description"


@pytest.mark.asyncio
async def test_call_get_timestamp(client):
    """get_timestamp returns valid data."""
    async with client:
        result = await client.call_tool("get_timestamp", {"timezone_name": "UTC"})
    text = str(result)
    assert "UTC" in text


@pytest.mark.asyncio
async def test_call_string_stats(client):
    """string_stats returns correct analysis."""
    async with client:
        result = await client.call_tool(
            "string_stats", {"text": "hello world", "include_frequency": True}
        )
    text = str(result)
    assert "11" in text  # characters
```

### pyproject.toml

```toml
# pyproject.toml
[project]
name = "my-mcp-server"
version = "0.1.0"
description = "MCP server -- Phase 2 production build"
requires-python = ">=3.11"
dependencies = [
    "fastmcp>=3.2.4,<4.0.0",
    "pydantic-settings>=2.0.0,<3.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "pytest-asyncio>=0.24.0",
    "pytest-cov>=6.0.0",
    "ruff>=0.8.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]
addopts = "--tb=short -q"

[tool.coverage.run]
source = ["src"]

[tool.coverage.report]
fail_under = 80

[tool.ruff]
target-version = "py311"
line-length = 100

[tool.ruff.lint]
select = ["E", "F", "I", "N", "W", "UP"]
```

### Dockerfile

```dockerfile
# Dockerfile
# Stage 1: Build
FROM python:3.12-slim AS builder

WORKDIR /app

RUN pip install --no-cache-dir uv

COPY pyproject.toml ./
RUN uv pip install --system --no-cache .

COPY src/ ./src/

# Stage 2: Production runtime
FROM python:3.12-slim AS runtime

RUN groupadd -r mcp && useradd -r -g mcp -m mcp

WORKDIR /app

COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /app/src ./src

USER mcp

ENV MCP_TRANSPORT=stdio
ENV LOG_LEVEL=info

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "print('ok')"

ENTRYPOINT ["python", "-m", "src.server"]
```

### docker-compose.yml

```yaml
# docker-compose.yml
services:
  mcp-server:
    build: .
    environment:
      - MCP_SERVER_NAME=my-mcp-server
      - MCP_TRANSPORT=streamable-http
      - MCP_HTTP_PORT=3000
      - LOG_LEVEL=debug
    ports:
      - "3000:3000"
    volumes:
      - ./src:/app/src:ro
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:3000/health')"]
      interval: 30s
      timeout: 5s
      retries: 3
```

### .github/workflows/ci.yml

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install ruff
      - run: ruff check src/ tests/
      - run: ruff format --check src/ tests/

  test:
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install -e ".[dev]"
      - run: pytest --cov --cov-report=xml
      - uses: actions/upload-artifact@v4
        with:
          name: coverage
          path: coverage.xml

  docker:
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/build-push-action@v6
        with:
          context: .
          push: false
          tags: my-mcp-server:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### .env.example

```bash
# .env.example

# Server identity
MCP_SERVER_NAME=my-mcp-server
MCP_SERVER_VERSION=0.1.0

# Transport: stdio or streamable-http
MCP_TRANSPORT=stdio
MCP_HTTP_PORT=3000
MCP_HTTP_HOST=0.0.0.0

# Logging
LOG_LEVEL=info

# Rate limiting
RATE_LIMIT_MAX_TOKENS=100
RATE_LIMIT_REFILL_RATE=10
RATE_LIMIT_REFILL_INTERVAL_SECONDS=1.0

# Add your API keys and secrets below
# API_KEY=your-api-key-here
```

### README.md

````markdown
# my-mcp-server

Production-grade MCP server -- Phase 2 build (Python / FastMCP).

## Architecture

```
Client --> Transport (stdio | HTTP) --> FastMCP --> Tool Registry --> Tool Handlers
                                                       |
                                                  Rate Limiter
                                                  Logger
```

## Prerequisites

- Python >= 3.11
- uv (recommended) or pip
- Docker (optional)

## Setup

```bash
# With uv
uv sync

# Or with pip
pip install -e ".[dev]"

cp .env.example .env
# Edit .env with your configuration
```

## Development

```bash
pytest                  # Run all tests
pytest --cov            # Tests with coverage
ruff check src/ tests/  # Lint
ruff format src/ tests/ # Format
```

## Run

### Stdio (local)

```bash
python -m src.server
```

### HTTP (remote)

```bash
MCP_TRANSPORT=streamable-http python -m src.server
```

### Docker

```bash
docker compose up            # Dev with mounted source
docker build -t my-mcp .     # Production image
docker run --rm -it my-mcp   # Run (stdio)
```

## Tools

| Tool | Description |
|------|-------------|
| `get_timestamp` | Returns current date/time with optional timezone |
| `string_stats` | Analyzes text: character count, word count, line count |

## Claude Desktop Configuration

```json
{
  "mcpServers": {
    "my-mcp-server": {
      "command": "python",
      "args": ["-m", "src.server"],
      "cwd": "/absolute/path/to/project"
    }
  }
}
```
````
