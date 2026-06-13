# `platform-timescaledb` initdb.d — per-app DB provisioning

Same mechanism as `infra/files/postgres/initdb.d` (see `modules/timescaledb`).
Each per-app database + login role is provisioned by a tiny idempotent script,
bin-placed into the container's `/docker-entrypoint-initdb.d/` via subPath so the
image's baked first-boot scripts are preserved.

## Adding an app

1. Create `initdb.d/<app>/init-db.sh`:

   ```sh
   #!/usr/bin/env bash
   # <app> — database + login role
   if [ -z "${_PG_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

   create_db "<app>" "<APP>_DB_USER" "<APP>_DB_PASSWORD"
   ```

   The folder name (`<app>`) is the single source of truth: it drives both the
   script set and the `<APP>_DB_USER` / `<APP>_DB_PASSWORD` env keys (uppercased).

2. Add `<APP>_DB_USER` and `<APP>_DB_PASSWORD` to the Infisical `/platform/postgres`
   path (env `prod`, project `k8-infra`). The operator syncs them into the
   `platform-timescaledb-secrets` managed Secret, which the module mounts as env.

3. `terragrunt apply` (creates fresh) or `./refresh-db.sh postgres` (idempotent
   re-run against the live pod — initdb.d only runs on an empty PGDATA).

`_lib.sh` holds the shared `create_db` / `create_extensions` helpers; it is keyed
`_lib` (no `.sh`) in the ConfigMap so the base image's initdb runner ignores it.
