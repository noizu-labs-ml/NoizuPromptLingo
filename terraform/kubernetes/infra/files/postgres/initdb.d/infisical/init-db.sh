#!/usr/bin/env bash
# infisical — database + login role, with uuid-ossp / pgcrypto extensions
if [ -z "${_PG_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "infisical" "INFISICAL_DB_USER" "INFISICAL_DB_PASSWORD"
if [ -n "${INFISICAL_DB_USER:-}" ]; then create_extensions "infisical" "uuid-ossp" "pgcrypto"; fi
