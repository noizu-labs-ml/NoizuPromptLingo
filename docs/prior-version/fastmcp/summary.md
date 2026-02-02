# FastMCP - Big Picture Overview

## What is FastMCP?

FastMCP is a Python framework for building Model Context Protocol (MCP) servers that enable Large Language Models to interact with external systems, data sources, and APIs. It provides a decorator-based programming model that leverages Python's type hints to automatically generate schemas, handle validation, and manage the communication protocol between LLMs and your application logic. FastMCP abstracts the complexity of the MCP specification into a familiar Pythonic interface, allowing developers to focus on implementing business logic rather than protocol mechanics.

FastMCP 2.x exists as an independent project separate from the MCP SDK's built-in FastMCP 1.0, offering production-grade features like server composition, OAuth 2.1 authentication, OpenAPI integration, and multiple transport mechanisms. Whether you're building a simple tool for Claude Desktop integration or deploying a complex multi-server architecture in production, FastMCP scales from minimal local servers to enterprise deployments with authentication, monitoring, and reliability patterns.

The framework is designed for rapid development cycles while maintaining type safety and protocol compliance. With support for synchronous and asynchronous operations, context injection, progress reporting, and resource management, FastMCP handles the infrastructure concerns so you can deliver MCP capabilities quickly and reliably.

## Learning Path

The recommended sequence for learning FastMCP progresses from local development to production deployment:

1. **Installation and environment setup** → Start with [01-installation.brief.md] to install FastMCP 2.x via `uv` or `pip`, understand version constraints, and verify your environment with a hello-world server.

2. **Core concepts and MCP primitives** → Read [02-core-concepts.brief.md] to understand the server container, tools, resources, prompts, and the MCP programming model that underlies all FastMCP features.

3. **Tool implementation** → Study [03-tools.brief.md] to learn decorator-based tool registration, type validation, async operations, and context injection for executing actions on behalf of LLMs.

4. **Resource and data serving** → Explore [04-resources.brief.md] for exposing read-only data through static URIs and dynamic templates, enabling LLMs to query information without performing actions.

5. **Client integration and testing** → Review [07-client.brief.md] to understand transport auto-detection, multi-server configuration, and testing patterns using the FastMCP client.

6. **Context, state management, and lifecycle** → Master [06-context.brief.md] for request-scoped logging, progress reporting, lifespan management, and shared resource patterns across server requests.

7. **Production deployment** → Implement authentication, containerization, and transport configuration from [08-deployment.brief.md] to transition from STDIO development to HTTP production deployments.

8. **Practical patterns and examples** → Work through [10-examples.brief.md] for progressive complexity examples from minimal servers to production-ready architectures with all features integrated.

## Core Concepts at a Glance

| Concept | Description | Key Feature |
|---------|-------------|-------------|
| **Server** | Container orchestrating MCP components | Manages tools, resources, prompts via `FastMCP()` instance |
| **Tools** | Callable functions exposed to LLMs | Decorator-based registration with automatic schema generation |
| **Resources** | Read-only data endpoints with URI templates | Static and dynamic data serving without computation |
| **Prompts** | Reusable LLM conversation templates | Parameterized message generation with multi-turn support |
| **Context** | Request-scoped utilities and metadata | Logging, progress reporting, resource access per request |
| **Lifespan** | Server-level startup/shutdown management | Shared resource initialization (databases, connections) |
| **Transports** | Communication layers (STDIO, HTTP, SSE) | STDIO for development, HTTP/Streamable HTTP for production |
| **Authentication** | OAuth 2.1 providers and JWT verification | GitHub, Google, Azure providers with PKCE support |

## Key Components

| Component | Purpose | When to Use |
|-----------|---------|------------|
| **@mcp.tool decorator** | Exposes Python functions as MCP tools | Whenever LLMs need to execute actions or computations |
| **@mcp.resource decorator** | Serves data via URI patterns | For read-only data access (configs, database queries, API results) |
| **@mcp.prompt decorator** | Creates reusable prompt templates | To standardize common LLM interaction patterns |
| **Context injection** | Provides request metadata and utilities | For logging, progress reporting, or accessing request state |
| **CurrentContext()** | Dependency injection for context | Use instead of type hints (v2.14+ recommended pattern) |
| **Lifespan management** | Handles startup/shutdown lifecycle | Initialize shared resources like database pools once per server |
| **FastMCP.as_proxy()** | Composes multiple servers | Aggregate multiple MCP services into single gateway |
| **Client class** | Connects to MCP servers programmatically | For testing, orchestration, or building custom MCP clients |
| **TokenVerifier** | Validates JWT tokens | Simplest auth for existing identity infrastructure |
| **OAuth Providers** | Implements OAuth 2.1 flows | For GitHub, Google, Azure authentication without external systems |

## Implementation Workflow

1. **Setup environment** → Install FastMCP via `uv add fastmcp` or `pip install fastmcp`, verify with `fastmcp version`, and ensure Python 3.10+ compatibility. See [01-installation.brief.md].

2. **Define server and tools** → Create FastMCP instance, use `@mcp.tool` decorator on functions with type hints, and leverage Pydantic models for complex inputs. See [03-tools.brief.md].

3. **Add resources and prompts** → Register data endpoints with `@mcp.resource` using URI templates, create conversation starters with `@mcp.prompt`. See [04-resources.brief.md] and [05-prompts.brief.md].

4. **Integrate context and lifecycle** → Inject `Context` via `CurrentContext()` for logging/progress, implement lifespan for database connections and shared state. See [06-context.brief.md].

5. **Deploy to production** → Configure authentication (JWT or OAuth providers), switch to `streamable-http` transport, containerize with Docker, and implement health checks. See [08-deployment.brief.md].

## Common Patterns & Examples

- **Async operations with progress reporting**: Use `async def` tools with `Context.report_progress()` to track long-running operations like API calls or database queries (Example Level 3).

- **Structured validation with Pydantic**: Define `BaseModel` subclasses for complex tool parameters and return types, enabling automatic validation and schema generation (Example Level 4).

- **Database connection management**: Use lifespan async context manager to initialize connection pools once per server, access via `get_lifespan_state()` in tools (Example Level 5).

- **Server composition for microservices**: Aggregate multiple specialized MCP servers using `import_server()` with prefixes, creating a unified gateway for diverse capabilities (Example Level 6).

- **Production authentication patterns**: Implement OAuth 2.1 with GitHub/Google providers or use TokenVerifier for existing JWT infrastructure, enforce HTTPS in production (Example Level 7, 10).

- **Client testing workflows**: Use `Client(mcp_instance)` with in-memory transport for fast unit tests, eliminating network overhead and enabling isolated test scenarios (Examples Level 7-8).

- **OpenAPI integration**: Mount FastMCP on existing FastAPI apps with `from_openapi()`, mapping HTTP routes to MCP tools and resources with `RouteMap` configurations (Example Level 9).

## Migration & Upgrades

When upgrading FastMCP versions, key compatibility considerations include:

- **FastMCP 2.13.x+** requires `mcp>1.23.1` (OAuth compatibility restored), use for new projects.
- **FastMCP 2.12.x-2.13.0** requires `mcp<1.23` due to OAuth patch incompatibilities.
- **Breaking change in v2.13.0**: Lifespan runs once per server, not per client session. Use middleware for session-specific initialization instead of lifespan hooks.
- **Constructor deprecation (v2.3.4+)**: Moved configuration to `mcp.run()` method. Replace `FastMCP("Server", port=8000)` with `mcp.run(port=8000)`.
- **SSE transport deprecated**: MCP spec (2025-03-26) mandates `streamable-http` for production, `sse` transport support is legacy only.
- **Import path change (1.x → 2.0)**: Switch from `mcp.server.fastmcp` to `fastmcp` package imports.

See [09-migration.brief.md] for detailed upgrade checklists and code examples for each breaking change.

## Quick Start

Get running in 5 minutes:

1. **Install**: `uv add fastmcp` (or `pip install fastmcp`)
2. **Create server.py**:
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
3. **Run**: `python server.py` or `fastmcp run server.py:mcp`
4. **Connect**: Configure in Claude Desktop or test with FastMCP client

For production deployment, see the implementation workflow above and [08-deployment.brief.md].

## Integration with Claude

FastMCP servers integrate with Claude through the Model Context Protocol. Claude Desktop supports STDIO transport for local development, requiring configuration in Claude's MCP settings with the command path to your server script. For web-based Claude interfaces, deploy servers with HTTP/Streamable HTTP transport and OAuth 2.1 authentication.

The MCP protocol enables Claude to:
- **Discover available tools** via `tools/list` requests, displaying them in the chat interface
- **Execute tool calls** with typed parameters, receiving validated responses
- **Access resources** through URI patterns, querying data without executing actions
- **Use prompts** to initialize conversations with standardized templates

FastMCP's automatic schema generation from Python type hints ensures Claude receives accurate tool signatures, descriptions, and parameter constraints, enabling effective autonomous tool usage during conversations.

## Next Steps

Navigate to relevant documentation based on your goal:

- **Want to get started?** → See [01-installation.brief.md] for setup and verification
- **Need to understand the architecture?** → See [02-core-concepts.brief.md] for MCP primitives
- **Building tools for LLMs?** → See [03-tools.brief.md] for decorator patterns and validation
- **Serving data or content?** → See [04-resources.brief.md] for resource templates
- **Creating conversation templates?** → See [05-prompts.brief.md] for prompt patterns
- **Managing state and logging?** → See [06-context.brief.md] for context injection and lifespan
- **Building a client or testing?** → See [07-client.brief.md] for client patterns
- **Deploying to production?** → See [08-deployment.brief.md] for auth, containers, security
- **Upgrading versions?** → See [09-migration.brief.md] for breaking changes and compatibility
- **Learning by example?** → See [10-examples.brief.md] for progressive complexity demos

---
**Synthesized from**: 11 FastMCP briefs + source documentation
