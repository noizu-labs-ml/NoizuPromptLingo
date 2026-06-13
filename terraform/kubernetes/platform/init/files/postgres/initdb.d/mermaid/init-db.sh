#!/usr/bin/env bash
# mermaid — database + login role
if [ -z "${_PG_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "mermaid" "MERMAID_DB_USER" "MERMAID_DB_PASSWORD"
