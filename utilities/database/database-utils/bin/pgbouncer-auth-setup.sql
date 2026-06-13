-- =============================================================================
-- pgbouncer user setup
-- Run on the PRIMARY only — replicates to standby via WAL streaming.
--
-- Replace placeholder variables before running:
--   ${DB_PGBOUNCER_USER}  — pgbouncer auth user (e.g. myapp_pgbouncer)
--   ${DB_READONLY_USER}   — read-only application user (e.g. myapp_backend_read)
--   ${DB_NAME}            — database name (e.g. myapp-prod-db)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. ${DB_PGBOUNCER_USER} — auth_user for both pgbouncers
--    No superuser. Can only execute get_auth() to look up credentials.
-- -----------------------------------------------------------------------------
CREATE USER ${DB_PGBOUNCER_USER} WITH
    LOGIN
    NOINHERIT
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    PASSWORD 'REPLACE_WITH_PGBOUNCER_PASSWORD';

-- Schema + SECURITY DEFINER function so ${DB_PGBOUNCER_USER} can read pg_shadow
-- without superuser privileges.
CREATE SCHEMA IF NOT EXISTS pgbouncer AUTHORIZATION postgres;

CREATE OR REPLACE FUNCTION pgbouncer.get_auth(p_usename TEXT)
RETURNS TABLE(usename TEXT, passwd TEXT)
LANGUAGE sql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
    SELECT usename::TEXT, passwd::TEXT
    FROM pg_catalog.pg_shadow
    WHERE usename = p_usename;
$$;

REVOKE ALL ON FUNCTION pgbouncer.get_auth(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION pgbouncer.get_auth(TEXT) TO ${DB_PGBOUNCER_USER};

-- -----------------------------------------------------------------------------
-- 2. ${DB_READONLY_USER} — read-only application user for the readonly pgbouncer
--    SELECT only. Cannot write even if the router is bypassed.
-- -----------------------------------------------------------------------------
CREATE USER ${DB_READONLY_USER} WITH
    LOGIN
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    PASSWORD 'REPLACE_WITH_READONLY_PASSWORD';

-- Grant connect + usage on the application database
GRANT CONNECT ON DATABASE "${DB_NAME}" TO ${DB_READONLY_USER};
GRANT USAGE ON SCHEMA public TO ${DB_READONLY_USER};

-- SELECT on all existing tables and sequences
GRANT SELECT ON ALL TABLES IN SCHEMA public TO ${DB_READONLY_USER};
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO ${DB_READONLY_USER};

-- SELECT on future tables/sequences (for migrations)
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO ${DB_READONLY_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON SEQUENCES TO ${DB_READONLY_USER};

-- Verify:
-- \du ${DB_PGBOUNCER_USER}
-- \du ${DB_READONLY_USER}
-- SELECT pgbouncer.get_auth('myapp_backend');
-- SELECT pgbouncer.get_auth('${DB_READONLY_USER}');
