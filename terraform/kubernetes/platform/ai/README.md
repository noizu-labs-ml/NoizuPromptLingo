# `platform/ai` — platform-tier AI workloads

Migrated from the `kubernetes/helm/ai/*` Helm charts into a single Terraform
module. Everything is consolidated into the **`platform-ai`** namespace (the
charts previously used `ai-ns` / `qdrant-ns` / `vllm-ns`).

| App | Host | How deployed |
|-----|------|--------------|
| JupyterHub | jupyter.noizu.com | `helm_release` jupyterhub/jupyterhub **4.3.2** |
| Qdrant | _internal_ (6333/6334) | `helm_release` qdrant/qdrant **1.17.1** |
| Weaviate | weaviate.noizu.com | `helm_release` weaviate/weaviate **17.8.0** + standalone ingress |
| Langfuse | langfuse.noizu.com | hand-translated (`kubernetes_*_v1`) |
| Livebook | nb.noizu.com | hand-translated |
| Open WebUI + LiteLLM | webui.noizu.com / inference.noizu.com | hand-translated (+ lmstudio-proxy) |
| vLLM | _internal_ (8000) | hand-translated (GPU, runtimeClass `nvidia`) |

Upstream charts are deployed via `helm_release` with values rendered from the
original chart values (`files/<app>/values.yaml.tftpl`, with `storage_class` and
`namespace` injected). Local chart templates were hand-translated to
`kubernetes_*_v1` resources. The LiteLLM `model_list` was rendered from the
chart's templating into `files/open-webui/litellm-config.yaml` and mounted via a
ConfigMap.

## Secret management — Infisical

Each app's `InfisicalSecret` CR (`secrets.infisical.com/v1alpha1`, applied via
`kubectl_manifest`) is reproduced from the chart. The operator syncs from the
`k8-infra` project (env `prod`) into the managed Secrets:

| Managed secret | Infisical path | Notes |
|----------------|----------------|-------|
| `jupyter-app-secrets` | `/ai/jupyterhub` | |
| `langfuse-app-secrets` | `/ai/langfuse` | |
| `livebook-app-secrets` | `/ai/livebook` | |
| `open-webui-app-secrets` | `/ai/open-webui` | shared by Open WebUI + LiteLLM |
| `qdrant-app-secrets` | `/ai/qdrant` | |
| `vllm-app-secrets` | `/ai/vllm` | `HF_TOKEN` |
| `weaviate-app-secrets` | `/ai/weaviate` | |
| `ops-registry-secret` | `/ai/weaviate` | dockerconfigjson (ops.noizu.com) |
| `docker-registry-secret` | `/ai/weaviate` | dockerconfigjson (docker.io) |

Prerequisites (from `infra-services`): the Infisical operator + the
`universal-auth-credentials` machine-identity secret in
`infisical-operator-system`, plus the shared `cloudflare-tls-synced` /
`cloudflare-origin-pull-ca` secrets in this namespace.

## State

MinIO s3 backend, key `platform/ai/terraform.tfstate`. Storage class is read
from the root `init` state (`../../init`).

```sh
export AWS_ACCESS_KEY_ID="$(terraform -chdir=../../init output -raw minio_root_user)"
export AWS_SECRET_ACCESS_KEY="$(terraform -chdir=../../init output -raw minio_root_password)"
terraform init && terraform plan
```

## Notes / not fully reproduced

- **PVC `volumeName` pins dropped.** Livebook, Open WebUI and vLLM charts pinned
  their PVCs to specific pre-existing PV UUIDs (tied to the old `openebs-lvmpv`
  cluster state). These pins are dropped in favour of dynamic provisioning via
  `local.storage_class`. Re-add `volume_name` if migrating existing data.
- **`ops-registry-secret` image-pull dependency.** Several workloads reference
  `imagePullSecrets: ops-registry-secret`, which is created by the Weaviate
  InfisicalSecret block. Apply order is handled by the operator at runtime.
