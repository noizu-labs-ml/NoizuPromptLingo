#!/usr/bin/env bash
# listmonk — database + login role
if [ -z "${_PG_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "listmonk" "LISTMONK_DB_USER" "LISTMONK_DB_PASSWORD"
