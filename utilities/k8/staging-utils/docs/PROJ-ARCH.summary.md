# Project Architecture Summary — staging-tools

CLI toolkit with four shell scripts managing the Kubernetes staging lifecycle: deploy (`staging-up`), teardown (`staging-down`), log tailing (`staging-logs`), and status inspection (`staging-status`). Installed via Makefile to `~/.local/bin`.

## Components

- **staging-up** — delegates to `helm-tools/helm-upgrade --env stage`
- **staging-down** — iterates Helm releases in staging namespace and uninstalls each
- **staging-logs** — tails kubectl logs by label selector; KEDA scale-to-zero aware
- **staging-status** — aggregates Helm releases, pods, ScaledObjects, and resource metrics

## Design

Thin wrappers over Helm and kubectl. Convention-driven namespace/label defaults via environment variables (`K8_STAGING_NAMESPACE`, `K8_APP_PREFIX`). No secret management — handled by broader infra.

## Dependencies

Helm 3, kubectl, sibling `helm-tools/helm-upgrade` utility, optional KEDA and metrics-server.
