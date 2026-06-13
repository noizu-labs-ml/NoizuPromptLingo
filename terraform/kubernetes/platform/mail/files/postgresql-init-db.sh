#!/bin/bash
set -e
echo "=== Initializing mailu databases ==="

# --- Helper functions ---
db_exists() { psql -U "$POSTGRES_USER" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$1'" | grep -q 1; }
role_exists() { psql -U "$POSTGRES_USER" -d postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$1'" | grep -q 1; }

# --- Mailu database ---
if ! db_exists mailu; then
    echo "Creating database: mailu"
    psql -U "$POSTGRES_USER" -d postgres -c "CREATE DATABASE mailu"
fi

if ! role_exists "$MAILU_DB_USER"; then
    echo "Creating role: $MAILU_DB_USER"
    psql -U "$POSTGRES_USER" -d postgres -c "CREATE ROLE $MAILU_DB_USER WITH LOGIN PASSWORD '$MAILU_DB_PASSWORD'"
fi

psql -U "$POSTGRES_USER" -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE mailu TO $MAILU_DB_USER"

psql -U "$POSTGRES_USER" -d mailu -c "
    GRANT ALL ON SCHEMA public TO $MAILU_DB_USER;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $MAILU_DB_USER;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $MAILU_DB_USER;
"

# --- Roundcube database ---
if [ -n "${ROUNDCUBE_DB_USER:-}" ]; then
    if ! db_exists roundcube; then
        echo "Creating database: roundcube"
        psql -U "$POSTGRES_USER" -d postgres -c "CREATE DATABASE roundcube"
    fi

    if ! role_exists "$ROUNDCUBE_DB_USER"; then
        echo "Creating role: $ROUNDCUBE_DB_USER"
        psql -U "$POSTGRES_USER" -d postgres -c "CREATE ROLE $ROUNDCUBE_DB_USER WITH LOGIN PASSWORD '$ROUNDCUBE_DB_PASSWORD'"
    fi

    psql -U "$POSTGRES_USER" -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE roundcube TO $ROUNDCUBE_DB_USER"

    psql -U "$POSTGRES_USER" -d roundcube -c "
        GRANT ALL ON SCHEMA public TO $ROUNDCUBE_DB_USER;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $ROUNDCUBE_DB_USER;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $ROUNDCUBE_DB_USER;
    "
fi

echo "=== Database initialization complete ==="
