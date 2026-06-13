# FastMCP Integration Summary

## What is MCP & Integration

**Model Context Protocol (MCP)** is a standardized interface enabling LLMs to interact with external tools, data sources, and APIs. **FastMCP 2.13.x** is a Python library providing a Pythonic decorator-based API for building MCP servers. NPL integrates FastMCP as the core transport layer: the unified MCP server in `src/npl_mcp/unified.py` registers all tools via FastMCP decorators and exports an ASGI app that handles STDIO, HTTP, and SSE transports.

## Tools Exposed

The NPL MCP server exposes **multiple tool categories** across five domains:

- **Documentation Tools** (~4): init-project, init-project-fast, update-arch, update-layout
- **Chat & Messaging** (~3): send-message, create-room, react-to-message
- **Artifacts & Versioning** (~4): create-artifact, update-artifact, view-history, compare-versions
- **Task Management** (~5): create-task, update-status, assign-complexity, link-artifact, pick-from-queue
- **Browser & Screenshots** (~6): capture-screenshot, annotate, navigate, inject-scripts, compare-screenshots
- **Agent Coordination** (~3): delegate-task, request-review, monitor-progress

**Total: ~25-30 tools** organized by functional domain. Each tool has auto-generated JSON schema from Python type hints. Tools support async execution, context injection, and streaming for long-running operations.

## Deployment Model

**Server Architecture**:
- **Unified ASGI App** (`npl_mcp/unified.py`) registers all FastMCP tools and returns a single ASGI application
- **Launcher** (`npl_mcp/launcher.py`) orchestrates process management: PID files, singleton detection, Uvicorn startup
- **Multiple Transports**: STDIO (default, Claude Desktop), HTTP/streamable-HTTP (web clients), SSE (streaming)
- **Web Routing** (`npl_mcp/web/app.py`): FastAPI mounts the MCP SSE endpoint at `/sse` and serves optional Next.js UI from `static/`

Deployment modes: (1) **Development**: `uv run src/mcp.py` for hello-world; `uv run -m npl_mcp.launcher` for full server. (2) **Production**: Docker container with Uvicorn, reverse proxy handling auth. (3) **Embedded**: ASGI app can be mounted in any FastAPI application.

## Identified Gaps

1. **Resource Templates**: FastMCP supports `@mcp.resource` decorators but NPL has not yet exposed resources (data endpoints) for things like project context, artifact libraries, or configuration files. These would enable LLMs to *read* persistent data without tool calls.

2. **Prompts & Templates**: FastMCP supports `@mcp.prompt` decorators for reusable prompt templates, but NPL has not exposed any. Adding prompts for common tasks (e.g., "code-review", "document-template") could reduce redundant instructions.

3. **Tool Composition**: FastMCP allows server proxying and composition, but the current unified server treats all tools as monolithic. Decomposing into sub-servers (docs-server, chat-server, task-server) could improve isolation, testing, and independent scaling.

4. **Error Recovery & Retry**: Tools have basic error handling, but no built-in retry logic with exponential backoff for transient failures (e.g., database locks, network timeouts).

5. **Versioning & Deprecation**: Tool schemas lack explicit versioning markers; adding `@deprecated` support and migration guides for breaking changes would help with long-term maintenance.

6. **Observability**: Limited built-in metrics; adding OpenTelemetry hooks for tool latency, error rates, and request tracing would enable production monitoring.
