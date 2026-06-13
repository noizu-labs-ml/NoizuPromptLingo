---
name: trl-kubernetes-engineer
description: >
  Design, deploy, and harden production Kubernetes clusters and Helm charts
  with idiomatic patterns, security best practices, and ecosystem tooling.
  Use this skill when the user wants to write Helm charts, design CRDs,
  refactor K8s manifests, configure autoscaling (Karpenter, KEDA, HPA/VPA),
  harden cluster security, set up GitOps pipelines, optimize costs, debug
  workloads, publish Helm charts, or architect multi-tenant namespaces —
  even if they don't say "Kubernetes." Also trigger when users mention
  kubectl, helm, kustomize, ArgoCD, Flux, Karpenter, KEDA, kubebuilder,
  operator-sdk, Ingress, Gateway API, NetworkPolicy, PodDisruptionBudget,
  StatefulSet, DaemonSet, CronJob, ServiceAccount, RBAC, Pod Security
  Standards, OPA, Kyverno, Velero, OpenEBS, Longhorn, or Prometheus.
---

# Kubernetes Engineer

Production-grade Kubernetes and Helm engineering — from chart authoring through cluster hardening, autoscaling, GitOps, and operational excellence.

## Overview

This skill provides:

- **Helm mastery** — Chart architecture, library charts, values schema, testing pipelines, OCI publishing, Helmfile orchestration
- **Cluster hardening** — Pod Security Standards, RBAC design, NetworkPolicy, admission controllers, image signing, audit logging
- **Autoscaling** — Karpenter node provisioning, KEDA event-driven scaling, HPA/VPA coordination, cost-aware scaling
- **CRD & operator design** — API conventions, kubebuilder scaffolding, CEL validation, status subresources, conversion webhooks
- **GitOps** — ArgoCD patterns, ApplicationSets, app-of-apps, progressive delivery with Argo Rollouts
- **Operational cookbook** — Zero-downtime deployments, StatefulSet migrations, multi-tenant namespaces, storage patterns

## Core Philosophy

1. **Declarative over imperative** — Express desired state in version-controlled manifests; let controllers converge. Never `kubectl edit` in production.
2. **Least privilege by default** — Restricted Pod Security Standards, deny-all NetworkPolicies, scoped RBAC. Open only what's needed.
3. **Fail fast, recover automatically** — Resource limits, PodDisruptionBudgets, liveness/readiness/startup probes, and rollback strategies. Don't let bad deploys linger.
4. **Environment-agnostic charts** — Helm charts should be parameterized, never environment-aware. `values-prod.yaml` is a thin overlay, not a fork.
5. **Observe everything** — If you can't alert on it, you can't operate it. Metrics, logs, traces, and SLO-based alerting are non-negotiable for production workloads.

## When to Use This Skill

- **Writing or refactoring Helm charts** — Chart structure, library extraction, values schema, template patterns
- **Designing Custom Resource Definitions** — API design, kubebuilder markers, CEL validation, operator patterns
- **Hardening cluster security** — Pod Security Standards, RBAC audit, NetworkPolicy design, admission policies
- **Configuring autoscaling** — Karpenter NodePools, KEDA ScaledObjects, HPA tuning, VPA recommendations
- **Setting up GitOps** — ArgoCD app-of-apps, ApplicationSets, sync policies, progressive delivery
- **Debugging production issues** — Pod scheduling failures, OOMKills, CrashLoopBackOff, network connectivity, DNS resolution
- **Optimizing costs** — Right-sizing workloads, spot instances, resource quotas, idle resource detection
- **Publishing Helm charts** — OCI registry publishing, chart testing CI, helm-docs generation, semantic versioning

> For Terraform-based infrastructure provisioning (VPCs, node groups, cloud resources), see **trl-terraform-engineer**.
> For threat modeling and security architecture review, see **trl-threat-modeler**.
> For database schema design and query tuning (PostgreSQL), see **trl-dba-db-designer-and-tuning**.

## Helm Chart Architecture

### Chart Types

| Type | Purpose | Example |
|------|---------|---------|
| **Application chart** | Deploys a single service with its resources | `nginx-ingress`, `prometheus` |
| **Library chart** | Shared templates, no rendered resources | `cloudflare-lib`, `common` |
| **Umbrella chart** | Dependencies only, orchestrates sub-charts | `kube-prometheus-stack` |
| **Multi-service chart** | Conditional rendering per service | `bob-infra` (Pattern B) |

### Values Schema

Always include `values.schema.json` to enforce types and required fields at install time:

```json
{
  "$schema": "https://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["image", "service"],
  "properties": {
    "image": {
      "type": "object",
      "required": ["repository", "tag"],
      "properties": {
        "repository": { "type": "string" },
        "tag": { "type": "string", "pattern": "^v[0-9]+\\.[0-9]+\\.[0-9]+$" }
      }
    }
  }
}
```

### Template Best Practices

| Pattern | Do | Don't |
|---------|----|----|
| **Labels** | Generate in `_helpers.tpl`, include `app.kubernetes.io/*` standard labels | Hardcode labels in each template |
| **Naming** | `{{ include "mychart.fullname" . }}` helper | `{{ .Release.Name }}-{{ .Chart.Name }}` inline |
| **Conditionals** | `{{- if .Values.ingress.enabled }}` wrapping entire resources | `if .Values.env == "prod"` environment checks |
| **Defaults** | `{{ .Values.replicas | default 1 }}` | Requiring every value to be set |
| **Indentation** | `nindent` for predictable whitespace | `indent` (context-dependent, error-prone) |
| **Strings** | `{{ .Values.name | quote }}` | Unquoted values that might contain special chars |

### Library Chart Extraction

Extract to a library chart when you see the same template logic in 2+ charts:

1. Create `Chart.yaml` with `type: library`
2. Move shared templates to `templates/_helpers.tpl` with a `define` block
3. Add as dependency in consuming charts
4. Run `helm dependency update` in each consumer

> For the full Helm best practices guide, see [references/helm-best-practices.md](references/helm-best-practices.md).
> For refactoring patterns and library extraction walkthrough, see [references/helm-chart-refactoring.md](references/helm-chart-refactoring.md).

## Kubernetes Anti-Patterns

### The Critical Seven

| Anti-Pattern | Why It's Dangerous | Fix |
|---|---|---|
| No resource requests/limits | Scheduler can't make informed decisions; nodes overcommit | Set both; use `Guaranteed` QoS for critical pods |
| `:latest` image tag | Non-deterministic deploys; can't rollback to known state | Pin to digest or semver tag |
| No PodDisruptionBudgets | Node drain evicts all replicas simultaneously | `minAvailable: 1` or `maxUnavailable: 1` |
| No NetworkPolicies | Any pod can reach any pod; lateral movement is trivial | Default deny-all per namespace, then allowlist |
| Privileged containers | Full host access; container escape is trivial | `restricted` Pod Security Standard |
| Bare Pods (no controller) | No rescheduling on node failure; no rollback | Always use Deployment/StatefulSet/Job |
| VPA + HPA on same metric | Feedback loop causes thrashing | VPA on memory, HPA on CPU (or recommender-only) |

> For the full anti-pattern catalog with remediation recipes, see [references/anti-patterns.md](references/anti-patterns.md).

## Autoscaling

### Decision Tree

```
Need to scale?
├── Nodes → Karpenter (or cluster-autoscaler)
├── Pods (event-driven, 0→N) → KEDA
├── Pods (CPU/memory, 1→N) → HPA
└── Pod resources (vertical) → VPA (recommender mode)
```

### Karpenter Quick Reference

| Concept | Best Practice |
|---------|---------------|
| **NodePools** | Segment by workload class (GPU, spot-tolerant, system) |
| **Instance diversity** | 15+ instance types per NodePool for spot consolidation |
| **Consolidation** | `WhenEmpty` + `WhenUnderutilized`; tune `consolidateAfter` |
| **Node TTL** | Set `expireAfter` for AMI drift remediation |
| **PDBs** | Always pair with PDBs; single-replica pods get evicted otherwise |

### KEDA Quick Reference

| Concept | Best Practice |
|---------|---------------|
| **Stabilization** | `stabilizationWindowSeconds: 300` on both directions |
| **Fallback** | Configure `fallback.replicas` for metrics outages |
| **Activation vs scaling** | Separate 0→1 threshold from 1→N scaling |
| **Polling** | Tune `pollingInterval` per trigger freshness |
| **Object vs Job** | `ScaledObject` for services, `ScaledJob` for batch consumers |

> For deep dives: [references/autoscaling/karpenter.md](references/autoscaling/karpenter.md), [references/autoscaling/keda.md](references/autoscaling/keda.md).

## Custom CRD Design

### API Design Principles

1. **Spec/Status separation** — `.spec` is user intent, `.status` is controller-observed state
2. **Subresource isolation** — Use `+kubebuilder:subresource:status` to separate update permissions
3. **CEL over webhooks** — Validation rules in the schema (GA since 1.29) beat admission webhooks for latency and reliability
4. **Print columns** — Add `+kubebuilder:printcolumn` for useful `kubectl get` output
5. **Idempotent reconciliation** — The same input state must always produce the same output; breaking this violates controller-runtime's contract

### Field Constraints for CEL

Always bound collection and string fields to keep CEL cost estimation tractable:

```yaml
properties:
  items:
    type: array
    maxItems: 100
    items:
      type: object
      properties:
        name:
          type: string
          maxLength: 253
```

### Versioning Strategy

| Situation | Action |
|-----------|--------|
| New CRD | Start at `v1alpha1` |
| Breaking change | New version (`v1alpha2`), conversion webhook |
| Stable API | Promote to `v1` with backwards compatibility guarantee |
| Deprecation | Serve old version, store new; set `deprecated: true` |

> For the full CRD design guide, see [references/crd-design.md](references/crd-design.md).

## Security Hardening

### Layer Model

| Layer | Controls | Tools |
|-------|----------|-------|
| **Cluster** | API server audit logging, etcd encryption, node hardening | kube-bench, CIS Benchmark |
| **Namespace** | Pod Security Standards, ResourceQuotas, LimitRanges, NetworkPolicies | Built-in labels |
| **Workload** | Non-root, read-only rootfs, dropped capabilities, seccomp profiles | Kyverno/Gatekeeper |
| **Supply chain** | Image signing, registry allowlists, SBOM, vulnerability scanning | cosign, Trivy, Grype |
| **Runtime** | Syscall monitoring, anomaly detection, forensics | Falco, Tetragon |

### Pod Security Standards

| Level | Use When |
|-------|----------|
| `privileged` | System-level workloads (CNI, CSI, logging DaemonSets) |
| `baseline` | Legacy workloads being migrated; minimum viable security |
| `restricted` | All application workloads (default for new namespaces) |

Apply via namespace labels:
```yaml
metadata:
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/warn: restricted
    pod-security.kubernetes.io/audit: restricted
```

> For the full security hardening guide, see [references/security-hardening.md](references/security-hardening.md).

## GitOps

### ArgoCD Patterns

| Pattern | When to Use |
|---------|-------------|
| **App-of-apps** | Root Application generates child Applications per service |
| **ApplicationSets** | Template hundreds of apps from a single source with generators |
| **Sync windows** | Block production deploys outside maintenance hours |
| **Auto-sync + self-heal** | Dev/staging; production should require manual sync or PR approval |
| **Progressive delivery** | Argo Rollouts for canary/blue-green with Prometheus analysis |

### Repository Structure

```
config-repo/
├── apps/                    # ApplicationSet or app-of-apps root
│   ├── base/               # Shared manifests
│   └── overlays/           # Per-environment values
│       ├── dev/
│       ├── staging/
│       └── prod/
├── infrastructure/          # Cluster-level resources
│   ├── namespaces/
│   ├── rbac/
│   └── policies/
└── argocd/                  # ArgoCD self-management
    └── argocd-app.yaml
```

> For the full GitOps guide, see [references/gitops.md](references/gitops.md).

## Observability

### Stack Recommendations

| Layer | Recommended | Alternative | Anti-Pattern |
|-------|------------|-------------|--------------|
| **Metrics** | VictoriaMetrics | Prometheus | No remote-write in multi-cluster |
| **Logs** | Loki + Fluent Bit | EFK stack | Fluentd (high memory footprint) |
| **Traces** | Tempo via OTel Collector | Jaeger | Direct SDK instrumentation |
| **Alerting** | SLO-based (Sloth/Pyrra) | PrometheusRules | Static threshold alerts |
| **Dashboards** | Grafana | — | Per-team siloed dashboards |

> For the full observability guide, see [references/observability.md](references/observability.md).

## Storage Patterns

| Storage Class | Best For | IOPS | HA |
|--------------|----------|------|----|
| **OpenEBS LVM LocalPV** | High-perf local storage, bare metal | Host disk speed | No (node-local) |
| **OpenEBS Mayastor** | NVMe workloads needing replication | ~28K | Yes |
| **Longhorn** | Simplicity-first HA storage | ~19K | Yes (replicated) |
| **Rook-Ceph** | Large-scale distributed storage | High | Yes |

### Key Patterns

- Use `WaitForFirstConsumer` on all StorageClasses
- Pre-provision PVs with `claimRef` for deterministic binding
- `volumeClaimTemplates` in StatefulSets for per-replica PVCs
- Velero + CSI snapshots for backup; test restores regularly

> For the full storage guide, see [references/storage-patterns.md](references/storage-patterns.md).

## Networking

### Ingress Evolution

| Generation | API | Status |
|-----------|-----|--------|
| Ingress (v1) | `networking.k8s.io/v1` | Legacy, limited to HTTP |
| Gateway API | `gateway.networking.k8s.io/v1` | Current standard, multi-protocol |

**Recommended data plane:** Envoy Gateway (strongest Gateway API conformance).

### Service Mesh Decision

| Need | Solution |
|------|----------|
| mTLS only | Istio Ambient (ztunnel layer, no sidecars) |
| Full L7 policy | Istio Ambient with waypoint proxies |
| Simplicity + low overhead | Linkerd |
| L7 NetworkPolicy | Cilium (no mesh needed) |

> For the full networking guide, see [references/networking.md](references/networking.md).

## Cost Optimization

| Strategy | Savings | Effort |
|----------|---------|--------|
| Right-size with VPA recommender | 20-40% | Low |
| Karpenter consolidation + spot | 50-60% | Medium |
| Scale non-prod to zero off-hours | 30-50% off-hours | Low |
| ResourceQuotas per namespace | Prevents runaway | Low |
| Orphan cleanup (PVCs, LBs) | Variable | Low |

> For the full cost optimization guide, see [references/cost-optimization.md](references/cost-optimization.md).

## Quick Start Guides

### Write a New Helm Chart
1. `helm create mychart` — scaffold
2. Delete the default templates you don't need
3. Add `values.schema.json` — enforce required fields
4. Read [references/helm-best-practices.md](references/helm-best-practices.md) for template patterns
5. Test with `helm-unittest` and `ct lint`
6. Publish to OCI registry

### Harden a Namespace
1. Apply `restricted` Pod Security Standard labels
2. Create default-deny NetworkPolicy
3. Set ResourceQuota and LimitRange
4. Create scoped ServiceAccount + RoleBinding
5. Read [references/security-hardening.md](references/security-hardening.md) for the full checklist

### Design a CRD
1. `kubebuilder init` + `kubebuilder create api`
2. Define `.spec` and `.status` types
3. Add CEL validation rules and print columns
4. Implement idempotent reconciler
5. Read [references/crd-design.md](references/crd-design.md) for API conventions

### Debug a Failing Pod
1. `kubectl describe pod <name>` — check Events
2. `kubectl logs <name> --previous` — check crash logs
3. Check resource limits vs actual usage
4. Check node conditions and taints
5. Read [references/cookbook/debugging-workloads.md](references/cookbook/debugging-workloads.md)

## Reference Guide

| Task | Read These |
|------|-----------|
| **Helm chart authoring** | `helm-best-practices.md` |
| **Helm refactoring** | `helm-chart-refactoring.md` |
| **Security hardening** | `security-hardening.md` |
| **CRD/operator design** | `crd-design.md` |
| **Karpenter setup** | `autoscaling/karpenter.md` |
| **KEDA setup** | `autoscaling/keda.md` |
| **GitOps with ArgoCD** | `gitops.md` |
| **Observability stack** | `observability.md` |
| **Storage architecture** | `storage-patterns.md` |
| **Networking & ingress** | `networking.md` |
| **Cost optimization** | `cost-optimization.md` |
| **Anti-pattern catalog** | `anti-patterns.md` |
| **Cookbook recipes** | `cookbook/index.md` |
| **Agent execution workflows** | `agent-playbook.claude-code.md` |

All reference paths are relative to `references/`.

## Related Skills

- **trl-terraform-engineer** — Infrastructure provisioning (VPCs, node groups, cloud resources) that feeds into K8s cluster setup
- **trl-threat-modeler** — Security architecture review and threat modeling for K8s deployments
- **trl-dba-db-designer-and-tuning** — Database workloads running on K8s (PostgreSQL StatefulSets, connection pooling)
- **trl-skill-engineer** — Meta-skill for designing and building new skills

## Bundled Resources

### References

**Foundation** (read first):
- [helm-best-practices.md](references/helm-best-practices.md) — Chart structure, template patterns, testing, OCI publishing, Helmfile
- [helm-chart-refactoring.md](references/helm-chart-refactoring.md) — Library extraction, values organization, DRY patterns, multi-environment management
- [anti-patterns.md](references/anti-patterns.md) — 20+ anti-patterns with severity, detection, and remediation recipes
- [agent-playbook.claude-code.md](references/agent-playbook.claude-code.md) — Agent role definition and execution workflows

**Deep Dives:**
- [security-hardening.md](references/security-hardening.md) — Pod Security Standards, RBAC, NetworkPolicy, admission controllers, supply chain security
- [crd-design.md](references/crd-design.md) — API conventions, kubebuilder, CEL validation, operator patterns, versioning
- [gitops.md](references/gitops.md) — ArgoCD, ApplicationSets, app-of-apps, progressive delivery, Flux
- [observability.md](references/observability.md) — Metrics, logs, traces, SLO alerting, dashboard design
- [storage-patterns.md](references/storage-patterns.md) — CSI drivers, StatefulSet patterns, backup/restore, storage comparison
- [networking.md](references/networking.md) — Gateway API, service mesh, DNS tuning, NetworkPolicy design
- [cost-optimization.md](references/cost-optimization.md) — Right-sizing, spot instances, quotas, idle detection, Kubecost

**Autoscaling** (`references/autoscaling/`):
- [karpenter.md](references/autoscaling/karpenter.md) — NodePool design, consolidation policies, spot strategies, migration from cluster-autoscaler
- [keda.md](references/autoscaling/keda.md) — ScaledObject/ScaledJob patterns, trigger types, stabilization, fallback

**Cookbook** (`references/cookbook/`):
- [index.md](references/cookbook/index.md) — Recipe index with difficulty ratings and prerequisites
- [zero-downtime-deploy.md](references/cookbook/zero-downtime-deploy.md) — Rolling updates, readiness gates, PDB configuration
- [multi-tenant-namespace.md](references/cookbook/multi-tenant-namespace.md) — Namespace isolation, quotas, RBAC, network boundaries
- [statefulset-migration.md](references/cookbook/statefulset-migration.md) — Data migration, PV rebinding, ordered rollout
- [helm-library-extraction.md](references/cookbook/helm-library-extraction.md) — Step-by-step library chart extraction from duplicated templates
- [debugging-workloads.md](references/cookbook/debugging-workloads.md) — Systematic debugging flowchart for common failure modes

### Assets

- [cluster-audit-worksheet.md](assets/cluster-audit-worksheet.md) — Fillable cluster health and security audit checklist
- [helm-chart-checklist.md](assets/helm-chart-checklist.md) — Pre-publish Helm chart quality gate
- [project-tracker.md](assets/project-tracker.md) — K8s project milestone and deliverable tracker
