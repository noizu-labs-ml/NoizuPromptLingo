# Deployment

**Type**: Documentation
**Category**: FastMCP
**Status**: Core

## Purpose

Comprehensive guide for deploying FastMCP 2.x servers to production environments. Covers transport configuration, authentication implementation, ASGI deployment strategies, containerization, and production readiness. Essential reference for transitioning FastMCP servers from local development (STDIO) to production-grade HTTP services with proper authentication, monitoring, and reliability patterns.

## Key Capabilities

- **Multiple transport modes**: STDIO (development), HTTP, SSE (legacy), and Streamable HTTP (production-recommended)
- **OAuth 2.1 compliance**: Built-in authentication providers (GitHub, Google, Azure) and JWT verification
- **ASGI integration**: Native support for Uvicorn, FastAPI mounting, and multi-worker deployments
- **Container orchestration**: Docker configurations with health checks and environment-based auth
- **Proxy patterns**: Transport bridging and multi-server composition
- **Production hardening**: SSL termination, graceful shutdown, middleware, and observability hooks

## Usage & Integration

- **Triggered by**: Project requirement to deploy FastMCP server beyond local Claude Desktop integration
- **Outputs to**: Production environments (cloud, on-premises, containers)
- **Complements**: FastMCP client configuration (07-client.md), CLI tooling, and authentication infrastructure

## Core Operations

### Transport Selection

```python
# Development: STDIO (default)
mcp.run()

# Production: Streamable HTTP (recommended)
mcp.run(transport="streamable-http", host="0.0.0.0", port=8000)

# Legacy: SSE support
mcp.run(transport="sse", host="0.0.0.0", port=8000)
```

### Authentication Setup

```python
# JWT Token Verification (simplest for existing infrastructure)
from fastmcp.server.auth import TokenVerifier

auth = TokenVerifier(
    issuer="https://auth.example.com",
    audience="mcp-server",
    jwks_uri="https://auth.example.com/.well-known/jwks.json"
)

# OAuth Provider (GitHub example)
from fastmcp.server.auth.providers.github import GitHubProvider

auth = GitHubProvider(
    client_id="your-client-id",
    client_secret="your-client-secret",
    base_url="https://your-server.com"
)

mcp = FastMCP("Secure Server", auth=auth)
```

### ASGI Deployment

```python
# Basic ASGI app
from fastmcp import FastMCP

def create_app():
    mcp = FastMCP("Production Server")

    @mcp.tool()
    def api_tool() -> str:
        return "Response"

    return mcp.http_app()

app = create_app()
```

Run with production settings:
```bash
uvicorn server:app --host 0.0.0.0 --port 8000 --workers 4 --loop uvloop
```

### Docker Containerization

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

ENV PORT=8000
EXPOSE ${PORT}

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:${PORT}/health || exit 1

CMD ["python", "server.py"]
```

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| `transport` | Connection mode | `"stdio"` | Options: stdio, http, sse, streamable-http |
| `host` | Bind address | `"127.0.0.1"` | Use `"0.0.0.0"` for external access |
| `port` | Listen port | `8000` | Configurable via environment |
| `auth` | Auth provider | `None` | Required for HTTP transports in production |
| `lifespan` | Startup/shutdown handler | `None` | Async context manager for resource management |
| `workers` | Process count | `1` | Set via Uvicorn for multi-core scaling |

## Integration Points

- **Upstream dependencies**:
  - OAuth provider infrastructure (GitHub, Google, Azure, custom JWKS)
  - SSL certificate management
  - Environment variable configuration (v2.12.1+)

- **Downstream consumers**:
  - Web clients (browser-based MCP interfaces)
  - API gateways
  - Load balancers (nginx, Caddy)
  - Container orchestration (Docker Compose, Kubernetes)

- **Related utilities**:
  - FastAPI integration for custom routes
  - Proxy clients for transport bridging
  - Health check endpoints for monitoring
  - CLI (`fastmcp run`) for development execution

## Limitations & Constraints

- **STDIO limitations**: Single-client, non-production, requires local process access (Claude Desktop integration only)
- **OAuth requirement**: HTTP transports mandate OAuth 2.1 with PKCE per MCP spec (2025-03-26)
- **Stateful auth**: Token verification requires JWKS endpoint availability; network failures block authentication
- **Worker isolation**: Multi-worker deployments require stateless tool implementations or shared state management (Redis, database)

## Success Indicators

- Server starts on specified transport/port without errors
- Health check endpoint returns 200 status
- Authentication validates tokens correctly (401/403 for invalid tokens, 200 for valid)
- Tools execute successfully under authenticated requests
- Docker container passes HEALTHCHECK probes
- Graceful shutdown completes without connection drops

## Advanced Patterns

### Environment-Based Auth (v2.12.1+)

```bash
export FASTMCP_SERVER_AUTH=fastmcp.server.auth.providers.google.GoogleProvider
export FASTMCP_SERVER_AUTH_GOOGLE_CLIENT_ID=xxx
export FASTMCP_SERVER_AUTH_GOOGLE_CLIENT_SECRET=xxx
export FASTMCP_SERVER_AUTH_GOOGLE_BASE_URL=https://server.com
```

Server code reads auth configuration automatically:
```python
mcp = FastMCP("Auto-Auth Server")  # Auth loaded from environment
```

### Multi-Server Composition

```python
from fastmcp import FastMCP

config = {
    "mcpServers": {
        "weather": {"url": "https://weather-api.example.com/mcp"},
        "calendar": {"url": "https://calendar-api.example.com/mcp"}
    }
}

proxy = FastMCP.as_proxy(config, name="Composite Gateway")
proxy.run()  # Exposes: weather_get_forecast, calendar_add_event
```

### Production Checklist

**Infrastructure**: HTTP/Streamable HTTP transport, Uvicorn multi-worker, reverse proxy SSL termination, health checks, container orchestration

**Security**: OAuth 2.1 with PKCE, HTTPS enforcement, secrets management (environment variables, vaults), rate limiting

**Observability**: Structured logging, Prometheus metrics, OpenTelemetry tracing, alerting rules

**Reliability**: Graceful shutdown, connection draining, retry logic, circuit breakers for external dependencies

---
**Generated from**: worktrees/main/docs/fastmcp/08-deployment.md
**Word count**: ~750 words
