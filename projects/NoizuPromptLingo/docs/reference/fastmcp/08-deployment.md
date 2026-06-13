# Deployment

> Authentication, security, and production deployment for FastMCP 2.x

## Running Modes

| Mode | Production Ready | Multi-Client | Use Case |
|:-----|:-----------------|:-------------|:---------|
| STDIO | No | No | Claude Desktop, local dev |
| HTTP | Yes | Yes | Web clients, production |
| SSE | Legacy | Yes | Backward compatibility |
| Streamable HTTP | Yes | Yes | Recommended for production |

## Transport Configuration

### STDIO (Default)

```python
mcp.run()  # Default
mcp.run(transport="stdio")
```

### HTTP

```python
mcp.run(transport="http", host="0.0.0.0", port=8000)
```

### Streamable HTTP (Recommended)

```python
mcp.run(transport="streamable-http", host="0.0.0.0", port=8000)
```

## Authentication

OAuth 2.1 with PKCE is **required** for HTTP-based servers (MCP spec 2025-03-26).

### Token Verifier (Simplest)

Validate JWTs from external IdP:

```python
from fastmcp import FastMCP
from fastmcp.server.auth import TokenVerifier

auth = TokenVerifier(
    issuer="https://auth.example.com",
    audience="mcp-server",
    jwks_uri="https://auth.example.com/.well-known/jwks.json"
)

mcp = FastMCP("My Server", auth=auth)
```

**Use when**: You have existing JWT infrastructure or API gateway.

### OAuth Providers

#### GitHub

```python
from fastmcp.server.auth.providers.github import GitHubProvider

auth = GitHubProvider(
    client_id="your-client-id",
    client_secret="your-client-secret",
    base_url="https://your-server.com"
)
```

#### Google

```python
from fastmcp.server.auth.providers.google import GoogleProvider

auth = GoogleProvider(
    client_id="your-client-id",
    client_secret="your-client-secret",
    base_url="https://your-server.com"
)
```

#### Azure/Entra ID

```python
from fastmcp.server.auth.providers import AzureOAuthProvider

auth = AzureOAuthProvider(
    client_id="your-client-id",
    client_secret="your-client-secret",
    tenant_id="your-tenant-id",
    # For Azure Government:
    # base_authority="https://login.microsoftonline.us"
)
```

### Environment Configuration (v2.12.1+)

```bash
export FASTMCP_SERVER_AUTH=fastmcp.server.auth.providers.google.GoogleProvider
export FASTMCP_SERVER_AUTH_GOOGLE_CLIENT_ID=xxx
export FASTMCP_SERVER_AUTH_GOOGLE_CLIENT_SECRET=xxx
export FASTMCP_SERVER_AUTH_GOOGLE_BASE_URL=https://your-server.com
```

```python
# Server code - auth loaded from environment
mcp = FastMCP("My Server")
```

## ASGI Deployment

### Basic ASGI Application

```python
from fastmcp import FastMCP

def create_app():
    mcp = FastMCP("ASGI Server")

    @mcp.tool()
    def hello() -> str:
        return "Hello from ASGI!"

    return mcp.http_app()

app = create_app()
```

Run with Uvicorn:

```bash
uvicorn server:app --host 0.0.0.0 --port 8000 --workers 4
```

### FastAPI Integration

```python
from fastapi import FastAPI
from fastmcp import FastMCP

api = FastAPI()
mcp = FastMCP("Integrated Server")

@mcp.tool()
def mcp_tool() -> str:
    return "MCP response"

@api.get("/api/health")
def health():
    return {"status": "healthy"}

# Mount MCP app
api.mount("/mcp", mcp.http_app())
```

### Production Uvicorn

```python
import uvicorn

if __name__ == "__main__":
    uvicorn.run(
        "server:app",
        host="0.0.0.0",
        port=8000,
        workers=4,
        loop="uvloop",
        log_level="info",
        ssl_keyfile="/path/to/key.pem",
        ssl_certfile="/path/to/cert.pem"
    )
```

## Docker Deployment

### Dockerfile

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV PORT=8000
EXPOSE ${PORT}

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT}/health || exit 1

CMD ["python", "server.py"]
```

### Health Check Endpoint

```python
from fastmcp import FastMCP
from fastmcp.server.http import custom_route
from starlette.responses import JSONResponse
import os

mcp = FastMCP("Containerized Server")

@custom_route("/health", methods=["GET"])
async def health_check(request):
    return JSONResponse({"status": "healthy"})

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    mcp.run(transport="http", host="0.0.0.0", port=port)
```

### docker-compose.yml

```yaml
version: '3.8'

services:
  mcp-server:
    build: .
    ports:
      - "8000:8000"
    environment:
      - PORT=8000
      - FASTMCP_SERVER_AUTH=fastmcp.server.auth.providers.jwt.JWTVerifier
      - FASTMCP_SERVER_AUTH_JWT_ISSUER=https://auth.example.com
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped
```

## Proxy Servers

### Transport Bridging

Expose remote SSE server locally:

```python
from fastmcp import FastMCP
from fastmcp.server.proxy import ProxyClient

proxy = FastMCP.as_proxy(
    ProxyClient("http://remote.example.com/mcp/sse"),
    name="Remote Bridge"
)

proxy.run()  # Local stdio access to remote server
```

### Multi-Server Composition

```python
config = {
    "mcpServers": {
        "weather": {"url": "https://weather-api.example.com/mcp"},
        "calendar": {"url": "https://calendar-api.example.com/mcp"}
    }
}

proxy = FastMCP.as_proxy(config, name="Composite")
# Tools: weather_get_forecast, calendar_add_event
```

## CLI Reference

```bash
# Basic execution
fastmcp run server.py

# Specify transport
fastmcp run server.py --transport http --port 8000

# Add dependencies
fastmcp run server.py --with pandas --with numpy

# Use requirements file
fastmcp run server.py --with-requirements requirements.txt

# Pass args to server
fastmcp run server.py -- --config config.json
```

## Production Checklist

### Infrastructure
- [ ] HTTP/Streamable HTTP transport configured
- [ ] ASGI server (Uvicorn) with multiple workers
- [ ] Reverse proxy (nginx/Caddy) for SSL termination
- [ ] Health check endpoints implemented
- [ ] Container orchestration configured

### Security
- [ ] OAuth 2.1 with PKCE enabled
- [ ] Authentication provider configured
- [ ] HTTPS enforced
- [ ] Secrets managed securely
- [ ] Rate limiting implemented

### Observability
- [ ] Structured logging configured
- [ ] Metrics collection (Prometheus)
- [ ] Distributed tracing (OpenTelemetry)
- [ ] Alerting rules defined

### Reliability
- [ ] Graceful shutdown handling
- [ ] Connection draining configured
- [ ] Retry logic for transient failures
- [ ] Circuit breakers for external dependencies

## Complete Production Example

```python
from contextlib import asynccontextmanager
from fastmcp import FastMCP
from fastmcp.server.auth import BearerAuthProvider
from fastmcp.server.middleware import Middleware, MiddlewareContext
from fastmcp.server.http import custom_route
from starlette.responses import JSONResponse
import os

# Auth
auth = BearerAuthProvider(
    jwks_uri="https://auth.example.com/.well-known/jwks.json",
    issuer="https://auth.example.com",
    audience="mcp-server",
)

# Lifespan
@asynccontextmanager
async def lifespan(server):
    print("Server starting...")
    yield {}
    print("Server stopped.")

# Middleware
class RequestLogger(Middleware):
    async def on_request(self, context: MiddlewareContext, call_next):
        print(f"[{context.method}] Request")
        return await call_next(context)

# Server
mcp = FastMCP("Production Server", lifespan=lifespan, auth=auth)
mcp.add_middleware(RequestLogger())

# Health check
@custom_route("/health", methods=["GET"])
async def health(request):
    return JSONResponse({"status": "healthy"})

# Tools
@mcp.tool
def ping() -> str:
    return "pong"

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    mcp.run(transport="http", host="0.0.0.0", port=port)
```

---

**Previous**: [Client](07-client.md) | **Next**: [Migration](09-migration.md) | **Index**: [README](README.md)
