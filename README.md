# MCP Host

**Domains:** justmcp.it | mcpjumpst.art | safemcp.com

**Status:** Concept / Pre-development

---

## Vision

A unified MCP hosting platform that treats security as a first-class concern — not an afterthought bolted onto tool definitions. MCP Host provides tested, hardened MCP endpoints with granular access control, delegated authorization, and a global discovery registry.

The core security invariant: **an MCP server can never access more than the human user behind the request could access directly.** Tool permissions are the intersection of what the MCP is allowed to do and what the calling user is authorized to do — never the union.

---

## Architecture

### Three Product Surfaces

| Surface | Domain | Purpose |
|---------|--------|---------|
| **JustMCP.it** | justmcp.it | One-click MCP deployment. Upload tool definitions, configure auth, get a live endpoint with monitoring, logging, and usage analytics. |
| **MCP Jumpstart** | mcpjumpst.art | Scaffolding and templates. Select language/use case, generate a ready-to-deploy project with transport config, tool defs, and example handlers. |
| **SafeMCP** | safemcp.com | Security control plane. Authorization policies, sandboxing, audit logs, simulation environments for testing agent interactions before production. |

### Core Components

```
┌─────────────────────────────────────────────────────────────┐
│                      MCP Host Platform                      │
│                                                             │
│  ┌──────────┐  ┌──────────────┐  ┌────────────────────────┐│
│  │ Registry │  │  Auth Gateway │  │   Execution Sandbox    ││
│  │          │  │              │  │                        ││
│  │ • Global │  │ • Caller ID  │  │ • Tool isolation       ││
│  │   search │  │ • User ID    │  │ • Resource limits      ││
│  │ • Per-   │  │ • Policy     │  │ • Network policy       ││
│  │   category│  │   engine    │  │ • Audit logging        ││
│  │ • Health │  │ • Scoped     │  │ • Response validation  ││
│  │   status │  │   tokens    │  │                        ││
│  └──────────┘  └──────────────┘  └────────────────────────┘│
│                                                             │
│  ┌──────────────────────────────────────────────────────────┐│
│  │                    Policy Engine                         ││
│  │  caller × user × tool × resource → allow | deny         ││
│  └──────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

---

## Security Model

### Dual-Principal Authorization

Every MCP request carries two principals:

1. **Caller** — the AI agent or application invoking the MCP tool (identified by API key, OAuth client, or signed token)
2. **User** — the human whose session or credentials initiated the agent's action (propagated via delegated auth token)

The authorization decision is: `allow(tool, args) = caller_policy(tool, args) ∧ user_policy(tool, args)`

Neither principal alone can escalate beyond their own permissions. If a caller has access to `gmail.send` but the user doesn't have Gmail connected, the tool call is denied. If the user has Gmail but the caller's policy excludes email tools, the tool call is denied.

### Delegated Authorization (No Credential Forwarding)

MCP Host never receives or stores user credentials for downstream services. Instead:

- Users authorize MCP Host as an OAuth delegate with explicitly scoped permissions
- Downstream access tokens are scoped to what the user granted, not what the service supports
- Token scope is further narrowed by the caller's policy before use
- Refresh tokens are encrypted at rest, rotated on use, and revocable per-caller

### Granular Access Control

Policies are defined at multiple levels, evaluated innermost-first:

| Level | Scope | Example |
|-------|-------|---------|
| **Global** | Platform-wide defaults | Rate limits, banned tool patterns, abuse prevention |
| **Organization** | All callers/users in an org | "No file-delete tools in production MCP servers" |
| **MCP Server** | All tools on a specific server | "This server's tools are read-only" |
| **Tool** | Individual tool | "gmail.send requires explicit user confirmation" |
| **Caller** | Specific API client | "Claude Desktop can use search tools but not write tools" |
| **User** | Specific human | "keith@ can access admin tools; contractors cannot" |

Policy expressions support:

- **Allow/deny lists** per tool per caller
- **Argument constraints** — e.g., `file.write` only to paths matching `/tmp/**`
- **Rate limiting** — per caller, per user, per tool, per time window
- **Confirmation gates** — require human-in-the-loop approval for sensitive operations
- **Time-based rules** — tools available only during business hours, maintenance windows

### Audit Trail

Every tool invocation produces an immutable audit record:

```
{
  timestamp, request_id,
  caller: { id, name, ip },
  user:   { id, email, org },
  tool:   { server, name, version },
  args:   { ... },              // redacted per policy
  policy: { decision, rules_evaluated, matched_rule },
  result: { status, duration_ms, error? }
}
```

Audit logs are queryable, exportable, and support compliance workflows (SOC 2, GDPR data access logs).

---

## MCP Registry & Discovery

### Global Search

A searchable catalog of all public MCP servers and tools hosted on the platform:

- Full-text search across tool names, descriptions, parameter schemas
- Filter by category, auth method, popularity, health status
- Version history and changelog per tool
- Compatibility matrix (which MCP client versions are supported)

### Categories

MCP servers are organized into categories for browsable discovery:

| Category | Examples |
|----------|---------|
| Communication | Email, Slack, SMS, calendar |
| Data & Storage | Databases, file systems, object stores |
| Developer Tools | Git, CI/CD, issue trackers, code search |
| AI & ML | Model inference, embeddings, vector search |
| Productivity | Document editing, spreadsheets, project management |
| Infrastructure | Cloud providers, DNS, monitoring, secrets |
| Finance | Payment processing, invoicing, accounting |
| Custom | User-published private or public tools |

Each category supports its own discovery endpoint, so callers can enumerate available tools within a domain without loading the full registry.

### Health & Trust

- **Health checks** — continuous synthetic probes for every hosted MCP endpoint
- **Trust scoring** — based on uptime, audit history, vulnerability scan results, and usage patterns
- **Verified publishers** — identity-verified organizations with signing keys
- **Deprecation signals** — automated notices when tools are sunset, with migration pointers

---

## Tool Lifecycle

### Publishing

```
define tool → test in sandbox → security scan → publish to registry → monitor
```

1. **Define** — tool schema (JSON Schema for inputs/outputs), handler implementation, required permissions
2. **Test** — simulation environment with synthetic callers, fuzz testing on inputs, permission boundary tests
3. **Scan** — automated checks for injection vectors, credential leaks, unbounded resource access
4. **Publish** — versioned release to registry with rollback capability
5. **Monitor** — real-time dashboards for latency, error rate, policy denials, anomalous usage patterns

### Sandboxing

Tools execute in isolated environments with:

- **Network policy** — explicit allowlist of outbound destinations; no arbitrary internet access
- **Resource caps** — CPU, memory, wall-clock limits per invocation
- **Filesystem isolation** — tools cannot read host filesystem or other tools' state
- **Secret injection** — credentials injected at runtime via sealed secrets, never baked into images

---

## Deployment

### One-Click (JustMCP.it)

For users who want to get an MCP endpoint running immediately:

1. Upload tool definition (OpenAPI, JSON Schema, or MCP native format)
2. Configure auth (API key, OAuth, or MCP Host managed)
3. Set access policy (who can call which tools)
4. Deploy — get a live `https://{name}.justmcp.it` endpoint
5. Monitor via built-in dashboard

### Scaffolded (MCP Jumpstart)

For users building custom MCP servers:

1. Select language (TypeScript, Python, Elixir, Go, Rust)
2. Select use case template (CRUD API wrapper, LLM tool, data pipeline, etc.)
3. Generate project with:
   - Tool definitions and handler stubs
   - Transport configuration (stdio, SSE, WebSocket)
   - Auth middleware pre-wired
   - Docker + K8s manifests
   - CI/CD pipeline (GitHub Actions)
   - Test harness with permission boundary tests
4. Develop locally, push to deploy

### Self-Hosted

For organizations that need to run MCP Host on their own infrastructure:

- Helm chart for Kubernetes deployment
- Configurable backing stores (Postgres, Redis)
- Pluggable auth providers (OIDC, SAML, LDAP)
- Air-gapped mode (no external registry calls)

---

## Extended Auth Protocols

### OAuth 2.1 + MCP Extensions

MCP Host extends standard OAuth 2.1 with MCP-specific grant types and token claims:

- **`mcp:tool` scope** — fine-grained scope per tool (e.g., `mcp:tool:gmail.read mcp:tool:gmail.send`)
- **`mcp:server` scope** — blanket access to all tools on a server
- **Delegated user claim** — JWT `sub` identifies the calling application; `act.sub` identifies the human user (RFC 8693 token exchange)
- **Dynamic scope narrowing** — callers can request fewer permissions than their maximum grant at call time

### API Key with Policy Binding

For simpler integrations, API keys are bound to a policy document at creation time:

```yaml
api_key: "mcp_live_..."
policy:
  allowed_tools:
    - "search.*"
    - "calendar.read"
  denied_tools:
    - "*.delete"
    - "*.admin.*"
  rate_limit: 100/min
  require_user_context: true
```

### Mutual TLS (mTLS)

For service-to-service MCP calls within a cluster, mTLS provides caller identity without tokens. Certificate SANs map to caller policies.

---

## Roadmap

| Phase | Focus | Key Deliverables |
|-------|-------|-----------------|
| **0 — Foundation** | Core platform | Auth gateway, policy engine, single-tool hosting, audit logging |
| **1 — Registry** | Discovery | Global search, categories, health checks, publisher verification |
| **2 — Sandbox** | Isolation | Network policies, resource limits, filesystem isolation, fuzz testing |
| **3 — Scale** | Multi-tenancy | Org management, usage billing, SLA tiers, self-hosted Helm chart |
| **4 — Ecosystem** | Integrations | Marketplace, revenue sharing for publishers, compliance certifications |

---

## Ecosystem Projects

MCP Host is the platform layer. Two sibling projects in the incubator portfolio are built to run on it:

### mcp.therobotlives.com

**Role:** Managed MCP hosting portal — the first-party deployment of the MCP Host platform.

Users sign up at `mcp.therobotlives.com`, browse a catalog of MCP services, enable/disable them per-org, and configure security settings. Each org gets a subdomain with per-service paths (e.g., `noizu.my-mcp.com/npl-mcp/sse`). This is the operational frontend that exercises all three MCP Host product surfaces (JustMCP.it one-click deploy, SafeMCP policy controls, and Registry discovery) under a single unified portal.

**Relationship to MCP Host:** mcp.therobotlives.com *is* the hosted instance — it consumes the MCP Host backend APIs, auth gateway, and policy engine. MCP Host provides the infrastructure; mcp.therobotlives.com provides the tenant-facing SaaS experience.

### Mockup MCP (securamcp.com)

**Role:** First showcase MCP service — a product mockup generator exposed as an MCP tool.

Uses image AI and structured diagramming (PlantUML, SVG, Mermaid) to generate product mockups, wireframes, and architectural diagrams. Includes a companion website for collecting stakeholder feedback on generated mockups.

**Relationship to MCP Host:** Mockup MCP is a tenant application — it is published to the MCP Host registry, deployed through JustMCP.it, and governed by SafeMCP access policies. It serves as the reference implementation for what a well-behaved MCP service looks like when hosted on the platform: sandboxed execution, scoped auth, audit-logged invocations, and discoverable via the registry.

### Project Map

```
MCP Host (platform)
├── mcp.therobotlives.com    — SaaS portal (consumes platform APIs)
└── Mockup MCP               — Reference tenant service (runs on platform)
    └── securamcp.com         — Companion feedback site
```

---

## Tech Stack (Planned)

| Layer | Technology |
|-------|-----------|
| Frontend | Next.js 15 (App Router) |
| Backend API | Phoenix 1.8 (Elixir) |
| Policy Engine | OPA (Open Policy Agent) or Cedar |
| Auth | OAuth 2.1 / OIDC, Guardian (JWT) |
| Database | PostgreSQL (Ecto) |
| Cache / Pub-Sub | Redis |
| Sandbox Runtime | Firecracker microVMs or gVisor containers |
| Registry | PostgreSQL + Meilisearch |
| Audit Store | Append-only PostgreSQL + optional S3 export |
| Deployment | Kubernetes (Helm), Docker |
| Reverse Proxy | nginx with Lua/njs for policy enforcement |
