#!/usr/bin/env bash
# Shared helpers for the per-app initdb.d scripts.
#
# At runtime this is placed in /docker-entrypoint-initdb.d/ as "_lib" (no .sh
# extension) so the base image's initdb runner skips it; each per-app
# 1NN-<app>.sh sources it from the same directory. The _PG_INITDB_LIB guard
# keeps it idempotent if sourced more than once.
set -e
export _PG_INITDB_LIB=1

: "${POSTGRES_USER:=postgres}"

db_exists()   { psql -U "$POSTGRES_USER" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$1'" | grep -q 1; }
role_exists() { psql -U "$POSTGRES_USER" -d postgres -tAc "SELECT 1 FROM pg_roles    WHERE rolname='$1'" | grep -q 1; }

# create_db <db_name> <user_env_var> <pass_env_var>
# Idempotent. No-op when the user env var is empty (app not provisioned here).
create_db() {
  local db_name="$1" user_var="$2" pass_var="$3"
  local db_user="${!user_var}" db_pass="${!pass_var}"

  if [ -z "$db_user" ]; then return 0; fi

  if ! db_exists "$db_name"; then
    echo "Creating database: $db_name"
    psql -U "$POSTGRES_USER" -d postgres -c "CREATE DATABASE $db_name"
  fi

  if ! role_exists "$db_user"; then
    echo "Creating role: $db_user"
    psql -U "$POSTGRES_USER" -d postgres -c "CREATE ROLE $db_user WITH LOGIN PASSWORD '$db_pass'"
  else
    psql -U "$POSTGRES_USER" -d postgres -c "ALTER ROLE $db_user WITH PASSWORD '$db_pass'"
  fi

  psql -U "$POSTGRES_USER" -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE $db_name TO $db_user"
  psql -U "$POSTGRES_USER" -d "$db_name" -c "
    GRANT ALL ON SCHEMA public TO $db_user;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $db_user;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $db_user;
  "
}

# create_extensions <db_name> <ext...>
create_extensions() {
  local db_name="$1"; shift
  local ext
  for ext in "$@"; do
    psql -U "$POSTGRES_USER" -d "$db_name" -c "CREATE EXTENSION IF NOT EXISTS \"$ext\";"
  done
}
