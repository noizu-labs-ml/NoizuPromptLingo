# helm-tools - Helm Upgrade, Rollback, and Publish

Helm deployment and chart publishing tools built around shared chart discovery, tiered deployment, environment overlays, change detection, rollback, and OCI chart publishing.

## Install

```bash
make install
```

Installs:

| Command | Purpose |
|---------|---------|
| `helm-upgrade` | Deploy charts in tier order with change detection |
| `helm-rollback` | Roll back releases by explicit target, revision, unhealthy pods, or recent deploy window |
| `helm-publish` | Package and push configured charts to an OCI registry |

## Prerequisites

- `helm` 3.x
- `kubectl`
- `yq`
- `jq`

## Config Sources

All Helm tools read the merged `infra-config.yaml`. Registry credentials for `helm-publish` come from `.envrc.k8.dc` or environment variables.

Important distinction:

- `helm-upgrade` and `helm-rollback` discover deployable chart directories from `paths.helm_dir`, `helm_scan_dirs`, and `chart_path_overrides`.
- `helm-publish` discovers publishable chart targets from `project.helm.charts[]` or `project.projects[].helm.charts[]`.

## Upgrade and Rollback Config

### Chart Discovery

```yaml
paths:
  helm_dir: helm

helm_scan_dirs:
  - helm/platform
  - helm/apps
  - random/testing/random/not-helm-dir

chart_path_overrides:
  easy-peasy: random/testing/random/not-helm-dir/easy-pasy
```

Use cases:

| Need | Config |
|------|--------|
| Scan a whole category of charts | Add the directory to `helm_scan_dirs` |
| Deploy a chart outside the standard tree | Add `chart_path_overrides.<name>` |
| Give a chart a friendly alias | Use the alias as the `chart_path_overrides` key |
| Keep a standard chart tree | Put charts under `paths.helm_dir` |

Enabled commands:

```bash
helm-upgrade --include easy-peasy
helm-rollback --include easy-peasy
```

### Tiers, Namespaces, and Timeouts

```yaml
tiers:
  - name: Platform
    tier: 0
    charts:
      - infisical
      - ingress-nginx
  - name: Applications
    tier: 3
    charts:
      - easy-peasy

namespace_overrides:
  ingress-nginx: ingress-nginx
  easy-peasy: testing

timeout_overrides:
  easy-peasy: 15m
```

Behavior:

- Tier N completes before tier N+1 starts.
- `namespace_overrides` wins over chart `values.yaml` namespace detection.
- `timeout_overrides` wins over the default Helm timeout.
- Charts not present in any tier can still be included directly, but tier config is the intended deployment plan.

### Environment Overlays

For non-production environments, use `--env <name>` and add matching values files:

```text
helm/apps/easy-peasy/values.yaml
helm/apps/easy-peasy/values-stage.yaml
```

With `--env stage`, `helm-upgrade`:

1. Uses release name `stage-<chart>`.
2. Applies `values.yaml` plus `values-stage.yaml`.
3. Includes only charts that have `values-stage.yaml`.
4. Reads the environment namespace from the overlay when present.

## Helm Publish Config

Set the default OCI registry:

```yaml
helm:
  oci_registry: oci://ghcr.io/my-org/helm-charts
  registry_host: ghcr.io
```

Set auth through the environment or `.envrc.k8.dc`:

```bash
export K8_HELM_REGISTRY_USER="my-org"
export K8_HELM_REGISTRY_PASSWORD="..."
```

`helm-publish` also accepts `GITHUB_TOKEN` or `gh auth token` when publishing to GitHub Container Registry.

### Flat Publish Targets

```yaml
project:
  name: my-stack
  helm:
    charts:
      - name: easy-peasy
        path: random/testing/random/not-helm-dir/easy-pasy
      - name: backend
        path: helm/apps/backend
        registry: oci://ghcr.io/other-org/charts
```

Enabled commands:

```bash
helm-publish --list
helm-publish easy-peasy
helm-publish --all
```

### Composite Publish Targets

```yaml
paths:
  projects_dir: repos/incubator

project:
  name: incubator
  type: composite
  projects:
    - domain: codefre.sh
      base_path: projects/codefre.sh
      helm:
        charts:
          - name: backend
            path: helm/backend
          - name: frontend
            path: helm/frontend
            registry: oci://ghcr.io/codefre/charts
```

Enabled commands:

```bash
helm-publish codefre.sh/backend
helm-publish --pick
```

## Usage

```bash
helm-upgrade --list
helm-upgrade --dry-run
helm-upgrade --include easy-peasy
helm-upgrade --exclude easy-peasy
helm-upgrade --tier 0
helm-upgrade --tiers 0,1
helm-upgrade --interactive
helm-upgrade --preview
helm-upgrade --env stage
helm-upgrade --force

helm-rollback --include easy-peasy
helm-rollback --env stage --include easy-peasy
helm-rollback --back-to 30m

helm-publish --list
helm-publish easy-peasy
helm-publish --pick
helm-publish --all
helm-publish --bump patch
helm-publish --dry-run
helm-publish --force
```

## State

`helm-upgrade` stores chart checksums in `.helm-state/{chart}.md5` after successful deploys. Re-running skips unchanged charts unless `--force` is set.

`helm-publish` stores publish state under `.helm-state/` so repeated publishing can detect what has already been pushed.
