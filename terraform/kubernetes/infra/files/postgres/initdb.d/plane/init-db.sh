#!/usr/bin/env bash
# plane — database + login role
if [ -z "${_PG_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "plane" "PLANE_DB_USER" "PLANE_DB_PASSWORD"
