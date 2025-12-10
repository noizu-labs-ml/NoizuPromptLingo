# Migration Guide

> Breaking changes and upgrade paths for FastMCP 2.x

## Version Compatibility Matrix

| FastMCP | MCP SDK | Python | Notes |
|:--------|:--------|:-------|:------|
| 2.13.x+ | >1.23.1 | 3.10+ | Current stable |
| 2.12.x-2.13.0 | <1.23 | 3.10+ | OAuth patch incompatibility |
| 2.12.5 | <1.17 | 3.10+ | `.well-known` endpoint issue |

**Note**: All versions exclude `mcp==1.21.1` due to integration test failures.

## FastMCP 1.x to 2.0

### Import Path Change

The primary migration step:

```python
# Before (MCP SDK built-in)
from mcp.server.fastmcp import FastMCP

# After (FastMCP 2.x)
from fastmcp import FastMCP
```

### Installation Change

```bash
# Before
pip install mcp

# After
pip install fastmcp
```

## v2.3.4: Constructor Deprecation

### Deprecated Pattern

```python
# DEPRECATED
mcp = FastMCP(
    "My Server",
    log_level="DEBUG",
    port=8000,
    stateless_http=True
)
mcp.run()
```

### Current Pattern

```python
mcp = FastMCP("My Server")

# Provide settings at run() time
mcp.run(transport="streamable-http", port=8000)

# Or via global settings
import fastmcp
fastmcp.settings.log_level = "DEBUG"
```

## v2.7: Decorator Return Values

Decorators now return Tool/Resource/Prompt objects, not the original function.

### Before

```python
@mcp.tool()
def my_tool():
    pass

type(my_tool)  # <class 'function'>
```

### After

```python
@mcp.tool()
def my_tool():
    pass

type(my_tool)  # <class 'fastmcp.tools.Tool'>
```

### If You Need the Original Function

```python
def _impl():
    pass

tool = mcp.tool()(_impl)
# _impl remains callable
```

## v2.8: OpenAPI Route Mapping

All OpenAPI endpoints now map to Tools by default.

### Before

```python
# GET endpoints became Resources
mcp = FastMCP.from_openapi(openapi_url="...")
# GET /users/{id} -> ResourceTemplate
```

### After

```python
# ALL endpoints become Tools
mcp = FastMCP.from_openapi(openapi_url="...")
# GET /users/{id} -> Tool
```

### Restore Previous Behavior

```python
from fastmcp.server.openapi import RouteMap

mcp = FastMCP.from_openapi(
    openapi_url="...",
    route_maps=[
        RouteMap(methods=["GET"], route_type="resource_template"),
        RouteMap(methods=["POST", "PUT", "DELETE"], route_type="tool"),
    ]
)
```

## v2.10: Client Return Signature

`client.call_tool()` return type changed.

### Before

```python
result = await client.call_tool("my_tool", {"arg": "value"})
print(result)  # Direct value
```

### After

```python
result = await client.call_tool("my_tool", {"arg": "value"})
print(result.content)   # Access content
print(result.is_error)  # Check errors
```

## v2.13.0: Lifespan Behavior (CRITICAL)

`lifespan` now runs once per server, not per client session.

### Before

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

### After

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

Use middleware:

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

## v2.13.x: MCP SDK Pinning

### v2.12.5 → v2.13.x

```bash
# v2.12.5
pip install "fastmcp>=2.12.5" "mcp<1.17"

# v2.13.x
pip install "fastmcp>=2.13.3" "mcp<1.23"
```

### After v2.14 (Future)

```bash
pip install "fastmcp>=2.14" "mcp>=1.23"
```

## SSE to Streamable HTTP

SSE transport is deprecated (MCP spec 2025-03-26).

### Before

```python
mcp.run(transport="sse")
```

### After

```python
mcp.run(transport="streamable-http")
```

### Client Configuration

```json
{
  "mcpServers": {
    "my-server": {
      "url": "http://localhost:8000/mcp",
      "transport": "streamable-http"
    }
  }
}
```

## Settings Access

### Deprecated

```python
from fastmcp.settings import settings
settings.log_level = "DEBUG"
```

### Current

```python
import fastmcp
fastmcp.settings.log_level = "DEBUG"
```

## v2.14 Context API (Preview)

### Before

```python
from fastmcp import Context

@mcp.tool()
def my_tool(ctx: Context):
    server = ctx.server
```

### After (v2.14+)

```python
from fastmcp.dependencies import CurrentContext

@mcp.tool()
def my_tool(ctx: CurrentContext):
    server = ctx.fastmcp
    request = ctx.request
```

## v2.14 Upgrade Checklist

When v2.14 releases:

- [ ] No constructor kwargs for transport settings
- [ ] Using `fastmcp.settings` not `fastmcp.settings.settings`
- [ ] `lifespan` logic is server-scoped not session-scoped
- [ ] Using `streamable-http` not `sse` transport
- [ ] MCP SDK upgraded to 1.23+
- [ ] Context access uses `CurrentContext()` and `ctx.fastmcp`
- [ ] Decorator return values handled as objects
- [ ] OpenAPI route maps explicitly configured if needed

## Quick Migration Commands

### Check Current Versions

```bash
pip show fastmcp mcp
```

### Upgrade to Latest Stable

```bash
pip install --upgrade "fastmcp>=2.13.3" "mcp<1.23"
```

### Verify Installation

```bash
fastmcp version
```

## Troubleshooting

### OAuth Errors After Upgrade

Check MCP SDK version compatibility:

```bash
pip show mcp
# Ensure matches FastMCP requirements
```

### `.well-known` Endpoint Issues

Pin to compatible MCP SDK:

```bash
pip install "mcp<1.17"
```

### Lifespan Not Running

Verify lifespan is passed correctly:

```python
mcp = FastMCP("My Server", lifespan=my_lifespan)  # Not run()
```

### Import Errors

Ensure using standalone FastMCP:

```python
# Correct
from fastmcp import FastMCP

# Wrong (MCP SDK built-in)
from mcp.server.fastmcp import FastMCP
```

---

**Previous**: [Deployment](08-deployment.md) | **Next**: [Examples](10-examples.md) | **Index**: [README](README.md)
