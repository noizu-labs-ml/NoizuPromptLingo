# NPL MCP Helm Chart

This chart deploys the NPL MCP server with optional in-cluster PostgreSQL and Valkey services.

## Build the image

```bash
docker build -t ghcr.io/noizu/npl-mcp:0.1.0 .
```

## Install with bundled dependencies

```bash
helm upgrade --install npl-mcp charts/npl-mcp \
  --set image.repository=ghcr.io/noizu/npl-mcp \
  --set image.tag=0.1.0
```

## Install with an external database

```bash
helm upgrade --install npl-mcp charts/npl-mcp \
  --set image.repository=ghcr.io/noizu/npl-mcp \
  --set image.tag=0.1.0 \
  --set postgresql.enabled=false \
  --set database.host=postgres.example.internal \
  --set database.name=npl \
  --set database.user=npl \
  --set database.existingSecret=npl-db-secret
```

The external database secret must contain the key configured by `database.passwordKey`, which defaults to `NPL_DB_PASSWORD`.

## Health

The deployment uses `/api/health/ping` for liveness and readiness probes. The MCP endpoints are exposed at `/sse` and `/mcp`.
