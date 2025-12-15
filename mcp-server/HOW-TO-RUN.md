# NPL MCP Server

MCP server with SSE transport, web UI, and 59 tools for artifacts, browser automation, sessions, and more.

## Install

```bash
cd mcp-server
uv pip install -e .
```

## Run Server

```bash
npl-mcp              # Start server (daemonized)
npl-mcp --status     # Check if running
npl-mcp --stop       # Stop server
npl-mcp --config     # Show Claude Code config
```

Or via Python module:
```bash
python -m npl_mcp.launcher
```

## Endpoints

- **SSE (MCP):** http://127.0.0.1:8765/sse
- **Web UI:** http://127.0.0.1:8765/

## Claude Code Configuration

Add to your MCP settings (`/mcp` in Claude Code):

```json
{
  "mcpServers": {
    "npl-mcp": {
      "url": "http://127.0.0.1:8765/sse"
    }
  }
}
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NPL_MCP_HOST` | 127.0.0.1 | Server host |
| `NPL_MCP_PORT` | 8765 | Server port |
| `NPL_MCP_DATA_DIR` | ./data | Data/database directory |

## Test Connection

```bash
npl-mcp --test
```

This connects via SSE, lists available tools, and runs a few test calls.
