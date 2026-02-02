# Tools

> Defining and configuring tools in FastMCP 2.x

## Basic Tool Definition

```python
from fastmcp import FastMCP

mcp = FastMCP("My Server")

@mcp.tool
def greet(name: str) -> str:
    """Greets the user by name."""
    return f"Hello, {name}!"
```

FastMCP automatically:
- Uses function name as tool name
- Uses docstring as LLM description
- Generates JSON schema from type hints

## Decorator Patterns

### Basic Decorator

```python
@mcp.tool
def my_tool(x: int) -> str:
    return str(x)
```

### Custom Name

```python
@mcp.tool("custom_name")
def my_tool(x: int) -> str:
    return str(x)

# Or with keyword
@mcp.tool(name="custom_name")
def my_tool(x: int) -> str:
    return str(x)
```

### With Metadata

```python
@mcp.tool(
    name="find_products",
    description="Search the product catalog.",
    tags={"catalog", "search"},
    meta={"version": "1.2", "author": "team"}
)
def search_impl(query: str) -> list[dict]:
    pass
```

### Functional Registration

```python
def my_function(x: int) -> str:
    return str(x)

mcp.tool(my_function, name="custom_name")
```

## Parameters

### Required vs Optional

```python
@mcp.tool
def search(
    query: str,                    # Required - no default
    max_results: int = 10,         # Optional - has default
    category: str | None = None    # Optional - can be None
) -> list[dict]:
    """Search with filters."""
    pass
```

### Complex Types

```python
from pydantic import BaseModel

class SearchParams(BaseModel):
    query: str
    filters: dict[str, str]
    limit: int = 10

@mcp.tool
def advanced_search(params: SearchParams) -> list[dict]:
    """Search with structured parameters."""
    return []
```

### Restrictions

- No `*args` or `**kwargs` (schema requires explicit params)
- Methods require special handling (see below)

## Async Tools

```python
import httpx

@mcp.tool
async def fetch_data(url: str) -> dict:
    """Fetches data from URL."""
    async with httpx.AsyncClient() as client:
        response = await client.get(url)
        return response.json()
```

## Return Types

### Simple Returns

```python
@mcp.tool
def add(a: int, b: int) -> int:
    return a + b
# Returns: {"result": 8}
```

### Structured Returns

```python
from pydantic import BaseModel

class Result(BaseModel):
    id: str
    score: float

@mcp.tool
def search(query: str) -> list[Result]:
    return [Result(id="1", score=0.95)]
```

## Input Validation

### Default (Flexible)

Pydantic coercion enabled - `"10"` converts to `10`:

```python
mcp = FastMCP("My Server")  # Default
```

### Strict Mode

Reject type mismatches:

```python
mcp = FastMCP("My Server", strict_input_validation=True)
```

## Method Decoration

Decorating class methods requires special handling:

### Wrong

```python
class MyClass:
    @mcp.tool  # Returns Tool object, not callable
    def method(self, x: int) -> str:
        return str(x)
```

### Correct

```python
class MyClass:
    def method(self, x: int) -> str:
        return str(x)

obj = MyClass()
mcp.tool(obj.method)  # Register bound method
```

### Class/Static Methods

```python
class MyClass:
    @classmethod
    def from_string(cls, s: str) -> "MyClass":
        return cls(s)

    @staticmethod
    def utility(x: int) -> str:
        return str(x)

mcp.tool(MyClass.from_string)
mcp.tool(MyClass.utility)
```

### Registration During Init

```python
class Provider:
    def __init__(self, mcp: FastMCP):
        mcp.tool(self.process)

    def process(self, data: str) -> str:
        return f"Processed: {data}"

mcp = FastMCP("My Server")
provider = Provider(mcp)
```

## Tool with Context

Access request context for logging and utilities:

```python
from fastmcp.server.context import Context
from fastmcp.dependencies import CurrentContext

@mcp.tool
async def process(data: str, ctx: Context = CurrentContext()) -> str:
    await ctx.info(f"Processing: {data}")
    await ctx.report_progress(50, 100, "Halfway")
    return f"Done: {data}"
```

## Enabling/Disabling Tools

```python
@mcp.tool(enabled=False)
def experimental_tool() -> str:
    return "Not ready"

# Programmatic toggle
tool = mcp.get_tool("experimental_tool")
tool.enable()
tool.disable()
```

## Decorator Return Value (v2.7+)

Decorators return Tool objects, not the original function:

```python
@mcp.tool
def my_tool():
    pass

type(my_tool)  # <class 'fastmcp.tools.Tool'>
```

If you need the original function:

```python
def _impl():
    pass

tool = mcp.tool()(_impl)
# _impl is still callable
```

## Error Handling

### Default Behavior

Exceptions are caught and converted to MCP error responses.

### Explicit Errors

```python
from fastmcp.exceptions import ToolError

@mcp.tool
def risky_operation() -> str:
    if not safe():
        raise ToolError("Operation not permitted")
    return "Success"
```

### Masking Details

```python
mcp = FastMCP("My Server", mask_error_details=True)
```

Hides internal error details from clients.

## Complete Example

```python
from fastmcp import FastMCP
from fastmcp.server.context import Context
from fastmcp.dependencies import CurrentContext
from pydantic import BaseModel

mcp = FastMCP("Calculator")

class Calculation(BaseModel):
    result: float
    operation: str

@mcp.tool(
    description="Perform arithmetic operations",
    tags={"math", "calculator"}
)
async def calculate(
    a: float,
    b: float,
    operation: str = "add",
    ctx: Context = CurrentContext()
) -> Calculation:
    """
    Calculate result of arithmetic operation.

    Operations: add, subtract, multiply, divide
    """
    await ctx.info(f"Calculating {a} {operation} {b}")

    ops = {
        "add": a + b,
        "subtract": a - b,
        "multiply": a * b,
        "divide": a / b if b != 0 else float('inf')
    }

    if operation not in ops:
        raise ValueError(f"Unknown operation: {operation}")

    return Calculation(result=ops[operation], operation=operation)

if __name__ == "__main__":
    mcp.run()
```

---

**Previous**: [Core Concepts](02-core-concepts.md) | **Next**: [Resources](04-resources.md) | **Index**: [README](README.md)
