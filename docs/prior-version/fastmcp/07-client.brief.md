# FastMCP Client

**Type**: Library Component
**Category**: fastmcp
**Status**: Core

## Purpose

The FastMCP Client provides a flexible, transport-agnostic interface for connecting to and interacting with MCP servers in FastMCP 2.x. It abstracts away connection complexity through automatic transport detection while offering explicit control when needed. The client supports HTTP/SSE, Stdio, and in-memory transports, making it suitable for production deployments, testing, and multi-server architectures.

## Key Capabilities

- **Transport auto-detection** - Automatically selects appropriate transport based on source (file path, URL, or server instance)
- **Multi-server support** - Connect to multiple MCP servers simultaneously with automatic tool prefixing
- **Structured tool responses** - Returns typed response objects with content and error handling (v2.10+)
- **Resource management** - Access static and templated resources with URI-based addressing
- **Authentication** - Built-in OAuth flow support with automatic token management
- **Testing utilities** - In-memory transport for fast, isolated unit tests

## Usage & Integration

- **Triggered by**: Client applications, test suites, orchestration scripts
- **Outputs to**: Application layer, testing frameworks, logging systems
- **Complements**: FastMCP server, transports (HTTP, SSE, Stdio), authentication providers

## Core Operations

### Basic Connection
```python
import asyncio
from fastmcp import Client

client = Client("http://localhost:8000/mcp")

async def main():
    async with client:
        result = await client.call_tool("greet", {"name": "World"})
        print(result.content)

asyncio.run(main())
```

### Auto-Detection by Source
```python
# Python file -> Stdio transport
client = Client("my_server.py")

# HTTP URL -> HTTP transport
client = Client("http://localhost:8000/mcp")

# Server instance -> In-memory transport
client = Client(mcp_server)
```

### Explicit Transport Selection
```python
from fastmcp.client.transports import StreamableHttpTransport

async with Client(StreamableHttpTransport("http://localhost:8000/mcp")) as c:
    tools = await c.list_tools()
```

### Multi-Server Configuration
```python
config = {
    "mcpServers": {
        "weather": {"url": "https://weather-api.example.com/mcp"},
        "calendar": {"command": "python", "args": ["./calendar.py"]}
    }
}

client = Client(config)

async with client:
    forecast = await client.call_tool("weather_get_forecast", {"city": "London"})
    events = await client.call_tool("calendar_list_events", {})
```

## Configuration & Parameters

| Method | Purpose | Key Parameters | Notes |
|--------|---------|----------------|-------|
| `call_tool()` | Execute server tool | `name`, `arguments` | Returns structured response with `.content` and `.is_error` |
| `list_tools()` | Get available tools | None | Returns list of tool definitions |
| `read_resource()` | Fetch resource content | `uri` | Supports templated URIs like `users://{id}/profile` |
| `list_resources()` | List static resources | None | Excludes templates |
| `list_resource_templates()` | List URI templates | None | Shows available template patterns |
| `get_prompt()` | Retrieve prompt | `name`, `arguments` | Returns formatted prompt with variables filled |
| `list_prompts()` | Get available prompts | None | Returns prompt definitions |
| `ping()` | Health check | None | Verifies server connectivity |

## Integration Points

- **Upstream dependencies**: MCP server, transport implementation, authentication provider
- **Downstream consumers**: Application logic, test assertions, orchestration workflows
- **Related utilities**: Transport classes (SSETransport, PythonStdioTransport, FastMCPTransport, StreamableHttpTransport), exception handlers (ClientError, ToolError)

## Limitations & Constraints

- OAuth authentication triggers browser flow; not suitable for headless environments without token caching
- Multi-server tool names are prefixed by server name; requires namespace awareness in calling code
- Structured response objects (v2.10+) require accessing `.content` attribute; breaking change from earlier versions
- Resource reading returns heterogeneous content types (text, blob); requires type checking in consumers

## Success Indicators

- Client successfully establishes connection (verified via `initialize_result.server_info`)
- Tool calls return results without raising exceptions
- Resource URIs resolve correctly, including templated patterns
- Multi-server configuration correctly prefixes tool names by server

---
**Generated from**: worktrees/main/docs/fastmcp/07-client.md
