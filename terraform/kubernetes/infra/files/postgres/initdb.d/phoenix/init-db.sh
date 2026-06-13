#!/usr/bin/env bash
# phoenix — database + login role
if [ -z "${_PG_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "phoenix" "PHOENIX_DB_USER" "PHOENIX_DB_PASSWORD"
