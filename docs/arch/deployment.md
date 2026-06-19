# Deployment

## Container Images

Two Docker images, both Alpine-based:

| Image | Dockerfile | Base | Port | Runtime |
|-------|-----------|------|------|---------|
| Elixir API | `Dockerfile` | elixir:1.20-otp-29-alpine | 4040 | Mix + Bandit |
| Next.js Dashboard | `Dockerfile.nextjs` | node:22-alpine | 3000 | Standalone output |

The Elixir image uses a multi-stage build: compile in a `build` stage, copy artifacts to a slim production stage. The Next.js image uses Next.js standalone output mode for minimal image size.

## Helm Chart

Single chart at `helm/npl-mcp/` deploys both containers. Configured via `values.yaml` with image tags auto-bumped by `docker-push --update-helm`.

## Kubernetes Resources

- **Deployment**: Both containers in a single pod (or separate deployments depending on chart config)
- **Service**: ClusterIP exposing ports 4040 (API) and 3000 (dashboard)
- **Ingress**: Wildcard `*.tobor.locker` for subdomain-based MCP routing
- **Secrets**: Managed via Infisical operator (InfisicalSecret CRDs)

## Subdomain Routing

Domain MCP servers require wildcard DNS resolution for `*.tobor.locker`. In production, this is handled by the Kubernetes ingress controller with a wildcard TLS cert. Phoenix's router uses `host:` matchers to dispatch to the correct MCP server.

Subdomain mapping:
```
sessions.tobor.locker  → Sessions MCP
tickets.tobor.locker   → Tickets MCP
chat.tobor.locker      → Chat MCP
review.tobor.locker    → Review MCP
wiki.tobor.locker      → Wiki MCP
projects.tobor.locker  → Projects MCP
artifacts.tobor.locker → Artifacts MCP
assets.tobor.locker    → Assets MCP
mockmcp.tobor.locker   → Mock MCP Gateway
tobor.locker           → Root MCP + REST API
```

## Database Migrations

Liquibase runs as a Kubernetes Job (or init container) using the `db/Dockerfile` image. Connection params are injected via environment variables: `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`.

## Environment Variables

| Variable | Required | Default | Purpose |
|----------|----------|---------|---------|
| `DATABASE_URL` | Yes | `localhost:5432/tobor_locker` | Ecto connection string |
| `SECRET_KEY_BASE` | Yes | dev fallback | Phoenix session signing |
| `BACKEND_URL` | Next.js | `http://localhost:4040` | API proxy target |
| `AUTHENTIK_ISSUER` | Next.js | — | OIDC discovery URL |
| `AUTHENTIK_CLIENT_ID` | Next.js | — | OAuth client ID |
| `AUTHENTIK_CLIENT_SECRET` | Next.js | — | OAuth client secret |
| `NPL_PROJECT` | Agents | — | Default project slug for agent sessions |
