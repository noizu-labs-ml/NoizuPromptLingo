-- Create the migrate role on the primary database.
-- Run as the postgres superuser:
--
--   psql -h ${DB_HOST} -U postgres -d ${DB_NAME} -f utils/sql/create-migrate-user.sql
--
-- Replace placeholder variables before running:
--   ${DB_MIGRATE_USER}  — migration user (e.g. myapp_migrate)
--   ${DB_NAME}          — database name (e.g. myapp-prod-db)
--   ${DB_SCHEMA}        — application schema (e.g. dbmyapp_myapp)
--   ${DB_HOST}          — database host
--
-- The password must match the MIGRATE_DB_PASSWORD value in Infisical.
-- After running, set the password:
--
--   ALTER ROLE ${DB_MIGRATE_USER} WITH PASSWORD '<password-from-infisical>';

-- Create role if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${DB_MIGRATE_USER}') THEN
    CREATE ROLE ${DB_MIGRATE_USER} WITH LOGIN;
  END IF;
END
$$;

-- Grant connection
GRANT CONNECT ON DATABASE "${DB_NAME}" TO ${DB_MIGRATE_USER};

-- ${DB_SCHEMA} schema: where Django tables live (django_migrations, reviews, etc.)
CREATE SCHEMA IF NOT EXISTS ${DB_SCHEMA};
GRANT USAGE, CREATE ON SCHEMA ${DB_SCHEMA} TO ${DB_MIGRATE_USER};
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA ${DB_SCHEMA} TO ${DB_MIGRATE_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA ${DB_SCHEMA} GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO ${DB_MIGRATE_USER};
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA ${DB_SCHEMA} TO ${DB_MIGRATE_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA ${DB_SCHEMA} GRANT USAGE, SELECT ON SEQUENCES TO ${DB_MIGRATE_USER};

-- public schema: extensions and shared objects
GRANT USAGE, CREATE ON SCHEMA public TO ${DB_MIGRATE_USER};
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO ${DB_MIGRATE_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO ${DB_MIGRATE_USER};
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO ${DB_MIGRATE_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO ${DB_MIGRATE_USER};

-- DDL privileges: CREATE TABLE, CREATE INDEX, ALTER TABLE
GRANT CREATE ON DATABASE "${DB_NAME}" TO ${DB_MIGRATE_USER};

-- Inherit postgres role for table ownership (required for CREATE INDEX on existing tables)
GRANT postgres TO ${DB_MIGRATE_USER} WITH INHERIT TRUE;

-- Set default search_path so Django finds tables in ${DB_SCHEMA}
ALTER ROLE ${DB_MIGRATE_USER} SET search_path TO ${DB_SCHEMA}, public;
