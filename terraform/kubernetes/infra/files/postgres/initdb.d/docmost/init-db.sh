#!/usr/bin/env bash
# docmost — database + login role
if [ -z "${_PG_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "docmost" "DOCMOST_DB_USER" "DOCMOST_DB_PASSWORD"
