# MinIO

S3-compatible object storage for the platform. Deployed by `minio.tf` as raw
Kubernetes resources (Deployment + PVC + Service + Secret + TLS + two Ingresses)
in the **`infra`** namespace.

This is a Terraform port of the platform Helm chart
(`noizu-infra/kubernetes/helm/platform/minio`), adapted for the bootstrap module.

## Facts

| Item | Value |
|---|---|
| Image | `quay.io/minio/minio:RELEASE.2025-09-07T16-13-09Z` |
| Namespace | `infra` |
| Server args | `server /data --console-address :9001` |
| API port | `9000` |
| Console port | `9001` |
| Data volume | `minio-data-pvc`, `100Gi`, `longhorn` StorageClass, RWO |
| Service | `minio-service` (ClusterIP) exposing `9000`/`9001` |
| API host | `minio.noizu.com` → service port 9000 |
| Console host | `minio-console.noizu.com` → service port 9001 |
| TLS secret | `minio-noizu-com-tls` |

## Credentials

Root credentials come from a Terraform-managed Secret (`minio-secrets`,
keys `MINIO_ROOT_USER` / `MINIO_ROOT_PASSWORD`), sourced from variables:

```sh
export TF_VAR_minio_root_user=minioadmin           # optional; defaults to minioadmin
export TF_VAR_minio_root_password='<strong-secret>' # required, sensitive
terraform apply
```

Do not commit a real password. The production chart instead syncs these from the
Infisical operator at `/platform/minio`; this bootstrap module has no Infisical,
so it uses TF variables. Migrate to a sealed/Infisical-managed secret once the
secret manager is up — the Deployment only references the Secret by name, so the
swap is transparent.

## TLS

`minio.tf` generates a **self-signed** cert (via the `tls` provider) covering both
`minio.noizu.com` and `minio-console.noizu.com`, stored in `minio-noizu-com-tls`.
Replace this secret with the real Cloudflare cert in production — the ingress
references are unchanged.

## Ingress

Both ingresses use the `nginx` class and carry the annotations from the platform
chart:

- `proxy-body-size: "0"` — no upload size cap (large S3 objects).
- `proxy-read-timeout` / `proxy-send-timeout: "600"` — long-running transfers.
- `ssl-redirect: "true"`.
- `configuration-snippet` strips `Accept-Encoding` — Cloudflare rewrites that
  header before reaching the origin, which breaks MinIO if forwarded.

Requires `helm_release.ingress_nginx` (declared in `controllers.tf`); the MinIO
ingresses `depends_on` it.

## Verify after apply

```sh
kubectl -n infra get pods,svc,ingress -l app.kubernetes.io/name=minio
kubectl -n infra rollout status deploy/minio
# health endpoints (from inside the cluster or via the ingress host):
#   GET /minio/health/ready  GET /minio/health/live  on port 9000
```
