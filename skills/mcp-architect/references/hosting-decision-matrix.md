# Hosting Decision Matrix for MCP Servers

> Comparison of hosting options for MCP servers. Includes decision matrix, deployment checklists, and cost models.

> For the specification checklist (Section 6), see `references/specification-checklist.md`.
> For implementation, see **trl-mcp-forge** (`references/scaffold-nodejs-production.md`).

---

## Decision Matrix

| Factor | Local/stdio | VPS/Docker | Serverless | Managed Platform | Kubernetes |
|--------|-------------|------------|------------|------------------|------------|
| **Monthly Cost** | $0 | $5-50 | Pay-per-use ($0-50+) | $5-25 | Varies |
| **Ops Burden** | None | Moderate | Low | Minimal | High |
| **Latency** | Minimal (IPC) | Network RTT | Network RTT + cold start | Network RTT | Network RTT |
| **Scaling** | Single user | Vertical | Horizontal (auto) | Auto | Horizontal |
| **Auth Required** | No | Yes (for remote) | Yes (platform IAM) | Yes | Yes (service mesh) |
| **Deployment** | npm/pip install | Docker + SSH/CI | CLI deploy | Git push / CLI | Helm/kubectl |
| **Monitoring** | Console logs | DIY or SaaS | Platform built-in | Platform built-in | Prometheus/Grafana |
| **TLS** | N/A | Manual or Let's Encrypt | Platform | Platform | Cert-manager |
| **Best For** | Dev tools, IDE extensions, personal use | Team tools, internal services | Public tools, variable load | Quick deployment, small teams | Enterprise, multi-service |

---

## Option 1: Local/stdio

### When to Choose

- Server is a developer tool (IDE extension, CLI helper)
- Single user, single machine
- No need for remote access
- Accessing local resources (file system, local databases)
- Zero-cost requirement

### Architecture

```
[LLM Client] <--stdio--> [MCP Server Process]
                          (spawned as child process)
```

### Deployment

Users install via package manager:

```bash
# Node.js
npm install -g my-mcp-server
# or
npx my-mcp-server

# Python
pip install my-mcp-server
# or
uvx my-mcp-server
```

### Client Configuration

**Claude Desktop (`claude_desktop_config.json`):**

```json
{
  "mcpServers": {
    "my-tool": {
      "command": "npx",
      "args": ["-y", "my-mcp-server"],
      "env": {
        "API_KEY": "sk-abc123"
      }
    }
  }
}
```

### Deployment Checklist

- [ ] Published to npm or PyPI
- [ ] README with installation instructions
- [ ] Client config examples (Claude Desktop, Cursor)
- [ ] Environment variable documentation
- [ ] Works on macOS, Linux, Windows (if applicable)
- [ ] No build step required (pre-compiled or interpreted)

---

## Option 2: VPS/Docker

### When to Choose

- Team tool (5-50 users)
- Internal service behind VPN/firewall
- Need persistent state (database, file storage)
- Predictable cost important
- Full control over environment

### Architecture

```
[LLM Clients] --HTTPS--> [Reverse Proxy (nginx/caddy)]
                              |
                          [MCP Server Container]
                              |
                          [Database / Storage]
```

### Cost Model

| Provider | Spec | Monthly Cost |
|----------|------|-------------|
| DigitalOcean Droplet | 1 vCPU, 1GB RAM | $6 |
| DigitalOcean Droplet | 2 vCPU, 4GB RAM | $24 |
| Hetzner VPS | 2 vCPU, 4GB RAM | $5 |
| AWS Lightsail | 2 vCPU, 2GB RAM | $12 |

### Docker Compose Example

```yaml
version: "3.8"
services:
  mcp-server:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/mcp
      - API_KEY=${API_KEY}
    depends_on:
      - db
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:16-alpine
    volumes:
      - pgdata:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: mcp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: ${DB_PASSWORD}

  caddy:
    image: caddy:2-alpine
    ports:
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile

volumes:
  pgdata:
```

### Deployment Checklist

- [ ] Docker image builds and runs
- [ ] TLS configured (Let's Encrypt via Caddy/nginx)
- [ ] Firewall rules (only 443 exposed)
- [ ] Automated backups (if stateful)
- [ ] Monitoring (uptime check, log aggregation)
- [ ] CI/CD pipeline (GitHub Actions -> SSH deploy or Docker push)
- [ ] Secrets in vault or env file (not docker-compose.yaml)
- [ ] Health check endpoint
- [ ] Log rotation configured
- [ ] OS auto-updates enabled

---

## Option 3: Serverless (Lambda/Cloud Run/Vercel)

### When to Choose

- Variable or unpredictable load
- Public-facing tool with unknown usage patterns
- Minimal ops capacity
- Pay-per-use pricing preferred
- Can tolerate cold start latency

### Architecture

```
[LLM Clients] --HTTPS--> [API Gateway / Cloud Run URL]
                              |
                          [Function / Container Instance]
                              |
                          [External APIs / Managed DB]
```

### Cold Start Considerations

| Platform | Cold Start | Mitigation |
|----------|-----------|------------|
| AWS Lambda (Node.js) | 200-800ms | Provisioned concurrency ($) |
| AWS Lambda (Python) | 300-1000ms | Provisioned concurrency ($) |
| Google Cloud Run | 1-5s | Min instances = 1 ($) |
| Vercel Functions | 100-500ms | Edge runtime (limited) |
| Cloudflare Workers | <5ms | V8 isolates (no cold start) |

### Cost Model

| Platform | Free Tier | Per-Request Cost | Monthly @ 100K req |
|----------|-----------|------------------|-------------------|
| AWS Lambda | 1M req/mo | $0.20/1M + compute | ~$2-5 |
| Cloud Run | 2M req/mo | $0.40/1M + compute | ~$3-8 |
| Vercel | 100K req/mo | $0.60/1M | ~$5-10 |
| Cloudflare Workers | 100K req/day | $0.50/1M | ~$1-3 |

### Google Cloud Run Deployment

```bash
# Build and push container
gcloud builds submit --tag gcr.io/PROJECT_ID/mcp-server

# Deploy
gcloud run deploy mcp-server \
  --image gcr.io/PROJECT_ID/mcp-server \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --min-instances 0 \
  --max-instances 10 \
  --memory 256Mi \
  --timeout 60s \
  --set-env-vars "API_KEY=sk-abc123"
```

### Deployment Checklist

- [ ] Container or function builds and deploys
- [ ] Cold start latency measured and acceptable
- [ ] Timeout configured (default may be too short for MCP)
- [ ] Memory allocated appropriately
- [ ] Environment variables set (not hardcoded)
- [ ] Scaling limits configured (prevent cost runaway)
- [ ] Monitoring and alerting (error rate, latency, cost)
- [ ] Cost alerts configured
- [ ] CI/CD pipeline (push to deploy)
- [ ] Health check or readiness probe

---

## Option 4: Managed Platform (Fly.io/Railway)

### When to Choose

- Quick deployment with minimal configuration
- Small team (1-10 users)
- Don't want to manage Docker registries or cloud IAM
- Need always-on (not serverless) but don't want VPS ops
- Global distribution is a plus

### Architecture

```
[LLM Clients] --HTTPS--> [Platform Edge Network]
                              |
                          [Container Instance(s)]
                              |
                          [Platform Managed DB (optional)]
```

### Cost Model

| Platform | Free Tier | Starter Cost | Scaling Cost |
|----------|-----------|-------------|-------------|
| Fly.io | 3 shared VMs | $2-5/mo per VM | $0.01/hr per extra |
| Railway | $5 credit/mo | $5-10/mo | Usage-based |
| Render | Static sites free | $7/mo per service | Per-service |

### Fly.io Deployment

```toml
# fly.toml
app = "my-mcp-server"
primary_region = "iad"

[build]
  dockerfile = "Dockerfile"

[http_service]
  internal_port = 3000
  force_https = true
  auto_start_machines = true
  auto_stop_machines = true
  min_machines_running = 1

[env]
  NODE_ENV = "production"
```

```bash
fly launch
fly secrets set API_KEY=sk-abc123
fly deploy
```

### Deployment Checklist

- [ ] App deployed and accessible via HTTPS
- [ ] Secrets configured via platform (not in config)
- [ ] Auto-scaling configured
- [ ] Health check responding
- [ ] Custom domain configured (if needed)
- [ ] CI/CD connected (GitHub Actions -> fly deploy)
- [ ] Monitoring dashboard reviewed

---

## Option 5: Kubernetes

### When to Choose

- Enterprise environment with existing K8s infrastructure
- Multi-service architecture (MCP server is one of many services)
- Need service mesh, network policies, or advanced orchestration
- Dedicated ops team available
- Compliance requirements (SOC 2, HIPAA)

### Architecture

```
[LLM Clients] --HTTPS--> [Ingress Controller]
                              |
                          [Service]
                              |
                          [Deployment (N replicas)]
                              |
                          [PersistentVolume / External DB]
```

### Cost Model

Kubernetes itself is free (open source), but infrastructure costs include:
- Control plane: $0 (self-managed) to $72/mo (EKS/GKE/AKS)
- Worker nodes: $10-100+/mo per node
- Load balancer: $10-20/mo
- Storage: $0.10/GB/mo

### Helm Chart Structure

```
mcp-server/
  Chart.yaml
  values.yaml
  templates/
    deployment.yaml
    service.yaml
    ingress.yaml
    configmap.yaml
    secret.yaml
    hpa.yaml
```

### Deployment Checklist

- [ ] Helm chart or manifests created
- [ ] Resource requests and limits set
- [ ] Liveness and readiness probes configured
- [ ] Horizontal Pod Autoscaler configured
- [ ] Network policies applied
- [ ] Secrets managed via external secrets operator (e.g., Infisical)
- [ ] Ingress with TLS configured
- [ ] Monitoring via Prometheus/Grafana
- [ ] CI/CD pipeline (build image -> push -> helm upgrade)
- [ ] Pod disruption budget set
- [ ] Node affinity/anti-affinity rules (if multi-node)

---

## Quick Selection Guide

```
Is the server local-only?
  Yes -> Local/stdio ($0, zero ops)
  No  |
      v
Do you have a K8s cluster and ops team?
  Yes -> Kubernetes (if justified by scale/compliance)
  No  |
      v
Is load predictable and low (<10K req/day)?
  Yes -> VPS/Docker ($5-50/mo) or Managed Platform ($5-25/mo)
  No  |
      v
Is load variable or unpredictable?
  Yes -> Serverless (pay-per-use, auto-scale)
  No  |
      v
Default -> Managed Platform (Fly.io/Railway)
           Lowest ops burden for most use cases
```
