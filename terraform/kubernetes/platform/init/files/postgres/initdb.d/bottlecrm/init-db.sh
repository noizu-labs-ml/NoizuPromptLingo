#!/usr/bin/env bash
# bottlecrm — database + login role
if [ -z "${_PG_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "bottlecrm" "BOTTLECRM_DB_USER" "BOTTLECRM_DB_PASSWORD"
