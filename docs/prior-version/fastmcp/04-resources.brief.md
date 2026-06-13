# Resources

**Type**: Documentation
**Category**: fastmcp
**Status**: Core

## Purpose

Resources in FastMCP 2.x provide a mechanism for exposing data to Large Language Models (LLMs) without requiring actions or computation. Unlike tools that perform operations, resources serve as read-only data endpoints that LLMs can query to retrieve information. They support both static URIs (fixed configuration data) and dynamic templates with parameters (user-specific content, queries with filters). Resources enable structured data exposure through custom URI schemes, making contextual information readily available during LLM interactions.

## Key Capabilities

- **Static Resources**: Fixed URI endpoints returning configuration, constants, or reference data
- **Dynamic Resource Templates**: URI templates with path and query parameters for parameterized data access
- **Async Support**: Native async/await for I/O-bound operations like database queries or HTTP calls
- **Multiple Content Types**: Text (JSON, strings, dicts) and binary (bytes) content handling
- **Context Integration**: Access to FastMCP context for logging and request tracking
- **Error Handling**: Specialized `ResourceError` for client-facing error messages
- **Metadata & Annotations**: Custom metadata and LLM guidance through priority and audience hints

## Usage & Integration

- **Triggered by**: LLM requests for data via URI patterns; client-side `read_resource()` calls
- **Outputs to**: LLM context window as text or binary blobs; client applications via MCP protocol
- **Complements**: Tools (for actions), Prompts (for LLM templates), Context (for request metadata)

Resources are registered using the `@mcp.resource()` decorator with URI schemes. Static resources use fixed URIs like `config://version`, while templates use path parameters `{param}` and query parameters `{?param}` for dynamic data.

## Core Operations

### Static Resource
```python
@mcp.resource("config://version")
def get_version() -> str:
    return "2.0.0"
```

### Dynamic Resource with Path Parameters
```python
@mcp.resource("users://{user_id}/profile")
def get_profile(user_id: int) -> dict:
    return {"id": user_id, "name": f"User {user_id}"}
```

### Dynamic Resource with Query Parameters
```python
@mcp.resource("search://products{?category,limit}")
def search(category: str = "all", limit: int = 10) -> list:
    # category and limit are optional with defaults
    pass
```

### Async Resource with HTTP Call
```python
import httpx

@mcp.resource("external://{endpoint}")
async def fetch_external(endpoint: str) -> dict:
    async with httpx.AsyncClient() as client:
        response = await client.get(f"https://api.example.com/{endpoint}")
        return response.json()
```

### Resource with Context
```python
from fastmcp.server.context import Context
from fastmcp.dependencies import CurrentContext

@mcp.resource("system://status")
async def get_status(ctx: Context = CurrentContext()) -> dict:
    await ctx.info("Fetching system status")
    return {"status": "operational", "request_id": ctx.request_id}
```

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| `uri` | Resource URI or template | Required | Use `scheme://path` format; `{param}` for path params, `{?param}` for query params |
| `name` | Resource name override | Function name | Used in resource listings |
| `description` | Human-readable description | Function docstring | Guides LLM usage |
| `mime_type` | Content MIME type | `text/plain` | Set for binary resources |
| `annotations` | LLM guidance metadata | `{}` | Keys: `audience` (list), `priority` (float 0-1) |
| `enabled` | Enable/disable resource | `True` | Toggle availability programmatically |

### URI Template Validation (v2.2.0+)

1. **Path parameters** `{param}` map to **required** function arguments (no defaults)
2. **Query parameters** `{?param}` map to **optional** arguments (with defaults)
3. All URI template params must exist as function parameters

## Integration Points

- **Upstream dependencies**: FastMCP server initialization; MCP protocol client
- **Downstream consumers**: LLM requests via URI; client applications reading resources
- **Related utilities**: Tools (action execution), Context (request metadata), ResourceError (error handling)

## Limitations & Constraints

- URI template parameters must match function signature (path=required, query=optional)
- Binary content returned as `bytes` type; clients must handle blob vs. text differentiation
- `ResourceError` always visible to clients regardless of `mask_error_details` setting
- Multiple URIs for same function require explicit registration per URI
- Disabled resources (`enabled=False`) are hidden from resource listings

## Success Indicators

- Resource URIs resolve correctly with proper parameter substitution
- Function signatures match URI template parameter requirements (validation passes)
- Async resources complete without blocking; external API calls return data
- LLM receives properly formatted text or binary content
- Context logging captures resource access patterns for debugging

---
**Generated from**: worktrees/main/docs/fastmcp/04-resources.md
