# Helm Chart Refactoring Guide

A practical guide to recognizing when Helm charts have outgrown their initial structure, and how to safely refactor them without breaking deployments.

---

## Table of Contents

1. [When to Refactor](#when-to-refactor)
2. [Library Chart Extraction](#library-chart-extraction)
3. [Values.yaml Organization](#valuesyaml-organization)
4. [Multi-Environment Management](#multi-environment-management)
5. [DRY Patterns with _helpers.tpl](#dry-patterns-with-_helperstpl)
6. [Multi-Service Charts with Conditional Rendering](#multi-service-charts-with-conditional-rendering)
7. [Migration Checklist](#migration-checklist)

---

## When to Refactor

### Duplication Signals

Refactoring is warranted when you observe:

| Signal | Description |
|--------|-------------|
| Copy-pasted `_helpers.tpl` | Same `fullname`, `labels`, `selectorLabels` blocks across 2+ charts |
| Environment conditionals in templates | `{{- if eq .Values.env "prod" }}` branches |
| Flat values.yaml | 50+ top-level keys with no grouping |
| Hardcoded namespaces | `namespace: my-app` instead of `{{ .Release.Namespace }}` |
| Repeated service/deployment boilerplate | Near-identical templates across multiple charts |
| Values without schema | Callers passing typo'd keys silently ignored |
| Missing upgrade test | Chart installs fine but upgrade has never been validated |

### Maintainability Triggers

- Adding a new app requires copying an entire chart directory
- A label change requires editing N chart repositories
- Onboarding a new team member requires reading 4+ charts to understand conventions
- A security default (securityContext) must be manually kept in sync across charts

### Refactoring Is NOT Always the Answer

Do not refactor when:
- The chart is only used once and unlikely to grow
- The duplication is superficial (similar names, different logic)
- Teams own the charts independently and have diverging requirements
- You're in the middle of a production incident (always stabilize first)

---

## Library Chart Extraction

### Step 1: Identify Shared Templates

Audit your charts and list templates that appear in 2+ places:

```bash
# Find duplicate template definitions across charts
grep -rh "{{- define " charts/ | sort | uniq -d
```

Common candidates:
- `fullname` / `name` helpers
- `labels` / `selectorLabels`
- `serviceAccountName`
- Standard `securityContext` blocks
- Resource limit defaults

### Step 2: Create the Library Chart

```bash
mkdir -p charts/common-lib/templates
```

`charts/common-lib/Chart.yaml`:

```yaml
apiVersion: v2
name: common-lib
version: 1.0.0
type: library
description: Shared Helm templates for the org
```

`charts/common-lib/templates/_helpers.tpl`:

```yaml
{{/*
Standard org labels. Call with: include "common-lib.labels" .
*/}}
{{- define "common-lib.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/name: {{ default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels — stable, minimal. Never add version here.
*/}}
{{- define "common-lib.selectorLabels" -}}
app.kubernetes.io/name: {{ default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Default container security context
*/}}
{{- define "common-lib.containerSecurityContext" -}}
allowPrivilegeEscalation: false
capabilities:
  drop: [ALL]
readOnlyRootFilesystem: true
runAsNonRoot: true
runAsUser: 1000
{{- end }}
```

Library charts have no `templates/*.yaml` resource files — only named template definitions in `_*.tpl` files.

### Step 3: Add Library as Dependency

In each consuming chart's `Chart.yaml`:

```yaml
dependencies:
  - name: common-lib
    version: "1.x.x"
    repository: "oci://ghcr.io/org/charts"   # or file://../common-lib for local dev
```

```bash
helm dependency update charts/my-app
```

### Step 4: Replace Duplicate Blocks in Consuming Charts

Before (in `charts/my-app/templates/_helpers.tpl`):

```yaml
{{- define "my-app.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/name: {{ default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
```

After:

```yaml
{{/*
my-app.labels — delegates to shared library
*/}}
{{- define "my-app.labels" -}}
{{- include "common-lib.labels" . }}
{{- end }}
```

Or call the library directly from resource templates (no wrapper needed):

```yaml
# templates/deployment.yaml
metadata:
  labels:
    {{- include "common-lib.labels" . | nindent 4 }}
```

### Step 5: Test the Migration

```bash
# Render before (save baseline)
helm template my-app ./charts/my-app > /tmp/before.yaml

# Add dependency, update, re-render
helm dependency update ./charts/my-app
helm template my-app ./charts/my-app > /tmp/after.yaml

# Diff — only whitespace and comment changes expected
diff /tmp/before.yaml /tmp/after.yaml
```

---

## Values.yaml Organization

### Flat vs Nested

**Before (flat — difficult to scan):**

```yaml
appName: my-app
appReplicas: 1
appImage: ghcr.io/org/my-app
appImageTag: v1.2.0
appImagePullPolicy: IfNotPresent
appPort: 8080
appServiceType: ClusterIP
appServicePort: 80
appIngressEnabled: false
appIngressHost: my-app.example.com
appIngressClass: nginx
appResourcesCpuRequest: 100m
appResourcesMemoryRequest: 128Mi
appResourcesMemoryLimit: 256Mi
appLogLevel: info
appDbHost: postgres
appDbPort: 5432
appDbName: my_app
appDbUser: app
```

**After (nested — grouped by resource):**

```yaml
replicaCount: 1

image:
  repository: ghcr.io/org/my-app
  tag: v1.2.0
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80
  targetPort: 8080

ingress:
  enabled: false
  className: nginx
  hosts:
    - host: my-app.example.com
      paths:
        - path: /
          pathType: Prefix

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    memory: 256Mi

config:
  logLevel: info
  db:
    host: postgres
    port: 5432
    name: my_app
    user: app
```

### Migration with Backwards Compatibility

When renaming keys in a released chart, use aliases temporarily:

```yaml
# In templates — support both old and new key during transition period
{{- $logLevel := .Values.config.logLevel | default .Values.appLogLevel | default "info" }}
```

Document the deprecation in NOTES.txt and values.yaml comments:

```yaml
# DEPRECATED: use config.logLevel instead. Will be removed in v2.0.0
appLogLevel: ""

config:
  # -- Log level for the application (debug|info|warn|error)
  logLevel: info
```

---

## Multi-Environment Management

### Problem: Values Files That Know About Environments

```yaml
# BAD — environment logic in templates
{{- if eq .Values.environment "production" }}
  replicas: 3
{{- else }}
  replicas: 1
{{- end }}
```

This couples the chart to specific environment names, makes the chart non-reusable, and requires chart changes when environments are added.

### Solution: Feature Flags and Resource Shapes

The chart exposes knobs. The caller chooses the values per environment.

**Base `values.yaml`:**

```yaml
replicaCount: 1

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 3

pdb:
  enabled: false
  minAvailable: 1

ingress:
  enabled: false
  hosts: []
  tls: []

resources:
  requests:
    cpu: 50m
    memory: 64Mi
  limits:
    memory: 128Mi
```

**`values-dev.yaml` (thin delta):**

```yaml
config:
  logLevel: debug

resources:
  requests:
    cpu: 50m
    memory: 64Mi
  limits:
    memory: 128Mi
```

**`values-staging.yaml`:**

```yaml
replicaCount: 2

ingress:
  enabled: true
  hosts:
    - host: my-app.staging.example.com
      paths:
        - path: /
          pathType: Prefix

config:
  logLevel: info
```

**`values-prod.yaml`:**

```yaml
replicaCount: 3

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10

pdb:
  enabled: true
  minAvailable: 2

ingress:
  enabled: true
  hosts:
    - host: my-app.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: my-app-tls
      hosts:
        - my-app.example.com

resources:
  requests:
    cpu: 200m
    memory: 256Mi
  limits:
    memory: 512Mi

config:
  logLevel: warn
```

**Deploy:**

```bash
helm upgrade --install my-app ./charts/my-app \
  -f values.yaml \
  -f values-prod.yaml \
  --namespace my-app-prod
```

---

## DRY Patterns with _helpers.tpl

### Before: Repetition Across Templates

Every template file repeating the same label block:

```yaml
# templates/deployment.yaml
labels:
  app.kubernetes.io/name: my-app
  app.kubernetes.io/instance: {{ .Release.Name }}
  helm.sh/chart: my-app-1.2.3

# templates/service.yaml
labels:
  app.kubernetes.io/name: my-app
  app.kubernetes.io/instance: {{ .Release.Name }}
  helm.sh/chart: my-app-1.2.3

# templates/ingress.yaml — same again
```

### After: Centralized in _helpers.tpl

```yaml
# templates/_helpers.tpl
{{- define "my-app.labels" -}}
helm.sh/chart: {{ include "my-app.chart" . }}
{{ include "my-app.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "my-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "my-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
```

```yaml
# templates/deployment.yaml
metadata:
  labels:
    {{- include "my-app.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "my-app.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "my-app.selectorLabels" . | nindent 8 }}
```

### Parameterized Helpers

For helpers that need arguments beyond `.` (the full context), use `dict`:

```yaml
{{/*
Image helper — accepts a dict with keys: repository, tag, digest
Usage: {{ include "my-app.image" (dict "image" .Values.image) }}
*/}}
{{- define "my-app.image" -}}
{{- $img := .image -}}
{{- if $img.digest -}}
{{ printf "%s@%s" $img.repository $img.digest }}
{{- else -}}
{{ printf "%s:%s" $img.repository ($img.tag | toString) }}
{{- end -}}
{{- end }}
```

Usage:

```yaml
containers:
  - name: app
    image: {{ include "my-app.image" (dict "image" .Values.image) }}
  - name: sidecar
    image: {{ include "my-app.image" (dict "image" .Values.sidecar.image) }}
```

---

## Multi-Service Charts with Conditional Rendering

### When One Release Manages Multiple Services

Appropriate when services:
- Are tightly coupled (always deployed together)
- Share a namespace, database, or config
- Have a single lifecycle (upgrade together or not at all)

Not appropriate when services need independent versioning or are owned by different teams.

### Before: Separate Charts with Copied Templates

```
charts/
├── frontend/       # 90% identical to backend chart
├── backend/        # copy of frontend with minor changes
└── worker/         # copy of backend with minor changes
```

### After: Single Chart with Feature Flags

`values.yaml`:

```yaml
frontend:
  enabled: true
  replicaCount: 2
  image:
    repository: ghcr.io/org/my-app-frontend
    tag: v1.2.0
  service:
    port: 3000
  ingress:
    enabled: true
    host: my-app.example.com

backend:
  enabled: true
  replicaCount: 2
  image:
    repository: ghcr.io/org/my-app-backend
    tag: v1.2.0
  service:
    port: 8080

worker:
  enabled: true
  replicaCount: 1
  image:
    repository: ghcr.io/org/my-app-worker
    tag: v1.2.0
  concurrency: 4

postgresql:
  enabled: true

redis:
  enabled: true
```

`templates/frontend-deployment.yaml`:

```yaml
{{- if .Values.frontend.enabled -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "my-app.fullname" . }}-frontend
  labels:
    {{- include "my-app.labels" . | nindent 4 }}
    app.kubernetes.io/component: frontend
spec:
  replicas: {{ .Values.frontend.replicaCount }}
  selector:
    matchLabels:
      {{- include "my-app.selectorLabels" . | nindent 6 }}
      app.kubernetes.io/component: frontend
  template:
    metadata:
      labels:
        {{- include "my-app.selectorLabels" . | nindent 8 }}
        app.kubernetes.io/component: frontend
    spec:
      containers:
        - name: frontend
          image: {{ include "my-app.image" (dict "image" .Values.frontend.image) }}
          ports:
            - containerPort: {{ .Values.frontend.service.port }}
          resources:
            {{- toYaml .Values.frontend.resources | nindent 12 }}
{{- end }}
```

`templates/worker-deployment.yaml`:

```yaml
{{- if .Values.worker.enabled -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "my-app.fullname" . }}-worker
  labels:
    {{- include "my-app.labels" . | nindent 4 }}
    app.kubernetes.io/component: worker
spec:
  replicas: {{ .Values.worker.replicaCount }}
  selector:
    matchLabels:
      {{- include "my-app.selectorLabels" . | nindent 6 }}
      app.kubernetes.io/component: worker
  template:
    metadata:
      labels:
        {{- include "my-app.selectorLabels" . | nindent 8 }}
        app.kubernetes.io/component: worker
    spec:
      containers:
        - name: worker
          image: {{ include "my-app.image" (dict "image" .Values.worker.image) }}
          env:
            - name: WORKER_CONCURRENCY
              value: {{ .Values.worker.concurrency | quote }}
          resources:
            {{- toYaml .Values.worker.resources | nindent 12 }}
{{- end }}
```

### Range-Based Multi-Service (Advanced)

When services are homogeneous enough to be defined as a list:

```yaml
# values.yaml
services:
  - name: api
    image: ghcr.io/org/api:v1.0
    port: 8080
    replicas: 2
  - name: worker
    image: ghcr.io/org/worker:v1.0
    port: 9090
    replicas: 1
```

```yaml
# templates/deployments.yaml
{{- range .Values.services }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "my-app.fullname" $ }}-{{ .name }}
  labels:
    {{- include "my-app.labels" $ | nindent 4 }}
    app.kubernetes.io/component: {{ .name }}
spec:
  replicas: {{ .replicas }}
  selector:
    matchLabels:
      {{- include "my-app.selectorLabels" $ | nindent 6 }}
      app.kubernetes.io/component: {{ .name }}
  template:
    metadata:
      labels:
        {{- include "my-app.selectorLabels" $ | nindent 8 }}
        app.kubernetes.io/component: {{ .name }}
    spec:
      containers:
        - name: {{ .name }}
          image: {{ .image }}
          ports:
            - containerPort: {{ .port }}
{{- end }}
```

Note: `$` refers to the root context within `range` blocks; `.` is the current item.

---

## Migration Checklist

Use this checklist when refactoring an existing chart. Work through it sequentially — each phase can be applied independently.

### Phase 0: Baseline

```
[ ] Render current chart: helm template > /tmp/baseline.yaml
[ ] Confirm current helm lint passes
[ ] Confirm upgrade path works in a test environment
[ ] Document all currently active releases and their values files
```

### Phase 1: Values.yaml Organization

```
[ ] Group top-level values by resource type (image, service, ingress, resources, config)
[ ] Move all environment-specific values to overlay files
[ ] Remove any {{ if eq .Values.env "..." }} branches from templates
[ ] Add values.schema.json for required fields and enum constraints
[ ] Verify: helm lint --strict passes
[ ] Verify: helm template output diff vs baseline is whitespace-only
```

### Phase 2: _helpers.tpl DRY

```
[ ] Audit all templates for duplicated label blocks
[ ] Centralize fullname, name, chart, labels, selectorLabels in _helpers.tpl
[ ] Replace inline label blocks with {{ include "chart.labels" . | nindent N }}
[ ] Add image helper if multiple containers reference image values
[ ] Verify: diff against baseline after render
```

### Phase 3: Library Chart Extraction (if 2+ charts share logic)

```
[ ] List all named templates duplicated across charts
[ ] Create charts/common-lib/Chart.yaml with type: library
[ ] Move shared templates to charts/common-lib/templates/_helpers.tpl
[ ] Add common-lib as dependency in each consuming chart's Chart.yaml
[ ] Run helm dependency update in each consuming chart
[ ] Replace local duplicates with includes from common-lib
[ ] Publish common-lib to OCI registry
[ ] Update consuming charts to reference OCI version
[ ] Verify: render diff vs baseline
```

### Phase 4: Multi-Service Consolidation (if applicable)

```
[ ] Identify charts that always deploy together and share a namespace
[ ] Design values.yaml structure: one block per service
[ ] Create per-service template files with {{ if .Values.<svc>.enabled }} guards
[ ] Ensure all resource names include component suffix: fullname + "-" + component
[ ] Ensure selectorLabels include app.kubernetes.io/component per service
[ ] Test: disable individual services via values and confirm resources absent
[ ] Test: upgrade from separate releases to consolidated chart (or document the migration path)
```

### Phase 5: CI Integration

```
[ ] helm lint --strict passes
[ ] yamllint passes on templates/
[ ] kubeconform passes on rendered manifests
[ ] helm-unittest covers key conditional paths
[ ] ct install passes on kind cluster
[ ] ct install --upgrade passes (validates upgrade path)
[ ] trivy config scan returns no CRITICAL/HIGH findings
```

### Phase 6: Documentation

```
[ ] helm-docs annotations added to all values.yaml fields
[ ] helm-docs regenerated (README.md updated)
[ ] CHANGELOG entry added for refactor
[ ] Deprecation notices added for renamed/removed keys
[ ] Migration notes in chart README if breaking changes exist
```

### Rollback Plan

Before applying to production:

```bash
# Save current release manifest state
helm get manifest my-app --namespace my-app-prod > /tmp/prod-before.yaml

# Apply refactored chart
helm upgrade my-app ./charts/my-app \
  -f values.yaml \
  -f values-prod.yaml \
  --namespace my-app-prod \
  --dry-run

# If dry-run looks good, apply
helm upgrade my-app ./charts/my-app \
  -f values.yaml \
  -f values-prod.yaml \
  --namespace my-app-prod

# If something goes wrong, rollback to previous release
helm rollback my-app --namespace my-app-prod
```
