# Core Concepts

> Servers, tools, resources, prompts, and the MCP architecture in FastMCP 2.x

## Overview

FastMCP implements the Model Context Protocol (MCP), providing a standardized way for LLMs to interact with external data and functionality. The core building blocks are:

| Concept | Purpose | Decorator |
|:--------|:--------|:----------|
| **Server** | Container for all MCP components | `FastMCP()` |
| **Tools** | Functions the LLM can execute | `@mcp.tool` |
| **Resources** | Data the LLM can read | `@mcp.resource` |
| **Prompts** | Reusable prompt templates | `@mcp.prompt` |
| **Context** | Request-scoped state and utilities | `Context` |

## Server

The `FastMCP` class is the central container:

```python
from fastmcp import FastMCP

mcp = FastMCP("My Server")

@mcp.tool
def hello(name: str) -> str:
    """Greet someone."""
    return f"Hello, {name}!"

if __name__ == "__main__":
    mcp.run()
```

### Running Modes

```python
# STDIO (default) - for Claude Desktop
mcp.run()

# HTTP - for web clients
mcp.run(transport="http", port=8000)

# Streamable HTTP (recommended for production)
mcp.run(transport="streamable-http", port=8000)
```

### CLI Usage

```bash
# Run with default transport
fastmcp run server.py:mcp

# Run with HTTP transport
fastmcp run server.py:mcp --transport http --port 8000
```

## Tools

Tools are functions that the LLM can call to perform actions:

```python
@mcp.tool
def calculate(a: float, b: float, operation: str) -> float:
    """Perform a calculation."""
    if operation == "add":
        return a + b
    elif operation == "multiply":
        return a * b
    raise ValueError(f"Unknown operation: {operation}")
```

FastMCP automatically:
- Uses the function name as the tool name
- Uses the docstring as the LLM description
- Generates JSON schema from type hints

See [Tools](03-tools.md) for detailed documentation.

## Resources

Resources provide data that the LLM can read:

```python
# Static resource
@mcp.resource("config://version")
def get_version() -> str:
    return "2.0.0"

# Dynamic template
@mcp.resource("users://{user_id}/profile")
def get_profile(user_id: int) -> dict:
    return {"id": user_id, "name": f"User {user_id}"}
```

See [Resources](04-resources.md) for detailed documentation.

## Prompts

Prompts are reusable templates for LLM interactions:

```python
@mcp.prompt
def code_review(language: str, code: str) -> str:
    """Request a code review."""
    return f"Review this {language} code:\n\n{code}"
```

See [Prompts](05-prompts.md) for detailed documentation.

## Context

Context provides request-scoped utilities:

```python
from fastmcp.server.context import Context
from fastmcp.dependencies import CurrentContext

@mcp.tool
async def process(data: str, ctx: Context = CurrentContext()) -> str:
    """Process with logging."""
    await ctx.info(f"Processing: {data}")
    return f"Processed: {data}"
```

See [Context](06-context.md) for detailed documentation.

## Type System

FastMCP uses Python type hints for schema generation:

```python
from pydantic import BaseModel

class User(BaseModel):
    name: str
    email: str
    age: int

@mcp.tool
def create_user(user: User) -> dict:
    """Create a new user."""
    return {"id": 123, **user.model_dump()}
```

### Supported Types

| Type | JSON Schema |
|:-----|:------------|
| `str` | `string` |
| `int` | `integer` |
| `float` | `number` |
| `bool` | `boolean` |
| `list[T]` | `array` |
| `dict[str, T]` | `object` |
| `Optional[T]` | nullable |
| `BaseModel` | object with properties |

### Input Validation

By default, FastMCP uses Pydantic's coercion (e.g., `"10"` → `10`):

```python
# Default: flexible coercion
mcp = FastMCP("My Server")

# Strict: reject type mismatches
mcp = FastMCP("My Server", strict_input_validation=True)
```

## Lifespan

Manage server startup and shutdown:

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

**Important (v2.13+)**: Lifespan runs once per server, not per session.

See [Context](06-context.md) for lifespan details.

## Architecture

```
┌─────────────────────────────────────────┐
│              FastMCP Server             │
├─────────────────────────────────────────┤
│  ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│  │  Tools  │ │Resources│ │ Prompts │   │
│  └────┬────┘ └────┬────┘ └────┬────┘   │
│       │           │           │         │
│       └───────────┼───────────┘         │
│                   │                     │
│           ┌───────┴───────┐             │
│           │    Context    │             │
│           └───────────────┘             │
├─────────────────────────────────────────┤
│              Transport Layer            │
│    (STDIO | HTTP | SSE | Streamable)    │
└─────────────────────────────────────────┘
```

## Next Steps

- [Tools](03-tools.md) - Detailed tool documentation
- [Resources](04-resources.md) - Resource handling
- [Prompts](05-prompts.md) - Prompt templates
- [Context](06-context.md) - Context and lifespan
- [Client](07-client.md) - Client usage

---

**Previous**: [Installation](01-installation.md) | **Next**: [Tools](03-tools.md) | **Index**: [README](README.md)
