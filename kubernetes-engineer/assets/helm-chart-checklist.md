# Helm Chart Pre-Publish Quality Gate

Run this checklist before releasing or deploying a Helm chart to production. All items in Metadata and Templates must pass. Items in Testing and Documentation must pass for new charts; mark N/A only for known internal-only charts.

**Chart Name:** ___________________
**Chart Version:** ___________________
**App Version:** ___________________
**Reviewer:** ___________________
**Date:** ___________________

---

## Section 1: Metadata

- [ ] `Chart.yaml` has `name`, `version`, `appVersion`, `description`, and `type` fields set
- [ ] `version` follows SemVer (MAJOR.MINOR.PATCH)
- [ ] `appVersion` matches the container image tag being shipped
- [ ] `type` is explicitly `application` or `library`
- [ ] Chart has a `maintainers` entry (name + email)
- [ ] Dependencies declared in `Chart.yaml` are pinned to a version range (not `*`)
- [ ] `helm dependency update` has been run and `charts/` lockfile (`Chart.lock`) is committed
- [ ] `.helmignore` excludes test fixtures, CI files, and editor artifacts

---

## Section 2: Templates

- [ ] All templates pass `helm lint` with no errors or warnings
- [ ] `helm template` renders without errors for default values
- [ ] No hardcoded namespace strings — all templates use `{{ .Release.Namespace }}`
- [ ] No hardcoded image tags — image tag sourced from `values.yaml`
- [ ] All resource names use the `fullname` helper or a consistent naming pattern
- [ ] All resources carry standard labels: `app.kubernetes.io/name`, `app.kubernetes.io/instance`, `app.kubernetes.io/version`, `helm.sh/chart`
- [ ] `Deployment`/`StatefulSet` has `readinessProbe` defined on all containers
- [ ] `Deployment`/`StatefulSet` has `livenessProbe` defined on all containers
- [ ] All containers have `resources.requests` and `resources.limits` set (or defaulted via values)
- [ ] `terminationGracePeriodSeconds` is explicitly set for stateful workloads
- [ ] `PodDisruptionBudget` is included for workloads with `replicas >= 2`
- [ ] No `hostNetwork`, `hostPID`, or `hostIPC` unless explicitly required and gated by a value flag
- [ ] `ServiceAccount` is scoped to the chart's namespace — no ClusterRole unless required
- [ ] Secrets are referenced via `secretKeyRef` — not embedded as plaintext in ConfigMaps
- [ ] Ingress templates include TLS configuration block

---

## Section 3: Values

- [ ] `values.yaml` has a comment for every non-obvious key
- [ ] All values used in templates have a default in `values.yaml`
- [ ] Image configuration follows the standard pattern: `image.repository`, `image.tag`, `image.pullPolicy`
- [ ] `imagePullSecrets` is configurable (even if empty by default)
- [ ] Resource requests/limits are tunable via values (not hardcoded in templates)
- [ ] Replica count is configurable (`replicaCount`)
- [ ] Feature flags use boolean values (not string `"true"`/`"false"`)
- [ ] Sensitive default values (passwords, tokens) are empty string `""` — never a real value

---

## Section 4: Testing

- [ ] `templates/tests/` directory contains at least one Helm test pod
- [ ] Helm test passes: `helm test <release> -n <namespace>`
- [ ] Chart has been deployed to a staging environment and all pods reached `Running`/`Ready`
- [ ] Upgrade from the previous chart version tested (no breaking changes to PVCs, RBAC, or CRDs)
- [ ] Rollback tested: `helm rollback <release> -n <namespace>` leaves the cluster in a healthy state
- [ ] `helm diff upgrade` (helm-diff plugin) reviewed for unintended changes

---

## Section 5: Documentation

- [ ] `README.md` exists with: purpose, prerequisites, quick-start install command, values table
- [ ] Values table documents: key, type, default, description for all configurable values
- [ ] Breaking changes between versions documented in `CHANGELOG.md` or release notes
- [ ] Runbook linked or included for common operational tasks (restart, scale, backup)

---

## Sign-Off

| Gate | Result |
|------|--------|
| Metadata | Pass / Fail |
| Templates | Pass / Fail |
| Values | Pass / Fail |
| Testing | Pass / Fail / N/A |
| Documentation | Pass / Fail / N/A |

**Approved to publish:** `[ ] Yes` `[ ] No`

**Notes:** ___________________
