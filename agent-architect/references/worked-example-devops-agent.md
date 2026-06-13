# Worked Example: DevOps Deployment Agent

Full walkthrough from requirements through validation, building a staging deployment agent for a Kubernetes-based infrastructure.

---

## Phase 1: Requirements

### The Brief

> "I need an agent that can deploy services to our staging Kubernetes cluster. It should check prerequisites, handle rollbacks, and not be able to touch production."

### Requirements Discovery

| Question | Answer |
|----------|--------|
| Primary task? | Deploy specified service version to staging K8s cluster |
| Trigger? | User says "deploy {service} {version} to staging" |
| Tools needed? | kubectl, helm, docker registry check, health check API |
| What can go wrong? | Bad image, failed health check, resource exhaustion, accidental prod deploy |
| Lifecycle? | Ephemeral — one deploy per invocation |
| Reports to? | User directly |
| Done when? | Service running at specified version, health checks passing |

---

## Phase 2: Architecture Selection

Walking the Complexity Ladder:

- **Level 0?** No — needs tools (kubectl, helm, registry)
- **Level 1?** Yes — single agent with 4-5 tools, sequential workflow, < 10 tool calls
- **Level 2+ needed?** No — the workflow is fixed (check → deploy → verify), no dynamic decomposition

**Decision: Level 1 — Single Agent + Tools**

---

## Phase 3: Context Design

| Layer | Content | Strategy |
|-------|---------|----------|
| System instructions | Agent identity, deployment constraints, rollback rules | Static |
| Conversation history | Not needed — ephemeral agent | N/A |
| Retrieved knowledge | Cluster state, service config | Fetched via tools |
| Persistent memory | N/A — ephemeral | N/A |
| Tool definitions | 5 tools (see below) | All loaded at start (small catalog) |
| Task state | Current deploy progress | In-context scratchpad |
| Guardrail context | Never touch production, always prepare rollback | Immutable prefix |

---

## Phase 4: Tool Design

### Tool 1: check_image

```json
{
  "name": "check_image",
  "description": "Verify a container image exists in the registry. Example: check_image(service='auth-service', tag='v2.3.1') returns {exists: true, size_mb: 245, built_at: '2025-03-15T10:00:00Z'}. Returns exists: false if not found.",
  "parameters": {
    "service": {"type": "string", "required": true},
    "tag": {"type": "string", "required": true}
  }
}
```

### Tool 2: get_cluster_status

```json
{
  "name": "get_cluster_status",
  "description": "Get current resource usage for the staging cluster. Returns {cpu_percent, memory_percent, pod_count, node_count}. Example: get_cluster_status() returns {cpu_percent: 45, memory_percent: 72, pod_count: 89, node_count: 3}.",
  "parameters": {}
}
```

### Tool 3: get_current_version

```json
{
  "name": "get_current_version",
  "description": "Get the currently deployed version of a service on staging. Returns {version, replicas, status, last_deployed}. Example: get_current_version(service='auth-service') returns {version: 'v2.2.0', replicas: 2, status: 'healthy', last_deployed: '2025-03-10T14:00:00Z'}.",
  "parameters": {
    "service": {"type": "string", "required": true}
  }
}
```

### Tool 4: deploy_service

```json
{
  "name": "deploy_service",
  "description": "Deploy a service version to staging via Helm upgrade. Returns {success: bool, message: string}. On failure, returns {success: false, message: 'reason', rollback_command: 'helm rollback ...'}.",
  "parameters": {
    "service": {"type": "string", "required": true},
    "tag": {"type": "string", "required": true},
    "dry_run": {"type": "boolean", "default": false}
  }
}
```

### Tool 5: health_check

```json
{
  "name": "health_check",
  "description": "Run health check against a service on staging. Returns {healthy: bool, checks: [{name, status, latency_ms}]}. Waits up to 60s for the service to become healthy. Example: health_check(service='auth-service') returns {healthy: true, checks: [{name: 'readiness', status: 'pass', latency_ms: 12}]}.",
  "parameters": {
    "service": {"type": "string", "required": true}
  }
}
```

---

## Phase 5: Agent Definition

```yaml
---
name: deploy-agent
description: Deploy services to staging Kubernetes cluster. Trigger with "deploy {service} {version} to staging". Checks prerequisites, deploys, verifies health, prepares rollback.
model: sonnet
---

# Deploy Agent

## Identity
agent_id: deploy-agent
role: Staging Deployment Specialist
lifecycle: ephemeral
reports_to: user
autonomy: medium

## Purpose
Safely deploy specified service versions to the staging Kubernetes cluster.
Always verify prerequisites before deploying and prepare rollback before proceeding.

## Guardrails
- NEVER deploy to production — staging only
- NEVER deploy if cluster memory > 90%
- ALWAYS verify image exists before deploying
- ALWAYS record current version for rollback before deploying
- ALWAYS run health check after deploying
- If health check fails, offer rollback immediately

## Workflow

1. Parse service name and version from user request
2. check_image(service, tag) — fail if image doesn't exist
3. get_cluster_status() — fail if memory > 90%
4. get_current_version(service) — record for rollback
5. deploy_service(service, tag, dry_run=true) — preview changes
6. Report dry run results, ask for confirmation
7. deploy_service(service, tag) — actual deploy
8. health_check(service) — verify
9. Report: success + rollback command, or failure + rollback offer

## Response Format
```yaml
status: checking | deploying | verifying | complete | failed
service: {name}
version: {current} → {target}
rollback: {command}
health: {status}
```
```

---

## Phase 6: Guardrail Design

| Guardrail | Type | Implementation |
|-----------|------|----------------|
| No production | Pre-tool-call | Tool parameters don't accept environment; hardcoded to staging |
| Memory threshold | Pre-deploy | Check cluster status; abort if > 90% |
| Image verification | Pre-deploy | Fail fast if check_image returns exists: false |
| Rollback preparation | Pre-deploy | Record current version before any changes |
| Health verification | Post-deploy | Auto-run health check; offer rollback on failure |
| Dry run first | Pre-deploy | Always dry_run=true before actual deploy |

---

## Phase 7: Validation

### Test Scenarios

| Scenario | Input | Expected Behavior |
|----------|-------|-------------------|
| Happy path | "deploy auth-service v2.3.1 to staging" | Full workflow, successful deploy |
| Missing image | "deploy auth-service v9.9.9 to staging" | Fails at image check, clear error |
| Cluster full | Normal deploy, but cluster at 95% memory | Fails at cluster check, suggests scaling |
| Health check failure | Deploy succeeds but service unhealthy | Offers rollback with command |
| Production attempt | "deploy auth-service v2.3.1 to production" | Refuses, explains staging-only |
| Already deployed | "deploy auth-service v2.3.1" when already at v2.3.1 | Reports already at target, no action |

### NPL Enhancement (Optional)

Add to the agent definition for visible reasoning:

```xml
<!-- Before each deploy -->
<npl-intent>
  <overview>Deploy auth-service v2.3.1 to staging</overview>
  <scope>Staging only, single service</scope>
  <assumptions>
    | Assumption | Basis | Risk |
    |------------|-------|------|
    | Image v2.3.1 exists | User requested it | Fail at pull |
    | No breaking config changes | Not specified | Service crash |
    | Cluster has capacity | Last check 2h ago | Resource exhaustion |
  </assumptions>
</npl-intent>

<!-- After deploy -->
<npl-ref>
✅ Deploy succeeded, health checks passing
⚠️ Cluster memory at 82% after deploy — approaching threshold
📝 TODO: Consider scaling staging nodes before next deploy
</npl-ref>
```

---

## Scoring (Against agent-scoring-rubric.md)

| Criterion | Weight | Score | Evidence |
|-----------|--------|-------|----------|
| Task completion | 20% | 9/10 | Handles all 6 test scenarios correctly |
| Tool design | 15% | 9/10 | All 6 rules followed: structured output, examples, recovery, pagination (N/A), high-leverage, lazy loading (N/A — small catalog) |
| Guardrail coverage | 20% | 9/10 | All 4 boundary types covered: input, retrieval (N/A), tool call, output |
| Context efficiency | 10% | 8/10 | Ephemeral — no memory overhead. Could lazy-load tools but catalog is small |
| Failure recovery | 15% | 9/10 | Rollback prepared, health check automated, clear error messages |
| Output quality | 10% | 8/10 | Structured YAML format, actionable information |
| NPL integration | 10% | 7/10 | Optional but well-placed intent + reflection |

**Weighted score: 8.6/10** — exceeds 8.5 target.
