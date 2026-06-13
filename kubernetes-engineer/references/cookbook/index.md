# Kubernetes Cookbook — Recipe Index

A curated set of production-tested recipes for common Kubernetes engineering tasks.
Each recipe is self-contained: background, working YAML, step-by-step commands, and verification.

---

## How to Use This Cookbook

1. Find your task in the table below.
2. Check the **Prerequisites** column — ensure you have the background before diving in.
3. Open the linked file and follow the recipe top to bottom.
4. Adapt the YAML examples to your namespace, image, and resource constraints.

---

## Recipe Index

| Recipe | Difficulty | Prerequisites | File |
|--------|-----------|---------------|------|
| Zero-Downtime Deployments | Beginner | Deployment basics, kubectl | [zero-downtime-deploy.md](zero-downtime-deploy.md) |
| Multi-Tenant Namespace Isolation | Intermediate | RBAC, NetworkPolicy | [multi-tenant-namespace.md](multi-tenant-namespace.md) |
| StatefulSet Data Migration | Advanced | StatefulSet, PersistentVolumes, storage drivers | [statefulset-migration.md](statefulset-migration.md) |
| Helm Library Chart Extraction | Intermediate | Helm templating, Go templates | [helm-library-extraction.md](helm-library-extraction.md) |
| Debugging Workloads | Beginner | kubectl, basic Kubernetes objects | [debugging-workloads.md](debugging-workloads.md) |

---

## Difficulty Guide

| Level | Meaning |
|-------|---------|
| **Beginner** | Requires only kubectl and basic object familiarity. Safe to run in dev/staging. |
| **Intermediate** | Requires understanding of at least two Kubernetes subsystems. Test in staging first. |
| **Advanced** | Involves stateful data, storage, or cross-system coordination. Requires a rollback plan. |

---

## Prerequisites Quick Reference

| Topic | What You Need to Know |
|-------|-----------------------|
| Deployment basics | `kubectl rollout`, `spec.strategy`, replica sets |
| RBAC | `Role`, `ClusterRole`, `RoleBinding`, service accounts |
| NetworkPolicy | CNI plugin support, ingress/egress rule syntax |
| StatefulSet | Ordered pod management, stable network identities, PVC templates |
| PersistentVolumes | `PV`, `PVC`, `StorageClass`, `claimRef`, access modes |
| Helm templating | `_helpers.tpl`, `include`, `Chart.yaml`, `values.yaml` |

---

## Related Assets

- `assets/cluster-audit-worksheet.md` — Fillable checklist for cluster health reviews
- `assets/helm-chart-checklist.md` — Pre-publish quality gate for Helm charts
- `references/patterns/` — Architectural patterns (sidecar, init containers, etc.)
- `references/autoscaling/` — HPA, VPA, KEDA recipes

---

## Contributing a Recipe

1. Use an existing recipe as a template.
2. Include: **Goal**, **Prerequisites**, **Background**, **Full YAML Example**, **Step-by-Step**, **Verification**, **Rollback**.
3. Add a row to this index table.
4. Keep YAML examples namespace-scoped and free of hardcoded secrets.
