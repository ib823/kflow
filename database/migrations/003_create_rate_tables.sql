-- ============================================================================
-- Migration: 003_create_rate_tables.sql
-- KerjaFlow ASEAN Statutory Framework
-- Purpose: Create rate, ceiling, lookup, and leave entitlement tables
-- Author: Claude Code
-- Date: 2025-12-27
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. STATUTORY RATE TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS kf_statutory_rate (
    id SERIAL PRIMARY KEY,
    scheme_id INTEGER NOT NULL REFERENCES kf_statutory_scheme(id) ON DELETE CASCADE,
    tier_code VARCHAR(50) NOT NULL,
    tier_description VARCHAR(300),

    -- Age conditions (NULL = no restriction)
    min_age SMALLINT,
    max_age SMALLINT,

    -- Salary conditions (NULL = no restriction)
    min_salary DECIMAL(15,2),
    max_salary DECIMAL(15,2),

    -- Worker type conditions
    nationality_condition VARCHAR(30) CHECK (nationality_condition IN ('CITIZEN', 'PR', 'FOREIGN', 'ALL')),
    pr_year_condition SMALLINT,

    -- Industry/risk conditions
    risk_category VARCHAR(30),
    employee_count_min INTEGER,
    employee_count_max INTEGER,

    -- Contribution rates (use NULL if not applicable)
    employee_rate DECIMAL(10,8),
    employer_rate DECIMAL(10,8),
    employee_fixed DECIMAL(15,2),
    employer_fixed DECIMAL(15,2),
    total_rate DECIMAL(10,8),

    -- Validity
    effective_from DATE NOT NULL,
    effective_until DATE,

    -- Audit trail
    source_reference TEXT,
    source_url VARCHAR(500),
    verified_date DATE,
    verified_by VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE (scheme_id, tier_code, effective_from)
);

CREATE INDEX IF NOT EXISTS idx_rate_scheme ON kf_statutory_rate(scheme_id);
CREATE INDEX IF NOT EXISTS idx_rate_effective ON kf_statutory_rate(effective_from, effective_until);
CREATE INDEX IF NOT EXISTS idx_rate_age ON kf_statutory_rate(min_age, max_age);
CREATE INDEX IF NOT EXISTS idx_rate_salary ON kf_statutory_rate(min_salary, max_salary);

COMMENT ON TABLE kf_statutory_rate IS 'Contribution rates with tier conditions and effective dates';
COMMENT ON COLUMN kf_statutory_rate.employee_rate IS 'Employee rate as decimal (e.g., 0.11 for 11%)';
COMMENT ON COLUMN kf_statutory_rate.verified_date IS 'Date when this rate was last verified against official source';

-- ============================================================================
-- 2. STATUTORY CEILING TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS kf_statutory_ceiling (
    id SERIAL PRIMARY KEY,
    scheme_id INTEGER NOT NULL REFERENCES kf_statutory_scheme(id) ON DELETE CASCADE,
    ceiling_type VARCHAR(30) NOT NULL CHECK (ceiling_type IN (
        'MONTHLY', 'ANNUAL', 'OW_MONTHLY', 'AW_ANNUAL', 'DAILY'
    )),
    ceiling_amount DECIMAL(15,2) NOT NULL,
    min_amount DECIMAL(15,2),
    effective_from DATE NOT NULL,
    effective_until DATE,
    source_reference TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (scheme_id, ceiling_type, effective_from)
);

CREATE INDEX IF NOT EXISTS idx_ceiling_scheme ON kf_statutory_ceiling(scheme_id);
CREATE INDEX IF NOT EXISTS idx_ceiling_effective ON kf_statutory_ceiling(effective_from, effective_until);

COMMENT ON TABLE kf_statutory_ceiling IS 'Wage ceilings for contribution calculations';
COMMENT ON COLUMN kf_statutory_ceiling.ceiling_type IS 'MONTHLY, ANNUAL, OW_MONTHLY (Ordinary Wages), AW_ANNUAL (Additional Wages), DAILY';

-- ============================================================================
-- 3. TABLE LOOKUP FOR SOCSO-STYLE CONTRIBUTIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS kf_statutory_table_lookup (
    id SERIAL PRIMARY KEY,
    scheme_id INTEGER NOT NULL REFERENCES kf_statutory_scheme(id) ON DELETE CASCADE,
    wage_from DECIMAL(15,2) NOT NULL,
    wage_to DECIMAL(15,2) NOT NULL,
    category VARCHAR(30),
    employee_amount DECIMAL(12,2) NOT NULL,
    employer_amount DECIMAL(12,2) NOT NULL,
    effective_from DATE NOT NULL,
    effective_until DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (scheme_id, wage_from, wage_to, category, effective_from),
    CHECK (wage_to >= wage_from)
);

CREATE INDEX IF NOT EXISTS idx_lookup_scheme ON kf_statutory_table_lookup(scheme_id);
CREATE INDEX IF NOT EXISTS idx_lookup_wage ON kf_statutory_table_lookup(wage_from, wage_to);

COMMENT ON TABLE kf_statutory_table_lookup IS 'SOCSO-style wage band contribution lookup tables (e.g., wage RM3,000-3,999.99 = RM19.75 employee)';

-- ============================================================================
-- 4. LEAVE ENTITLEMENT DEFAULTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS kf_country_leave_entitlement (
    id SERIAL PRIMARY KEY,
    country_id INTEGER NOT NULL REFERENCES kf_country(id) ON DELETE CASCADE,
    leave_type_code VARCHAR(30) NOT NULL,
    leave_type_name_en VARCHAR(100) NOT NULL,
    leave_type_name_local VARCHAR(100),
    service_years_from DECIMAL(4,1) DEFAULT 0,
    service_years_to DECIMAL(4,1),
    days_entitled DECIMAL(5,2) NOT NULL,
    is_paid BOOLEAN DEFAULT true,
    is_calendar_days BOOLEAN DEFAULT false,
    gender_restriction VARCHAR(10) CHECK (gender_restriction IN ('M', 'F')),
    max_confinements SMALLINT,
    legal_reference TEXT,
    notes TEXT,
    effective_from DATE NOT NULL,
    effective_until DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (country_id, leave_type_code, service_years_from, effective_from)
);

CREATE INDEX IF NOT EXISTS idx_leave_country ON kf_country_leave_entitlement(country_id);
CREATE INDEX IF NOT EXISTS idx_leave_type ON kf_country_leave_entitlement(leave_type_code);

COMMENT ON TABLE kf_country_leave_entitlement IS 'Statutory leave entitlements by country and service years';
COMMENT ON COLUMN kf_country_leave_entitlement.is_calendar_days IS 'True for calendar days, False for working days';

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- SELECT COUNT(*) FROM kf_statutory_rate;
-- SELECT COUNT(*) FROM kf_statutory_ceiling;
-- SELECT COUNT(*) FROM kf_country_leave_entitlement;
