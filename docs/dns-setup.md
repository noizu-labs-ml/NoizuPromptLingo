# tobornalp.com — DNS Setup Checklist

Domain for the **tobornalp.com** project (source: `projects/therobotplans.com/`), registered on Namecheap under the `the-robot-lives` (trl) account. Managed via Cloudflare DNS with Terraform.

## Prerequisites

- [ ] Cloudflare API token for TRL account (`CF_TRL_API_TOKEN` in `.envrc`)
- [ ] Namecheap API access for TRL account (`TheRobotIsMe`)
- [ ] `direnv` active in terminal (for `.envrc` auto-loading)

## Infrastructure Location

| Component | Path |
|-----------|------|
| Terraform zone config | `terraform/zones-trl/tobornalp.com/` |
| Provider + variables | `terraform/zones-trl/tobornalp.com/providers.tf` |
| DNS records | `terraform/zones-trl/tobornalp.com/main.tf` |
| Credentials | `terraform/.envrc` → `terraform/.envrc.dc` (gitignored secrets layer) |

## Step-by-Step

### 1. Terraform Init

```bash
cd terraform/zones-trl/tobornalp.com
direnv allow
terraform init
```

### 2. Review the Plan (Mandatory)

```bash
terraform plan
```

**Expected resources:**
- `cloudflare_zone.tobornalp_com` — creates the zone in Cloudflare
- `cloudflare_dns_record.tobornalp_com_a_root` — A record `tobornalp.com → 208.64.36.79` (proxied)
- `cloudflare_dns_record.tobornalp_com_cname_www` — CNAME `www → tobornalp.com` (proxied)

Review the plan output thoroughly before proceeding.

### 3. Apply

```bash
terraform apply
```

**Save the outputs:**
- `nameservers` — the two CF nameservers to set in Namecheap
- `zone_id` — for the import block (add to `main.tf` after first apply)

### 4. Update Namecheap Nameservers

1. Log in to Namecheap as `TheRobotIsMe`
2. Navigate to **Domain List → tobornalp.com → Nameservers**
3. Select **Custom DNS**
4. Enter the two nameserver values from the Terraform output (e.g., `aria.ns.cloudflare.com`, `bob.ns.cloudflare.com`)
5. Save

### 5. Wait for Zone Activation

Cloudflare needs to verify nameserver delegation. Typically 5–30 minutes, occasionally up to 24 hours.

Check status:
```bash
# Via Cloudflare API
curl -s -H "Authorization: Bearer $CF_TRL_API_TOKEN" \
  "https://api.cloudflare.com/client/v4/zones?name=tobornalp.com" | jq '.result[0].status'
```

Expected: `"active"` once nameservers propagate.

### 6. Add Import Block to Terraform

After the zone is active and you have the zone ID, add an import block to `main.tf` for future state management:

```hcl
import {
  to = cloudflare_zone.tobornalp_com
  id = "<zone-id-from-output>"
}
```

This ensures `terraform plan` on a fresh checkout doesn't try to recreate the zone.

### 7. Configure TLS

Cloudflare TLS is automatic for proxied records:

- **SSL/TLS mode**: Full (Strict) — set in Cloudflare dashboard or via Terraform
- **Origin certificate**: If the cluster needs a Cloudflare origin cert for this domain:
  1. Generate an origin cert in Cloudflare dashboard (or API)
  2. Store in Infisical under `/platform/tls/tobornalp.com`
  3. Create an InfisicalSecret CRD to sync it as a K8s TLS secret
  4. Reference the secret in the ingress `tls[].secretName`

For initial setup, Cloudflare's universal SSL with Full (Strict) mode and the existing `*.noizu.com` origin cert pattern is sufficient — the service will be behind Cloudflare's proxy.

### 8. Wire Up Ingress (When Ready)

When a Helm chart exists for the service:

```yaml
# Example ingress snippet
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - tobornalp.com
      secretName: tobornalp-com-tls
  rules:
    - host: tobornalp.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: <service-name>
                port:
                  number: 80
```

Use `cloudflare-lib.ingress-annotations` for standard Cloudflare annotations:
```yaml
annotations:
  {{- include "cloudflare-lib.ingress-annotations" (dict "bodySize" "50m" "readTimeout" "300") | nindent 4 }}
```

## Adding Subdomains Later

Add new DNS records to `terraform/zones-trl/tobornalp.com/main.tf`:

```hcl
resource "cloudflare_dns_record" "tobornalp_com_a_<subdomain>" {
  zone_id = local.zone_id
  name    = "<subdomain>"
  type    = "A"
  content = local.server_ip
  proxied = true
  ttl     = 1
}
```

Then: `terraform plan` → review → `terraform apply`. Always through Terraform. Never the dashboard.

## Architecture Notes

- **Single-node cluster**: 16 GB M4 Mac (`208.64.36.79`)
- **All traffic proxied through Cloudflare** — origin IP never exposed
- **DNS is infrastructure** — changes go through Terraform PRs with `terraform plan` output
- **Pattern**: follows `zones-trl/derobot.is/` (the canonical TRL per-domain config)
