# Docker Patterns for MCP Servers

Containerization patterns for both stdio and HTTP-based MCP servers.

## Multi-Stage Builds

### TypeScript: Build --> Runtime

```dockerfile
# Dockerfile (TypeScript)

# Stage 1: Build
FROM node:22-slim AS builder
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci --ignore-scripts
COPY tsconfig.json ./
COPY src/ ./src/
RUN npm run build

# Stage 2: Production
FROM node:22-slim AS runtime

# Create non-root user
RUN groupadd -r mcp && useradd -r -g mcp -m mcp

WORKDIR /app

# Install production deps only
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev --ignore-scripts && npm cache clean --force

# Copy built artifacts
COPY --from=builder /app/dist ./dist

# Drop privileges
USER mcp

ENV NODE_ENV=production
ENTRYPOINT ["node", "dist/server.js"]
```

### Python: Builder --> Runtime

```dockerfile
# Dockerfile (Python)

# Stage 1: Build with dependencies
FROM python:3.12-slim AS builder
WORKDIR /app
RUN pip install --no-cache-dir uv
COPY pyproject.toml ./
RUN uv pip install --system --no-cache .
COPY src/ ./src/

# Stage 2: Production
FROM python:3.12-slim AS runtime

# Create non-root user
RUN groupadd -r mcp && useradd -r -g mcp -m mcp

WORKDIR /app

# Copy installed packages and source
COPY --from=builder /usr/local/lib/python3.12/site-packages \
     /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /app/src ./src

USER mcp

ENV MCP_TRANSPORT=stdio
ENTRYPOINT ["python", "-m", "src.server"]
```

## Non-Root User Setup

Always run as non-root in production:

```dockerfile
# Create dedicated user and group
RUN groupadd -r mcp && useradd -r -g mcp -m mcp

# If the app needs to write to specific directories:
RUN mkdir -p /app/data && chown mcp:mcp /app/data

# Switch to non-root before ENTRYPOINT
USER mcp
```

## Health Check Endpoints

### For HTTP Transport Servers

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

Install curl in the image if not present:

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*
```

Or use a language-native health check to avoid adding curl:

```dockerfile
# Node.js
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD node -e "fetch('http://localhost:3000/health').then(r => { if (!r.ok) throw r; })"

# Python
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:3000/health')"
```

### For Stdio Transport Servers

Stdio servers have no HTTP endpoint. Use a process-alive check:

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD node -e "process.exit(0)"
```

This is minimal but confirms the runtime is functional. For deeper checks, write a small script that sends an MCP initialize request via stdin.

## Volume Mounts for Config

```yaml
# docker-compose.yml
services:
  mcp-server:
    build: .
    volumes:
      # Mount config file (read-only)
      - ./config:/app/config:ro
      # Mount data directory (read-write)
      - mcp-data:/app/data
    environment:
      - CONFIG_PATH=/app/config/settings.json

volumes:
  mcp-data:
```

## Docker Compose for Development

```yaml
# docker-compose.yml
services:
  mcp-server:
    build:
      context: .
      target: builder  # Use builder stage for dev (has dev deps)
    environment:
      - MCP_TRANSPORT=streamable-http
      - MCP_HTTP_PORT=3000
      - LOG_LEVEL=debug
      - NODE_ENV=development
    ports:
      - "3000:3000"
    volumes:
      # Mount source for hot reload
      - ./src:/app/src:ro
      - ./node_modules:/app/node_modules  # Avoid rebuilding deps
    restart: unless-stopped

  # Optional: backing services
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  postgres:
    image: postgres:16-alpine
    environment:
      - POSTGRES_DB=mcp
      - POSTGRES_USER=mcp
      - POSTGRES_PASSWORD=dev-password
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

## Production Hardening

### Read-Only Filesystem

```yaml
services:
  mcp-server:
    image: my-mcp-server:latest
    read_only: true
    tmpfs:
      - /tmp:noexec,nosuid,size=64m
    security_opt:
      - no-new-privileges:true
```

### Resource Limits

```yaml
services:
  mcp-server:
    image: my-mcp-server:latest
    deploy:
      resources:
        limits:
          cpus: "1.0"
          memory: 512M
        reservations:
          cpus: "0.25"
          memory: 128M
```

### Full Production Compose

```yaml
# docker-compose.prod.yml
services:
  mcp-server:
    image: ghcr.io/org/my-mcp-server:1.2.3
    read_only: true
    tmpfs:
      - /tmp:noexec,nosuid,size=64m
    security_opt:
      - no-new-privileges:true
    environment:
      - MCP_TRANSPORT=streamable-http
      - MCP_HTTP_PORT=3000
      - NODE_ENV=production
      - LOG_LEVEL=info
    ports:
      - "3000:3000"
    deploy:
      resources:
        limits:
          cpus: "1.0"
          memory: 512M
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
    healthcheck:
      test: ["CMD", "node", "-e", "fetch('http://localhost:3000/health').then(r=>{if(!r.ok)throw r})"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
```

## Stdio Servers vs HTTP Servers in Docker

| Aspect | Stdio Server | HTTP Server |
|---|---|---|
| **Transport** | stdin/stdout | HTTP POST to /mcp |
| **Docker usage** | Run interactively (`docker run -it`) | Run as daemon (`docker run -d`) |
| **Health checks** | Process-alive only | HTTP endpoint (`/health`) |
| **Port mapping** | None needed | Map server port |
| **Client connection** | Client spawns container as subprocess | Client sends HTTP requests to container |
| **Scaling** | One container per client session | One container, many sessions |
| **Typical use** | Local dev, Claude Desktop | Remote deployment, shared access |

### Stdio Server Docker Usage

```bash
# Client spawns the container as its MCP server process
docker run --rm -i my-mcp-server:latest

# Claude Desktop config:
{
  "mcpServers": {
    "my-server": {
      "command": "docker",
      "args": ["run", "--rm", "-i", "my-mcp-server:latest"]
    }
  }
}
```

### HTTP Server Docker Usage

```bash
# Run as a daemon
docker run -d -p 3000:3000 --name mcp-server my-mcp-server:latest

# Client connects via HTTP
# MCP_SERVER_URL=http://localhost:3000/mcp
```

## .dockerignore

```
# .dockerignore
node_modules
dist
.git
.github
.env
.env.*
*.md
!README.md
test
coverage
.vscode
.idea
__pycache__
*.pyc
.pytest_cache
.mypy_cache
.ruff_cache
```
