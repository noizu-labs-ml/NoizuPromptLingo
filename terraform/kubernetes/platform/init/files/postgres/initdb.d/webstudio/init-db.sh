#!/usr/bin/env bash
# webstudio — database + login role
if [ -z "${_PG_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "webstudio" "WEBSTUDIO_DB_USER" "WEBSTUDIO_DB_PASSWORD"
