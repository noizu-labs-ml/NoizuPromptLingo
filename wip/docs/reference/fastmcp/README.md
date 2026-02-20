# FastMCP Documentation

> Comprehensive documentation for FastMCP 2.x - The fast, Pythonic way to build MCP servers.

**Current Version**: 2.13.x | **Upcoming**: 2.14

## Quick Start

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

## Documentation Index

| Document | Description |
|:---------|:------------|
| [Installation](01-installation.md) | Setup, requirements, version pinning |
| [Core Concepts](02-core-concepts.md) | Servers, tools, resources, prompts overview |
| [Tools](03-tools.md) | Tool definitions, decorators, parameters |
| [Resources](04-resources.md) | Resource handling and templates |
| [Prompts](05-prompts.md) | Prompt definitions and usage |
| [Context](06-context.md) | Context, dependencies, lifespan management |
| [Client](07-client.md) | Client usage patterns |
| [Deployment](08-deployment.md) | Auth, security, production deployment |
| [Migration](09-migration.md) | Breaking changes, upgrade guides |
| [Examples](10-examples.md) | Progressive examples (simple to complex) |

## Key Features

- **Pythonic API**: Decorators and type hints for intuitive development
- **Automatic Schema Generation**: From Python type annotations
- **Multiple Transports**: stdio, SSE, HTTP support
- **Composition**: Combine multiple servers
- **Context Management**: Dependency injection and lifespan hooks

## Version Compatibility

| FastMCP | Python | MCP SDK |
|:--------|:-------|:--------|
| 2.13.x+ | 3.10+ | >1.23.1 |
| 2.12.x-2.13.0 | 3.10+ | <1.23 |
| 2.14 (upcoming) | 3.10+ | >=1.23 |

**Note**: All versions exclude `mcp==1.21.1` due to compatibility issues.

## Resources

- [Official Documentation](https://gofastmcp.com)
- [GitHub Repository](https://github.com/jlowin/fastmcp)
- [Changelog](https://gofastmcp.com/changelog)

---

*Documentation generated for FastMCP 2.x. Last updated: 2025-12.*
