#!/usr/bin/env bash
# taiga — database + login role
if [ -z "${_PG_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "taiga" "TAIGA_DB_USER" "TAIGA_DB_PASSWORD"
