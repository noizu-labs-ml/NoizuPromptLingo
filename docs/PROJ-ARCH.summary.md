# helm-tools Architecture Summary

CLI utilities for tiered Helm chart lifecycle management on Kubernetes.

## Components

- **bin/helm-upgrade** -- Tier-ordered upgrade with MD5 change detection, env overlays, interactive UI, manifest preview, and server-side apply conflict auto-fix.
- **bin/helm-rollback** -- Reverse-tier rollback via explicit selection, auto-detect unhealthy pods, or time-window mode.
- **../k8-lib** -- Sibling shared library providing logging, tier definitions, namespace lookup, and Helm helpers.
- **.helm-state/** -- Persisted checksums for skip-unchanged behavior.

## Data Flow

helm-upgrade discovers charts, filters by namespace/env/include/exclude, computes checksums, builds a tier-ordered plan, confirms with user, and executes tier-by-tier with conflict recovery. helm-rollback detects candidates (explicit, unhealthy, or time-based), presents an editable plan, and executes in reverse tier order.

## Key Decisions

- MD5 checksums per-release avoid redundant Helm operations.
- Tier ordering ensures infrastructure deploys before workloads; rollback reverses this.
- Shared k8-lib avoids duplication across devops tooling.
- Only requires Bash, Helm, kubectl, and jq.
