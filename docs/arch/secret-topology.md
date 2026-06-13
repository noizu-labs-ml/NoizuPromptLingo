# Secret Topology

## Infisical Folder Structure

18 folders organized by service, each mapping to a K8s secret consumed by that service's pods:

| Folder | Service | Key Secrets |
|--------|---------|-------------|
| `/mysqldb` | MySQL | Root password, per-app DB passwords, monitoring password |
| `/wordpress` | WordPress (EKS MySQL) | DB password, 8 auth keys/salts, EC2 transitional secrets |
| `/wordpress-cms` | WordPress CMS | DB password, 8 auth keys/salts |
| `/manticore` | Manticore Search | PgSQL connection params (host, port, user, db, pass) |
| `/redis` | Redis (app namespace) | Per-ACL-user passwords (backend, frontend, wordpress, monitoring) |
| `/valkey` | Valkey (Redis replacement) | Subset of Redis passwords for migrated services |
| `/timescaledb` | TimescaleDB | Postgres superuser, replication, per-app user passwords |
| `/pgbouncer` | PgBouncer | EC2 credentials (temp patch), auth_user password |
| `/proxysql` | ProxySQL | Admin password, backend DB password |
| `/backend` | Django backend | Secret key, DB passwords (primary + replica), SendGrid, PayPal, GraphicMail |
| `/frontend` | Frontend app | DB password |
| `/api` | Legacy PHP API | MySQL password |
| `/admin` | Admin tools | EC2 SSH key (base64-encoded) |
| `/donation` | Donation service | Stripe secret key, SendGrid API key |
| `/fblogin` | Facebook OAuth | App ID, app secret, graph version, encryption key |
| `/infra-directus` | Directus CMS | App secret, DB password, admin credentials, Redis password |
| `/infra-posthog` | PostHog | Secret key, DB password, Redis password |
| `/infra-valkey` | Valkey (infra namespace) | Per-service passwords (Infisical, Directus, PostHog) |

## Cross-Folder Secret Sharing

Several secrets are written to multiple folders under different key names:

```
APP_WORDPRESS_DB_PASSWORD
  -> /mysqldb/APP_WORDPRESS_DB_PASSWORD
  -> /wordpress/DB_PASSWORD

APP_BACKEND_DB_PASSWORD
  -> /timescaledb/APP_BACKEND_DB_PASSWORD
  -> /backend/DB_PASSWORD
  -> /proxysql/PGSQL_USER_APP_BACKEND_PASSWORD

APP_FRONTEND_DB_PASSWORD
  -> /timescaledb/APP_FRONTEND_DB_PASSWORD
  -> /frontend/DB_PASSWORD

DIRECTUS_REDIS_PASSWORD
  -> /infra-directus/DIRECTUS_REDIS_PASSWORD
  -> /infra-valkey/DIRECTUS_PASSWORD

POSTHOG_REDIS_PASSWORD
  -> /infra-posthog/POSTHOG_REDIS_PASSWORD
  -> /infra-valkey/POSTHOG_PASSWORD
```

## Generation vs. Override

Every secret follows a consistent pattern:

```bash
VAR=${VAR:-$(generate_password VAR)}
```

- If the env var is set: uses the provided value (migration, manual override)
- If unset: auto-generates via `openssl rand` or `python3 secrets`
- Some secrets have no generator and are skipped with a warning if unset (e.g., `SENDGRID_API_KEY`, `EC2_USER_RSA_KEY`)
