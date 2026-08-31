-- =============================================================================
-- TimescaleDB Initialization Script
-- =============================================================================
-- Creates required databases and extensions for Phoenix
-- =============================================================================

-- Create Phoenix database
-- CREATE DATABASE phoenixi;

-- Connect and enable extensions
\c phoenix
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
