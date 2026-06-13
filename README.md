# staging-tools — Staging Environment Lifecycle

Manage staging environment deployment, teardown, logs, and status.

## Installation

```bash
make install    # Installs staging-* tools to ~/.local/bin
```

## Prerequisites

- `kubectl` with cluster access
- `helm` for release management
- `helm-upgrade` (from [helm-tools](../helm-tools/)) for `staging-up`

## Configuration

All tools load settings from `infra-config.yaml` via the shared k8-lib config chain (see [k8-lib README](../k8-lib/README.md)). Relevant sections:

| YAML Path | Env Override | Default | Purpose |
|-----------|-------------|---------|---------|
| `.kubernetes.staging_namespace` | `K8_STAGING_NAMESPACE` | `staging` | Target namespace for staging |
| `.kubernetes.app_prefix` | `K8_APP_PREFIX` | `app` | Label prefix for pod selectors |

Every tool accepts `--config <path>` to specify an alternative config file.

## Tools

| Command | Purpose |
|---------|---------|
| `staging-up` | Deploy all staging services (delegates to `helm-upgrade --env stage`) |
| `staging-down` | Uninstall all Helm releases in the staging namespace |
| `staging-logs` | Tail logs for a staging service by name |
| `staging-status` | Show pods, Helm releases, KEDA ScaledObjects, and resource usage |

## Usage

```bash
staging-up                          # Deploy staging environment
staging-down                        # Tear down all staging releases
staging-logs                        # Tail frontend logs (default)
staging-logs backend                # Tail backend logs
staging-logs worker                 # Tail any service by name
staging-status                      # Full staging dashboard
```

### KEDA scale-to-zero

If `staging-logs` reports no pods, KEDA may have scaled the deployment to zero. Run `staging-status` to check ScaledObject state, then curl your staging URL to wake it up.
