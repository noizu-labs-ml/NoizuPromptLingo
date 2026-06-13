# Docker Stack Validation

## 1. Build

```bash
docker compose build --progress=plain
```

Watch for errors in each stage:
- **frontend-build**: npm ci failures, Next.js build errors
- **python-deps**: apt package not found, uv sync failures
- **runtime**: COPY path misses, final uv sync errors

## 2. Start

```bash
docker compose up -d
```

Wait ~30s for healthchecks, then:

```bash
docker compose ps
```

All three services should show `healthy`:
- `npl-timescaledb`
- `npl-valkey`
- `npl-mcp`

If `npl-mcp` shows `starting` or `unhealthy`, check logs:

```bash
docker compose logs npl-mcp --tail=100
```

## 3. Smoke Tests

```bash
# Liveness (no dependencies)
curl http://localhost:8765/api/health/ping

# Full health (validates DB connection + latency)
curl http://localhost:8765/api/health

# Frontend serves HTML
curl -s http://localhost:8765/ | head -5
```

Expected `/api/health/ping` response:
```json
{"status": "ok", "ts": "2025-..."}
```

Expected `/api/health` response includes:
```json
{
  "status": "ok",
  "subsystems": {
    "database": {"status": "ok", "latency_ms": ...},
    ...
  }
}
```

## 4. Teardown

```bash
docker compose down
```

To also remove volumes (full reset):

```bash
docker compose down -v
```

## Notes

- DB tables won't exist yet (no migrations). The health check validates connectivity, not schema.
- Playwright browsers are not installed in the image. Browser tools will error at call time.
- The host-mapped ports default to 8765 (app), 5432 (postgres), 6379 (valkey). Override with `NPL_MCP_PORT`, `NPL_DB_PORT`, `NPL_VALKEY_PORT` env vars.
