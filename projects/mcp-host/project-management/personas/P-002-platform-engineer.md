---
id: P-002
name: "Priya Sharma"
slug: "platform-engineer"
archetype: "The Orchestrator"
segment: "primary"
tags: [platform-engineering, devops, kubernetes, helm, self-hosted, multi-environment, infrastructure]
---

# Priya Sharma — The Orchestrator

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 30-39 |
| **Role** | Staff Platform Engineer |
| **Technical Level** | Expert |
| **Industry** | Enterprise SaaS |
| **Location** | Berlin, Germany |

## Bio

Priya runs the internal developer platform team at a 400-person SaaS company. Her team owns the Kubernetes clusters, CI/CD pipelines, and the service catalog that other engineering teams use to deploy workloads. The AI team just asked her to host six MCP servers for internal tooling, and she needs a solution that fits into existing Helm-based workflows, supports staging/production parity, and does not become another snowflake system she has to babysit.

## Goals

1. Deploy and manage MCP servers at scale using familiar infrastructure-as-code patterns (Helm, Terraform, GitOps)
2. Maintain consistent configurations across dev, staging, and production environments with promotion workflows
3. Achieve fleet-level visibility — health, resource usage, rollout status — across all hosted MCP servers from a single pane

## Frustrations

1. AI teams spin up ad-hoc MCP deployments that bypass platform standards — no version pinning, no resource limits, no alerting
2. No off-the-shelf Helm chart or operator for MCP hosting that respects enterprise patterns (private registries, network policies, secret management)
3. Every MCP server is deployed differently, making incident response harder because there is no consistent operational model

## Behaviors

- Manages infrastructure with Helm charts, ArgoCD, and Terraform — expects new services to integrate with these tools
- Uses namespace-per-team isolation with RBAC and network policies on Kubernetes
- Reviews PRs for deployment manifests and enforces policy through OPA or Kyverno admission controllers
- Tracks everything in Grafana dashboards and PagerDuty alerts

## Job to Be Done

> "When a product team requests a new MCP server deployment, I want to provision it through our standard GitOps pipeline with a parameterized Helm chart, so I can ensure it meets security, networking, and resource policies without manual review."

## Relationship to Product

Priya evaluates MCP Host from the self-hosted deployment angle. She wants Helm charts she can drop into her ArgoCD application manifests, a values file schema she can template per environment, and operational runbooks. The JustMCP.it SaaS is not interesting for her use case — she needs the software, not the service. She would adopt MCP Host if it feels like a first-class Kubernetes workload and would reject it if it assumes Docker Compose or requires the SaaS control plane to function.

## Scenarios

1. **Helm-Based Fleet Deploy** — Priya adds the MCP Host Helm chart to her organization's chart registry, writes environment-specific values files (dev/staging/prod), and deploys via ArgoCD sync with automatic rollbacks on health check failure.
2. **Multi-Environment Promotion** — A new MCP server version passes CI in staging; Priya promotes it to production by updating a single tag in the production values file and merging the GitOps PR.
3. **Fleet Health Dashboard** — Priya opens the MCP Host admin console and sees the health, request rate, error rate, and resource consumption of every hosted MCP server across all environments in one view.
