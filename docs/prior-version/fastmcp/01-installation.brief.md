# FastMCP Installation

**Type**: Documentation Guide
**Category**: fastmcp
**Status**: Core

## Purpose

This guide provides comprehensive setup instructions for FastMCP 2.x, a Python framework for building Model Context Protocol (MCP) servers with enterprise features. It covers installation via modern package managers (uv/pip), version compatibility constraints, dependency management, and migration paths from earlier versions. The guide ensures developers can quickly establish a working FastMCP environment and understand critical version pinning requirements for production deployments.

FastMCP 2.x exists as an independent project separate from the MCP SDK's built-in FastMCP 1.0, offering advanced capabilities like server composition, OpenAPI generation, OAuth2 authentication, and deployment tooling. This guide addresses common installation pitfalls and provides clear migration paths for existing MCP SDK users.

## Key Capabilities

- **Flexible installation methods** supporting both `uv` (recommended) and traditional `pip` workflows
- **Version constraint management** with explicit MCP SDK compatibility matrix
- **Optional dependency groups** for OpenAI SDK integration and other extensions
- **Development setup guidance** for contributors with editable installs
- **Quick verification** commands to validate installation success
- **Migration documentation** for transitioning from MCP SDK built-in FastMCP 1.0

## Usage & Integration

- **Triggered by**: Developer need to set up FastMCP environment for MCP server development
- **Outputs to**: Working FastMCP 2.x installation with CLI tools and Python package
- **Complements**: FastMCP core concepts documentation and quickstart guides

Installation is the prerequisite step before any FastMCP server development. The guide integrates with the broader FastMCP documentation ecosystem, linking to core concepts and providing immediate next steps via the hello-world quickstart example.

## Core Operations

### Primary Installation (uv - Recommended)
```bash
uv add fastmcp
```

### Alternative Installation (pip)
```bash
pip install fastmcp
```

### Installation Verification
```bash
fastmcp version
# Expected output:
# FastMCP version: 2.13.x
# MCP version: 1.23.x
# Python: 3.12.x
```

### Quick Validation Server
```python
# server.py
from fastmcp import FastMCP

mcp = FastMCP("My Server")

@mcp.tool
def greet(name: str) -> str:
    """Greet someone by name."""
    return f"Hello, {name}!"

if __name__ == "__main__":
    mcp.run()
```

Run via:
```bash
python server.py
# or
fastmcp run server.py:mcp
```

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| Python version | Runtime environment | None | 3.10+ required, 3.12+ recommended |
| MCP SDK version | Protocol compatibility | `>1.23.1` | Current FastMCP 2.13.x constraint |
| Package extras | Optional dependencies | None | Use `[openai]` for OpenAI SDK support |
| Version pinning | Production stability | Latest | Use exact pins (e.g., `fastmcp==2.13.3`) in production |

### MCP SDK Version Compatibility Matrix

| FastMCP Version | MCP SDK Constraint | Rationale |
|:----------------|:-------------------|:----------|
| 2.13.x+ (current) | `mcp>1.23.1` | Full 11/25/25 protocol support |
| 2.12.x | `mcp<1.23` | OAuth patch incompatibility |
| 2.12.5 | `mcp<1.17` | `.well-known` endpoint issue |
| All versions | excludes `1.21.1` | Integration test failures |

## Integration Points

- **Upstream dependencies**: Python 3.10+, uv or pip package manager
- **Downstream consumers**: FastMCP servers, CLI tools (`fastmcp` command), MCP clients
- **Related utilities**: Core dependencies include `httpx>=0.28.1`, `pydantic>=2.11.7`, `uvicorn>0.35`, `mcp>1.23.1`

The installation integrates with the FastMCP ecosystem by providing both library imports (`from fastmcp import FastMCP`) and CLI utilities (`fastmcp run`, `fastmcp version`). Development installations enable editable mode for contribution workflows.

## Limitations & Constraints

- **MCP SDK version exclusions**: Specific MCP SDK versions (e.g., 1.21.1) are excluded due to compatibility issues
- **Python version floor**: Requires Python 3.10 minimum; older Python versions unsupported
- **httpx version dependency**: FastMCP 2.13.x strictly requires `httpx>=0.28.1` due to `TransportError` API changes
- **Licensing consideration**: Cyclopts v4 includes `docutils` with complex licensing; use v5.0.0a1+ for strict compliance scenarios

## Success Indicators

- `fastmcp version` command executes without errors and displays version information
- Python import succeeds: `from fastmcp import FastMCP` does not raise ImportError
- Quick validation server runs and responds to tool invocations
- No version conflict warnings from package manager during installation

---
**Generated from**: worktrees/main/docs/fastmcp/01-installation.md
