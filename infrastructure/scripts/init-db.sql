-- KerjaFlow Database Initialization Script
-- This script runs when the PostgreSQL container is first created

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE kerjaflow TO odoo;

-- Log initialization
DO $$
BEGIN
    RAISE NOTICE 'KerjaFlow database initialized successfully at %', NOW();
END $$;
