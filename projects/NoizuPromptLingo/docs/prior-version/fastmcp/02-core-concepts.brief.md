# Core Concepts

**Type**: Documentation
**Category**: FastMCP
**Status**: Core

## Purpose

Core Concepts provides the foundational architecture for FastMCP 2.x, introducing the Model Context Protocol (MCP) implementation that enables LLMs to interact with external systems. This document defines the primary building blocks—servers, tools, resources, prompts, and context—that form FastMCP's standardized interface layer between AI models and application logic.

The concepts establish how developers structure MCP servers, expose callable functions to LLMs, provide data access through resources, create reusable prompt templates, and manage request-scoped state. Understanding these primitives is essential for building production FastMCP applications.

## Key Capabilities

- **Server Container**: FastMCP class orchestrates all MCP components with support for STDIO, HTTP, and streamable transports
- **Tool Definitions**: Decorator-based tool registration with automatic schema generation from type hints
- **Resource Access**: URI-templated resources for static and dynamic data provision to LLMs
- **Prompt Templates**: Reusable prompt definitions with parameter substitution
- **Context Management**: Request-scoped utilities for logging, state access, and lifecycle hooks
- **Type System**: Full Pydantic integration with configurable strict/coerce validation modes

## Usage & Integration

- **Triggered by**: Developers building MCP servers, imported via `from fastmcp import FastMCP`
- **Outputs to**: MCP clients (Claude Desktop, web clients, custom LLM integrations)
- **Complements**: All FastMCP feature modules (tools, resources, prompts, context)

The core concepts are mandatory reading for anyone implementing FastMCP servers. They define the programming model that all other features build upon.

## Core Operations

### Server Initialization
```python
from fastmcp import FastMCP

mcp = FastMCP("My Server")

@mcp.tool
def hello(name: str) -> str:
    """Greet someone."""
    return f"Hello, {name}!"

if __name__ == "__main__":
    mcp.run()  # Default: STDIO transport
```

### Running with Transports
```python
# HTTP transport for web clients
mcp.run(transport="http", port=8000)

# Streamable HTTP for production
mcp.run(transport="streamable-http", port=8000)
```

### CLI Execution
```bash
# Default transport
fastmcp run server.py:mcp

# HTTP with custom port
fastmcp run server.py:mcp --transport http --port 8000
```

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| `name` | Server identifier for MCP protocol | *required* | Shown to clients |
| `transport` | Communication layer (stdio/http/streamable-http) | `stdio` | STDIO for CLI, HTTP for web |
| `port` | HTTP server port | `8000` | Only applies to HTTP transports |
| `strict_input_validation` | Enforce exact type matching vs Pydantic coercion | `False` | Set `True` to reject `"10"` → `10` |
| `lifespan` | Async context manager for startup/shutdown | `None` | Runs once per server (v2.13+) |

## Integration Points

- **Upstream dependencies**: Python type system (type hints, Pydantic models)
- **Downstream consumers**: Tool, resource, prompt decorators; context utilities
- **Related utilities**: `@mcp.tool`, `@mcp.resource`, `@mcp.prompt`, `Context` class

All FastMCP features reference the server instance created via `FastMCP()`. The server acts as a registry for tools/resources/prompts and manages the transport layer for client communication.

## Limitations & Constraints

- Lifespan runs once per server, not per session (v2.13+)—session-specific setup requires alternative patterns
- STDIO transport limits server to single-client CLI usage (no concurrent connections)
- Type coercion default may surprise users expecting strict validation (requires explicit opt-in)
- Resource URI templates must follow specific syntax for parameter extraction

## Success Indicators

- Server starts without errors and responds to client `tools/list` requests
- Tools appear in LLM interfaces with correct names, descriptions, and schemas
- Resources respond to URI queries with expected data formats
- Transport layer handles client connections appropriately for chosen mode
- Context and lifespan hooks execute at expected lifecycle points

---
**Generated from**: worktrees/main/docs/fastmcp/02-core-concepts.md
