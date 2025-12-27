-- ============================================================================
-- Migration: 009_seed_philippines_statutory.sql
-- KerjaFlow ASEAN Statutory Framework
-- Purpose: Seed Philippines statutory rates (SSS, PhilHealth, Pag-IBIG)
-- Author: Claude Code
-- Date: 2025-12-27
-- Sources: SSS, PhilHealth, Pag-IBIG
-- Verified: 2025-12-27
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. STATUTORY AUTHORITIES
-- ============================================================================

INSERT INTO kf_statutory_authority (country_id, code, name_en, acronym, website_url) VALUES
((SELECT id FROM kf_country WHERE code='PH'), 'SSS', 'Social Security System', 'SSS', 'https://www.sss.gov.ph'),
((SELECT id FROM kf_country WHERE code='PH'), 'PHIC', 'Philippine Health Insurance Corporation', 'PhilHealth', 'https://www.philhealth.gov.ph'),
((SELECT id FROM kf_country WHERE code='PH'), 'HDMF', 'Home Development Mutual Fund', 'Pag-IBIG', 'https://www.pagibigfund.gov.ph')
ON CONFLICT (country_id, code) DO NOTHING;

-- ============================================================================
-- 2. SSS (Social Security System)
-- ============================================================================

INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en,
    scheme_type, calculation_method, calculation_base,
    citizen_applicable, pr_applicable, foreign_worker_applicable,
    effective_from, legal_reference
) VALUES
((SELECT id FROM kf_country WHERE code='PH'),
 (SELECT id FROM kf_statutory_authority WHERE code='SSS'),
 'SSS', 'Social Security System',
 'SOCIAL_SECURITY', 'PERCENTAGE', 'GROSS',
 true, true, false,
 '1957-09-01', 'Republic Act No. 11199')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

-- SSS Rates 2025 - VERIFIED (Final phase of RA 11199)
INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    employee_rate, employer_rate, total_rate,
    effective_from, source_reference, verified_date, notes
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='SSS'),
 'SSS_2025', 'SSS 2025 Rates (Final RA 11199)',
 0.05000000, 0.10000000, 0.15000000,
 '2025-01-01', 'SSS Circular 2024-06', '2025-12-27', 'Employer rate includes EC')
ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

-- SSS MSC (Monthly Salary Credit) Brackets 2025 - VERIFIED
INSERT INTO kf_statutory_ceiling (
    scheme_id, ceiling_type, ceiling_amount, min_amount,
    effective_from, source_reference, notes
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='SSS'),
 'MONTHLY', 35000.00, 5000.00,
 '2025-01-01', 'SSS Circular 2024-06', 'MSC range PHP 5,000 - PHP 35,000')
ON CONFLICT (scheme_id, ceiling_type, effective_from) DO NOTHING;

-- ============================================================================
-- 3. PhilHealth (Health Insurance)
-- ============================================================================

INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en,
    scheme_type, calculation_method, calculation_base,
    citizen_applicable, pr_applicable, foreign_worker_applicable,
    effective_from, legal_reference
) VALUES
((SELECT id FROM kf_country WHERE code='PH'),
 (SELECT id FROM kf_statutory_authority WHERE code='PHIC'),
 'PHIC', 'PhilHealth Premium',
 'HEALTH', 'PERCENTAGE', 'GROSS',
 true, true, false,
 '1995-02-14', 'Republic Act No. 11223')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    employee_rate, employer_rate, total_rate,
    effective_from, source_reference, verified_date
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='PHIC'),
 'PHIC_2025', 'PhilHealth 2025',
 0.02500000, 0.02500000, 0.05000000,
 '2025-01-01', 'PhilHealth Circular', '2025-12-27')
ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

INSERT INTO kf_statutory_ceiling (
    scheme_id, ceiling_type, ceiling_amount, min_amount,
    effective_from, source_reference
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='PHIC'),
 'MONTHLY', 100000.00, 10000.00,
 '2025-01-01', 'PhilHealth Income Floor/Ceiling')
ON CONFLICT (scheme_id, ceiling_type, effective_from) DO NOTHING;

-- ============================================================================
-- 4. Pag-IBIG (HDMF)
-- ============================================================================

INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en, name_local,
    scheme_type, calculation_method, calculation_base,
    citizen_applicable, pr_applicable, foreign_worker_applicable,
    effective_from, legal_reference
) VALUES
((SELECT id FROM kf_country WHERE code='PH'),
 (SELECT id FROM kf_statutory_authority WHERE code='HDMF'),
 'PAGIBIG', 'Pag-IBIG Fund', 'HDMF',
 'RETIREMENT', 'TIERED_PERCENTAGE', 'GROSS',
 true, true, false,
 '1978-06-11', 'Republic Act No. 9679')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

-- Pag-IBIG Tiered Rates
INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    max_salary,
    employee_rate, employer_rate,
    effective_from, source_reference, verified_date
) VALUES

-- Salary <= PHP 1,500
((SELECT id FROM kf_statutory_scheme WHERE code='PAGIBIG'),
 'PAGIBIG_LOW', 'Compensation ≤ PHP 1,500',
 1500.00,
 0.01000000, 0.02000000,
 '2025-01-01', 'Pag-IBIG Contribution Table', '2025-12-27'),

-- Salary > PHP 1,500
((SELECT id FROM kf_statutory_scheme WHERE code='PAGIBIG'),
 'PAGIBIG_STANDARD', 'Compensation > PHP 1,500',
 NULL,
 0.02000000, 0.02000000,
 '2025-01-01', 'Pag-IBIG Contribution Table', '2025-12-27')

ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

-- Pag-IBIG Ceiling
INSERT INTO kf_statutory_ceiling (
    scheme_id, ceiling_type, ceiling_amount,
    effective_from, source_reference
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='PAGIBIG'),
 'MONTHLY', 5000.00,
 '2025-01-01', 'Pag-IBIG Max Monthly Compensation')
ON CONFLICT (scheme_id, ceiling_type, effective_from) DO NOTHING;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- SELECT s.code, s.name_en, COUNT(r.id) as rate_count
-- FROM kf_statutory_scheme s
-- LEFT JOIN kf_statutory_rate r ON s.id = r.scheme_id
-- WHERE s.country_id = (SELECT id FROM kf_country WHERE code='PH')
-- GROUP BY s.id, s.code, s.name_en
-- ORDER BY s.code;
--
-- Expected:
-- SSS: 1 rate
-- PHIC: 1 rate
-- PAGIBIG: 2 rates (tiered)
