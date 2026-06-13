#!/usr/bin/env bash
# nextcloud — database + login role
if [ -z "${_PG_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "nextcloud" "NEXTCLOUD_DB_USER" "NEXTCLOUD_DB_PASSWORD"
