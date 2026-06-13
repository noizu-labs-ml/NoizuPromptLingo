# Worked Example: Virtual DevOps MCP

Building a Virtual MCP that composes kubectl, Docker CLI, and GitHub Actions tools into a unified DevOps interface.

## Overview

This Virtual MCP presents 5 published tools to the client, each implemented by composing calls to 3 backing MCP servers.

### Backing MCP Servers

| Server | Tools Used | Purpose |
|---|---|---|
| kubectl-mcp | get_pods, describe_pod, apply, logs, rollout_history, rollout_undo | Kubernetes operations |
| docker-mcp | build, push, tag, inspect | Container image operations |
| gh-actions-mcp | trigger_workflow, get_run_status, download_artifacts | GitHub Actions CI/CD |

### Published Tools

| Tool | Description | Backing Calls |
|---|---|---|
| deploy_service | Build, push, and deploy a service | docker.build --> docker.push --> kubectl.apply |
| rollback | Roll back a deployment to previous version | kubectl.rollout_history --> kubectl.rollout_undo |
| check_health | Check health of a deployed service | kubectl.get_pods --> kubectl.describe_pod |
| view_logs | View logs for a service | kubectl.get_pods --> kubectl.logs |
| run_workflow | Trigger and monitor a GitHub Actions workflow | gh.trigger_workflow --> gh.get_run_status |

## Step 1: Define v1 Version Contract

```markdown
# Version Contract: Virtual DevOps MCP v1.0

## Metadata
- **Version:** 1.0
- **Effective Date:** 2026-05-01
- **Status:** Active

## Tool Manifest

### deploy_service
- **Category:** Deployment
- **Description:** Build a Docker image, push to registry, and deploy to Kubernetes
- **Parameters:**
  - `service_name` (string, required): Service name
  - `namespace` (string, required): Kubernetes namespace
  - `source_path` (string, required): Path to source with Dockerfile
  - `image_tag` (string, optional): Override auto-generated tag
- **Response:** { service, image, status, steps[] }
- **Backing:** docker.build, docker.push, kubectl.apply

### rollback
- **Category:** Deployment
- **Description:** Roll back a Kubernetes deployment to the previous revision
- **Parameters:**
  - `service_name` (string, required): Deployment name
  - `namespace` (string, optional): Default "default"
  - `revision` (number, optional): Target revision. Default: previous
- **Response:** { service, rolled_back_to, previous_image, current_image }
- **Backing:** kubectl.rollout_history, kubectl.rollout_undo

### check_health
- **Category:** Monitoring
- **Description:** Check pod health for a deployed service
- **Parameters:**
  - `service_name` (string, required): Service name
  - `namespace` (string, optional): Default "default"
- **Response:** { service, status, pods[] }
- **Backing:** kubectl.get_pods, kubectl.describe_pod

## Backing Tool Dependencies

| Server | Tool | Required |
|--------|------|----------|
| kubectl-mcp | get_pods | Yes |
| kubectl-mcp | describe_pod | Yes |
| kubectl-mcp | apply | Yes |
| kubectl-mcp | logs | Yes |
| kubectl-mcp | rollout_history | Yes |
| kubectl-mcp | rollout_undo | Yes |
| docker-mcp | build | Yes |
| docker-mcp | push | Yes |
| gh-actions-mcp | trigger_workflow | Yes |
| gh-actions-mcp | get_run_status | Yes |
```

## Step 2: Implement Agent Definition

```yaml
---
name: virtual-devops-mcp
description: >
  Virtual MCP agent composing kubectl, Docker, and GitHub Actions into
  a unified DevOps tool interface.
tools:
  - mcp: kubectl-mcp
  - mcp: docker-mcp
  - mcp: gh-actions-mcp
---

# Virtual DevOps MCP Agent

You are a Virtual MCP agent providing unified DevOps operations.

## Version Contract
Load `version-contract-v1.md` at session start. This defines your
published tool interface. You expose meta-tools (Tier 1) and published
tools (Tier 2, via ToolCall).

## Composition Rules

### deploy_service
1. Call docker.build with context=source_path, tag=image_tag or auto
2. Call docker.push with the built image
3. Generate Kubernetes deployment manifest
4. Call kubectl.apply with the manifest
5. Return consolidated result

Error handling:
- If docker.build fails: return error, do not push or deploy
- If docker.push fails: return error with build info, do not deploy
- If kubectl.apply fails: return error with build+push info

### rollback
1. Call kubectl.rollout_history for the deployment
2. Identify target revision (specified or previous)
3. Call kubectl.rollout_undo to that revision
4. Return the rollback result

### check_health
1. Call kubectl.get_pods with label selector app=service_name
2. For any pod not in Running/Ready state, call kubectl.describe_pod
3. Synthesize overall status:
   - All pods Running+Ready: "healthy"
   - Some pods unhealthy: "degraded"
   - All pods unhealthy: "unhealthy"
4. Return status with per-pod details

### view_logs
1. Call kubectl.get_pods to find pod names
2. Call kubectl.logs for the first pod (or specified pod)
3. Return log lines

### run_workflow
1. Call gh.trigger_workflow with the workflow file and inputs
2. Wait briefly, then call gh.get_run_status
3. Return run ID and initial status
```

## Step 3: Generate Self-Audit Prompt

```markdown
# Self-Audit Prompt: Virtual DevOps MCP v1.0

## Interface Contract

Published tools:
1. deploy_service(service_name, namespace, source_path, image_tag?)
2. rollback(service_name, namespace?, revision?)
3. check_health(service_name, namespace?)
4. view_logs(service_name, namespace?, tail?, container?)
5. run_workflow(workflow_file, inputs?)

## Test Scenarios

### deploy_service / happy path
- Input: {service_name: "nginx-test", namespace: "test", source_path: "./nginx"}
- Expected: Response contains {service: "nginx-test", status: "deployed"}
- Verify: docker.build was called, docker.push was called, kubectl.apply was called

### deploy_service / build failure
- Input: {service_name: "bad-app", namespace: "test", source_path: "./nonexistent"}
- Expected: Error response mentioning build failure
- Verify: docker.push and kubectl.apply were NOT called

### check_health / healthy service
- Input: {service_name: "nginx-test", namespace: "test"}
- Expected: {status: "healthy"} with pod details
- Verify: kubectl.get_pods was called

### check_health / unhealthy service
- Input: {service_name: "crash-app", namespace: "test"}
- Expected: {status: "unhealthy" or "degraded"} with error details
- Verify: kubectl.describe_pod was called for unhealthy pods

### rollback / to previous
- Input: {service_name: "nginx-test", namespace: "test"}
- Expected: Rollback confirmation with revision info
- Verify: kubectl.rollout_history and kubectl.rollout_undo were called

## Consistency Checks
- After deploy_service succeeds, check_health for the same service should
  eventually show "healthy"
- view_logs for a running service should return non-empty log lines

## Regression Flags
- kubectl status value normalization (healthy/degraded/unhealthy)
- Docker build context path resolution
```

## Step 4: v2 Extension -- Adding 2 More Tools

New tools to add in v2.0:
- `scale_service` -- Scale a deployment up or down
- `get_deployment_status` -- Get detailed deployment status

### Version Bump Analysis

- Adding new tools only --> MINOR bump? No -- we are also changing check_health response format.
- check_health adds a `history` field --> compatible change (new field) --> still MINOR.
- Decision: v1.0 --> v1.1 (all changes are backward compatible).

Actually, let's make this a v2.0 for the example. Assume we also want to make `namespace` required on check_health (currently optional with default). That is a breaking change.

### v2.0 Contract Changes

```markdown
# Version Contract: Virtual DevOps MCP v2.0

## Changes from v1.0

### Breaking Changes
- check_health: `namespace` parameter is now required (was optional with default)
- check_health: Response `status` values changed:
  "healthy | degraded | unhealthy" --> "healthy | warning | critical | unknown"

### New Tools
- scale_service: Scale a deployment replica count
- get_deployment_status: Get detailed deployment info with rollout status

### Deprecations
- rollback: Deprecated in v2.0. Use deploy_service with previous image_tag.
  Will be removed in v3.0.

## Tool Manifest

### scale_service (NEW)
- **Category:** Deployment
- **Description:** Scale a Kubernetes deployment to a target replica count
- **Parameters:**
  - `service_name` (string, required)
  - `namespace` (string, required)
  - `replicas` (number, required): Target replica count (0-100)
- **Response:** { service, replicas, previous_replicas }
- **Backing:** kubectl.scale

### get_deployment_status (NEW)
- **Category:** Monitoring
- **Description:** Get detailed deployment status including rollout progress
- **Parameters:**
  - `service_name` (string, required)
  - `namespace` (string, required)
- **Response:** { service, replicas, available, unavailable, conditions[], images[] }
- **Backing:** kubectl.get_deployment, kubectl.get_pods
```

### Migration Guide: v1.0 --> v2.0

```markdown
## Breaking Changes

### check_health: namespace now required
// v1.0 -- namespace defaulted to "default"
ToolCall("check_health", {service_name: "api"})

// v2.0 -- must specify namespace
ToolCall("check_health", {service_name: "api", namespace: "default"})

### check_health: status values changed
| v1.0 | v2.0 |
|------|------|
| healthy | healthy |
| degraded | warning |
| unhealthy | critical |
| (n/a) | unknown |

### rollback: deprecated
// v2.0 -- still works but emits deprecation warning
ToolCall("rollback", {service_name: "api"})
// Response includes: {"_deprecated": true, "_deprecated_message": "..."}

// Recommended replacement:
ToolCall("deploy_service", {service_name: "api", namespace: "prod", image_tag: "previous-tag"})
```

## Step 5: Self-Audit Run

```
=== Virtual DevOps MCP Self-Audit ===
Contract: version-contract-v2.md (v2.0, 2026-06-15)
Mode: full

--- Phase 1: Contract Check ---
[PASS] deploy_service: callable, schema valid
[PASS] rollback: callable (deprecated), schema valid
[PASS] check_health: callable, schema valid (namespace now required)
[PASS] view_logs: callable, schema valid
[PASS] scale_service: callable, schema valid
[PASS] get_deployment_status: callable, schema valid
[PASS] run_workflow: callable, schema valid

--- Phase 2: Regression Check ---
[PASS] deploy_service/happy_path
[PASS] deploy_service/build_failure
[PASS] check_health/healthy: returned status="healthy" (correct)
[PASS] check_health/unhealthy: returned status="critical" (v2 value, correct)
[PASS] rollback/to_previous: works, deprecation warning emitted
[PASS] view_logs/basic
[PASS] scale_service/scale_up: scaled from 1 to 3 replicas
[PASS] scale_service/scale_down: scaled from 3 to 1 replica
[PASS] get_deployment_status/running: correct replica counts
[PASS] run_workflow/trigger: workflow triggered, status returned

--- Phase 3: Drift Detection ---
[STABLE] kubectl-mcp: no schema changes
[STABLE] docker-mcp: no schema changes
[STABLE] gh-actions-mcp: no schema changes

--- Phase 4: Report ---

Summary: 7 tools, 7 contract checks passed, 10/10 regression checks passed,
         0 drift warnings, 1 deprecation active

| Tool                  | Contract | Regression | Drift  | Status |
|-----------------------|----------|------------|--------|--------|
| deploy_service        | PASS     | PASS       | STABLE | PASS   |
| rollback              | PASS     | PASS       | STABLE | DEPRECATED |
| check_health          | PASS     | PASS       | STABLE | PASS   |
| view_logs             | PASS     | PASS       | STABLE | PASS   |
| scale_service         | PASS     | PASS       | STABLE | PASS   |
| get_deployment_status | PASS     | PASS       | STABLE | PASS   |
| run_workflow          | PASS     | PASS       | STABLE | PASS   |

Deprecation Notices:
- rollback: Deprecated since v2.0. Removal planned for v3.0.
  Replacement: deploy_service with previous image_tag.

Recommendations:
- All tools passing. No action required.
- Consider documenting the rollback --> deploy_service migration
  more prominently for consumers still using v1.
```

## Full Lifecycle Summary

```
v1.0 (3 tools)
  |
  +-- Deploy, test, serve
  |
v2.0 (5 tools, 1 deprecated, 1 breaking change)
  |
  +-- Migration guide published
  +-- v1 still served for backward compat
  +-- Self-audit: all pass
  |
v3.0 (planned)
  |
  +-- Remove rollback
  +-- Retire v1 contract
```
