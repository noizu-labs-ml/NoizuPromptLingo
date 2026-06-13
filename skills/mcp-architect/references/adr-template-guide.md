# Architecture Decision Record Guide

> Why and how to write ADRs for MCP server design decisions. Includes the format, when to write them, and 3 complete examples.

> For the fillable template, see `assets/adr-template.md`.

---

## Why ADRs Matter for MCP Servers

MCP servers involve a cascade of interconnected decisions: transport determines auth, auth constrains hosting, hosting affects cost, cost affects scope. Six months from now, you (or your successor) will look at the server and ask "why did we choose stdio?" or "why API keys instead of OAuth?"

Without ADRs, the answer is lost. The decision becomes invisible, and changing it requires re-deriving the original reasoning.

ADRs make decisions explicit, searchable, and reviewable. They also prevent the same debate from recurring -- if the decision was made with full context, re-litigating it requires new information.

### When to Write an ADR

Write an ADR for every decision that:

1. **Constrains future decisions** -- transport choice, auth pattern, hosting platform
2. **Is hard to reverse** -- database selection, API design, versioning scheme
3. **Was debated** -- if reasonable people disagreed, the reasoning matters
4. **Affects security** -- auth, encryption, access control

For MCP servers, this typically means at minimum:
- Transport selection (Section 2)
- Authentication pattern (Section 3)
- Hosting choice (Section 6)
- Any data store selection (Section 4, if non-trivial)

---

## ADR Format

```markdown
# ADR-NNN: [Title]

**Date:** YYYY-MM-DD
**Status:** proposed | accepted | deprecated | superseded by ADR-NNN
**Deciders:** [who made the decision]

## Context

What is the issue that we're seeing that is motivating this decision or change?
Include relevant constraints, requirements, and forces at play.

## Decision

What is the change that we're proposing and/or doing?
State the decision clearly and unambiguously.

## Consequences

What becomes easier or more difficult to do because of this change?
Include both positive and negative consequences.

### Positive
- ...

### Negative
- ...

### Neutral
- ...

## Alternatives Considered

### [Alternative 1 Name]
- **Description:** What this option would have looked like
- **Pros:** What would have been better
- **Cons:** Why we didn't choose it

### [Alternative 2 Name]
- **Description:** ...
- **Pros:** ...
- **Cons:** ...
```

### Status Lifecycle

```
proposed → accepted → [active]
                    → deprecated (no longer applies)
                    → superseded by ADR-NNN (replaced by a new decision)
```

---

## Example ADR 1: Transport Selection

```markdown
# ADR-001: Use Streamable HTTP Transport

**Date:** 2026-05-08
**Status:** accepted
**Deciders:** Engineering team

## Context

We are building a Weather API MCP server that will be consumed by multiple
LLM clients (Claude Desktop, Cursor, custom apps). The server wraps the
OpenWeatherMap API and will be deployed as a public service.

Key requirements:
- Multiple concurrent clients
- Public internet accessibility
- API key authentication for rate limiting
- No real-time push requirements

## Decision

Use Streamable HTTP as the transport layer.

## Consequences

### Positive
- Supports unlimited concurrent clients
- Enables API key authentication natively via HTTP headers
- Can be deployed to any HTTP hosting platform (Cloud Run, Fly.io, VPS)
- Standard HTTP monitoring and debugging tools apply

### Negative
- Requires hosting infrastructure (not zero-cost like stdio)
- Network latency added to every request
- Must implement TLS termination
- Must handle connection management and timeouts

### Neutral
- Server-sent events available but not currently needed
- Migration from stdio would have been possible but adds unnecessary complexity

## Alternatives Considered

### stdio
- **Description:** Local process communication via stdin/stdout
- **Pros:** Zero hosting cost, zero latency, no auth needed
- **Cons:** Single client per process, no remote access, can't serve multiple users

### SSE (Server-Sent Events)
- **Description:** HTTP with SSE for server push
- **Pros:** Supports server-initiated events
- **Cons:** Deprecated in MCP spec (mid-2026), not recommended for new servers
```

---

## Example ADR 2: Authentication Method

```markdown
# ADR-002: Use API Key Authentication

**Date:** 2026-05-08
**Status:** accepted
**Deciders:** Engineering team

## Context

The Weather API MCP server (ADR-001: Streamable HTTP) needs authentication
to identify clients for rate limiting and usage tracking. The server is
read-only (no user data mutations), so the auth requirements are:

- Identify which client is making requests
- Enable per-client rate limiting
- Track usage for billing/analytics
- Simple onboarding (developers should start in minutes, not hours)

## Decision

Use API key authentication. Keys are issued via a self-service dashboard,
passed in the `Authorization: Bearer <key>` header, and validated on every
request.

## Consequences

### Positive
- Simple to implement (middleware validates key against database)
- Simple for consumers (one header, no OAuth flow)
- Sufficient for rate limiting and usage tracking
- Industry-standard pattern, well understood

### Negative
- Keys can be shared or leaked (no user-level identity)
- No token expiration by default (must implement rotation)
- No fine-grained permissions (all-or-nothing access)
- Cannot delegate user-specific permissions (no OAuth consent)

### Neutral
- Key rotation is manual (regenerate via dashboard)
- Rate limiting is per-key, not per-user

## Alternatives Considered

### No Authentication
- **Description:** Open access, no keys required
- **Pros:** Zero friction, simplest possible onboarding
- **Cons:** No rate limiting, no usage tracking, abuse vector

### OAuth 2.0
- **Description:** Full OAuth flow with user consent
- **Pros:** User-level identity, fine-grained permissions, standard flows
- **Cons:** Massive implementation complexity for a read-only weather API;
  consumers need OAuth client registration; terrible DX for a simple tool

### JWT (Service-to-Service)
- **Description:** Signed tokens with claims
- **Pros:** Stateless validation, rich claims, standard format
- **Cons:** Requires token issuance infrastructure; overkill for
  identifying API consumers; adds key management complexity
```

---

## Example ADR 3: Hosting Choice

```markdown
# ADR-003: Deploy on Google Cloud Run

**Date:** 2026-05-08
**Status:** accepted
**Deciders:** Engineering team

## Context

The Weather API MCP server needs hosting that supports:
- Streamable HTTP transport (ADR-001)
- Auto-scaling from 0 to handle variable load
- Low operational overhead (small team, no dedicated ops)
- Cost-effective at low-to-moderate volume (~10K requests/day)

The team has existing GCP infrastructure and familiarity.

## Decision

Deploy as a Docker container on Google Cloud Run with auto-scaling
from 0 to 10 instances.

## Consequences

### Positive
- Scale-to-zero reduces cost during low-traffic periods
- Auto-scaling handles traffic spikes without manual intervention
- Fully managed -- no server patching, no OS updates
- Built-in TLS termination and load balancing
- Free tier covers ~2M requests/month
- Team already familiar with GCP

### Negative
- Cold start latency (first request after scale-to-zero: ~2-5 seconds)
- Vendor lock-in to GCP (mitigated by Docker containerization)
- Limited to 60-minute request timeout (sufficient for this use case)
- Debugging is harder than local development

### Neutral
- Container-based deployment is portable to other platforms if needed
- Logging via Cloud Logging (adequate but not ideal)

## Alternatives Considered

### Self-Hosted VPS (e.g., DigitalOcean Droplet)
- **Description:** Single VM running the server process
- **Pros:** No cold starts, full control, predictable cost ($5-12/mo)
- **Cons:** Manual scaling, OS maintenance, no auto-scaling, single point of failure

### AWS Lambda
- **Description:** Serverless functions on AWS
- **Pros:** Scale-to-zero, pay-per-request, massive scale ceiling
- **Cons:** Team has no AWS experience; Lambda cold starts can be worse;
  different deployment tooling needed

### Fly.io
- **Description:** Managed container platform
- **Pros:** Simple deployment, global edge network, good DX
- **Cons:** Smaller ecosystem than GCP; less familiar to team;
  pricing less predictable at scale

### Kubernetes (existing cluster)
- **Description:** Deploy to existing K8s infrastructure
- **Pros:** Existing infrastructure, full control, team K8s experience
- **Cons:** Operational overhead disproportionate for a small stateless service;
  resource reservation wastes cluster capacity
```
