-- ============================================================================
-- Migration: 002_create_statutory_tables.sql
-- KerjaFlow ASEAN Statutory Framework
-- Purpose: Create statutory scheme table with enums and metadata
-- Author: Claude Code
-- Date: 2025-12-27
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. CREATE ENUMS
-- ============================================================================

CREATE TYPE scheme_type AS ENUM (
    'RETIREMENT',
    'SOCIAL_SECURITY',
    'HEALTH',
    'UNEMPLOYMENT',
    'TAX',
    'LEVY',
    'TRADE_UNION'
);

CREATE TYPE calculation_method AS ENUM (
    'PERCENTAGE',
    'TIERED_PERCENTAGE',
    'TABLE_LOOKUP',
    'FORMULA',
    'FIXED_AMOUNT'
);

CREATE TYPE calculation_base AS ENUM (
    'GROSS',
    'BASIC',
    'BASIC_FIXED_ALLOWANCES',
    'ORDINARY_WAGES',
    'ADDITIONAL_WAGES',
    'TOTAL_WAGES',
    'NET_SALARY'
);

COMMENT ON TYPE scheme_type IS 'Type of statutory contribution program';
COMMENT ON TYPE calculation_method IS 'How contribution amount is calculated';
COMMENT ON TYPE calculation_base IS 'Which wage component to use as calculation base';

-- ============================================================================
-- 2. STATUTORY SCHEME TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS kf_statutory_scheme (
    id SERIAL PRIMARY KEY,
    country_id INTEGER NOT NULL REFERENCES kf_country(id) ON DELETE CASCADE,
    authority_id INTEGER REFERENCES kf_statutory_authority(id),
    code VARCHAR(30) NOT NULL,
    name_en VARCHAR(200) NOT NULL,
    name_local VARCHAR(200),
    description TEXT,
    scheme_type scheme_type NOT NULL,
    calculation_method calculation_method NOT NULL,
    calculation_base calculation_base NOT NULL,

    -- Contribution parties
    employee_contribution BOOLEAN DEFAULT true,
    employer_contribution BOOLEAN DEFAULT true,

    -- Applicability by nationality
    citizen_applicable BOOLEAN DEFAULT true,
    pr_applicable BOOLEAN DEFAULT true,
    foreign_worker_applicable BOOLEAN DEFAULT false,

    -- Administrative details
    payment_deadline_day SMALLINT DEFAULT 15,
    member_number_required BOOLEAN DEFAULT true,
    member_number_label VARCHAR(50),
    member_number_format VARCHAR(100),

    -- Calculation settings
    rounding_method VARCHAR(20) DEFAULT 'NEAREST',
    rounding_precision SMALLINT DEFAULT 2,

    -- Metadata
    sort_order SMALLINT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    effective_from DATE NOT NULL,
    effective_until DATE,
    legal_reference TEXT,
    notes TEXT,

    -- Audit
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE (country_id, code, effective_from)
);

CREATE INDEX IF NOT EXISTS idx_scheme_country ON kf_statutory_scheme(country_id);
CREATE INDEX IF NOT EXISTS idx_scheme_active ON kf_statutory_scheme(is_active, effective_from, effective_until);
CREATE INDEX IF NOT EXISTS idx_scheme_type ON kf_statutory_scheme(scheme_type);
CREATE INDEX IF NOT EXISTS idx_scheme_code ON kf_statutory_scheme(code);

COMMENT ON TABLE kf_statutory_scheme IS 'Definition of statutory contribution programs by country (EPF, CPF, SOCSO, etc.)';
COMMENT ON COLUMN kf_statutory_scheme.code IS 'Unique scheme code within country (e.g., EPF, SOCSO, CPF)';
COMMENT ON COLUMN kf_statutory_scheme.rounding_method IS 'NEAREST, NEAREST_RINGGIT, FLOOR, CEILING';

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- SELECT enumlabel FROM pg_enum WHERE enumtypid = 'scheme_type'::regtype;
-- SELECT enumlabel FROM pg_enum WHERE enumtypid = 'calculation_method'::regtype;
-- SELECT enumlabel FROM pg_enum WHERE enumtypid = 'calculation_base'::regtype;
