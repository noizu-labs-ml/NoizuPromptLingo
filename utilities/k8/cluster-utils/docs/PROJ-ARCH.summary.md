# Cluster Tools — Architecture Summary

Bash CLI utilities for Kubernetes cluster inspection. Six `cluster-*` scripts in `bin/` query kubectl, helm, and metrics-server to render color-coded terminal dashboards. Shared config and formatting live in `share/k8-lib/bin/`. Installed via `make install` to `~/.local/bin`.

## Components

- **cluster-status** — Pod dashboard grouped by category
- **cluster-nodes** — Node layout with CPU/RAM reservations
- **cluster-resources** — Pod resource usage vs requests
- **cluster-layout** — Node/pod/storage mapping as markdown
- **cluster-helm** — Helm release status with failure highlighting
- **cluster-manticore** — Manticore Search status and S3 index state
- **share/k8-lib/bin/** — Shared shell library (config + formatting)
