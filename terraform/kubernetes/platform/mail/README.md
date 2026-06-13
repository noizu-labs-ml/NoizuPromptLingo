# `platform/mail` — Mailu mail server (therobotlives.com)

Terraform translation of the `kubernetes/helm/mail/mailu` Helm chart. Deploys the
full Mailu monolith into the **`platform-mail`** namespace (created by this
module):

- **PostgreSQL** (shared — `mailu` + `roundcube` databases) + **Redis** cache
- **front** (nginx mail-protocol proxy), **admin** (Podop/DKIM), **postfix**
  (SMTP, relays via SendGrid), **dovecot** (IMAP/POP3), **rspamd** (antispam)
- **roundcube** webmail + **mta-sts** policy server

The chart's only dependency (`cloudflare-lib`) is a local Helm helper library
(ingress annotations), not an external subchart — so everything is hand-
translated to `kubernetes_*_v1` / `kubectl_manifest` resources (no
`helm_release`).

## Services / networking

- **front-external** (`ClusterIP` + `externalIPs = [<server_ip>]`) binds the
  public mail ports: SMTP 25, SMTPS 465, submission 587, IMAPS 993, POP3S 995,
  sieve 4190.
- **front** (`ClusterIP`) adds internal proxy ports 10143 / 10025 / 2525.
- All other services are `ClusterIP`.
- HTTP ingresses (nginx class, Cloudflare whitelist + TLS
  `cloudflare-tls-therobotlives`): `webmail`, `mail-admin`, `mta-sts` hosts.

## Secret management — Infisical

`InfisicalSecret` CRs (operator syncs Infisical -> managed K8s Secrets):

| CR                       | Path                        | Managed Secret                 | Type                |
| ------------------------ | --------------------------- | ------------------------------ | ------------------- |
| `infisical-mail-secrets` | `/mail/mailu`               | `mail-app-secrets`             | Opaque (+ DB URIs)  |
| `infisical-mail-ops-pull`| `/mail/mailu`               | `ops-registry-secret`          | dockerconfigjson    |
| `infisical-mail-tls`     | `/apps/tls/therobotlives`   | `cloudflare-tls-therobotlives` | kubernetes.io/tls   |

A cert-manager `Certificate` (`mail-tls-letsencrypt`) issues the Let's Encrypt
cert used for mail-protocol TLS.

Prerequisites: the Infisical operator + `universal-auth-credentials` machine
identity (from `infra-services`), nginx ingress, and cert-manager with the
`letsencrypt-prod` ClusterIssuer.

## State

MinIO s3 backend, key `platform/mail/terraform.tfstate`. Storage class read from
the root `init` state.

```sh
export AWS_ACCESS_KEY_ID="$(terraform -chdir=../../init output -raw minio_root_user)"
export AWS_SECRET_ACCESS_KEY="$(terraform -chdir=../../init output -raw minio_root_password)"
terraform init && terraform plan
```

> **Verify before deploy:** confirm `var.subnet` matches the cluster pod CIDR
> (`kubectl get nodes -o jsonpath='{.items[0].spec.podCIDR}'`) and that
> `var.server_ip` is the correct public IP for the `front-external` Service.
