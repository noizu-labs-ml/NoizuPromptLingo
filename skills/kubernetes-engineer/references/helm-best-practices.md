# Helm Best Practices

Comprehensive reference for authoring, structuring, testing, and publishing production-grade Helm charts.

---

## Table of Contents

1. [Chart Structure](#chart-structure)
2. [Template Patterns](#template-patterns)
3. [Values Design](#values-design)
4. [Library Charts](#library-charts)
5. [Testing Pipeline](#testing-pipeline)
6. [OCI Registry Publishing](#oci-registry-publishing)
7. [Helmfile](#helmfile)
8. [Common Mistakes](#common-mistakes)

---

## Chart Structure

### Standard Layout

```
my-chart/
├── Chart.yaml               # Chart metadata (required)
├── values.yaml              # Default values (required)
├── values.schema.json       # JSON Schema for values validation (recommended)
├── .helmignore              # Files to exclude from packaging
├── README.md                # Human-readable documentation
├── charts/                  # Dependency charts (vendored)
├── crds/                    # Custom Resource Definitions
└── templates/
    ├── _helpers.tpl         # Named template definitions
    ├── NOTES.txt            # Post-install notes
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    ├── serviceaccount.yaml
    ├── configmap.yaml
    ├── secret.yaml
    ├── hpa.yaml
    ├── pdb.yaml
    └── tests/
        └── test-connection.yaml
```

### Chart.yaml

Full example with all relevant fields for a v2 chart:

```yaml
apiVersion: v2                          # Required; v2 for Helm 3
name: my-app                            # Chart name; matches directory name
version: 1.4.2                          # Chart version (SemVer 2)
appVersion: "2.3.0"                     # App version (informational, quoted)
description: A Helm chart for my-app
type: application                       # application | library

# Optional metadata
home: https://github.com/org/my-app
sources:
  - https://github.com/org/my-app
maintainers:
  - name: Jane Dev
    email: jane@example.com
    url: https://jane.dev
icon: https://example.com/icon.png
keywords:
  - web
  - api

# Dependencies (resolved via `helm dependency update`)
dependencies:
  - name: postgresql
    version: "15.x.x"
    repository: https://charts.bitnami.com/bitnami
    condition: postgresql.enabled
    alias: pg
  - name: redis
    version: "19.x.x"
    repository: https://charts.bitnami.com/bitnami
    condition: redis.enabled
  - name: common-lib
    version: "1.x.x"
    repository: "file://../common-lib"  # Local library chart
```

**Versioning rules:**
- `version`: chart version, bumped on every chart change (not just app changes)
- `appVersion`: the upstream app version being packaged; change independently
- Both must be valid SemVer 2.0 strings
- Use `~1.2.3` or `^1.2.0` range selectors for dependencies when appropriate

### .helmignore

```
# Patterns to ignore when packaging
.git/
.gitignore
.DS_Store
*.swp
*.bak
*.tmp
.vscode/
.idea/
node_modules/
README.md.gotmpl   # helm-docs source templates
CHANGELOG.md
coverage/
tests/             # Only if using separate integration test dirs outside templates/
```

---

## Template Patterns

### _helpers.tpl

The `_helpers.tpl` file is the heart of chart DRY patterns. All named templates live here.

```yaml
{{/*
Expand the name of the chart.
*/}}
{{- define "my-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this.
If release name contains chart name it will be used as a full name.
*/}}
{{- define "my-app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "my-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels — applied to all resources
*/}}
{{- define "my-app.labels" -}}
helm.sh/chart: {{ include "my-app.chart" . }}
{{ include "my-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels — used in spec.selector.matchLabels and pod template labels.
Do NOT change after initial deploy — selectors are immutable.
*/}}
{{- define "my-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "my-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ServiceAccount name
*/}}
{{- define "my-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "my-app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Image reference — combines repository, tag, and digest with precedence.
Usage: image: {{ include "my-app.image" .Values.image }}
*/}}
{{- define "my-app.image" -}}
{{- $img := . }}
{{- if $img.digest }}
{{- printf "%s@%s" $img.repository $img.digest }}
{{- else }}
{{- printf "%s:%s" $img.repository ($img.tag | toString) }}
{{- end }}
{{- end }}
```

### nindent vs indent

Always prefer `nindent` (adds a leading newline) over `indent` to avoid whitespace surprises:

```yaml
# GOOD — nindent adds newline before indenting
labels:
  {{- include "my-app.labels" . | nindent 4 }}

# BAD — indent does not add leading newline; can merge with preceding content
labels:
  {{ include "my-app.labels" . | indent 4 }}
```

### quote, toYaml, and Range

```yaml
# quote — always quote values that may be numeric strings
annotations:
  prometheus.io/port: {{ .Values.metrics.port | quote }}

# toYaml — serialize a map or list back to YAML
env:
  {{- toYaml .Values.extraEnv | nindent 2 }}

# Merging user annotations with chart-managed annotations
annotations:
  {{- with .Values.podAnnotations }}
  {{- toYaml . | nindent 4 }}
  {{- end }}

# range — iterate over a map
{{- range $key, $val := .Values.configData }}
  {{ $key }}: {{ $val | quote }}
{{- end }}

# range — iterate over a list
{{- range .Values.hosts }}
- host: {{ . | quote }}
{{- end }}
```

### with Blocks

Use `with` to scope into a nested value and skip the block when the value is falsy:

```yaml
# Skip entire ingress block when no hosts configured
{{- with .Values.ingress.hosts }}
spec:
  rules:
    {{- range . }}
    - host: {{ .host | quote }}
    {{- end }}
{{- end }}

# Scoped annotations merge
metadata:
  annotations:
    {{- with .Values.ingress.annotations }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
```

### Conditional Rendering

Gate entire resources on a `.enabled` flag:

```yaml
{{- if .Values.ingress.enabled -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "my-app.fullname" . }}
  labels:
    {{- include "my-app.labels" . | nindent 4 }}
spec:
  ...
{{- end }}
```

Conditional fields within a resource:

```yaml
spec:
  {{- if .Values.serviceAccount.create }}
  serviceAccountName: {{ include "my-app.serviceAccountName" . }}
  {{- end }}
  {{- if .Values.podSecurityContext }}
  securityContext:
    {{- toYaml .Values.podSecurityContext | nindent 4 }}
  {{- end }}
```

### tpl Function

Use `tpl` when a values field should itself be rendered as a Go template. This allows users to reference `.Release.Name` and other context inside their values:

```yaml
# values.yaml
someAnnotation: "release={{ .Release.Name }},chart={{ .Chart.Name }}"

# template usage
annotations:
  my-annotation: {{ tpl .Values.someAnnotation . }}
```

Be cautious: `tpl` runs user-supplied strings through the template engine. Validate inputs and document the capability explicitly.

---

## Values Design

### Nested by Resource Type

Organize values.yaml by resource type, not by feature flag soup:

```yaml
# GOOD — hierarchical, predictable
replicaCount: 1

image:
  repository: ghcr.io/org/my-app
  tag: ""           # Defaults to .Chart.AppVersion when empty
  pullPolicy: IfNotPresent
  digest: ""        # When set, overrides tag

imagePullSecrets: []
nameOverride: ""
fullnameOverride: ""

serviceAccount:
  create: true
  annotations: {}
  name: ""

podAnnotations: {}
podLabels: {}
podSecurityContext:
  runAsNonRoot: true
  seccompProfile:
    type: RuntimeDefault

securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop: [ALL]
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000

service:
  type: ClusterIP
  port: 80
  targetPort: 8080
  annotations: {}

ingress:
  enabled: false
  className: nginx
  annotations: {}
  hosts:
    - host: my-app.example.com
      paths:
        - path: /
          pathType: Prefix
  tls: []

resources:
  limits:
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi

livenessProbe:
  httpGet:
    path: /healthz
    port: http
  initialDelaySeconds: 15
  periodSeconds: 20

readinessProbe:
  httpGet:
    path: /readyz
    port: http
  initialDelaySeconds: 5
  periodSeconds: 10

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80

pdb:
  enabled: false
  minAvailable: 1

nodeSelector: {}
tolerations: []
affinity: {}

extraEnv: []
extraEnvFrom: []
extraVolumes: []
extraVolumeMounts: []

config:
  logLevel: info
  port: 8080

postgresql:
  enabled: false   # Bitnami postgresql sub-chart toggle
```

### values.schema.json

JSON Schema draft-07 validation, enforced by `helm install --validate` and `helm lint`:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["image"],
  "additionalProperties": true,
  "properties": {
    "replicaCount": {
      "type": "integer",
      "minimum": 0,
      "description": "Number of replicas"
    },
    "image": {
      "type": "object",
      "required": ["repository"],
      "properties": {
        "repository": {
          "type": "string",
          "minLength": 1
        },
        "tag": {
          "type": "string"
        },
        "pullPolicy": {
          "type": "string",
          "enum": ["Always", "IfNotPresent", "Never"]
        },
        "digest": {
          "type": "string",
          "pattern": "^(sha256:[a-f0-9]{64})?$"
        }
      },
      "additionalProperties": false
    },
    "service": {
      "type": "object",
      "properties": {
        "type": {
          "type": "string",
          "enum": ["ClusterIP", "NodePort", "LoadBalancer", "ExternalName"]
        },
        "port": {
          "type": "integer",
          "minimum": 1,
          "maximum": 65535
        }
      }
    },
    "ingress": {
      "type": "object",
      "properties": {
        "enabled": { "type": "boolean" },
        "className": { "type": "string" },
        "annotations": { "type": "object" },
        "hosts": {
          "type": "array",
          "items": {
            "type": "object",
            "required": ["host"],
            "properties": {
              "host": { "type": "string" },
              "paths": {
                "type": "array",
                "items": {
                  "type": "object",
                  "properties": {
                    "path": { "type": "string" },
                    "pathType": {
                      "type": "string",
                      "enum": ["Prefix", "Exact", "ImplementationSpecific"]
                    }
                  }
                }
              }
            }
          }
        },
        "tls": { "type": "array" }
      }
    },
    "resources": {
      "type": "object",
      "properties": {
        "limits": {
          "type": "object",
          "properties": {
            "cpu": { "type": "string" },
            "memory": { "type": "string" }
          }
        },
        "requests": {
          "type": "object",
          "properties": {
            "cpu": { "type": "string" },
            "memory": { "type": "string" }
          }
        }
      }
    },
    "autoscaling": {
      "type": "object",
      "properties": {
        "enabled": { "type": "boolean" },
        "minReplicas": { "type": "integer", "minimum": 1 },
        "maxReplicas": { "type": "integer", "minimum": 1 },
        "targetCPUUtilizationPercentage": {
          "type": "integer",
          "minimum": 1,
          "maximum": 100
        }
      }
    },
    "config": {
      "type": "object",
      "properties": {
        "logLevel": {
          "type": "string",
          "enum": ["debug", "info", "warn", "error"]
        },
        "port": {
          "type": "integer",
          "minimum": 1024,
          "maximum": 65535
        }
      }
    }
  }
}
```

### Environment-Agnostic Values

**Never** branch on environment names inside templates. Use feature flags and resource shapes instead:

```yaml
# BAD — environment coupling, brittle, non-reusable
{{- if eq .Values.env "prod" }}
  replicas: 3
{{- else }}
  replicas: 1
{{- end }}

# GOOD — caller controls the knobs
replicaCount: 1   # base default

# production override file (values-prod.yaml)
replicaCount: 3
```

### Overlay Pattern

Use a thin base values.yaml with environment-specific overlay files:

```
deploy/
├── values.yaml           # Shared defaults (applies everywhere)
├── values-dev.yaml       # Dev delta: low replicas, debug log, no TLS
├── values-staging.yaml   # Staging delta: prod-like sizing, staging hostnames
└── values-prod.yaml      # Prod delta: full replicas, prod hostnames, PDB on
```

Deploy with layered `-f` flags:

```bash
helm upgrade --install my-app ./my-chart \
  -f deploy/values.yaml \
  -f deploy/values-prod.yaml \
  --namespace my-app-prod \
  --create-namespace
```

The rightmost file wins on key conflicts. Keep overlays thin — only the delta from base.

---

## Library Charts

### When to Extract

Extract a library chart when:
- 2 or more application charts share identical `_helpers.tpl` blocks
- Teams are copy-pasting template snippets across repos
- You need a single source of truth for org-wide labeling standards
- You want to enforce security defaults (securityContext, resource limits) across all charts

### Chart.yaml for a Library

```yaml
apiVersion: v2
name: common-lib
version: 1.2.0
type: library              # Required — library charts cannot be installed directly
description: Shared Helm templates for the org
```

### Define Blocks and Include Patterns

In library chart `templates/_helpers.tpl`:

```yaml
{{/*
Standard labels — call from application charts
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
Selector labels (immutable after first deploy)
*/}}
{{- define "common-lib.selectorLabels" -}}
app.kubernetes.io/name: {{ default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Standard ServiceAccount
*/}}
{{- define "common-lib.serviceAccount" -}}
{{- if .Values.serviceAccount.create -}}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ default (printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-") .Values.serviceAccount.name }}
  labels:
    {{- include "common-lib.labels" . | nindent 4 }}
  {{- with .Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Standard security context
*/}}
{{- define "common-lib.podSecurityContext" -}}
runAsNonRoot: true
seccompProfile:
  type: RuntimeDefault
{{- end }}

{{- define "common-lib.containerSecurityContext" -}}
allowPrivilegeEscalation: false
capabilities:
  drop: [ALL]
readOnlyRootFilesystem: true
runAsNonRoot: true
runAsUser: 1000
{{- end }}
```

### Consuming a Library in an Application Chart

`Chart.yaml` dependency:

```yaml
dependencies:
  - name: common-lib
    version: "1.x.x"
    repository: "oci://ghcr.io/org/charts"
```

Usage in `templates/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "my-app.fullname" . }}
  labels:
    {{- include "common-lib.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "common-lib.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "common-lib.selectorLabels" . | nindent 8 }}
    spec:
      securityContext:
        {{- include "common-lib.podSecurityContext" . | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          securityContext:
            {{- include "common-lib.containerSecurityContext" . | nindent 12 }}
```

---

## Testing Pipeline

### Local Tools

```bash
# Lint — catches YAML syntax and template errors
helm lint ./my-chart
helm lint ./my-chart -f values-prod.yaml --strict

# Validate values against schema
helm install --dry-run --generate-name ./my-chart -f values.yaml

# YAML linting (broader than helm lint)
yamllint -c .yamllint.yaml templates/

# Kubernetes manifest validation against API schemas
helm template my-app ./my-chart | kubeconform \
  -strict \
  -schema-location default \
  -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'

# Unit tests (helm-unittest plugin)
helm plugin install https://github.com/helm-unittest/helm-unittest
helm unittest ./my-chart

# Security scanning
helm template my-app ./my-chart | trivy config -
```

### helm-unittest Test Example

`tests/deployment_test.yaml`:

```yaml
suite: Deployment tests
templates:
  - deployment.yaml
tests:
  - it: renders with default values
    asserts:
      - isKind:
          of: Deployment
      - equal:
          path: spec.replicas
          value: 1
      - matchRegex:
          path: spec.template.spec.containers[0].image
          pattern: "^ghcr.io/org/my-app:"

  - it: respects replicaCount override
    set:
      replicaCount: 3
    asserts:
      - equal:
          path: spec.replicas
          value: 3

  - it: does not render when disabled
    set:
      enabled: false
    asserts:
      - hasDocuments:
          count: 0

  - it: sets security context
    asserts:
      - equal:
          path: spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation
          value: false
      - equal:
          path: spec.template.spec.containers[0].securityContext.readOnlyRootFilesystem
          value: true
```

### GitHub Actions CI Pipeline

`.github/workflows/helm-ci.yaml`:

```yaml
name: Helm CI

on:
  pull_request:
    paths:
      - 'charts/**'
      - '.github/workflows/helm-ci.yaml'

jobs:
  lint-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Set up Helm
        uses: azure/setup-helm@v4
        with:
          version: v3.14.0

      - name: Set up chart-testing
        uses: helm/chart-testing-action@v2.6.1

      - name: Run chart-testing (list-changed)
        id: list-changed
        run: |
          changed=$(ct list-changed --target-branch ${{ github.event.repository.default_branch }})
          if [[ -n "$changed" ]]; then
            echo "changed=true" >> "$GITHUB_OUTPUT"
          fi

      - name: Run chart-testing (lint)
        if: steps.list-changed.outputs.changed == 'true'
        run: ct lint --target-branch ${{ github.event.repository.default_branch }}

      - name: Create kind cluster
        if: steps.list-changed.outputs.changed == 'true'
        uses: helm/kind-action@v1.10.0

      - name: Run chart-testing (install)
        if: steps.list-changed.outputs.changed == 'true'
        run: ct install --target-branch ${{ github.event.repository.default_branch }}

  kubeconform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Helm
        uses: azure/setup-helm@v4

      - name: Install kubeconform
        run: |
          curl -sL https://github.com/yannh/kubeconform/releases/latest/download/kubeconform-linux-amd64.tar.gz \
            | tar xz && sudo mv kubeconform /usr/local/bin/

      - name: Validate manifests
        run: |
          helm template my-app ./charts/my-app \
            | kubeconform -strict -summary \
              -schema-location default \
              -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'

  unit-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Helm
        uses: azure/setup-helm@v4

      - name: Install helm-unittest
        run: helm plugin install https://github.com/helm-unittest/helm-unittest

      - name: Run unit tests
        run: helm unittest ./charts/my-app

  trivy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Helm
        uses: azure/setup-helm@v4

      - name: Run Trivy config scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: config
          scan-ref: charts/my-app
          format: table
          exit-code: 1
          severity: CRITICAL,HIGH
```

### ct Configuration

`ct.yaml`:

```yaml
chart-dirs:
  - charts
chart-repos:
  - bitnami=https://charts.bitnami.com/bitnami
helm-extra-args: "--timeout 600s"
validate-maintainers: false   # Set true if maintainer emails must exist
```

---

## OCI Registry Publishing

### Package and Push

```bash
# Package the chart
helm package ./charts/my-app --destination ./dist

# Log in to GHCR
echo $GITHUB_TOKEN | helm registry login ghcr.io -u $GITHUB_ACTOR --password-stdin

# Push to OCI registry
helm push ./dist/my-app-1.4.2.tgz oci://ghcr.io/org/charts

# Pull / install from OCI
helm install my-app oci://ghcr.io/org/charts/my-app --version 1.4.2
```

### Semantic Versioning Discipline

| Change type | Version bump | Example |
|-------------|-------------|---------|
| Bug fix in templates | PATCH | 1.4.2 → 1.4.3 |
| New optional value added | MINOR | 1.4.2 → 1.5.0 |
| Breaking values change | MAJOR | 1.4.2 → 2.0.0 |
| AppVersion bump only | PATCH or MINOR | depends on API contract |

### Cosign Signing

Sign chart artifacts after push for supply chain security:

```bash
# Sign the OCI artifact
cosign sign --key cosign.key \
  ghcr.io/org/charts/my-app:1.4.2

# Verify
cosign verify --key cosign.pub \
  ghcr.io/org/charts/my-app:1.4.2
```

CI workflow addition:

```yaml
- name: Sign chart
  env:
    COSIGN_PRIVATE_KEY: ${{ secrets.COSIGN_PRIVATE_KEY }}
    COSIGN_PASSWORD: ${{ secrets.COSIGN_PASSWORD }}
  run: |
    cosign sign --key env://COSIGN_PRIVATE_KEY \
      ghcr.io/org/charts/my-app@${{ steps.push.outputs.digest }}
```

### helm-docs

Auto-generate README.md from values.yaml comments:

```yaml
# values.yaml with helm-docs annotations

# -- Number of replicas to run
replicaCount: 1

image:
  # -- Container image repository
  repository: ghcr.io/org/my-app
  # -- Image tag (defaults to .Chart.AppVersion)
  tag: ""
  # -- Image pull policy
  pullPolicy: IfNotPresent
```

```bash
# Generate docs
helm-docs --chart-search-root=./charts

# Add to CI
docker run --rm -v $(pwd):/helm-docs jnorwood/helm-docs:latest
```

### Multi-Arch Publishing

```yaml
# GitHub Actions matrix for multi-arch image + chart push
jobs:
  release:
    runs-on: ubuntu-latest
    if: startsWith(github.ref, 'refs/tags/v')
    steps:
      - uses: actions/checkout@v4

      - name: Set version
        id: version
        run: echo "version=${GITHUB_REF#refs/tags/v}" >> $GITHUB_OUTPUT

      - name: Update Chart.yaml version
        run: |
          sed -i "s/^version:.*/version: ${{ steps.version.outputs.version }}/" charts/my-app/Chart.yaml

      - name: Package and push
        run: |
          helm package charts/my-app -d dist/
          helm push dist/my-app-*.tgz oci://ghcr.io/org/charts
```

---

## Helmfile

### Basic Structure

`helmfile.yaml`:

```yaml
repositories:
  - name: bitnami
    url: https://charts.bitnami.com/bitnami
  - name: ingress-nginx
    url: https://kubernetes.github.io/ingress-nginx

environments:
  dev:
    values:
      - environments/dev.yaml
  staging:
    values:
      - environments/staging.yaml
  production:
    values:
      - environments/production.yaml

---
releases:
  - name: ingress-nginx
    namespace: ingress-nginx
    chart: ingress-nginx/ingress-nginx
    version: ~4.9.0
    values:
      - values/ingress-nginx.yaml
    installed: true

  - name: my-app
    namespace: my-app-{{ .Environment.Name }}
    chart: ./charts/my-app
    version: ~1.4.0
    values:
      - values/my-app.yaml
      - values/my-app-{{ .Environment.Name }}.yaml
    set:
      - name: replicaCount
        value: {{ .Values.replicaCount | default 1 }}
    installed: true

  - name: postgresql
    namespace: my-app-{{ .Environment.Name }}
    chart: bitnami/postgresql
    version: ~15.0.0
    values:
      - values/postgresql.yaml
    condition: postgresql.enabled
    installed: {{ .Values.postgresql.enabled | default false }}
```

### Environment Overlay Files

`environments/production.yaml`:

```yaml
replicaCount: 3

postgresql:
  enabled: true

ingress:
  enabled: true
  host: my-app.example.com
```

`environments/dev.yaml`:

```yaml
replicaCount: 1

postgresql:
  enabled: false

ingress:
  enabled: false
```

### Secrets Integration

Using `helm-secrets` plugin with sops:

```yaml
releases:
  - name: my-app
    chart: ./charts/my-app
    secrets:
      - secrets/my-app.yaml          # sops-encrypted file
      - secrets/my-app-{{ .Environment.Name }}.yaml
    values:
      - values/my-app.yaml
```

```bash
# Encrypt a secrets file
sops --encrypt --in-place secrets/my-app.yaml

# Deploy with decrypted secrets (helm-secrets handles transparently)
helmfile --environment production sync
```

### Key Helmfile Commands

```bash
# Preview what would change
helmfile --environment production diff

# Apply all releases
helmfile --environment production sync

# Apply a single release
helmfile --environment production sync --selector name=my-app

# Destroy a release
helmfile --environment production destroy --selector name=my-app

# List releases and their state
helmfile --environment production list

# Lint all charts
helmfile lint
```

---

## Common Mistakes

### 1. No Schema Validation

```yaml
# BAD — no values.schema.json; typos in caller values silently ignored
ingres:         # typo — helm ignores this entirely
  enabled: true
```

Fix: always ship `values.schema.json`. Use `additionalProperties: false` on critical objects.

### 2. Skipping Upgrade Tests

Install tests pass but upgrade tests fail because:
- Immutable fields changed (selector labels, volume claim templates)
- Missing `helm.sh/resource-policy: keep` on PVCs during upgrade

Fix: run `ct install` AND `ct install --upgrade` in CI.

### 3. Hardcoded Namespaces

```yaml
# BAD
metadata:
  namespace: my-app   # Broken when installed in different namespace
```

```yaml
# GOOD
metadata:
  namespace: {{ .Release.Namespace }}
```

### 4. Unquoted Numeric-Looking Annotations

```yaml
# BAD — Kubernetes annotations must be strings; YAML interprets 0755 as octal int
annotations:
  my-annotation: 0755

# GOOD
annotations:
  my-annotation: "0755"
  another: {{ .Values.someValue | quote }}
```

### 5. Mutable Selector Labels

```yaml
# BAD — changing this after first deploy requires delete+reinstall
selector:
  matchLabels:
    app: {{ .Release.Name }}-{{ .Chart.Name }}  # Too unstable
    version: {{ .Chart.AppVersion }}              # NEVER in selectorLabels
```

```yaml
# GOOD — stable, minimal, never include version
selector:
  matchLabels:
    app.kubernetes.io/name: {{ include "my-app.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
```

### 6. Resource Limits Missing

All containers must declare resource requests and limits. Without them:
- QoS class is BestEffort — first to be evicted under pressure
- HPA has no baseline to scale against
- Namespace resource quotas cannot be enforced

```yaml
# GOOD
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    memory: 256Mi   # CPU limit is optional (can cause throttling)
```

### 7. Leaking Secrets into ConfigMaps

```yaml
# BAD — secret value rendered into ConfigMap
data:
  config.yaml: |
    db_password: {{ .Values.db.password }}

# GOOD — reference the Secret instead
envFrom:
  - secretRef:
      name: {{ include "my-app.fullname" . }}-db-credentials
```

### 8. Using `latest` Tag

```yaml
# BAD
image:
  tag: latest   # Non-deterministic, breaks rollback

# GOOD
image:
  tag: ""       # Defaults to .Chart.AppVersion (pinned per chart release)
```

### 9. Forgetting NOTES.txt

Post-install NOTES.txt helps users know what was deployed and how to reach it:

```
templates/NOTES.txt:

1. Get the application URL by running:
{{- if .Values.ingress.enabled }}
  http{{ if .Values.ingress.tls }}s{{ end }}://{{ (first .Values.ingress.hosts).host }}
{{- else if contains "LoadBalancer" .Values.service.type }}
  export SERVICE_IP=$(kubectl get svc --namespace {{ .Release.Namespace }} {{ include "my-app.fullname" . }} \
    --template "{{"{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}"}}")
  echo http://$SERVICE_IP:{{ .Values.service.port }}
{{- else }}
  kubectl --namespace {{ .Release.Namespace }} port-forward \
    svc/{{ include "my-app.fullname" . }} 8080:{{ .Values.service.port }}
  echo "Visit http://127.0.0.1:8080"
{{- end }}
```

### 10. Skipping PodDisruptionBudget for Production

Any workload with `replicaCount > 1` that needs availability guarantees during node drain should have a PDB:

```yaml
{{- if .Values.pdb.enabled }}
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ include "my-app.fullname" . }}
  labels:
    {{- include "my-app.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "my-app.selectorLabels" . | nindent 6 }}
  {{- if .Values.pdb.minAvailable }}
  minAvailable: {{ .Values.pdb.minAvailable }}
  {{- end }}
  {{- if .Values.pdb.maxUnavailable }}
  maxUnavailable: {{ .Values.pdb.maxUnavailable }}
  {{- end }}
{{- end }}
```

---

## Quick Reference Checklist

```
Chart authoring:
[ ] Chart.yaml has apiVersion: v2, valid semver version, appVersion quoted
[ ] values.schema.json covers required fields and key objects
[ ] .helmignore excludes CI files, docs, git dirs
[ ] _helpers.tpl defines fullname, name, chart, labels, selectorLabels
[ ] All resources use include "chart.labels" and include "chart.selectorLabels"
[ ] selectorLabels never include version fields
[ ] Namespaces use .Release.Namespace, never hardcoded
[ ] All string values that may be numeric are passed through | quote
[ ] toYaml + nindent used for map/list values (never inline)
[ ] Conditional resources gated with .Values.x.enabled pattern
[ ] NOTES.txt provided with access instructions

Security defaults:
[ ] securityContext: allowPrivilegeEscalation: false, readOnlyRootFilesystem: true
[ ] runAsNonRoot: true on pod and container
[ ] capabilities: drop: [ALL]
[ ] Resource requests and limits on all containers
[ ] No secrets in ConfigMaps or environment variables as plain values

Testing:
[ ] helm lint passes --strict
[ ] kubeconform validates all manifests
[ ] helm-unittest covers key rendering paths
[ ] ct install passes on kind cluster
[ ] Upgrade path tested (ct install --upgrade or manual)
[ ] trivy config scan returns no CRITICAL/HIGH

Publishing:
[ ] Version bumped before push
[ ] CHANGELOG updated
[ ] helm-docs regenerated
[ ] OCI push succeeds
[ ] Cosign signature verified
```
