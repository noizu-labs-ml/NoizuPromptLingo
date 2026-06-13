# docker-tools - Docker Build and Push

Docker image build and push helpers with shared config, target aliases, BuildKit/buildx support, multi-image selection, and local build state.

## Install

```bash
make install
```

Installs:

| Command | Purpose |
|---------|---------|
| `docker-build` | Build one or more configured Docker image targets |
| `docker-push` | Push a previously built image or a selected configured target |
| `docker-qemu11` | Register newer QEMU binfmt support for amd64 emulation on arm hosts |

## Prerequisites

- Docker with BuildKit enabled
- `docker buildx` for multi-arch builds
- Registry credentials, for example `docker login $K8_DOCKER_REGISTRY`
- `yq`

## Config Sources

`docker-build` and `docker-push` read Docker targets from the merged `infra-config.yaml` `project:` section.

Registry and credential values should come from `.envrc.k8.dc` or environment variables:

```bash
export K8_DOCKER_REGISTRY="783147025407.dkr.ecr.us-east-1.amazonaws.com"
```

## Docker Target Config

### Flat Images

Use `project.docker.images[]` for standalone image targets:

```yaml
project:
  name: my-stack
  docker:
    images:
      - name: backend
        context: app/backend
        dockerfile: Dockerfile
        registry_path: my-org/backend
        build_args:
          MIX_ENV: prod
        platform: linux/amd64,linux/arm64
```

Fields:

| Field | Required | Purpose |
|-------|----------|---------|
| `name` | Yes | CLI target and alias, for example `docker-build backend` |
| `context` | No | Build context path relative to `infra-config.yaml`; defaults to config directory |
| `dockerfile` | No | Dockerfile path relative to the context; defaults to `Dockerfile` |
| `registry_path` | No | Path under `K8_DOCKER_REGISTRY`; defaults to `name` |
| `build_args` | No | Static `--build-arg` values |
| `platform` | No | Per-image platform override |

### Alias for a Nonstandard Directory

Use `name` as the alias and point `context` at the real path:

```yaml
project:
  name: testing
  docker:
    images:
      - name: easy-peasy
        context: random/testing/random/not-helm-dir/easy-pasy
        dockerfile: Dockerfile
        registry_path: testing/easy-peasy
```

Enabled commands:

```bash
docker-build easy-peasy
docker-build --include easy-peasy
docker-build --push easy-peasy
docker-push easy-peasy
```

### Composite Images

Use `project.type: composite` when one config describes many domain/service targets. The CLI target becomes `<domain>/<service>`:

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
        - name: frontend
          context: app/frontend
          dockerfile: Dockerfile
          registry_path: codefre.sh/frontend
```

Enabled commands:

```bash
docker-build codefre.sh/backend
docker-build --include 'codefre.sh/*'
docker-build --pick
```

### Build to Deploy Wiring

`docker-build` can build and push the image, but it does not by itself update Helm values. For the full build-push-values-deploy pipeline, see `deploy-service` in [infra-tools](../infra-tools/).

The image-to-chart wiring looks like this in per-project `project.yaml` files consumed by `deploy-service`:

```yaml
docker:
  images:
    - name: backend
      context: app/backend
      registry_path: my-org/backend
      helm:
        chart_path: helm/backend
        values_path: .image.tag
        format: tag
```

## Usage

```bash
docker-build                         # Auto-detect from CWD or build configured targets
docker-build backend                 # Build one target
docker-build --include backend,worker # Build a comma-separated list
docker-build --include 'codefre.sh/*' # Build targets matching a glob
docker-build --pick                  # Interactive multi-select
docker-build --all                   # Build every configured target
docker-build --push backend          # Build and push
docker-build --native backend        # Native architecture only
docker-build --multiarch backend     # linux/amd64 and linux/arm64
docker-build --platform linux/amd64 backend
docker-build --no-cache backend

docker-push backend
docker-push --include backend,worker
docker-push --all
```

## How Target Resolution Works

`--include` accepts configured target names, not file paths. To build a target by a friendly name, add an entry under `project.docker.images[]` or `project.projects[].services[]`.

Legacy `docker.repos` and `docker.mappings` still exist as fallback behavior, but current project config should prefer the `project:` model. In the current implementation, legacy mappings are loaded only when no project Docker targets were discovered.

## QEMU 11 for Elixir Builds

`tonistiigi/binfmt:latest` can lag upstream QEMU. If Elixir/BEAM cross-arch builds fail under amd64 emulation on an arm64 host, run:

```bash
docker-qemu11
docker-qemu11 --check
```

Rerun it after Docker Desktop or OrbStack restarts.

## State

Build state is tracked in `.docker-state/` at the project root:

| File | Purpose |
|------|---------|
| `last` | Last build variables |
| `shadow` | Last pushed build |
| `builds` | Unpushed build queue, capped at 10 |
| `pushes` | Push history, capped at 10 |
