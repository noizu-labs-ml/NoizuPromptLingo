# `kubernetes/init` — provider bootstrap

This module wires up the Terraform **Kubernetes** and **Helm** providers against the
local `docker-desktop` cluster and lays down the baseline platform:

- **Longhorn** distributed block storage (+ an `iscsid` DaemonSet prereq)
- **Sealed Secrets** controller (the in-cluster secret manager)
- **ingress-nginx** controller (default ingress class)
- **MinIO** S3-compatible object storage in the `infra` namespace, exposed at
  `minio.noizu.com` (S3 API) and `minio-console.noizu.com` (web console)

> Scope is intentionally narrow: this is the bootstrap that stands the cluster
> back up. The final step of the colo overhaul tears down the k8s cluster and
> rebuilds from here, so the module stays minimal.

> **Why this doc exists:** the pinned providers are on **v3.x**, which carries
> breaking syntax changes vs. the v2.x examples found in most older blog posts and
> in model training data. The gotchas below were verified against the current
> provider docs on 2026-06-07. Read this before editing the `.tf` files.

## Docs in this folder

| Doc | Covers |
|---|---|
| `README.md` (this) | overview, versions, **v3 provider breaking changes**, provider connection options |
| `longhorn.md` | Longhorn chart config, rollout, node prereqs, uninstall gotcha |
| `minio.md` | MinIO deployment, credentials, TLS, ingress hosts |

## Cluster target

| Setting | Value |
|---|---|
| kubeconfig | `~/.kube/config` |
| context | `docker-desktop` |
| control plane | `https://127.0.0.1:<random>` (docker-desktop) |

Single-node cluster → Longhorn replica count is pinned to `1`.

## Pinned versions

| Component | Version | Source |
|---|---|---|
| Terraform | `>= 1.5` | — |
| `hashicorp/kubernetes` | `~> 3.2` | registry |
| `hashicorp/helm` | `~> 3.2` | registry |
| Longhorn chart | `1.12.0` | `https://charts.longhorn.io` |

Re-pin by checking the registry/Helm repo:

```sh
curl -s https://registry.terraform.io/v1/providers/hashicorp/kubernetes | jq -r .version
curl -s https://registry.terraform.io/v1/providers/hashicorp/helm       | jq -r .version
helm repo add longhorn https://charts.longhorn.io && helm repo update longhorn
helm search repo longhorn/longhorn --versions | head
```

## Resources in this module

| File | Resource | Notes |
|---|---|---|
| `provider.tf` | provider config | kubernetes + helm + kubectl + tls, via kubeconfig/context |
| `namespace.tf` | `kubernetes_namespace_v1.infra` | namespace `infra` (hosts MinIO) |
| `longhorn.tf` | `kubernetes_namespace_v1.longhorn` | namespace `longhorn-system` |
| `longhorn.tf` | `helm_release.longhorn` | Longhorn chart into `longhorn-system` |
| `iscsid.tf` | `kubernetes_daemon_set_v1.iscsid` | host iSCSI daemon for Longhorn (docker-desktop) |
| `controllers.tf` | `helm_release.sealed_secrets` | Sealed Secrets controller in `kube-system` |
| `controllers.tf` | `helm_release.ingress_nginx` | ingress-nginx controller (default class) |
| `minio.tf` | `kubernetes_deployment_v1.minio` + PVC/Service/Secret/TLS/Ingress | MinIO in `infra`, API + console ingress |

## v3 provider breaking changes (the important part)

These are the differences that bite when copying v2-era examples:

### 1. Resources are versioned — use the `_v1` suffix
`kubernetes_namespace` (and most resources) are **deprecated** in v3 in favor of
`kubernetes_namespace_v1`. The unversioned names still work but emit
`Deprecated; use kubernetes_namespace_v1` warnings and may be removed.

```hcl
resource "kubernetes_namespace_v1" "infra" {
  metadata { name = "infra" }
}
```

### 2. Helm provider `kubernetes` is now an ATTRIBUTE, not a block
v2 used a nested `kubernetes { ... }` block. v3 uses an attribute assignment with
`=` and `{ }`:

```hcl
provider "helm" {
  kubernetes = {                 # <-- '=' is required in v3
    config_path    = "~/.kube/config"
    config_context = "docker-desktop"
  }
}
```

### 3. `helm_release.set` is now a LIST ATTRIBUTE, not repeated blocks
v2 used repeated `set { name = ... value = ... }` blocks. v3 takes a single
`set = [ { ... }, { ... } ]` list:

```hcl
resource "helm_release" "longhorn" {
  # ...
  set = [
    { name = "defaultSettings.defaultDataPath",        value = "/var/lib/longhorn" },
    { name = "persistence.defaultClassReplicaCount",   value = "1" },
  ]
}
```

`set_sensitive` and `set_list` migrate to list attributes the same way.

## Provider connection options (reference)

We connect via kubeconfig + context, which is simplest for docker-desktop. The
full set of connection arguments (same names on both the `kubernetes` provider and
the helm provider's `kubernetes = {}` attribute), for when this moves to a real
cluster:

| Argument | Env var | Use |
|---|---|---|
| `config_path` | `KUBE_CONFIG_PATH` | single kubeconfig file (what we use) |
| `config_paths` | `KUBE_CONFIG_PATHS` | multiple kubeconfig files |
| `config_context` | `KUBE_CTX` | context to select (what we use) |
| `config_context_auth_info` | `KUBE_CTX_AUTH_INFO` | override kubeconfig user |
| `config_context_cluster` | `KUBE_CTX_CLUSTER` | override kubeconfig cluster |
| `host` | `KUBE_HOST` | API endpoint (credential-based config) |
| `token` | `KUBE_TOKEN` | service-account token |
| `client_certificate` / `client_key` | `KUBE_CLIENT_CERT_DATA` / `KUBE_CLIENT_KEY_DATA` | mTLS client auth |
| `cluster_ca_certificate` | `KUBE_CLUSTER_CA_CERT_DATA` | CA bundle |
| `username` / `password` | `KUBE_USER` / `KUBE_PASSWORD` | HTTP basic auth |
| `exec` | — | external credential plugin (EKS/GKE/AKS short-lived tokens) |
| `proxy_url` | `KUBE_PROXY_URL` | proxy to the API |
| `insecure` | `KUBE_INSECURE` | skip TLS verify (avoid) |
| `tls_server_name` | `KUBE_TLS_SERVER_NAME` | SNI override |
| `ignore_annotations` / `ignore_labels` | — | RegExp filters to stop Terraform churning on controller-managed metadata |

Notes:
- **Do not mix an `exec` block with other credential attributes.**
- **Don't create the cluster and its Kubernetes resources in the same module** —
  provider config is resolved at plan time, so the cluster must already exist
  (docker-desktop does, so we're fine).

## Longhorn notes

- Chart installs into its own `longhorn-system` namespace (created here explicitly
  so the namespace lifecycle is managed by Terraform, not the chart).
- `helm_release` uses `wait = true` + `timeout = 600` because Longhorn rolls out
  DaemonSets (manager, CSI plugin) that take time to become ready on first install.
- `defaultSettings.defaultDataPath = /var/lib/longhorn` — where replica data lives
  on the node. On docker-desktop this is inside the VM.
- `persistence.defaultClassReplicaCount = 1` — single node, so more replicas can't
  be scheduled and would leave volumes degraded.
- After apply, Longhorn registers a `longhorn` StorageClass. Verify:
  ```sh
  kubectl -n longhorn-system get pods
  kubectl get storageclass
  ```

## Usage

```sh
terraform init -upgrade   # picks up provider version bumps
terraform validate
terraform plan
terraform apply
```

State is local (no backend configured). Add a remote backend before sharing this
module across machines.
