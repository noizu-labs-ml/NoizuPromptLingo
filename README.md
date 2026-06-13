# infra-tools - Infrastructure Bootstrap and Service Deploy

Infrastructure bootstrap helpers plus the `deploy-service` pipeline for building an image, pushing it, updating Helm values, and deploying the affected release.

## Install

```bash
make install
```

Installs:

| Command | Purpose |
|---------|---------|
| `infra-init` | Bootstrap repos, Terraform, imports, and dependency checks |
| `deploy-service` | Build -> push -> values.yaml bump -> Helm upgrade |
| `deploy-one-off` | One-off Kubernetes deployment helper |
| `open-dashboard` | Open configured dashboards |
| `add-import-permissions` | IAM setup for Terraformer imports |

## Prerequisites

- `terraform`
- `kubectl`
- `aws`
- `git`
- `docker-build`
- `helm-upgrade`
- `yq`

## Config Sources

`infra-init` reads shared project config from `infra-config.yaml` and `.envrc.k8.dc`.

`deploy-service` uses both:

| Config | Purpose |
|--------|---------|
| `infra-config.yaml` | Sets `paths.projects_dir` and shared scalar/path config |
| per-project `project.yaml` files | Declare Helm releases and image-to-values wiring |

This is different from `docker-build`, which reads Docker targets from the merged `infra-config.yaml` `project:` section.

## Basic Infra Config

```yaml
paths:
  terraform_dir: terraform
  projects_dir: repos/incubator/projects

terraform:
  state_bucket: my-tf-state
```

Scalar values such as AWS account and profile can come from `.envrc.k8.dc`:

```bash
export K8_AWS_ACCOUNT_ID="123456789012"
export K8_AWS_PROFILE="terraformer"
export K8_AWS_REGION="us-east-1"
```

## deploy-service

`deploy-service` is a release pipeline:

1. Resolve the image key to a `project.yaml` entry.
2. Build and push the image with `docker-build --push`.
3. Read the configured Helm chart `values.yaml`.
4. Update the configured `values_path`.
5. Reverse-map the chart path to a Helm release.
6. Run `helm-upgrade --include <release>`.

### Flat Project YAML

Use this shape for standalone projects under `paths.projects_dir`:

```yaml
# repos/incubator/projects/easy-peasy/project.yaml
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
      context: app
      dockerfile: Dockerfile
      registry_path: testing/easy-peasy
      helm:
        chart_path: repos/incubator/projects/easy-peasy/helm/easy-peasy
        values_path: .image.tag
        format: tag
```

Enabled commands:

```bash
deploy-service easy-peasy
deploy-service easy-peasy --dry-run
deploy-service easy-peasy --skip-deploy
deploy-service easy-peasy --tag v2.1.0
```

### Composite Project YAML

Use this shape when image keys are `<domain>/<service>`:

```yaml
# repos/incubator/projects/codefre.sh/project.yaml
type: composite
status: active

helm:
  release: codefre-sh
  namespace: apps
  tier: 3
  timeout: 15m
  path: helm/codefre-sh

projects:
  - domain: codefre.sh
    services:
      - name: backend
        helm:
          chart_path: repos/incubator/projects/codefre.sh/helm/codefre-sh
          values_path: .backend.image.tag
          format: tag
      - name: frontend
        helm:
          chart_path: repos/incubator/projects/codefre.sh/helm/codefre-sh
          values_path: .frontend.image.tag
          format: tag
```

Enabled commands:

```bash
deploy-service codefre.sh/backend
deploy-service codefre.sh/backend codefre.sh/frontend
```

When multiple images point at the same chart, `deploy-service` updates all configured values and runs one final Helm upgrade for the unique release.

### Field Reference

Project-level Helm release metadata:

| Field | Required | Purpose |
|-------|----------|---------|
| `helm.release` | Yes for deploy | Release name passed to `helm-upgrade --include` |
| `helm.namespace` | No | Namespace metadata for project registry |
| `helm.tier` | No | Deploy ordering metadata; default `5` |
| `helm.timeout` | No | Timeout metadata; default `10m` |
| `helm.path` | Yes for reverse-map | Chart path relative to the project directory |

Image-to-values wiring:

| Field | Required | Purpose |
|-------|----------|---------|
| `helm.chart_path` | Yes | Chart directory containing `values.yaml`; used to find and update the values file |
| `helm.values_path` | Yes | `yq` path to update inside `values.yaml` |
| `helm.format` | No | `tag` for a bare tag value, `image` for a full image string; default `tag` |

The current reverse-map compares `helm.chart_path` against the project registry's `PROJECT_DIR/helm.path`. Keep those paths equivalent or deployment will fail with `Could not reverse-map chart_path`.

## Usage

```bash
infra-init doctor
infra-init all
infra-init terraform
infra-init repos
infra-init import
infra-init import --force

deploy-service easy-peasy
deploy-service easy-peasy --dry-run
deploy-service easy-peasy --skip-build
deploy-service easy-peasy --skip-deploy
deploy-service easy-peasy --no-cache
deploy-service easy-peasy --stage
deploy-service easy-peasy --prod
deploy-service backend frontend
```

## Common Failure Modes

| Error | Fix |
|-------|-----|
| `No project.yaml declares helm for image` | Add a matching `docker.images[].name` or `projects[].services[].name` entry under a `project.yaml` in `paths.projects_dir` |
| `values.yaml not found` | Check `helm.chart_path`; it must point at the chart directory from the infra root |
| `Could not reverse-map chart_path` | Make `helm.chart_path` match `PROJECT_DIR/helm.path` |
| `values.yaml has no value at ...` | Add the configured `values_path` to the chart values file |
