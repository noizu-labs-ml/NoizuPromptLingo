-- NPL PostgreSQL Initialization Script
-- Install required extensions

-- Enable pgvector for vector similarity search
CREATE EXTENSION IF NOT EXISTS vector;

-- Enable uuid-ossp for UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Verify extensions are installed
DO $$
BEGIN
    RAISE NOTICE 'Extensions installed successfully:';
    RAISE NOTICE '  - vector (pgvector)';
    RAISE NOTICE '  - uuid-ossp';
END $$;
