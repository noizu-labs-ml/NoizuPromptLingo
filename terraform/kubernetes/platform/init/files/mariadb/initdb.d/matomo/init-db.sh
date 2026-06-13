#!/usr/bin/env bash
# matomo — database + login user
if [ -z "${_MARIADB_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "matomo" "MATOMO_DB_USER" "MATOMO_DB_PASSWORD"
