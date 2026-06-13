# Cluster Audit Worksheet

Use this worksheet during periodic cluster health reviews, pre-production sign-offs, or incident postmortems. Fill in blanks, check boxes, and note findings in the Comments column.

**Audit Date:** ___________________
**Auditor:** ___________________
**Cluster Name:** ___________________
**Environment:** `[ ] dev` `[ ] staging` `[ ] production`

---

## Section 1: Cluster Info

| Field | Value |
|-------|-------|
| Kubernetes version | |
| CNI plugin + version | |
| Container runtime | |
| Cloud provider / bare metal | |
| Node count (control plane) | |
| Node count (workers) | |
| Total cluster CPU (allocatable) | |
| Total cluster Memory (allocatable) | |
| Storage backends in use | |
| Ingress controller + version | |
| Metrics server installed | yes / no |
| Cluster age | |

---

## Section 2: Security Checks

### RBAC

- [ ] No ClusterRoleBindings grant `cluster-admin` to service accounts or user groups except break-glass accounts
- [ ] `system:anonymous` and `system:unauthenticated` have no ClusterRoleBindings
- [ ] All namespaces have a dedicated ServiceAccount — no workloads use the `default` SA
- [ ] `automountServiceAccountToken: false` on all SAs that don't need API access
- [ ] No wildcard `*` verbs on sensitive resources (secrets, configmaps) in production namespaces

**Comments:** ___________________

### Pod Security

- [ ] Pod Security Standards labels are set on all namespaces (`enforce`, `warn`, `audit`)
- [ ] No pods running as UID 0 in production namespaces
- [ ] No pods with `hostNetwork: true` except approved infra components (list: _________)
- [ ] No pods with `hostPID: true` or `hostIPC: true` in production
- [ ] All containers have `allowPrivilegeEscalation: false`
- [ ] No containers with `privileged: true` in production

**Comments:** ___________________

### Secrets

- [ ] No secrets hardcoded in ConfigMaps or pod environment variables (use secretKeyRef)
- [ ] Secrets managed by external operator (Infisical, Vault, ESO) — not committed to Git
- [ ] Secret rotation policy documented and tested
- [ ] etcd encryption at rest enabled (check with `kubectl get apiserver` or cloud console)

**Comments:** ___________________

### Network

- [ ] Default-deny NetworkPolicy applied to all production namespaces
- [ ] Ingress traffic reaches pods only through allowed ingress controller namespace
- [ ] No NodePort Services exposed to public internet without explicit justification
- [ ] API server access restricted to known CIDRs (cloud firewall or `--authorized-ip-ranges`)

**Comments:** ___________________

---

## Section 3: Resource Checks

### Quotas and Limits

- [ ] ResourceQuota defined for all production namespaces
- [ ] LimitRange defined for all production namespaces (default requests/limits set)
- [ ] All containers have `resources.requests` and `resources.limits` set
- [ ] No namespace is at >80% of its CPU or memory quota

**Commands to check:**
```bash
kubectl describe resourcequota -A | grep -A 3 "Resource\|Used\|Hard"
kubectl top pods -A --sort-by=memory | head -20
```

**Comments:** ___________________

### Storage

- [ ] No PVCs in `Pending` state
- [ ] No PVs in `Released` or `Failed` state
- [ ] All PVs have reclaim policy set appropriately (`Retain` for stateful production data)
- [ ] Disk usage on nodes below 75% (check `DiskPressure` condition)
- [ ] Backup of stateful PVs verified within the last _____ days

**Comments:** ___________________

### Workload Health

- [ ] No pods in `CrashLoopBackOff`, `Error`, or `OOMKilled` state
- [ ] No pods in `Pending` state for more than 5 minutes
- [ ] All Deployments and StatefulSets have desired replica count met
- [ ] All PodDisruptionBudgets have `DisruptionsAllowed >= 1`
- [ ] HPA min/max replicas reviewed — not stuck at min under normal load

**Comments:** ___________________

---

## Section 4: Observability Checks

- [ ] Metrics pipeline healthy: Prometheus scraping all targets (check `/targets` page)
- [ ] Alertmanager routing verified — test alert fired and delivered within SLA
- [ ] Log aggregation collecting from all namespaces
- [ ] Dashboards exist for: cluster overview, per-namespace resource usage, ingress error rate
- [ ] Audit log enabled and being retained for _____ days
- [ ] Tracing enabled for production services (if applicable)
- [ ] On-call runbook links are current and accessible

**Comments:** ___________________

---

## Section 5: Backup and Disaster Recovery

- [ ] etcd backup configured and tested within the last 30 days
- [ ] Stateful PV backups running on schedule (tool: _________)
- [ ] Last backup restore test date: ___________________
- [ ] RTO documented: _______  RPO documented: _______
- [ ] Cluster can be rebuilt from IaC (Terraform/Ansible/scripts) without manual steps
- [ ] Runbook for node failure exists and is current
- [ ] Runbook for full cluster rebuild exists and is current
- [ ] DR environment tested within the last _____ days

**Comments:** ___________________

---

## Summary

| Section | Status | Critical Findings |
|---------|--------|------------------|
| Security | Pass / Fail / Partial | |
| Resource | Pass / Fail / Partial | |
| Observability | Pass / Fail / Partial | |
| Backup & DR | Pass / Fail / Partial | |

**Overall Status:** `[ ] Pass` `[ ] Fail` `[ ] Conditional Pass`

**Action Items:**

1. ___________________
2. ___________________
3. ___________________

**Next Audit Date:** ___________________
