# FastMCP Summary

## Overview
FastMCP is a lightweight, production-ready framework for building Model Context Protocol (MCP) servers with Python and FastAPI. It enables seamless integration between Claude AI and external tools through a standardized protocol.

## Key Characteristics

### Architecture
- **Protocol**: Model Context Protocol (MCP)
- **Framework**: FastAPI + MCP SSE endpoint
- **Language**: Python
- **Entry Points**:
  - `src/mcp.py` - Minimal hello-world FastMCP server for quick experiments
  - `src/npl_mcp/launcher.py` - Full NPL MCP server entry point
  - Console script: `npl-mcp` (defined in `pyproject.toml`)

### Technology Stack
- **Web Server**: Uvicorn (ASGI server)
- **API Framework**: FastAPI
- **Build Tool**: uv (Python package manager)
- **Deployment**: Docker, Kubernetes, or standalone
- **Database**: SQLite (storage layer)

## Core Packages (src/npl_mcp/)

| Package | Purpose |
|:--------|:---------|
| `unified.py` | Builds FastMCP instance with all tool definitions; returns ASGI app |
| `launcher.py` | Orchestrates process management, singleton detection, CLI flags |
| `storage/` | SQLite wrapper and schema migrations |
| `artifacts/` | Versioned artifact management |
| `reviews/` | Review workflow abstractions |
| `chat/` | Chat room abstractions |
| `sessions/` | Session grouping and management |
| `tasks/` | Task queue abstractions |
| `browser/` | Headless browser interactions (screenshots, navigation) |
| `web/` | FastAPI routes for web UI, APIs, session pages |

## Tool Types

FastMCP enables these types of tools:

### File Operations
- Read files with context limits
- Search file contents (ripgrep)
- Create/modify files
- Glob pattern matching

### Command Execution
- Run bash commands
- Control timeout and environment
- Capture output

### Web Operations
- WebFetch - Get and analyze web content
- WebSearch - Search the web
- Browser automation (headless)

### Task Management
- Create/track tasks
- Update task status
- Multi-agent task orchestration

## Server Architecture

```
┌─────────────────────────────────────────────────────────┐
│                FastAPI Application                      │
├─────────────────────────────────────────────────────────┤
│  MCP Endpoint (/sse)                                    │
│  ├─ Tool definitions (read, write, grep, glob, etc.)   │
│  └─ Request/response handling                          │
├─────────────────────────────────────────────────────────┤
│  Web UI Routes                                          │
│  ├─ Session pages                                       │
│  ├─ Chat rooms                                          │
│  └─ API endpoints                                       │
├─────────────────────────────────────────────────────────┤
│  Storage Layer                                          │
│  └─ SQLite database with migrations                     │
└─────────────────────────────────────────────────────────┘
```

## Running the Server

### Minimal Server
```bash
# Quick prototyping with hello tool
uv run src/mcp.py
```

### Full NPL Server
```bash
# Production-ready server
uv run -m npl_mcp.launcher

# Or via console script (after editable install)
npl-mcp

# With CLI options
npl-mcp --status              # Check server status
npl-mcp --stop                # Stop server
npl-mcp --config path/to.yml  # Use custom config
npl-mcp --test                # Test mode
```

### Development Server
```bash
# Install in editable mode
uv sync --editable

# Now you can use console script directly
npl-mcp
```

## Process Management

### Launcher Features
- **PID File Management**: Tracks singleton instance
- **Singleton Detection**: Prevents multiple instances
- **Graceful Shutdown**: Clean process termination
- **Status Checking**: Query server health
- **Configuration Loading**: YAML/JSON config support

### Typical Lifecycle
```
User invokes: npl-mcp
    ↓
Launcher checks PID file (singleton check)
    ↓
If running: return status or --stop
If not: start Uvicorn server
    ↓
Server starts listening on configured port
    ↓
Claude connects to /sse endpoint
    ↓
Tools become available for Claude to invoke
```

## Tool Integration with Claude

### Tool Definition Pattern
```python
@mcp.tool()
def tool_name(param1: str, param2: int) -> str:
    """Tool description for Claude"""
    # Implementation
    return result
```

### Claude Invocation
Claude sees tools via `/sse` endpoint and can:
1. List available tools: `tools/list`
2. Invoke tools: `tools/call`
3. Handle tool results
4. Chain multiple tool calls

## Frontend (Optional)

### Web UI
- Located in `worktrees/main/mcp-server/frontend` (Next.js)
- Built with: `npm install && npm run build`
- Output: Static files to `src/npl_mcp/web/static/`
- Mounted by FastAPI at root `/`

### Features
- Session dashboard
- Chat room interface
- Artifact viewer
- Task tracking
- Real-time updates

## Configuration

### Runtime Configuration
```python
# src/npl_mcp/web/app.py
config = {
    "host": "0.0.0.0",
    "port": 8000,
    "workers": 4,
    "reload": False,
    "log_level": "info"
}
```

### Database Configuration
- SQLite path: `src/npl_mcp/storage/db.sqlite`
- Migrations: `src/npl_mcp/storage/migrations/`
- Schema management: Automatic on startup

## Deployment Patterns

### Local Development
```bash
uv sync --editable
npl-mcp
# Server runs on localhost:8000
```

### Docker Container
```bash
# Build with Dockerfile
docker build -t npl-mcp .

# Run container
docker run -p 8000:8000 npl-mcp
```

### Kubernetes
```bash
# Deploy via helm or kubectl manifests
# See infrastructure/ directory for deployment configs
```

## Testing

```bash
# Unit tests
uv run -m pytest

# Single test file
uv run -m pytest path/to/test_file.py

# With coverage
uv run -m pytest --cov=src/npl_mcp

# Run in test mode
npl-mcp --test
```

## Key Files

| File | Purpose |
|:-----|:---------|
| `src/mcp.py` | Minimal hello-world MCP server |
| `src/npl_mcp/launcher.py` | Main entry point and CLI |
| `src/npl_mcp/unified.py` | FastMCP instance builder |
| `src/npl_mcp/web/app.py` | FastAPI application |
| `pyproject.toml` | Package definition, dependencies, scripts |
| `Dockerfile` | Container image definition |

## Integration Points

### with Python Ecosystem
- Uses `uv` for dependency management
- Compatible with standard Python packages
- Virtual environment management built-in

### with MCP Protocol
- Implements Model Context Protocol spec
- SSE (Server-Sent Events) for real-time updates
- JSON-RPC message format

### with Storage
- SQLite for structured data
- File-based artifact storage
- Session persistence

## Development Workflow

1. **Sync dependencies**: `uv sync`
2. **Edit code**: All source in `src/npl_mcp/`
3. **Run locally**: `uv run src/mcp.py` or `npl-mcp`
4. **Test changes**: `uv run -m pytest`
5. **Build for release**: `uv build`

## Performance Considerations

- **Connection pooling**: SQLite with connection limits
- **Request handling**: Async/await throughout
- **Memory**: Efficient tool definition loading
- **Scaling**: Horizontal via load balancer + multiple instances

## Security

- **Authentication**: Via Claude's authentication system
- **Tool Restrictions**: Per-agent tool access control
- **File Access**: Respects system permissions and .gitignore
- **Secrets**: Stored in environment variables, not in code

## Key Insight

FastMCP provides a clean, minimal abstraction over the Model Context Protocol. It handles the plumbing of request/response, tool registration, and server lifecycle, allowing developers to focus on implementing tools that extend Claude's capabilities. The plugin-like architecture enables easy addition of new tools without modifying core framework code.

## Resources

- **Package**: `pyproject.toml` defines entry points and dependencies
- **Documentation**: Inline docstrings and example tools
- **Configuration**: `.env` files for local development
- **Deployment**: Docker/Kubernetes configs in `infrastructure/`
