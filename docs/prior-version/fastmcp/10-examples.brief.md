# Examples

**Type**: Documentation / Tutorial
**Category**: fastmcp
**Status**: Core

## Purpose

Provides progressive learning path from minimal server to production-ready FastMCP 2.x implementations through 10 complexity levels. Each example builds on previous concepts, demonstrating isolated features before integration. Designed as practical reference for developers implementing MCP servers with increasing sophistication.

## Key Capabilities

- Progressive complexity from hello-world to production servers
- Isolated feature demonstrations (async, auth, middleware, composition)
- Multiple integration patterns (Pydantic models, FastAPI composition, OpenAPI)
- Client and testing examples for end-to-end workflows
- Production deployment patterns with lifespan management and authentication
- Real-world patterns: context injection, progress reporting, database integration

## Usage & Integration

- **Triggered by**: Developer onboarding, feature implementation reference, architecture decisions
- **Outputs to**: Functional server implementations, test suites, client integrations
- **Complements**: FastMCP API documentation, migration guides, production deployment guides

## Core Operations

### Level 1: Minimal Server
```python
from fastmcp import FastMCP
mcp = FastMCP("Hello Server")

@mcp.tool
def hello(name: str) -> str:
    return f"Hello, {name}!"

if __name__ == "__main__":
    mcp.run()
```
**Run**: `fastmcp run hello.py:mcp`

### Level 3: Async with Context
```python
@mcp.tool
async def fetch_url(url: str, ctx: Context = CurrentContext()) -> dict:
    await ctx.info(f"Fetching: {url}")
    async with httpx.AsyncClient() as client:
        response = await client.get(url)
        await ctx.report_progress(1, 1, "Complete")
        return {"status": response.status_code}
```

### Level 6: Server Composition
```python
weather = FastMCP("Weather")
news = FastMCP("News")
main = FastMCP("Composite Server")

main.import_server(weather, prefix="weather")
main.import_server(news, prefix="news")
```

### Level 10: Production Server
Combines lifespan management, middleware, authentication, custom routes, and health checks.

## Configuration & Parameters

| Level | Features | Key Parameters | Use Case |
|-------|----------|----------------|----------|
| 1 | Basic tools | `@mcp.tool` decorator | Hello world |
| 2 | Multi-component | Tools + resources + prompts | Feature demonstration |
| 3 | Async + context | `Context`, `CurrentContext()` | Real I/O operations |
| 4 | Pydantic models | `BaseModel`, `EmailStr` | Type validation |
| 5 | Lifespan | `@asynccontextmanager`, `AppState` | Resource management |
| 6 | Composition | `import_server()`, `prefix` | Service aggregation |
| 7 | Authentication | `BearerAuthProvider`, JWKS | Security |
| 8 | Middleware | `on_request()`, `call_next()` | Cross-cutting concerns |
| 9 | OpenAPI | `RouteMap`, `MCPType` | FastAPI integration |
| 10 | Production | All above + health checks + env vars | Deployment |

## Integration Points

- **Upstream dependencies**: FastMCP 2.x library, Python 3.10+, asyncio runtime
- **Downstream consumers**: MCP clients (Claude Desktop, custom clients), monitoring systems, API gateways
- **Related utilities**: `Client` class for testing, `fastmcp run` CLI, FastAPI apps for composition

## Progression Path

1. **Basics** (L1-L2): Tools, resources, prompts
2. **Async** (L3): Context injection, progress reporting, async/await
3. **Typing** (L4): Pydantic models for input/output validation
4. **Lifecycle** (L5): Startup/shutdown, shared state management
5. **Architecture** (L6): Server composition, service aggregation
6. **Production** (L7-L10): Auth, middleware, OpenAPI, health checks, environment configuration

## Limitations & Constraints

- Examples use mock databases and simplified error handling
- Production server example requires external JWKS endpoint for authentication
- Client examples assume server running on localhost:8000
- OpenAPI integration requires existing FastAPI app structure
- Environment variables required for production deployment (JWKS_URI, AUTH_ISSUER, etc.)

## Success Indicators

- Developer can run Level 1 example within 5 minutes
- Each level runs independently without dependencies on other examples
- Client example successfully interacts with production server (Level 10)
- Test example demonstrates tool and resource validation patterns
- Production server passes health check and handles authenticated requests

---
**Generated from**: worktrees/main/docs/fastmcp/10-examples.md
