# k8-lib - Shared Shell Library and Config

Shared shell functions and configuration loaders used by all devops tool suites. This directory is installed as `~/.local/share/k8-lib` and is normally sourced by commands, not invoked directly.

## Install

```bash
make install
```

## Config Layers

| File | Purpose | Commit? |
|------|---------|---------|
| `infra-config.yaml` | Structural config: paths, tiers, namespaces, chart discovery, Docker targets, Helm publish targets | Yes |
| `.envrc.k8.dc` | Scalar values and secrets through direnv-config | Commit safe base values only |

Tools resolve scalar values in this order:

1. Environment variable
2. `dc get k8 <path>`
3. YAML fallback
4. Hardcoded default

Tools resolve `infra-config.yaml` in this order:

1. `--config <path>`
2. `K8_CONFIG`
3. `$INFRA_ROOT/infra-config.yaml`
4. Git-root walker
5. `$K8_LIB_DIR/infra-config.yaml`

All paths in `infra-config.yaml` are relative to the config file's directory.

## Quick Start

```bash
cp k8-lib/infra-config.yaml.example infra-config.yaml
cp secrets-tools/envrc.dc.example .envrc.k8.dc
```

Then source the env file from `.envrc`:

```bash
source_env_if_exists .envrc.k8.dc
```

## infra-config.yaml Reference

### Paths

```yaml
paths:
  helm_dir: helm
  terraform_dir: terraform
  projects_dir: repos/incubator/projects
```

| Path | Consumed by | Purpose |
|------|-------------|---------|
| `helm_dir` | `helm-upgrade`, `helm-rollback` | Primary Helm chart root |
| `terraform_dir` | `infra-init`, Terraform helpers | Terraform root |
| `projects_dir` | `deploy-service`, project registry helpers | Directory containing per-project `project.yaml` files |

### Helm Discovery and Deploy Behavior

```yaml
helm_scan_dirs:
  - helm/apps
  - helm/platform

chart_path_overrides:
  easy-peasy: random/testing/random/not-helm-dir/easy-pasy

tiers:
  - name: Applications
    tier: 3
    charts:
      - easy-peasy

namespace_overrides:
  easy-peasy: testing

timeout_overrides:
  easy-peasy: 15m
```

| Section | Consumed by | Purpose |
|---------|-------------|---------|
| `helm_scan_dirs` | `helm-upgrade`, `helm-rollback` | Additional directories to scan for `Chart.yaml` |
| `chart_path_overrides` | `helm-upgrade`, `helm-rollback` | Explicit chart alias to chart directory |
| `tiers` | `helm-upgrade`, `helm-rollback` | Deploy and rollback ordering |
| `namespace_overrides` | `helm-upgrade`, `helm-rollback` | Chart-to-namespace override |
| `timeout_overrides` | `helm-upgrade`, `helm-rollback` | Chart-to-timeout override |

### Docker Targets

```yaml
project:
  name: my-stack
  docker:
    images:
      - name: easy-peasy
        context: random/testing/random/not-helm-dir/easy-pasy
        dockerfile: Dockerfile
        registry_path: testing/easy-peasy
        build_args:
          MIX_ENV: prod
        platform: linux/amd64
```

Consumed by `docker-build` and `docker-push`. The `name` field is the CLI target and alias.

### Composite Targets

```yaml
paths:
  projects_dir: repos/incubator

project:
  name: incubator
  type: composite
  projects:
    - domain: codefre.sh
      base_path: projects/codefre.sh
      services:
        - name: backend
          context: app/backend
          dockerfile: Dockerfile
          registry_path: codefre.sh/backend
      helm:
        charts:
          - name: backend
            path: helm/backend
```

Consumed by:

- `docker-build` as target `codefre.sh/backend`
- `helm-publish` as chart target `codefre.sh/backend`

### Helm Publish Targets

```yaml
helm:
  oci_registry: oci://ghcr.io/my-org/helm-charts
  registry_host: ghcr.io

project:
  name: my-stack
  helm:
    charts:
      - name: easy-peasy
        path: random/testing/random/not-helm-dir/easy-pasy
        registry: oci://ghcr.io/other-org/charts
```

Consumed by `helm-publish`.

## Per-Project project.yaml Files

Some tools use project registry files under `paths.projects_dir`. `deploy-service` depends on these files for image-to-Helm wiring.

Flat example:

```yaml
status: active
helm:
  release: easy-peasy
  namespace: testing
  tier: 3
  timeout: 15m
  path: helm/easy-peasy

docker:
  images:
    - name: easy-peasy
      helm:
        chart_path: repos/incubator/projects/easy-peasy/helm/easy-peasy
        values_path: .image.tag
        format: tag
```

Composite example:

```yaml
type: composite
status: active
helm:
  release: codefre-sh
  namespace: apps
  tier: 3
  path: helm/codefre-sh

projects:
  - domain: codefre.sh
    services:
      - name: backend
        helm:
          chart_path: repos/incubator/projects/codefre.sh/helm/codefre-sh
          values_path: .backend.image.tag
          format: tag
```

## Library Scripts

| Script | Purpose |
|--------|---------|
| `bin/config-resolver.sh` | Config discovery, YAML helpers, direnv-config integration |
| `bin/config.sh` | Loads resolved config and exported `K8_*` variables |
| `bin/common.sh` | Shared shell output, errors, logging, and config bootstrap |
| `bin/helm-common.sh` | Chart discovery, namespaces, overlays, tiers, checksums, impact helpers |
| `bin/docker-config.sh` | Docker target discovery, registry paths, Dockerfile/build arg maps, build state |
| `bin/helm-publish-config.sh` | Helm publish target discovery and publish state |
| `bin/project-registry.sh` | Per-project `project.yaml` registry loader |
| `bin/docker-vsn.sh` | Version and tag helpers |
| `bin/terraform.sh` | Terraform helpers |
| `bin/iam.sh` | IAM helpers |
| `bin/doctor.sh` | Dependency checks |
