#!/usr/bin/env bash
# mautic — database + login user
if [ -z "${_MARIADB_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "mautic" "MAUTIC_DB_USER" "MAUTIC_DB_PASSWORD"
