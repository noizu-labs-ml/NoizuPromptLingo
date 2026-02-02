# Context & Lifespan

**Type**: Documentation
**Category**: FastMCP
**Status**: Core

## Purpose

Context and lifespan management are essential request-scoped and server-scoped capabilities in FastMCP 2.x. Context provides request-scoped utilities including logging, progress reporting, resource access, and request metadata. Lifespan management handles server initialization and teardown, enabling shared resources like database connections across all requests. These features together provide the foundation for stateful server behavior and client communication.

## Key Capabilities

- **Request-scoped context injection** via type hints (`Context`) or `CurrentContext()` dependency
- **Structured logging** at debug, info, warning, and error levels
- **Progress reporting** for long-running operations with step tracking
- **Resource access** through context methods (`read_resource()`)
- **LLM sampling** capabilities via `ctx.sample()`
- **Lifespan hooks** for server startup and shutdown with typed state management
- **FastAPI integration** with combined lifespan management

## Usage & Integration

Context is injected into tools via dependency injection, either through type hints (legacy) or the preferred `CurrentContext()` pattern (v2.14+). For utility functions outside tool signatures, `get_context()` provides access within the request scope. Lifespan functions manage resources that persist across all requests.

- **Triggered by**: MCP client requests (context), server start/stop (lifespan)
- **Outputs to**: MCP clients via log notifications and progress updates
- **Complements**: Tool definitions (03-tools), resource handlers (04-resources), deployment strategies (08-deployment)

## Core Operations

### Context Injection (Preferred Pattern)

```python
from fastmcp import FastMCP
from fastmcp.server.context import Context
from fastmcp.dependencies import CurrentContext

mcp = FastMCP("My Server")

@mcp.tool
async def process(data: str, ctx: Context = CurrentContext()) -> str:
    await ctx.info(f"Processing: {data}")
    await ctx.report_progress(1, 2, "Step 1")
    return f"Done: {data}"
```

### Lifespan Management

```python
from contextlib import asynccontextmanager
from dataclasses import dataclass

@dataclass
class AppState:
    db: Database

@asynccontextmanager
async def lifespan(server: FastMCP):
    db = await Database.connect()
    yield AppState(db=db)
    await db.disconnect()

mcp = FastMCP("My Server", lifespan=lifespan)
```

### Accessing Lifespan State in Tools

```python
from fastmcp.server.dependencies import get_lifespan_state

@mcp.tool
async def query(sql: str) -> list:
    state = get_lifespan_state()
    return await state["db"].query(sql)
```

## Configuration & Parameters

| Method/Parameter | Purpose | Default | Notes |
|------------------|---------|---------|-------|
| `ctx.debug(msg)` | Debug-level logging | N/A | Async method |
| `ctx.info(msg)` | Info-level logging | N/A | Async method |
| `ctx.warning(msg)` | Warning-level logging | N/A | Async method |
| `ctx.error(msg)` | Error-level logging | N/A | Async method |
| `ctx.report_progress(current, total, msg)` | Progress updates | N/A | Async method |
| `ctx.request_id` | Unique request identifier | Auto-generated | Read-only property |
| `ctx.client_id` | Client session identifier | Auto-generated | Read-only property |

## Integration Points

- **Upstream dependencies**: FastMCP server initialization, tool registration
- **Downstream consumers**: MCP clients (Claude Desktop, IDE extensions), logs, monitoring
- **Related utilities**: `get_context()` for non-tool functions, `get_lifespan_state()` for shared resources, `get_http_request()` for HTTP access

## Limitations & Constraints

- Context is request-scoped only; state does NOT persist across requests
- `get_context()` raises `RuntimeError` outside request scope
- **Breaking change in v2.13.0**: Lifespan runs once per server, not per session
- For per-session behavior, use middleware instead of lifespan hooks
- Context methods are async; calling functions typically need `async def`
- FastAPI integration requires passing `lifespan` to FastAPI constructor

## Success Indicators

- Log messages appear in MCP client console
- Progress notifications update during long operations
- Database connections persist across multiple tool invocations
- Server starts and stops cleanly with resource cleanup
- No `RuntimeError` exceptions from context access
- Lifespan state accessible in all tools via `get_lifespan_state()`

---
**Generated from**: worktrees/main/docs/fastmcp/06-context.md
