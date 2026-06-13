#!/usr/bin/env bash
# posthog — database + login role
if [ -z "${_PG_INITDB_LIB:-}" ]; then source "$(dirname "${BASH_SOURCE[0]}")/_lib"; fi

create_db "posthog" "POSTHOG_DB_USER" "POSTHOG_DB_PASSWORD"
