#!/usr/bin/env bash
# growthbook — database + readWrite user
if [ -z "${_MONGO_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "growthbook" "GROWTHBOOK_DB_USER" "GROWTHBOOK_DB_PASSWORD"
