# Category: Monitoring and Observability

## Overview
Use tools in this category when a skill needs to query error data, inspect traces, analyze logs, or surface anomalies in a running system. Relevant for skills that operate on deployed services — debugging production issues, generating incident summaries, or building automated triage workflows. A smaller category than others, but critical for any ops-adjacent skill.

## MCP Services

| Name | Deployment | Key Features | Security Notes | Maturity |
|------|-----------|-------------|----------------|----------|
| Sentry MCP | hosted SSE (OAuth 2.0) at mcp.sentry.dev | Seer AI root cause, issue/error/trace queries, zero-install | OAuth per org; data stays in Sentry | Stable (official) |
| Datadog MCP | hosted SSE (OAuth) | 50+ tools across 10+ toolsets: APM, infra, logs, errors, feature flags, LLM observability | API + App key required; broad org access | Stable (official) |
| Grafana MCP | self-hosted (Apache 2.0) | 40+ tools, 15 categories, Prometheus/Loki/ClickHouse/CloudWatch | Self-hosted; no external data egress | Stable (community) |

### Sentry MCP
- **What it does**: Connects directly to Sentry's error tracking platform. Queries issues, reads stack traces, fetches event details, surfaces Seer AI root-cause analysis, and navigates projects/organizations.
- **Deployment**: Hosted SSE at `mcp.sentry.dev` — zero install, OAuth 2.0 authentication per Sentry organization. No local server setup required.
- **Key features**:
  - Issue and event queries with filter support (environment, release, date range)
  - Seer AI integration: automated root cause analysis and fix suggestions surfaced inline
  - Stack trace reading with full context frames
  - Project and organization navigation
  - Zero-install: add the MCP URL to your client config and authenticate via OAuth
- **Security considerations**: OAuth token scoped to a Sentry organization. Token grants read access to all projects the user can see. For CI/automation, create a dedicated Sentry internal integration token with the minimum required scopes. Do not share tokens across team members.
- **When to use**: Any skill doing production debugging, incident triage, or error pattern analysis. Ideal for a "daily error review" skill or post-deploy health check workflow. Best fit when Sentry is the primary error tracker.
- **When to avoid**: Teams not on Sentry; environments where error data must not leave internal network; when only infrastructure metrics (CPU, memory) are needed — Sentry covers application errors, not infra

### Datadog MCP
- **What it does**: Comprehensive Datadog platform access. 50+ tools organized into 10+ toolsets covering APM traces, infrastructure metrics, log analytics, error tracking, feature flag states, and LLM observability (AI/ML model performance).
- **Deployment**: Hosted SSE via Datadog API key + Application key pair. Official Datadog-maintained server.
- **Key features**:
  - APM: query traces, service maps, latency distributions, downstream dependency errors
  - Infrastructure: host metrics, container stats, process lists, network flows
  - Logs: full-text search, log analytics, pattern detection
  - Error tracking: similar to Sentry but natively integrated with all other Datadog signals
  - Feature flags: read flag states and evaluate which flags are active for a context
  - LLM observability toolset: token usage, prompt/completion latency, model error rates — purpose-built for AI products
- **Security considerations**: API key + App key together grant broad org access. Scope App key permissions in Datadog's RBAC settings. Store keys in a secrets manager, not in `.env` files committed to repos. Audit key usage in Datadog's API key management dashboard.
- **When to use**: Teams already on Datadog as their primary observability platform. The LLM observability toolset is uniquely valuable for skills building or operating AI products — no other tool in this category has native LLM cost/latency/error tracking. Use when you need correlated signals across APM + logs + infra in a single query session.
- **When to avoid**: Teams not on Datadog (cost prohibitive for small projects); when only application errors are needed (Sentry is simpler); self-hosted/air-gapped environments

### Grafana MCP
- **What it does**: Self-hosted MCP server for Grafana's observability stack. 40+ tools across 15 categories: query Prometheus/Loki/ClickHouse/CloudWatch, manage dashboards, trigger/silence alerts, annotate time ranges, explore data sources.
- **Deployment**: Self-hosted stdio or SSE; open source under Apache 2.0. Runs against your own Grafana instance. No external data egress.
- **Key features**:
  - Prometheus: PromQL execution, metric discovery, label enumeration
  - Loki: LogQL queries, log stream filtering, log volume analysis
  - ClickHouse: SQL analytics on stored observability data
  - CloudWatch: AWS metrics and logs via Grafana data source
  - Dashboard management: create panels, update dashboard JSON, snapshot dashboards
  - Alert management: list, silence, and annotate alert rules
- **Security considerations**: Runs against your Grafana instance using a service account token. Token scopes map to Grafana's RBAC roles — use `Viewer` role for read-only tools, `Editor` only when dashboard writes are needed. All queries execute inside your network; no data leaves to a third-party MCP host.
- **When to use**: Teams running self-hosted Grafana with Prometheus/Loki (the standard open-source observability stack). Ideal when data sovereignty is a requirement — no SaaS dependency. Use when skills need to correlate metrics (Prometheus) and logs (Loki) together, or when CloudWatch data lives in Grafana data sources.
- **When to avoid**: Teams without a Grafana instance; environments where setting up a self-hosted MCP server is too heavyweight; when managed SaaS observability (Datadog, Sentry) is already in use and working

## Selection Guide

Choose based on your observability stack and data residency requirements:

| If your stack is... | Use | Reason |
|--------------------|-----|--------|
| Sentry (error tracking only) | Sentry MCP | Zero-install, Seer AI root cause analysis |
| Datadog (full-stack SaaS) | Datadog MCP | 50+ tools, LLM observability toolset |
| Grafana + Prometheus + Loki (self-hosted) | Grafana MCP | Open source, no data egress, full PromQL/LogQL |
| AWS CloudWatch | Grafana MCP | Via CloudWatch data source in Grafana |
| Mixed: Sentry errors + Datadog APM | Both MCPs | Query errors in Sentry, traces/metrics in Datadog |
| Air-gapped / data-sovereign | Grafana MCP | Self-hosted only option |

**Decision rules**:
- Need root cause AI analysis with zero setup → Sentry MCP
- Need LLM/AI product observability (token costs, prompt latency) → Datadog MCP
- Need full control and open-source stack → Grafana MCP
- Building a "debugging assistant" skill → Sentry MCP as primary, Datadog MCP if team uses it
- Building an "infrastructure health" skill → Grafana MCP (Prometheus) or Datadog MCP (infra toolset)
