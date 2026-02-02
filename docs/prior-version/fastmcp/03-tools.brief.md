# FastMCP Tools

**Type**: Framework Component
**Category**: FastMCP
**Status**: Core

## Purpose

Tools are the primary interface through which LLMs interact with FastMCP servers. The framework provides a decorator-based system for defining callable functions that automatically generate JSON schemas, handle type validation, and process both synchronous and asynchronous operations. Tools abstract away the complexity of MCP protocol implementation, allowing developers to focus on business logic while the framework handles parameter parsing, validation, error handling, and response formatting.

FastMCP's tool system is designed for flexibility and type safety, leveraging Python's type hints and Pydantic models to automatically generate correct schemas that LLMs can understand and use effectively.

## Key Capabilities

- **Automatic schema generation** from Python type hints and docstrings
- **Sync and async tool support** with transparent handling
- **Flexible parameter types** including Pydantic models for complex inputs
- **Context injection** for logging, progress reporting, and request metadata
- **Custom naming and metadata** via decorator parameters
- **Input validation modes** (flexible coercion or strict type checking)
- **Enable/disable controls** for feature flagging
- **Error handling** with optional detail masking

## Usage & Integration

- **Triggered by**: Decorator application (`@mcp.tool`) on functions or methods
- **Outputs to**: MCP protocol responses, available to connected LLM clients
- **Complements**: Resources (read-only data), Prompts (templates)

Tools are registered at server initialization and remain available throughout the server lifecycle. They can be enabled/disabled programmatically for runtime feature control.

## Core Operations

### Basic Tool Registration

```python
from fastmcp import FastMCP

mcp = FastMCP("My Server")

@mcp.tool
def greet(name: str) -> str:
    """Greets the user by name."""
    return f"Hello, {name}!"
```

### Custom Tool with Metadata

```python
@mcp.tool(
    name="find_products",
    description="Search the product catalog.",
    tags={"catalog", "search"},
    meta={"version": "1.2", "author": "team"}
)
def search_impl(query: str) -> list[dict]:
    # Implementation
    pass
```

### Async Tool with Context

```python
from fastmcp.server.context import Context
from fastmcp.dependencies import CurrentContext

@mcp.tool
async def process(data: str, ctx: Context = CurrentContext()) -> str:
    await ctx.info(f"Processing: {data}")
    await ctx.report_progress(50, 100, "Halfway")
    return f"Done: {data}"
```

### Structured Parameters and Returns

```python
from pydantic import BaseModel

class SearchParams(BaseModel):
    query: str
    filters: dict[str, str]
    limit: int = 10

class Result(BaseModel):
    id: str
    score: float

@mcp.tool
def advanced_search(params: SearchParams) -> list[Result]:
    """Search with structured parameters."""
    return [Result(id="1", score=0.95)]
```

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| `name` | Tool name exposed to LLM | Function name | Override with string or kwarg |
| `description` | Tool purpose for LLM | Docstring | Override with kwarg |
| `tags` | Categorization tags | None | Set for grouping |
| `meta` | Custom metadata | None | Arbitrary key-value pairs |
| `enabled` | Availability flag | `True` | Toggle at runtime with `.enable()` / `.disable()` |
| `strict_input_validation` | Type checking mode | `False` | Server-level setting; `True` rejects type mismatches |
| `mask_error_details` | Error message masking | `False` | Server-level setting; `True` hides internal errors |

## Integration Points

- **Upstream dependencies**: FastMCP instance, Pydantic for validation
- **Downstream consumers**: LLM clients via MCP protocol
- **Related utilities**:
  - Context system for logging and progress
  - Error handling via `ToolError` exceptions
  - Method registration for class-based tools

## Limitations & Constraints

- **No variadic parameters**: `*args` and `**kwargs` not supported (schema requires explicit params)
- **Decorator method handling**: Direct decoration of instance methods fails; must register bound methods post-instantiation
- **Decorator return change (v2.7+)**: Decorator returns `Tool` object, not original function
- **Type coercion by default**: Flexible validation may accept incorrect types unless `strict_input_validation=True`

## Success Indicators

- Tool appears in server's tool list and is callable by LLM
- Type validation accepts valid inputs and rejects invalid ones according to mode
- Async tools complete without blocking other requests
- Context injection provides logging and progress reporting
- Error responses include appropriate detail level based on masking setting

---
**Generated from**: worktrees/main/docs/fastmcp/03-tools.md
