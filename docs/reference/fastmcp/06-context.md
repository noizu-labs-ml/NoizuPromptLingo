# Context & Lifespan

> Request context, dependency injection, and server lifecycle in FastMCP 2.x

## Context Overview

Context provides request-scoped utilities for logging, progress reporting, and accessing request metadata.

## Accessing Context

### Preferred Pattern (v2.14+)

```python
from fastmcp import FastMCP
from fastmcp.server.context import Context
from fastmcp.dependencies import CurrentContext

mcp = FastMCP("My Server")

@mcp.tool
async def process(data: str, ctx: Context = CurrentContext()) -> str:
    await ctx.info(f"Processing: {data}")
    return f"Done: {data}"
```

### Type Hint Injection (Legacy)

```python
from fastmcp.server.context import Context

@mcp.tool
async def my_tool(param: str, ctx: Context) -> str:
    await ctx.info("Processing...")
    return "Done"
```

### get_context() for Utility Functions

```python
from fastmcp.server.dependencies import get_context

async def helper(data: list) -> dict:
    ctx = get_context()
    await ctx.info(f"Processing {len(data)} items")
    return {"count": len(data)}
```

**Note**: Only use within server request context. Raises `RuntimeError` outside requests.

## Context Capabilities

### Logging

```python
@mcp.tool
async def demo(ctx: Context = CurrentContext()) -> str:
    await ctx.debug("Debug message")
    await ctx.info("Info message")
    await ctx.warning("Warning message")
    await ctx.error("Error message")
    return "Done"
```

### Progress Reporting

```python
@mcp.tool
async def long_task(ctx: Context = CurrentContext()) -> str:
    for i in range(10):
        await ctx.report_progress(i + 1, 10, f"Step {i + 1}")
        await process_step(i)
    return "Complete"
```

### Request Information

```python
@mcp.tool
async def info(ctx: Context = CurrentContext()) -> dict:
    return {
        "request_id": ctx.request_id,
        "client_id": ctx.client_id
    }
```

### Resource Access

```python
@mcp.tool
async def process(uri: str, ctx: Context = CurrentContext()) -> str:
    data = await ctx.read_resource(uri)
    return f"Read {len(data)} bytes"
```

### LLM Sampling

```python
@mcp.tool
async def summarize(text: str, ctx: Context = CurrentContext()) -> str:
    summary = await ctx.sample(f"Summarize: {text[:500]}")
    return summary.text
```

## Context Scope

- Each MCP request receives a NEW context object
- Context is scoped to single request
- State set in one request is NOT available in subsequent requests
- Context methods are async (function usually needs to be async)

## Lifespan Management

### Basic Lifespan

```python
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(server):
    # Startup
    db = await connect_db()
    yield {"db": db}
    # Shutdown
    await db.close()

mcp = FastMCP("My Server", lifespan=lifespan)
```

### Typed Lifespan Context

```python
from dataclasses import dataclass
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

@dataclass
class AppContext:
    db: Database
    cache: Cache

@asynccontextmanager
async def lifespan(server: FastMCP) -> AsyncIterator[AppContext]:
    db = await Database.connect()
    cache = await Cache.connect()
    try:
        yield AppContext(db=db, cache=cache)
    finally:
        await db.disconnect()
        await cache.disconnect()

mcp = FastMCP("My Server", lifespan=lifespan)
```

## Breaking Change: Lifespan Behavior (v2.13.0)

**Critical**: In v2.13.0+, lifespan runs once per server, not per session.

### Before (v2.12 and earlier)

```python
@asynccontextmanager
async def lifespan(server):
    # Ran for EVERY client connection
    print("Client connected")
    db = await connect_db()
    yield {"db": db}
    await db.close()
    print("Client disconnected")
```

### After (v2.13+)

```python
@asynccontextmanager
async def lifespan(server):
    # Runs ONCE when server starts
    print("Server starting")
    db = await connect_db()
    yield {"db": db}
    await db.close()
    print("Server stopping")
```

### Migration for Per-Session Behavior

Use middleware for per-request/session logic:

```python
from fastmcp.server.middleware import Middleware

class SessionMiddleware(Middleware):
    async def __call__(self, request, call_next):
        session_db = await get_session_connection()
        request.state.db = session_db
        try:
            return await call_next(request)
        finally:
            await session_db.close()

mcp = FastMCP("My Server")
mcp.add_middleware(SessionMiddleware())
```

## FastAPI Integration with Lifespan

```python
from fastapi import FastAPI

mcp = FastMCP("My Server")
mcp_app = mcp.http_app(path='/mcp')

# IMPORTANT: Pass lifespan to FastAPI
app = FastAPI(lifespan=mcp_app.lifespan)
app.mount("/mcp", mcp_app)
```

### Combining Multiple Lifespans

```python
from contextlib import asynccontextmanager

@asynccontextmanager
async def combined_lifespan(app: FastAPI):
    async with app_lifespan(app):
        async with mcp_app.lifespan(app):
            yield
```

## HTTP Request Access

```python
from fastmcp.server.dependencies import get_http_request

# In middleware or handlers
request = get_http_request()
# Works whether or not MCP session is established
```

## Accessing Lifespan State

```python
from fastmcp.server.dependencies import get_lifespan_state

@mcp.tool
async def query(sql: str) -> list:
    state = get_lifespan_state()
    db = state["db"]
    return await db.query(sql)
```

## Complete Example

```python
from contextlib import asynccontextmanager
from dataclasses import dataclass
from collections.abc import AsyncIterator

from fastmcp import FastMCP
from fastmcp.server.context import Context
from fastmcp.dependencies import CurrentContext
from fastmcp.server.dependencies import get_lifespan_state

# Database mock
class Database:
    @classmethod
    async def connect(cls):
        return cls()
    async def disconnect(self):
        pass
    async def query(self, sql: str) -> list:
        return [{"id": 1}]

@dataclass
class AppState:
    db: Database

@asynccontextmanager
async def lifespan(server: FastMCP) -> AsyncIterator[AppState]:
    print("Server starting...")
    db = await Database.connect()
    try:
        yield AppState(db=db)
    finally:
        await db.disconnect()
        print("Server stopped.")

mcp = FastMCP("Context Demo", lifespan=lifespan)

@mcp.tool
async def get_users(ctx: Context = CurrentContext()) -> list:
    """Fetch users from database."""
    await ctx.info("Fetching users...")

    # Access lifespan state
    state = get_lifespan_state()
    users = await state["db"].query("SELECT * FROM users")

    await ctx.report_progress(1, 1, "Complete")
    return users

@mcp.tool
async def long_process(
    steps: int = 5,
    ctx: Context = CurrentContext()
) -> str:
    """Demonstrate progress reporting."""
    for i in range(steps):
        await ctx.info(f"Step {i + 1}")
        await ctx.report_progress(i + 1, steps, f"Processing step {i + 1}")
        # Simulate work
        import asyncio
        await asyncio.sleep(0.1)

    return f"Completed {steps} steps"

if __name__ == "__main__":
    mcp.run()
```

---

**Previous**: [Prompts](05-prompts.md) | **Next**: [Client](07-client.md) | **Index**: [README](README.md)
