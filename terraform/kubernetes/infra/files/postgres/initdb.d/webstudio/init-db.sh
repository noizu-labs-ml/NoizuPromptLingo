#!/usr/bin/env bash
# webstudio — database + login role, plus PostgREST roles (anon/authenticated/service_role)
if [ -z "${_PG_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "webstudio" "WEBSTUDIO_DB_USER" "WEBSTUDIO_DB_PASSWORD"

if [ -n "${WEBSTUDIO_DB_USER:-}" ]; then
  for role in anon authenticated service_role; do
    if ! role_exists "$role"; then
      echo "Creating PostgREST role: $role"
      psql -U "$POSTGRES_USER" -d "webstudio" -c "CREATE ROLE $role NOLOGIN"
    fi
  done
  psql -U "$POSTGRES_USER" -d "webstudio" -c "
    GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO anon;
    GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated, service_role;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO authenticated, service_role;
  "
fi
