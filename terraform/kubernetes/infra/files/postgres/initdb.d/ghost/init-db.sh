#!/usr/bin/env bash
# ghost — database + login role
if [ -z "${_PG_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "ghost" "GHOST_DB_USER" "GHOST_DB_PASSWORD"
