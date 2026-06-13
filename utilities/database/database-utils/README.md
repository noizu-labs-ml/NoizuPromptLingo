# database-tools — Database Utilities

TimescaleDB snapshot, Liquibase migration, and database administration tools.

## Installation

```bash
make install    # Installs liquibase-shell, liquibase-update, tsdb-snapshot
```

## Prerequisites

- `kubectl` with cluster access
- `liquibase` for `liquibase-shell`
- `yq` for config parsing
- `nc` for port-forward readiness checks
- `psql` or `mysql` for direct database operations inside `--shell` mode (optional)

## Configuration

`liquibase-shell` reads `liquibase_targets` from the resolved `infra-config.yaml`
or `.infra-config.yaml`. Set `LIQUIBASE_CONFIG=/path/to/config.yaml` to override
the default search.

Targets define the Kubernetes service to port-forward, the secret keys to read,
and optionally the Liquibase changelog path. Instance-level targets may omit a
changelog and are treated as connection shells unless a `--changelog-file`
argument is supplied. Example:

```yaml
liquibase_targets:
  start-app:
    namespace: data-ns
    service: svc/shared-postgres
    remote_port: 5432
    local_port: 54320
    db_type: postgresql
    db_name: startapp
    schema: public
    secret_name: data-postgres-secrets
    username_key: STARTAPP_DB_USER
    username_key_fallbacks:
      - START_APP_DB_USER
    secret_key: STARTAPP_DB_PASSWORD
    secret_key_fallbacks:
      - START_APP_DB_PASSWORD
    safety: destructive
    changelog_dir: incubator/start-app/backend/db
    changelog_file: changelog/db.changelog-master.yaml
```

## Tools

| Command | Purpose |
|---------|---------|
| `liquibase-shell` | Open an interactive Liquibase shell through a Kubernetes port-forward |
| `liquibase-update` | Run the legacy one-shot Liquibase update Job |
| `tsdb-snapshot` | Create and manage TimescaleDB snapshots |

## Liquibase Shell

```bash
liquibase-shell                 # prompt for a target
liquibase-shell start-app       # interactive Liquibase menu
liquibase-shell start-app -- status
liquibase-shell start-app -- update-sql
liquibase-shell start-app --shell
liquibase-shell shared-postgres --shell
liquibase-shell shared-postgres -- --changelog-file=/path/to/changelog.yaml status
```

`--shell` exports `LB_DEFAULTS_FILE`, `PGHOST`, `PGPORT`, `PGDATABASE`,
`PGUSER`, and `PGPASSWORD` for PostgreSQL targets while keeping the
port-forward alive. It also exports `LB_CHANGELOG_PATH` and
`LB_CHANGELOG_DIR`; these are empty for connection-only instance targets.

## SQL Templates

| File | Purpose |
|------|---------|
| `bin/pgbouncer-auth-setup.sql` | Configure PgBouncer authentication |
| `bin/sql/create-migrate-user.sql` | Create migration database user |

Copy these to your project and adjust credentials/database names before use.
