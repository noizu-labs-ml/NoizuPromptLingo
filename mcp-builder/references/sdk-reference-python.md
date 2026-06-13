# Python SDK Reference

Version-pinned reference for FastMCP v3.2.4 (wrapping `modelcontextprotocol` v1.26.0).

> For TypeScript, see [sdk-reference-nodejs.md](sdk-reference-nodejs.md). For transport selection guidance, see [transport-guide.md](transport-guide.md).

---

## Installation

### FastMCP (Recommended)

```bash
# pip
pip install fastmcp

# uv (recommended)
uv add fastmcp

# With specific extras
pip install "fastmcp[uvicorn]"  # For HTTP transport
```

FastMCP v3.2.4 includes the official `modelcontextprotocol` SDK v1.26.0 as a dependency.

### Raw Official SDK (Advanced)

```bash
pip install modelcontextprotocol
```

Use the raw SDK only when you need maximum control over the protocol layer. FastMCP covers the vast majority of use cases with less boilerplate.

---

## API Comparison

| Feature | FastMCP | Raw SDK |
|---|---|---|
| Server creation | `FastMCP("name")` | `Server("name")` + manual handler registration |
| Tool registration | `@mcp.tool()` decorator | `setRequestHandler` with schema dicts |
| Type validation | Automatic from type hints + Pydantic | Manual JSON Schema |
| Tool versioning | `@mcp.tool(version="1.0")` | Not built-in |
| Auth | `MultiAuth` built-in | Manual middleware |
| Context injection | `ctx: Context` parameter | Manual from request |
| Lifespan | `@mcp.lifespan` decorator | Manual setup/teardown |

---

## Server Creation

### FastMCP

```python
from fastmcp import FastMCP

mcp = FastMCP(
    name="my-server",
    version="1.0.0",
    description="A helpful MCP server",
)
```

### With Configuration

```python
from fastmcp import FastMCP

mcp = FastMCP(
    name="github-status",
    version="1.0.0",
    description="GitHub Status API integration",
    # Server settings
    log_level="INFO",
)
```

---

## Tool Registration

### Basic Tool

```python
@mcp.tool()
def greet(name: str) -> str:
    """Say hello to someone."""
    return f"Hello, {name}! Welcome to MCP."
```

FastMCP automatically:
- Extracts the tool name from the function name
- Generates the JSON Schema from type hints
- Uses the docstring as the tool description
- Validates inputs against the schema

### Tool with Detailed Schema

```python
from typing import Literal

@mcp.tool()
def search_issues(
    query: str,
    repo: str,
    state: Literal["open", "closed", "all"] = "open",
    labels: list[str] | None = None,
    limit: int = 10,
) -> str:
    """Search GitHub issues.

    Args:
        query: Search query string
        repo: Repository in owner/repo format
        state: Filter by issue state
        labels: Filter by label names
        limit: Maximum results (1-100)
    """
    issues = github_search(repo, query, state=state, labels=labels, limit=limit)
    return format_issues(issues)
```

### Tool with Custom Name

```python
@mcp.tool(name="get_weather")
def fetch_current_weather(city: str, units: Literal["celsius", "fahrenheit"] = "celsius") -> str:
    """Get current weather for a city."""
    # Tool is registered as "get_weather", not "fetch_current_weather"
    return fetch_weather(city, units)
```

### Tool with Version

```python
@mcp.tool(version="1.0")
def get_status() -> str:
    """Get current system status."""
    return fetch_status()

@mcp.tool(version="2.0")
def get_status_v2(include_components: bool = False) -> str:
    """Get current system status with optional component breakdown."""
    return fetch_status(include_components=include_components)
```

Tool versioning is a FastMCP v3.x feature. It allows clients to discover tool versions and migrate gracefully.

### Async Tool

```python
import httpx

@mcp.tool()
async def get_status() -> str:
    """Get current GitHub system status."""
    async with httpx.AsyncClient() as client:
        response = await client.get("https://www.githubstatus.com/api/v2/status.json")
        response.raise_for_status()
        return response.text
```

### Tool with Error Handling

```python
from fastmcp.exceptions import ToolError

@mcp.tool()
async def create_issue(repo: str, title: str, body: str = "") -> str:
    """Create a GitHub issue."""
    try:
        issue = await github_create_issue(repo, title, body)
        return f"Created issue #{issue['number']}: {issue['html_url']}"
    except GitHubAPIError as e:
        raise ToolError(f"Failed to create issue: {e}")
```

`ToolError` sets `isError: true` in the MCP response, signaling an application-level failure to the model.

### Tool with Pydantic Models

```python
from pydantic import BaseModel, Field

class IssueFilter(BaseModel):
    query: str = Field(description="Search query")
    state: Literal["open", "closed", "all"] = "open"
    limit: int = Field(default=10, ge=1, le=100)

@mcp.tool()
def search_issues(filters: IssueFilter) -> str:
    """Search issues with structured filters."""
    return do_search(filters)
```

---

## Resource Registration

### Static Resource

```python
@mcp.resource("config://app/settings")
def get_config() -> str:
    """Application configuration."""
    return json.dumps(load_config())
```

### Parameterized Resource Template

```python
@mcp.resource("github://issues/{number}")
def get_issue(number: int) -> str:
    """Get a GitHub issue by number."""
    issue = fetch_issue(number)
    return json.dumps(issue)
```

---

## Prompt Registration

```python
@mcp.prompt()
def code_review(language: str, focus: str = "all") -> str:
    """Generate a code review prompt."""
    return f"Review the following {language} code with focus on {focus}. Provide specific, actionable feedback."
```

### Prompt with Multiple Messages

```python
from fastmcp.prompts import Message

@mcp.prompt()
def debug_session(error_message: str, stack_trace: str) -> list[Message]:
    """Set up a debugging session."""
    return [
        Message(role="user", content=f"I'm seeing this error:\n\n```\n{error_message}\n```\n\nStack trace:\n```\n{stack_trace}\n```"),
        Message(role="assistant", content="I'll analyze this error. Let me start by identifying the root cause from the stack trace."),
        Message(role="user", content="Please suggest specific fixes with code examples."),
    ]
```

---

## Context Injection

The `Context` object provides access to MCP session state, logging, and progress reporting:

```python
from fastmcp import Context

@mcp.tool()
async def long_operation(query: str, ctx: Context) -> str:
    """A tool that reports progress."""
    await ctx.info(f"Starting search for: {query}")

    results = []
    items = await fetch_items(query)

    for i, item in enumerate(items):
        await ctx.report_progress(i, len(items))
        results.append(await process_item(item))

    await ctx.info(f"Processed {len(results)} items")
    return json.dumps(results)
```

Context methods:

| Method | Purpose |
|---|---|
| `ctx.info(msg)` | Log info-level message |
| `ctx.debug(msg)` | Log debug-level message |
| `ctx.warning(msg)` | Log warning |
| `ctx.error(msg)` | Log error |
| `ctx.report_progress(current, total)` | Report progress to client |
| `ctx.request_id` | Current request ID |
| `ctx.session` | Underlying MCP session |

---

## Lifespan Management

Initialize and clean up shared resources (database connections, HTTP clients, API sessions):

```python
from contextlib import asynccontextmanager
from fastmcp import FastMCP, Context

@asynccontextmanager
async def app_lifespan(server: FastMCP):
    """Initialize shared resources."""
    import httpx

    # Startup
    client = httpx.AsyncClient(
        base_url="https://api.github.com",
        headers={"Authorization": f"Bearer {os.environ['GITHUB_TOKEN']}"},
    )

    try:
        yield {"http_client": client}
    finally:
        # Shutdown
        await client.aclose()

mcp = FastMCP("github-tools", lifespan=app_lifespan)

@mcp.tool()
async def get_repo(owner: str, repo: str, ctx: Context) -> str:
    """Get repository information."""
    client = ctx.request_context["http_client"]
    response = await client.get(f"/repos/{owner}/{repo}")
    return response.text
```

---

## Transport Configuration

### stdio (Default)

```python
# This is the default -- just run the server
mcp.run()

# Equivalent to:
mcp.run(transport="stdio")
```

Run from command line:
```bash
python server.py
# or
uv run server.py
```

### Streamable HTTP via Uvicorn

```python
mcp.run(transport="streamable-http", host="0.0.0.0", port=3000)
```

Or use the ASGI app directly with Uvicorn for production:

```python
# server.py
app = mcp.streamable_http_app()

# Run with:
# uvicorn server:app --host 0.0.0.0 --port 3000
```

### SSE (Deprecated)

```python
# Do NOT use for new projects -- migrate to streamable-http
mcp.run(transport="sse", host="0.0.0.0", port=3000)
```

---

## MultiAuth Patterns

FastMCP v3.x includes built-in authentication support:

```python
from fastmcp import FastMCP
from fastmcp.server.auth import BearerTokenAuth

auth = BearerTokenAuth(
    tokens={"valid-token-1", "valid-token-2"},
    # Or use a validation function:
    # validate=async_token_validator,
)

mcp = FastMCP("secure-server", auth=auth)
```

### Custom Auth Validator

```python
from fastmcp.server.auth import BearerTokenAuth

async def validate_token(token: str) -> bool:
    """Validate against your auth service."""
    async with httpx.AsyncClient() as client:
        resp = await client.post(
            "https://auth.example.com/validate",
            headers={"Authorization": f"Bearer {token}"},
        )
        return resp.status_code == 200

auth = BearerTokenAuth(validate=validate_token)
mcp = FastMCP("secure-server", auth=auth)
```

---

## Complete Minimal Server Example

```python
#!/usr/bin/env python3
"""Minimal MCP server -- run with: python server.py"""

from fastmcp import FastMCP

mcp = FastMCP("hello-world", version="1.0.0")

@mcp.tool()
def greet(name: str) -> str:
    """Say hello to someone."""
    return f"Hello, {name}! Welcome to MCP."

@mcp.tool()
def add(a: float, b: float) -> str:
    """Add two numbers."""
    return f"{a} + {b} = {a + b}"

if __name__ == "__main__":
    mcp.run()
```

**Claude Desktop config:**

```json
{
  "mcpServers": {
    "hello-world": {
      "command": "python",
      "args": ["/absolute/path/to/server.py"]
    }
  }
}
```

Or with `uv`:

```json
{
  "mcpServers": {
    "hello-world": {
      "command": "uv",
      "args": ["run", "/absolute/path/to/server.py"]
    }
  }
}
```

---

## Complete Production Server Example

```python
#!/usr/bin/env python3
"""GitHub Status MCP Server -- production configuration."""

import os
import json
import logging
from contextlib import asynccontextmanager
from typing import Literal

import httpx
from fastmcp import FastMCP, Context
from fastmcp.exceptions import ToolError

# --- Configuration ---
API_BASE_URL = os.environ.get("GITHUB_STATUS_API", "https://www.githubstatus.com/api/v2")
LOG_LEVEL = os.environ.get("LOG_LEVEL", "INFO")
TRANSPORT = os.environ.get("MCP_TRANSPORT", "stdio")

logging.basicConfig(
    level=getattr(logging, LOG_LEVEL),
    format="%(asctime)s [%(levelname)s] %(message)s",
)
logger = logging.getLogger("github-status-mcp")


# --- Lifespan ---
@asynccontextmanager
async def app_lifespan(server: FastMCP):
    """Manage HTTP client lifecycle."""
    client = httpx.AsyncClient(
        base_url=API_BASE_URL,
        timeout=30.0,
        headers={"Accept": "application/json"},
    )
    logger.info("HTTP client initialized for %s", API_BASE_URL)
    try:
        yield {"http": client}
    finally:
        await client.aclose()
        logger.info("HTTP client closed")


# --- Server ---
mcp = FastMCP(
    name="github-status",
    version="1.0.0",
    description="GitHub Status API integration for monitoring service health",
    lifespan=app_lifespan,
)


@mcp.tool(version="1.0")
async def get_status(ctx: Context) -> str:
    """Get current GitHub system status summary.

    Returns the overall status indicator and description.
    """
    http: httpx.AsyncClient = ctx.request_context["http"]
    try:
        response = await http.get("/status.json")
        response.raise_for_status()
        return response.text
    except httpx.HTTPError as e:
        logger.error("get_status failed: %s", e)
        raise ToolError(f"Failed to fetch GitHub status: {e}")


@mcp.tool(version="1.0")
async def get_incidents(
    limit: int = 5,
    ctx: Context = None,
) -> str:
    """Get recent GitHub incidents.

    Args:
        limit: Number of incidents to return (1-50, default 5)
    """
    if limit < 1 or limit > 50:
        raise ToolError("limit must be between 1 and 50")

    http: httpx.AsyncClient = ctx.request_context["http"]
    try:
        response = await http.get("/incidents.json")
        response.raise_for_status()
        data = response.json()
        incidents = data.get("incidents", [])[:limit]
        return json.dumps(incidents, indent=2)
    except httpx.HTTPError as e:
        logger.error("get_incidents failed: %s", e)
        raise ToolError(f"Failed to fetch incidents: {e}")


@mcp.tool(version="1.0")
async def get_component_status(
    component_name: str,
    ctx: Context = None,
) -> str:
    """Get status of a specific GitHub component.

    Args:
        component_name: Component name (e.g., 'Git Operations', 'API Requests')
    """
    http: httpx.AsyncClient = ctx.request_context["http"]
    try:
        response = await http.get("/components.json")
        response.raise_for_status()
        data = response.json()
        components = data.get("components", [])

        match = next(
            (c for c in components if c["name"].lower() == component_name.lower()),
            None,
        )
        if not match:
            available = ", ".join(c["name"] for c in components)
            raise ToolError(
                f"Component '{component_name}' not found. Available: {available}"
            )

        return json.dumps(match, indent=2)
    except httpx.HTTPError as e:
        logger.error("get_component_status failed: %s", e)
        raise ToolError(f"Failed to fetch component status: {e}")


@mcp.resource("github-status://components")
async def list_components(ctx: Context) -> str:
    """List all GitHub Status components."""
    http: httpx.AsyncClient = ctx.request_context["http"]
    response = await http.get("/components.json")
    response.raise_for_status()
    return response.text


# --- Entry Point ---
if __name__ == "__main__":
    if TRANSPORT == "http":
        mcp.run(transport="streamable-http", host="0.0.0.0", port=3000)
    else:
        mcp.run()
```

**Dockerfile:**

```dockerfile
FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY server.py .

ENV MCP_TRANSPORT=http
ENV LOG_LEVEL=INFO

EXPOSE 3000

CMD ["python", "server.py"]
```

**requirements.txt:**

```
fastmcp==3.2.4
httpx>=0.27.0
uvicorn>=0.34.0
```

> For specification design before building, see **trl-mcp-architect** (`references/specification-checklist.md`). For scaffold generation and deployment, see **trl-mcp-forge** (`references/scaffold-guide.md`).
