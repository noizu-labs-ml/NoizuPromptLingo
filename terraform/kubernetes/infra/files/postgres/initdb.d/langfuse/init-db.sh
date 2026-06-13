#!/usr/bin/env bash
# langfuse — database + login role
if [ -z "${_PG_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "langfuse" "LANGFUSE_DB_USER" "LANGFUSE_DB_PASSWORD"
