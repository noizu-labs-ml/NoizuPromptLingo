# FastMCP Installation

> Setup, requirements, and version management for FastMCP 2.x

## Requirements

- **Python**: 3.10+ (3.12+ recommended)
- **Package Manager**: uv (recommended) or pip

## Installation

### Using uv (Recommended)

```bash
# Add to project
uv add fastmcp

# Or install directly
uv pip install fastmcp
```

### Using pip

```bash
pip install fastmcp
```

### With Optional Dependencies

```bash
# OpenAI SDK support
pip install fastmcp[openai]

# Or with uv
uv add fastmcp --extra openai
```

### Verify Installation

```bash
fastmcp version
```

Expected output:
```
FastMCP version: 2.13.x
MCP version: 1.23.x
Python: 3.12.x
```

## MCP SDK Version Compatibility

FastMCP has specific MCP SDK version constraints due to protocol changes:

| FastMCP Version | MCP SDK Constraint | Notes |
|:----------------|:-------------------|:------|
| 2.13.x+ (current) | `mcp>1.23.1` | Full 11/25/25 protocol support |
| 2.12.x | `mcp<1.23` | OAuth patch incompatibility |
| 2.12.5 | `mcp<1.17` | `.well-known` endpoint issue |
| All versions | excludes `1.21.1` | Integration test failures |

### Production Version Pinning

For production deployments, use exact version pins:

```toml
# pyproject.toml - Recommended
dependencies = [
    "fastmcp==2.13.3",
]

# NOT recommended (may introduce breaking changes)
dependencies = [
    "fastmcp>=2.13.0",
]
```

## Core Dependencies

FastMCP 2.13.x includes these core dependencies:

```
httpx>=0.28.1
pydantic[email]>=2.11.7
uvicorn>0.35
websockets>=15.0.1
authlib>=1.6.5
cyclopts>=4.0.0
mcp>1.23.1
```

### Cyclopts Licensing Note

Cyclopts v4 includes `docutils` (complex licensing). For strict compliance:

```bash
pip install "cyclopts>=5.0.0a1"
```

## Quick Start

Create `server.py`:

```python
from fastmcp import FastMCP

mcp = FastMCP("My Server")

@mcp.tool
def greet(name: str) -> str:
    """Greet someone by name."""
    return f"Hello, {name}!"

if __name__ == "__main__":
    mcp.run()
```

Run the server:

```bash
# Direct execution
python server.py

# Or via FastMCP CLI
fastmcp run server.py:mcp
```

## Migration from MCP SDK FastMCP 1.0

FastMCP 1.0 was incorporated into the MCP Python SDK. To migrate to FastMCP 2.x:

```python
# Before (MCP SDK built-in)
from mcp.server.fastmcp import FastMCP

# After (FastMCP 2.x)
from fastmcp import FastMCP
```

### Why Migrate?

FastMCP 2.x provides:
- Server composition and proxying
- OpenAPI/FastAPI generation
- Tool transformation
- Enterprise auth (Google, GitHub, WorkOS, Azure, Auth0)
- Deployment tools
- Testing utilities

## Common Issues

### httpx Compatibility

**Symptom**: `TransportError` import failure

**Solution**: FastMCP 2.13.x requires `httpx>=0.28.1`

### MCP SDK Version Conflict

**Symptom**: OAuth or `.well-known` endpoint issues

**Solution**: Check versions match compatibility table:
```bash
pip show fastmcp mcp
```

### CLI Not Found

**Symptom**: `fastmcp: command not found`

**Solution**:
```bash
pip install fastmcp
# or
pipx install fastmcp
```

## Development Setup

For contributing to FastMCP:

```bash
git clone https://github.com/jlowin/fastmcp.git
cd fastmcp

# Using uv
uv venv && uv sync

# Or traditional
python -m venv venv
source venv/bin/activate
pip install -e ".[dev]"
```

---

**Next**: [Core Concepts](02-core-concepts.md) | **Index**: [README](README.md)
