# Kubernetes Project Tracker

## Project Info

| Field | Value |
|-------|-------|
| **Project** | ___ |
| **Goal** | ___ |
| **Start Date** | ___ |
| **Target Date** | ___ |
| **Owner** | ___ |
| **Cluster** | ___ |
| **Namespaces** | ___ |

## Milestones

| # | Milestone | Status | Target | Completed | Notes |
|---|-----------|--------|--------|-----------|-------|
| 1 | Requirements gathered | Not Started | | | |
| 2 | Architecture designed | Not Started | | | |
| 3 | Helm chart scaffolded | Not Started | | | |
| 4 | Security hardened | Not Started | | | |
| 5 | Testing pipeline configured | Not Started | | | |
| 6 | Observability wired up | Not Started | | | |
| 7 | Staging deployed | Not Started | | | |
| 8 | Production deployed | Not Started | | | |
| 9 | Documentation complete | Not Started | | | |

## Decisions Log

| Date | Decision | Rationale | Decided By |
|------|----------|-----------|------------|
| | | | |

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation | Status |
|------|-----------|--------|------------|--------|
| | | | | |

## Dependencies

| Dependency | Type | Status | Owner | Notes |
|-----------|------|--------|-------|-------|
| | External/Internal | | | |

## Checklist

### Pre-Deploy

- [ ] Resource requests/limits set on all containers
- [ ] PodDisruptionBudgets configured
- [ ] Image tags pinned (no :latest)
- [ ] Pod Security Standards enforced
- [ ] NetworkPolicies applied
- [ ] RBAC scoped to least privilege
- [ ] Health probes configured (readiness, liveness, startup)
- [ ] Graceful shutdown handled (preStop, SIGTERM)
- [ ] Secrets managed via external operator (not .envrc)
- [ ] Helm values.schema.json validates inputs

### Post-Deploy

- [ ] Metrics visible in Grafana
- [ ] Logs flowing to Loki
- [ ] Alerts configured for SLOs
- [ ] Runbook created for on-call
- [ ] Backup schedule verified (if stateful)
- [ ] Upgrade path tested (helm upgrade --install)
