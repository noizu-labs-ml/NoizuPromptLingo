# Remote-access TLS — origin certificate runbook

`*.remote-access.noizu.com` is a **second-level wildcard** and is **not** covered
by the existing `*.noizu.com` origin cert (`cloudflare-tls-synced`). The frps
ingress in `apps-ns` therefore needs its own origin certificate (for Cloudflare
**Full (strict)** origin validation). Two ways to mint it — pick one.

> Both are outward-facing (they create a real Cloudflare Origin CA certificate)
> and need the account **Origin CA Key** (Cloudflare dashboard → SSL/TLS → Origin
> Server → *Origin CA key*), which is **distinct** from the DNS `api_token` the
> zones module uses. Neither touches the cluster.

## Option A — Cloudflare API script (quickest)

```bash
export CLOUDFLARE_ORIGIN_CA_KEY="v1.0-…"      # or CLOUDFLARE_API_TOKEN with Origin-CA edit
projects/NoizuPromptLingo/scripts/mint-remote-access-origin-cert.sh
```

Writes `.secrets/tls/remote-access/{cert.pem,key.pem}` (openssl-generated key +
CSR → `POST /client/v4/certificates`, `request_type=origin-rsa`).

## Option B — Terraform (IaC, reproducible)

`terraform/cloudflare/origin-certs/` mints the same cert via the provider and
writes the PEMs to `.secrets/tls/remote-access/`:

```bash
cd terraform/cloudflare/origin-certs
export TF_VAR_cloudflare_origin_ca_key="v1.0-…"
export TF_VAR_out_dir="$(git rev-parse --show-toplevel)/.secrets/tls/remote-access"
tofu init && tofu apply
```

> Verify the cloudflare **v5** provider argument names for
> `cloudflare_origin_ca_certificate` + Origin CA auth (`api_user_service_key`)
> before applying; v5 was an API-schema rewrite. The API script (Option A) has no
> such version risk.

## Getting the cert into the cluster (`remote-access-tls-synced`)

The `remote-access` Helm chart ingress references `secretName:
remote-access-tls-synced` (override via `ingress.tlsSecretName`). Produce that
secret in `apps-ns` using whichever mechanism that namespace uses — mirroring the
existing `cloudflare-tls-synced`:

- **Sealed secret** (as `infra-services/secrets.tf` does for `cloudflare-tls-synced`):
  ```bash
  kubectl create secret tls remote-access-tls-synced \
    --cert=.secrets/tls/remote-access/cert.pem \
    --key=.secrets/tls/remote-access/key.pem \
    -n apps-ns --dry-run=client -o yaml \
    | kubeseal --format yaml > <module>/secrets/remote-access-tls-synced.sealedsecret.yaml
  ```
- **or Infisical**: add a `remote-access-tls` section to `.infisical-secrets.yaml`
  (mirror the `shared-tls` block: `TLS_CRT`/`TLS_KEY` → the two PEM files,
  `decode: base64`), `infisical-populate-secrets`, then an `InfisicalSecret` CRD
  syncing it to `remote-access-tls-synced` in `apps-ns`.

## Shortcut (no dedicated cert)

If the zone runs Cloudflare SSL mode **Full** (not Full-Strict), the origin SNI
mismatch is tolerated, so you can skip minting and point the chart at the existing
wildcard: `--set ingress.tlsSecretName=cloudflare-tls-synced`. Use a dedicated
cert (above) for Full-Strict.

## Related
- DNS records: `terraform/cloudflare/zones/noizu.com/main.tf` (`*.remote-access`,
  `remote-access`, `tunnel`).
- Chart: `projects/NoizuPromptLingo/helm/remote-access/`.
- Design: `projects/NoizuPromptLingo/docs/REMOTE-ACCESS-TUNNEL-DESIGN.md` §4.2.
