#!/usr/bin/env bash
# postiz — database + login role
if [ -z "${_PG_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "postiz" "POSTIZ_DB_USER" "POSTIZ_DB_PASSWORD"
