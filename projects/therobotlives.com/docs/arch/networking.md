# Networking & Security

## Traffic Flow

```
Browser → Cloudflare (DNS + CDN + WAF) → NGINX Ingress (K8s) → Service → Pod (nginx)
```

All DNS for `therobotlives.com` is managed via Cloudflare with proxy enabled (orange cloud). Direct origin access is blocked.

## Cloudflare IP Whitelist

The Ingress uses `nginx.ingress.kubernetes.io/whitelist-source-range` populated from the `therobotlives.cloudflareWhitelist` helper in `_helpers.tpl`. This restricts origin traffic to known Cloudflare IP ranges only.

Enabled when `ingress.cloudflareOnly: true` in values.yaml (default: true).

## TLS

TLS termination occurs at the Ingress. The certificate is stored in a K8s Secret (`therobotlives-tls`) synced by the Infisical Operator via an InfisicalSecret CRD.

**Infisical path**: `k8-infra` project, `prod` environment, `/apps/tls/therobotlives`
**Sync interval**: 300 seconds
**Keys**: `THEROBOTLIVES_TLS_CRT` (certificate), `THEROBOTLIVES_TLS_KEY` (private key)

## Ingress Annotations

- `ssl-redirect: "true"` — force HTTPS
- `proxy-body-size: "10m"` — adequate for form submissions
