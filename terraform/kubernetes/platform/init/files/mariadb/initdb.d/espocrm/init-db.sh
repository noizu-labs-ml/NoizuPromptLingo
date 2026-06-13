#!/usr/bin/env bash
# espocrm — database + login user
if [ -z "${_MARIADB_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "espocrm" "ESPOCRM_DB_USER" "ESPOCRM_DB_PASSWORD"
