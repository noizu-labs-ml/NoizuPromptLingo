#!/usr/bin/env bash
# penpot — database + login role, with uuid-ossp / pgcrypto extensions
if [ -z "${_PG_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "penpot" "PENPOT_DB_USER" "PENPOT_DB_PASSWORD"
if [ -n "${PENPOT_DB_USER:-}" ]; then create_extensions "penpot" "uuid-ossp" "pgcrypto"; fi
