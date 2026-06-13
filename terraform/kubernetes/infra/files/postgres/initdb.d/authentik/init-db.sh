#!/usr/bin/env bash
# authentik — database + login role
if [ -z "${_PG_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "authentik" "AUTHENTIK_DB_USER" "AUTHENTIK_DB_PASSWORD"
