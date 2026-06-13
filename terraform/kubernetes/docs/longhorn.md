# Longhorn

Distributed block storage for the cluster. Installed via `helm_release.longhorn`
in `longhorn.tf`.

## Facts (verified 2026-06-07)

| Item | Value |
|---|---|
| Helm repo | `https://charts.longhorn.io` |
| Chart | `longhorn` |
| Pinned version | `1.12.0` (latest stable) |
| Namespace | `longhorn-system` (managed by `kubernetes_namespace_v1.longhorn`) |
| StorageClass created | `longhorn` |

Check for newer chart releases:

```sh
helm repo add longhorn https://charts.longhorn.io
helm repo update longhorn
helm search repo longhorn/longhorn --versions | head
```

## Values we set

```hcl
set = [
  { name = "defaultSettings.defaultDataPath",      value = "/var/lib/longhorn" },
  { name = "persistence.defaultClassReplicaCount", value = "1" },
]
```

- **`defaultSettings.defaultDataPath`** — host path where replica data is stored.
  On the NixOS nodes this is `/var/lib/longhorn`, created by the node module
  ([`nixos-longhorn-node.nix`](./nixos-longhorn-node.nix)).
- **`persistence.defaultClassReplicaCount = 1`** — one replica per volume. This
  cluster has 3 nodes, so it can safely be raised for redundancy; see the
  prerequisites section below.

## Rollout behaviour

`helm_release.longhorn` uses `wait = true` and `timeout = 600`. Longhorn deploys
several DaemonSets (the manager, the CSI plugin, the engine image) plus the UI and
CSI controller Deployments. First install genuinely takes minutes; the long timeout
prevents Terraform from failing the apply prematurely.

## Verify after apply

```sh
kubectl -n longhorn-system get pods
kubectl -n longhorn-system rollout status ds/longhorn-manager
kubectl get storageclass            # expect a 'longhorn' class
```

## Prerequisites on the node

Longhorn needs `open-iscsi` / `iscsid`, NFS client tooling (for RWX volumes), and
a few kernel modules on **every node that runs Longhorn**. Without them the
`longhorn-manager` (and CSI) pods crash-loop and the `:9502` readiness probe is
refused.

### This cluster is NixOS (not docker-desktop)

The cluster is 3 NixOS nodes — `noizu-server` (base colo) plus `k8s-mvm-1` /
`k8s-mvm-2` (VM members). NixOS has no `/usr/bin`, so the prerequisites must be
declared in each node's config. A freshly provisioned member that skips this will
crash-loop `longhorn-manager` while an already-provisioned node (e.g. the base)
works — the exact failure we hit on the VM members.

Apply the reference module [`nixos-longhorn-node.nix`](./nixos-longhorn-node.nix)
on every Longhorn node, then `nixos-rebuild switch`. It enables
`services.openiscsi`, NFS support, the required kernel modules, and creates
`/var/lib/longhorn`. **Do this before `terraform apply`/`terragrunt apply`.**

### Replica count on a multi-node cluster

`persistence.defaultClassReplicaCount` is still `1` (carried over from the
single-node docker-desktop setup). On this 3-node cluster, bump it to `2`–`3` in
`longhorn.tf` for real data redundancy — a deliberate availability decision, so
it's left at `1` until chosen.

## Gotchas

- **Uninstall is sticky.** Longhorn protects against accidental data loss. Before
  `terraform destroy`, set `deleting-confirmation-flag` to `true` (Setting
  `defaultSettings.deletingConfirmationFlag` or via the UI), otherwise the helm
  release deletion hangs/fails.
- **Don't co-locate cluster creation and storage in one module/apply.** Provider
  config is resolved at plan time; if the cluster doesn't exist yet the helm
  provider can't connect. Here the cluster (docker-desktop) already exists, so it's
  fine.
