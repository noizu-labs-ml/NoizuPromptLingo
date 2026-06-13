# Recipe: Helm Library Chart Extraction

**Difficulty:** Intermediate
**Prerequisites:** Helm 3, Go template syntax, `helm template`, `helm dependency update`

---

## Goal

Extract duplicated Helm templates across multiple application charts into a shared library chart. After this recipe, a single change to the library propagates to all consumer charts on the next `helm dependency update`.

---

## When to Extract to a Library

| Signal | Example |
|--------|---------|
| Same `_helpers.tpl` block copy-pasted across 3+ charts | `fullname`, `labels`, `selectorLabels` |
| Ingress annotations duplicated verbatim | Cloudflare IP whitelist, TLS settings |
| NetworkPolicy or RBAC boilerplate repeated | Default-deny, common role rules |
| Resource limit defaults repeated | Standard container resource blocks |

**Rule of three:** if a template appears in three or more charts without meaningful variation, extract it.

---

## Before: Duplication Across Charts

```
projects/
  app-a/app-a-infra/
    templates/_helpers.tpl        ← contains cloudflare-annotations snippet
    templates/ingress.yaml        ← inline annotations copy-paste
  app-b/app-b-infra/
    templates/_helpers.tpl        ← same cloudflare-annotations snippet
    templates/ingress.yaml        ← same annotations copy-paste
```

---

## Step 1: Create the Library Chart Scaffold

```bash
helm create shared/cloudflare-lib
```

Edit `shared/cloudflare-lib/Chart.yaml`:

```yaml
apiVersion: v2
name: cloudflare-lib
description: Shared Helm library for Cloudflare ingress and IP allowlisting
type: library          # <-- Required. Library charts cannot be deployed directly.
version: 0.3.0
```

Delete the generated `templates/` content — library charts only expose named templates:

```bash
rm -rf shared/cloudflare-lib/templates/*
rm shared/cloudflare-lib/values.yaml
touch shared/cloudflare-lib/templates/_ingress-annotations.tpl
touch shared/cloudflare-lib/templates/_ip-whitelist.tpl
```

---

## Step 2: Define Shared Templates

```
shared/cloudflare-lib/templates/_ingress-annotations.tpl
```

```yaml
{{/*
Standard Cloudflare ingress annotations.
Usage: {{ include "cloudflare-lib.ingress-annotations" (dict "bodySize" "50m" "readTimeout" "3600") | nindent 4 }}
*/}}
{{- define "cloudflare-lib.ingress-annotations" -}}
nginx.ingress.kubernetes.io/ssl-redirect: "true"
nginx.ingress.kubernetes.io/proxy-body-size: {{ .bodySize | default "10m" | quote }}
nginx.ingress.kubernetes.io/proxy-read-timeout: {{ .readTimeout | default "60" | quote }}
nginx.ingress.kubernetes.io/proxy-send-timeout: {{ .readTimeout | default "60" | quote }}
nginx.ingress.kubernetes.io/whitelist-source-range: {{ include "cloudflare-lib.ip-whitelist-v4" . }}
{{- end }}

{{/*
Cloudflare IPv4 CIDR allowlist (current as of 2025-01).
*/}}
{{- define "cloudflare-lib.ip-whitelist-v4" -}}
173.245.48.0/20,103.21.244.0/22,103.22.200.0/22,103.31.4.0/22,141.101.64.0/18,108.162.192.0/18,190.93.240.0/20,188.114.96.0/20,197.234.240.0/22,198.41.128.0/17,162.158.0.0/15,104.16.0.0/13,104.24.0.0/14,172.64.0.0/13,131.0.72.0/22
{{- end }}
```

---

## Step 3: Add the Library as a Dependency

In each consumer chart's `Chart.yaml`:

```yaml
# app-a/app-a-infra/Chart.yaml
apiVersion: v2
name: app-a-infra
version: 1.0.0
dependencies:
  - name: cloudflare-lib
    version: ">=0.3.0"
    repository: "file://../../../shared/cloudflare-lib"
```

Run dependency update for each consumer:

```bash
cd projects/app-a/app-a-infra
helm dependency update
```

This creates `charts/cloudflare-lib-0.3.0.tgz` in the consumer chart.

---

## Step 4: Replace Inline Templates with `include`

**Before** (app-a/app-a-infra/templates/ingress.yaml):

```yaml
annotations:
  nginx.ingress.kubernetes.io/ssl-redirect: "true"
  nginx.ingress.kubernetes.io/proxy-body-size: "50m"
  nginx.ingress.kubernetes.io/whitelist-source-range: "173.245.48.0/20,..."
```

**After:**

```yaml
annotations:
  {{- include "cloudflare-lib.ingress-annotations" (dict "bodySize" "50m" "readTimeout" "3600") | nindent 4 }}
```

---

## Step 5: Test

```bash
# Render the chart locally and inspect the output
helm template my-app-a projects/app-a/app-a-infra --debug 2>&1 | grep -A 20 "kind: Ingress"

# Lint the chart
helm lint projects/app-a/app-a-infra

# Diff against live release (requires helm-diff plugin)
helm diff upgrade my-app-a projects/app-a/app-a-infra -n production
```

---

## After: Centralized Library

```
shared/cloudflare-lib/
  Chart.yaml                      ← type: library, single source of truth
  templates/
    _ingress-annotations.tpl
    _ip-whitelist.tpl
projects/
  app-a/app-a-infra/
    Chart.yaml                    ← declares dependency on cloudflare-lib
    charts/cloudflare-lib-0.3.0.tgz
    templates/ingress.yaml        ← uses include "cloudflare-lib.ingress-annotations"
  app-b/app-b-infra/
    Chart.yaml
    templates/ingress.yaml        ← same include, no duplication
```

Updating the Cloudflare IP list now requires a single change in `_ip-whitelist.tpl`, a version bump in `Chart.yaml`, and a `helm dependency update` in each consumer.
