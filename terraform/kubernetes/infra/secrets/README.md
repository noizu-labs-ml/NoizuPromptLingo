# Sealed secrets

This directory holds the encrypted `*.sealedsecret.yaml` files consumed by
`../secrets.tf`. They are safe to commit — only the in-cluster sealed-secrets
controller can decrypt them.

These sealed files are the **source of truth** for the infra credentials —
Terraform only applies them, so an apply can never regenerate the values.

Expected files, one SealedSecret each:

| File | Keys | Used by | Sealed via |
|---|---|---|---|
| `postgres-secrets.sealedsecret.yaml` | `POSTGRES_PASSWORD`, `<APP>_DB_USER/PASSWORD` | postgres | `../seal-managed-secrets.sh` |
| `clickhouse-secrets.sealedsecret.yaml` | `SIGNOZ_TOKENIZER_JWT_SECRET` | clickhouse | `../seal-managed-secrets.sh` |
| `registry-basic-auth.sealedsecret.yaml` | `auth` (htpasswd) | registry ingress | `../seal-managed-secrets.sh` |
| `ops-noizu-com-tls.sealedsecret.yaml` | `tls.crt`, `tls.key` | registry ingress | `../seal-secrets.sh` |

Generate/refresh (needs `kubeseal` + the controller running):

```bash
../seal-managed-secrets.sh   # generates DB/registry creds ONCE, seals the 3 above
../recover-ops-tls.sh        # cluster backup -> .secrets/tls/ops.noizu.com/{cert,key}.pem
../seal-secrets.sh           # those PEMs -> ops-noizu-com-tls.sealedsecret.yaml
```

Plaintext source values live in the central, gitignored store
`<repo>/.secrets/infra/` (DB/registry) and `<repo>/.secrets/tls/ops.noizu.com/`
(cert). Re-running the sealers reuses them, so values stay stable.

> The `*.noizu.com` wildcard (`cloudflare-tls-synced`) is owned by the
> `infra-services` module — its apps reference it. Don't seal it here.
