#!/usr/bin/env bash
# ghost — database + login user (Ghost requires MySQL/MariaDB)
if [ -z "${_MARIADB_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "ghost" "GHOST_DB_USER" "GHOST_DB_PASSWORD"
