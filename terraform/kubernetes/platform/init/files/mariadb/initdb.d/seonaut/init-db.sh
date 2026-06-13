#!/usr/bin/env bash
# seonaut — database + login user
if [ -z "${_MARIADB_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "seonaut" "SEONAUT_DB_USER" "SEONAUT_DB_PASSWORD"
