# cluster-tools — Cluster Inspection

Kubernetes cluster dashboards and inspection utilities.

## Installation

```bash
make install    # Installs cluster-* tools to ~/.local/bin
```

## Prerequisites

- `kubectl` with cluster access
- `helm` for release inspection
- `glow` for markdown rendering (optional, used by `cluster-layout`)

## Configuration

Uses current `kubectl` context. Optionally reads `infra-config.yaml` for tier groupings and status patterns (see `~/.local/share/k8-lib/README.md`). Every tool accepts `--config <path>` to specify an alternative config file.

## Tools

| Command | Purpose |
|---------|---------|
| `cluster-status` | Tiered pod dashboard showing health across namespaces |
| `cluster-nodes` | Node layout with CPU/RAM reservations |
| `cluster-resources` | Per-pod CPU/RAM usage vs requests (needs metrics-server) |
| `cluster-helm` | Helm release status, color-coded by status |
| `cluster-layout` | Node/PVC/PV layout as rendered markdown |
| `cluster-manticore` | Manticore search status dashboard (readers, indexes, S3, jobs) |
| `cluster-setup-telemetry` | Install OTel Collector + Fluent Bit on a VM/EC2 instance |

## Usage

```bash
cluster-status                  # All pods, grouped by tier
cluster-status --watch          # Auto-refresh
cluster-nodes                   # Node summary
cluster-nodes --pods            # Nodes with pod placement
cluster-resources               # Resource usage (requires metrics-server)
cluster-helm                    # Helm releases with failure highlighting
cluster-layout                  # Full cluster layout (requires glow)
cluster-manticore               # Manticore search status (readers, S3, jobs)
```

### cluster-setup-telemetry

Installs `signoz-otel-collector` + Fluent Bit on a VM or EC2 instance, auto-detects local services (PostgreSQL, MySQL, Nginx, Redis, Docker), and generates complete OTel Collector + Fluent Bit configs pointing at a central OTLP endpoint.

```bash
cluster-setup-telemetry otel.example.com:4317                    # Basic setup
cluster-setup-telemetry 10.0.1.50:4317 legacy-db-01             # With custom hostname label
FORCE_REINSTALL=1 cluster-setup-telemetry otel.example.com:4317  # Overwrite existing
```

Requires root/sudo. Run on the target VM (not the dev machine).

#### Configuration

In `infra-config.yaml`:

```yaml
telemetry:
  environment: production       # deployment.environment resource attribute
  host_type: ec2                # host.type attribute (ec2 | vm | bare-metal)
  otelcol_version: "0.129.12"  # signoz-otel-collector release version
  resource_detectors: "env, system, ec2"
  otelcol_memory_limit_mib: 512
  otelcol_spike_limit_mib: 128
```

All values overridable via `K8_TELEMETRY_*` env vars. k8-lib is optional — the tool gracefully falls back to defaults on remote VMs without it installed.

#### Service-Specific Environment Variables

| Variable | Purpose |
|----------|---------|
| `PG_MONITOR_USER` / `PG_MONITOR_PASSWORD` | PostgreSQL monitoring credentials |
| `MYSQL_MONITOR_USER` / `MYSQL_MONITOR_PASSWORD` | MySQL monitoring credentials |
