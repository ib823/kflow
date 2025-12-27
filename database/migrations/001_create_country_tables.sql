-- ============================================================================
-- Migration: 001_create_country_tables.sql
-- KerjaFlow ASEAN Statutory Framework
-- Purpose: Create master country and statutory authority tables
-- Author: Claude Code
-- Date: 2025-12-27
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. COUNTRY MASTER TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS kf_country (
    id SERIAL PRIMARY KEY,
    code VARCHAR(2) NOT NULL UNIQUE,
    name_en VARCHAR(100) NOT NULL,
    name_local VARCHAR(100),
    currency_code VARCHAR(3) NOT NULL,
    currency_symbol VARCHAR(10) NOT NULL,
    currency_decimal_places SMALLINT DEFAULT 2,
    currency_subunit_name VARCHAR(50),
    default_locale VARCHAR(10) NOT NULL,
    fiscal_year_start_month SMALLINT DEFAULT 1 CHECK (fiscal_year_start_month BETWEEN 1 AND 12),
    workweek_start_day SMALLINT DEFAULT 1 CHECK (workweek_start_day BETWEEN 0 AND 6),
    weekend_days SMALLINT[] DEFAULT '{6,0}',
    standard_work_hours_day DECIMAL(4,2) DEFAULT 8.00,
    standard_work_days_week SMALLINT DEFAULT 5,
    date_format VARCHAR(20) DEFAULT 'DD/MM/YYYY',
    timezone VARCHAR(50) NOT NULL,
    payment_deadline_default_day SMALLINT DEFAULT 15,
    data_residency_required BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_country_code ON kf_country(code);
CREATE INDEX IF NOT EXISTS idx_country_active ON kf_country(is_active);

COMMENT ON TABLE kf_country IS 'Master table for 9 ASEAN countries supported by KerjaFlow';
COMMENT ON COLUMN kf_country.code IS 'ISO 3166-1 alpha-2 country code';
COMMENT ON COLUMN kf_country.currency_decimal_places IS '0 for IDR/VND/KHR/MMK, 2 for others';
COMMENT ON COLUMN kf_country.data_residency_required IS 'True for ID and VN (mandatory local storage)';

-- ============================================================================
-- 2. STATUTORY AUTHORITY TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS kf_statutory_authority (
    id SERIAL PRIMARY KEY,
    country_id INTEGER NOT NULL REFERENCES kf_country(id) ON DELETE CASCADE,
    code VARCHAR(30) NOT NULL,
    name_en VARCHAR(200) NOT NULL,
    name_local VARCHAR(200),
    acronym VARCHAR(20),
    website_url VARCHAR(500),
    payment_portal_url VARCHAR(500),
    filing_portal_url VARCHAR(500),
    contact_email VARCHAR(200),
    contact_phone VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (country_id, code)
);

CREATE INDEX IF NOT EXISTS idx_authority_country ON kf_statutory_authority(country_id);
CREATE INDEX IF NOT EXISTS idx_authority_code ON kf_statutory_authority(code);

COMMENT ON TABLE kf_statutory_authority IS 'Government agencies administering statutory contributions (EPF, KWSP, CPF, BPJS, etc.)';

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- SELECT table_name, column_name, data_type
-- FROM information_schema.columns
-- WHERE table_name IN ('kf_country', 'kf_statutory_authority')
-- ORDER BY table_name, ordinal_position;
