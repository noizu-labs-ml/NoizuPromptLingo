# Client

> Connecting to and interacting with MCP servers in FastMCP 2.x

## Basic Usage

```python
import asyncio
from fastmcp import Client

client = Client("http://localhost:8000/mcp")

async def main():
    async with client:
        # Call a tool
        result = await client.call_tool("greet", {"name": "World"})
        print(result)

asyncio.run(main())
```

## Transport Auto-Detection

The client automatically detects transport based on the source:

| Source | Transport |
|:-------|:----------|
| `server.py` | Python Stdio |
| `http://...` | HTTP |
| `FastMCP` instance | In-memory |

```python
# Python file -> Stdio transport
client = Client("my_server.py")

# HTTP URL -> HTTP transport
client = Client("http://localhost:8000/mcp")

# Server instance -> In-memory transport
from my_app import mcp_server
client = Client(mcp_server)
```

## Explicit Transport

```python
from fastmcp import Client
from fastmcp.client.transports import (
    SSETransport,
    PythonStdioTransport,
    FastMCPTransport,
    StreamableHttpTransport
)

# HTTP (recommended for production)
async with Client(StreamableHttpTransport("http://localhost:8000/mcp")) as c:
    tools = await c.list_tools()

# SSE (legacy)
async with Client(SSETransport("http://localhost:8000/mcp")) as c:
    tools = await c.list_tools()

# Stdio
async with Client(PythonStdioTransport("server.py")) as c:
    tools = await c.list_tools()

# In-memory (testing)
async with Client(FastMCPTransport(mcp_server)) as c:
    tools = await c.list_tools()
```

## Core Methods

### Tools

```python
async with client:
    # List available tools
    tools = await client.list_tools()

    # Call a tool
    result = await client.call_tool("add", {"a": 5, "b": 3})
    print(result.content)  # Access content
    print(result.is_error)  # Check for errors
```

### Resources

```python
async with client:
    # List resources
    resources = await client.list_resources()

    # List resource templates
    templates = await client.list_resource_templates()

    # Read a resource
    content = await client.read_resource("config://version")

    # Read templated resource
    profile = await client.read_resource("users://123/profile")
```

### Prompts

```python
async with client:
    # List prompts
    prompts = await client.list_prompts()

    # Get a prompt
    prompt = await client.get_prompt("code_review", {
        "language": "python",
        "code": "def hello(): pass"
    })
```

### Utilities

```python
async with client:
    # Ping server
    await client.ping()

    # Access initialization result
    init = client.initialize_result
    print(f"Server: {init.server_info.name}")
    print(f"Capabilities: {init.capabilities}")
```

## Return Value Changes (v2.10+)

Tool calls return structured response objects:

```python
# Before v2.10
result = await client.call_tool("my_tool", {"arg": "value"})
print(result)  # Direct value

# After v2.10
result = await client.call_tool("my_tool", {"arg": "value"})
print(result.content)   # Access content
print(result.is_error)  # Check for errors
```

## Authentication

```python
# OAuth (triggers browser flow)
client = Client("https://protected.com/mcp", auth="oauth")

async with client:
    # Token acquisition handled automatically
    result = await client.call_tool("protected_tool")
```

## Multi-Server Client

Connect to multiple servers:

```python
config = {
    "mcpServers": {
        "weather": {"url": "https://weather-api.example.com/mcp"},
        "calendar": {"command": "python", "args": ["./calendar.py"]}
    }
}

client = Client(config)

async with client:
    # Tools are prefixed by server name
    forecast = await client.call_tool("weather_get_forecast", {"city": "London"})
    events = await client.call_tool("calendar_list_events", {})
```

## Reading Resource Content

```python
content = await client.read_resource("files://data.txt")

for item in content:
    if hasattr(item, 'text'):
        print(item.text)
    elif hasattr(item, 'blob'):
        with open("output", "wb") as f:
            f.write(item.blob)
```

## Error Handling

```python
from fastmcp.exceptions import ClientError, ToolError

async with client:
    try:
        result = await client.call_tool("risky_tool", {})
    except ToolError as e:
        print(f"Tool error: {e}")
    except ClientError as e:
        print(f"Client error: {e}")
```

## Complete Example

```python
import asyncio
from fastmcp import Client

async def main():
    # Connect to server
    client = Client("http://localhost:8000/mcp")

    async with client:
        # Check server info
        print(f"Connected to: {client.initialize_result.server_info.name}")

        # List available tools
        tools = await client.list_tools()
        print(f"Available tools: {[t.name for t in tools]}")

        # Call a tool
        result = await client.call_tool("calculate", {
            "a": 10,
            "b": 5,
            "operation": "add"
        })

        if result.is_error:
            print(f"Error: {result.content}")
        else:
            print(f"Result: {result.content}")

        # Read a resource
        config = await client.read_resource("config://version")
        print(f"Version: {config}")

        # List and use prompts
        prompts = await client.list_prompts()
        if prompts:
            prompt = await client.get_prompt(prompts[0].name, {})
            print(f"Prompt: {prompt}")

asyncio.run(main())
```

## Testing with In-Memory Client

```python
from fastmcp import FastMCP, Client

# Create server
mcp = FastMCP("Test Server")

@mcp.tool
def add(a: int, b: int) -> int:
    return a + b

# Test with in-memory client
async def test():
    async with Client(mcp) as client:
        result = await client.call_tool("add", {"a": 5, "b": 3})
        assert result.content[0].text == "8"

import asyncio
asyncio.run(test())
```

---

**Previous**: [Context](06-context.md) | **Next**: [Deployment](08-deployment.md) | **Index**: [README](README.md)
