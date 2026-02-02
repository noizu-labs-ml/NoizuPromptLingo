# FastMCP Documentation

**Type**: Documentation Index
**Category**: Framework Reference
**Status**: Core

## Purpose

FastMCP is a Python framework for building Model Context Protocol (MCP) servers. This documentation index serves as the primary entry point for developers implementing MCP servers using FastMCP 2.x. It provides a structured roadmap through installation, core concepts, feature implementation, and production deployment with progressive examples ranging from simple hello-world tools to complex server architectures.

The documentation emphasizes FastMCP's Pythonic API design, leveraging decorators and type hints to simplify server development. It supports multiple transport mechanisms (stdio, SSE, HTTP) and provides automatic schema generation from Python type annotations, reducing boilerplate while maintaining MCP specification compliance.

## Key Capabilities

- **Progressive documentation structure** covering installation through production deployment
- **Automatic schema generation** from Python type annotations
- **Multiple transport support** (stdio, SSE, HTTP) with unified API
- **Server composition** for modular architecture
- **Context management** with dependency injection and lifespan hooks
- **Version compatibility matrix** for Python and MCP SDK versions

## Usage & Integration

- **Triggered by**: Developers building MCP servers in Python
- **Outputs to**: FastMCP server implementations, client integrations, production deployments
- **Complements**: Official FastMCP website (gofastmcp.com), GitHub repository, changelog

The documentation is organized as a linear progression:
1. Setup and installation → 2. Core concepts → 3. Feature implementation (tools, resources, prompts) → 4. Advanced features (context, client) → 5. Production deployment

## Core Operations

```python
from fastmcp import FastMCP

mcp = FastMCP("My Server")

@mcp.tool()
def hello(name: str) -> str:
    """Greet someone by name."""
    return f"Hello, {name}!"

if __name__ == "__main__":
    mcp.run()
```

Minimal server setup requires:
1. Import FastMCP
2. Create server instance
3. Define tools/resources/prompts via decorators
4. Run server

## Configuration & Parameters

| Document | Coverage | Focus Area |
|----------|----------|------------|
| 01-installation.md | Setup, requirements, version pinning | Dependencies, environment setup |
| 02-core-concepts.md | Servers, tools, resources, prompts | MCP primitives overview |
| 03-tools.md | Tool definitions, decorators, parameters | Function exposure as tools |
| 04-resources.md | Resource handling and templates | Data/content serving |
| 05-prompts.md | Prompt definitions and usage | Prompt template patterns |
| 06-context.md | Context, dependencies, lifespan | State management, DI |
| 07-client.md | Client usage patterns | Consumer integration |
| 08-deployment.md | Auth, security, production | Deployment best practices |
| 09-migration.md | Breaking changes, upgrade guides | Version transitions |
| 10-examples.md | Progressive examples (simple to complex) | Implementation patterns |

## Integration Points

- **Upstream dependencies**: Python 3.10+, MCP SDK (version-specific compatibility)
- **Downstream consumers**: MCP clients, Claude Desktop, custom integrations
- **Related utilities**: FastAPI (for HTTP/SSE transport), Pydantic (schema validation)

**Version compatibility**:
- FastMCP 2.13.x+ requires Python 3.10+ and MCP SDK >1.23.1
- FastMCP 2.12.x-2.13.0 requires MCP SDK <1.23
- All versions exclude mcp==1.21.1 (compatibility issues)

## Limitations & Constraints

- **Version-specific SDK requirements** necessitate careful dependency pinning
- **No 2.14 documentation** yet (upcoming release)
- **Breaking changes** between major versions require migration guides (see 09-migration.md)
- **Documentation version lag** (last updated 2025-12, current version 2.13.x)

## Success Indicators

- Developer can install and run minimal server within 5 minutes
- Type hints generate correct JSON schemas automatically
- Server deploys to production with auth/security enabled
- Migration guides prevent breaking changes during upgrades

---
**Generated from**: worktrees/main/docs/fastmcp/README.md
