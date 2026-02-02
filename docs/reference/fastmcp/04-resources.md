# Resources

> Exposing data to LLMs with static and dynamic resources in FastMCP 2.x

## Overview

Resources provide data that LLMs can read. Unlike tools (which perform actions), resources expose information.

## Static Resources

Fixed URI, no parameters:

```python
from fastmcp import FastMCP

mcp = FastMCP("My Server")

@mcp.resource("config://version")
def get_version() -> str:
    return "2.0.0"

@mcp.resource("data://categories")
def get_categories() -> list[str]:
    return ["Electronics", "Books", "Home"]
```

Client accesses via URI: `config://version`

## Resource Templates

Dynamic resources with parameters:

```python
@mcp.resource("users://{user_id}/profile")
def get_profile(user_id: int) -> dict:
    return {"id": user_id, "name": f"User {user_id}"}

@mcp.resource("weather://{city}/{date}")
def get_weather(city: str, date: str) -> dict:
    return {"city": city, "date": date, "temp": 72}
```

Client requests:
- `users://123/profile` → `get_profile(user_id=123)`
- `weather://london/2025-01-15` → `get_weather(city="london", date="2025-01-15")`

## URI Template Rules (v2.2.0+)

### Path Parameters (Required)

Path parameters `{param}` map to required function arguments:

```python
@mcp.resource("products://{category}/{id}")
def get_product(category: str, id: int) -> dict:
    # category and id are required
    pass
```

### Query Parameters (Optional)

Query parameters `{?param}` map to optional arguments with defaults:

```python
@mcp.resource("search://products{?category,limit}")
def search(category: str = "all", limit: int = 10) -> list:
    # category and limit are optional
    pass
```

### Validation Rules

1. Required function parameters (no defaults) MUST appear in URI path
2. Query parameters MUST have defaults
3. All URI template parameters must exist as function parameters

## Async Resources

```python
import httpx

@mcp.resource("external://{endpoint}")
async def fetch_external(endpoint: str) -> dict:
    async with httpx.AsyncClient() as client:
        response = await client.get(f"https://api.example.com/{endpoint}")
        return response.json()
```

## Resource with Context

```python
from fastmcp.server.context import Context
from fastmcp.dependencies import CurrentContext

@mcp.resource("system://status")
async def get_status(ctx: Context = CurrentContext()) -> dict:
    await ctx.info("Fetching system status")
    return {"status": "operational", "request_id": ctx.request_id}
```

## Content Types

Resources return text or binary content:

```python
# Text content (default)
@mcp.resource("data://config")
def get_config() -> dict:
    return {"key": "value"}

# Binary content
@mcp.resource("files://{filename}")
def get_file(filename: str) -> bytes:
    with open(f"data/{filename}", "rb") as f:
        return f.read()
```

### Client-Side Handling

```python
content = await client.read_resource("files://image.png")

for item in content:
    if hasattr(item, 'text'):
        print(item.text)
    elif hasattr(item, 'blob'):
        with open("output", "wb") as f:
            f.write(item.blob)
```

## Resource Annotations

Add metadata for LLM guidance:

```python
@mcp.resource(
    "data://config",
    annotations={
        "audience": ["user"],
        "priority": 0.8
    }
)
def get_config() -> dict:
    return {"setting": "value"}
```

## Custom Metadata

```python
@mcp.resource(
    "api://endpoints",
    name="api_endpoints",
    description="List of available API endpoints",
    mime_type="application/json",
    meta={"version": "1.0"}
)
def list_endpoints() -> list[dict]:
    return [{"path": "/users", "method": "GET"}]
```

## Multiple URIs for Same Function

```python
def lookup_user(name: str | None = None, email: str | None = None) -> dict:
    if email:
        return find_by_email(email)
    elif name:
        return find_by_name(name)
    return {"error": "No parameters"}

# Register multiple URIs
mcp.resource("users://email/{email}")(lookup_user)
mcp.resource("users://name/{name}")(lookup_user)
```

## Error Handling

```python
from fastmcp.exceptions import ResourceError

@mcp.resource("secure://data")
def get_secure_data() -> dict:
    if not authorized():
        raise ResourceError("Access denied")
    return {"secret": "value"}
```

`ResourceError` contents are always sent to clients regardless of `mask_error_details` setting.

## Enabling/Disabling Resources

```python
@mcp.resource("deprecated://old", enabled=False)
def old_resource() -> str:
    return "Deprecated"

# Programmatic toggle
resource = mcp.get_resource("deprecated://old")
resource.enable()
resource.disable()
```

## Complete Example

```python
from fastmcp import FastMCP
from fastmcp.server.context import Context
from fastmcp.dependencies import CurrentContext
from fastmcp.exceptions import ResourceError

mcp = FastMCP("Data Server")

# Static configuration
@mcp.resource("config://app")
def app_config() -> dict:
    return {
        "version": "2.0.0",
        "environment": "production"
    }

# Dynamic user profile
@mcp.resource("users://{user_id}/profile")
async def user_profile(user_id: int, ctx: Context = CurrentContext()) -> dict:
    await ctx.info(f"Fetching profile for user {user_id}")

    if user_id <= 0:
        raise ResourceError("Invalid user ID")

    return {
        "id": user_id,
        "name": f"User {user_id}",
        "email": f"user{user_id}@example.com"
    }

# Search with optional filters
@mcp.resource("products://search{?category,min_price,max_price}")
def search_products(
    category: str = "all",
    min_price: float = 0,
    max_price: float = 1000
) -> list[dict]:
    return [
        {"id": 1, "name": "Widget", "price": 29.99, "category": category}
    ]

# Binary file
@mcp.resource("files://{path}")
def get_file(path: str) -> bytes:
    with open(f"data/{path}", "rb") as f:
        return f.read()

if __name__ == "__main__":
    mcp.run()
```

---

**Previous**: [Tools](03-tools.md) | **Next**: [Prompts](05-prompts.md) | **Index**: [README](README.md)
