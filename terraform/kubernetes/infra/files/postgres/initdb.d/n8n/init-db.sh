#!/usr/bin/env bash
# n8n — database + login role
if [ -z "${_PG_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "n8n" "N8N_DB_USER" "N8N_DB_PASSWORD"
