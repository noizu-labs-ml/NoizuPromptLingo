# FastMCP Migration Guide

**Type**: Documentation
**Category**: fastmcp
**Status**: Core

## Purpose

Provides comprehensive upgrade paths and breaking change documentation for FastMCP 2.x releases. Covers version compatibility, critical API changes, deprecated patterns, and migration checklists. Essential for developers upgrading from FastMCP 1.x or navigating breaking changes between 2.x minor versions.

The guide focuses on practical migration steps with before/after code examples, compatibility matrices for FastMCP/MCP SDK/Python versions, and troubleshooting common upgrade issues.

## Key Capabilities

- Version compatibility matrix tracking FastMCP, MCP SDK, and Python versions
- Step-by-step migration paths from 1.x to 2.0 and between 2.x versions
- Breaking change documentation with code examples showing deprecated and current patterns
- Critical version-specific behavioral changes (constructor deprecation, lifespan scope, decorator returns)
- Compatibility workarounds for MCP SDK version pinning issues
- Upgrade checklists and verification commands

## Usage & Integration

- **Triggered by**: Version upgrades, breaking change notifications, compatibility issues
- **Outputs to**: Development workflows, CI/CD pipeline updates, dependency management
- **Complements**: FastMCP deployment guide, API documentation, changelog

Used as reference during:
- Major/minor version upgrades (1.x → 2.0, 2.x → 2.y)
- Troubleshooting OAuth, lifespan, or endpoint issues post-upgrade
- Dependency conflict resolution between FastMCP and MCP SDK versions

## Core Operations

### Import Path Migration (1.x → 2.0)
```python
# Before (MCP SDK built-in)
from mcp.server.fastmcp import FastMCP

# After (FastMCP 2.x)
from fastmcp import FastMCP
```

### Constructor Deprecation (v2.3.4+)
```python
# Deprecated
mcp = FastMCP("My Server", log_level="DEBUG", port=8000, stateless_http=True)
mcp.run()

# Current
mcp = FastMCP("My Server")
mcp.run(transport="streamable-http", port=8000)
```

### Lifespan Scope Change (v2.13.0 - CRITICAL)
```python
# Before: ran per-client connection
@asynccontextmanager
async def lifespan(server):
    db = await connect_db()
    yield {"db": db}
    await db.close()

# After: runs once per server
# Use middleware for per-session behavior
class SessionMiddleware(Middleware):
    async def __call__(self, request, call_next):
        session_db = await get_session_connection()
        request.state.db = session_db
        try:
            return await call_next(request)
        finally:
            await session_db.close()
```

### OpenAPI Route Mapping Change (v2.8)
```python
# v2.8+: ALL endpoints become Tools by default
# Restore previous behavior (GET → Resources)
from fastmcp.server.openapi import RouteMap

mcp = FastMCP.from_openapi(
    openapi_url="...",
    route_maps=[
        RouteMap(methods=["GET"], route_type="resource_template"),
        RouteMap(methods=["POST", "PUT", "DELETE"], route_type="tool"),
    ]
)
```

## Configuration & Parameters

| Version | MCP SDK | Python | Critical Changes |
|---------|---------|--------|------------------|
| 2.13.x+ | >1.23.1 | 3.10+ | OAuth compatibility fixed |
| 2.12.x-2.13.0 | <1.23 | 3.10+ | OAuth patch incompatibility |
| 2.12.5 | <1.17 | 3.10+ | `.well-known` endpoint issue |

**Note**: All versions exclude `mcp==1.21.1` due to integration test failures.

## Integration Points

- **Upstream dependencies**: FastMCP package, MCP SDK version constraints
- **Downstream consumers**: Application code, CI/CD pipelines, deployment configs
- **Related utilities**: FastMCP settings API, transport configuration, middleware system

## Limitations & Constraints

- MCP SDK version pinning required for stable operation across certain FastMCP versions
- Constructor kwargs deprecated but not removed (breaking change deferred to v2.14)
- SSE transport deprecated per MCP spec (2025-03-26), `streamable-http` required
- Decorator return type change (v2.7) breaks code expecting function references

## Success Indicators

- Version compatibility verified via `pip show fastmcp mcp`
- All deprecated patterns replaced with current equivalents
- Transport updated to `streamable-http` (not `sse`)
- Lifespan logic correctly scoped to server lifecycle (not per-session)
- OAuth and `.well-known` endpoint issues resolved via correct MCP SDK pinning

---
**Generated from**: worktrees/main/docs/fastmcp/09-migration.md
