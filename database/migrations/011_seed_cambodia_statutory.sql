-- ============================================================================
-- Migration: 011_seed_cambodia_statutory.sql
-- KerjaFlow ASEAN Statutory Framework
-- Purpose: Seed Cambodia statutory rates (NSSF)
-- Author: Claude Code
-- Date: 2025-12-27
-- Sources: NSSF Cambodia
-- Verified: 2025-12-27
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. STATUTORY AUTHORITIES
-- ============================================================================

INSERT INTO kf_statutory_authority (country_id, code, name_en, name_local, acronym, website_url) VALUES
((SELECT id FROM kf_country WHERE code='KH'), 'NSSF', 'National Social Security Fund', 'មូលនិធិជាតិរបបសន្តិសុខសង្គម', 'NSSF', 'https://www.nssf.gov.kh')
ON CONFLICT (country_id, code) DO NOTHING;

-- ============================================================================
-- 2. NSSF EMPLOYMENT INJURY (Occupational Risk)
-- ============================================================================

INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en, name_local,
    scheme_type, calculation_method, calculation_base,
    employee_contribution, employer_contribution,
    foreign_worker_applicable, effective_from, legal_reference
) VALUES
((SELECT id FROM kf_country WHERE code='KH'),
 (SELECT id FROM kf_statutory_authority WHERE code='NSSF'),
 'NSSF_ORC', 'NSSF Occupational Risk', 'បេឡាជាតិ អ៊ាស្សូរ៉ង់',
 'SOCIAL_SECURITY', 'PERCENTAGE', 'GROSS',
 false, true,
 true, '2008-11-01', 'Law on Social Security Schemes')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    employee_rate, employer_rate,
    effective_from, source_reference, verified_date
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='NSSF_ORC'),
 'ORC_STANDARD', 'All employers',
 0.00000000, 0.00800000,
 '2025-01-01', 'NSSF Cambodia', '2025-12-27')
ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

-- ============================================================================
-- 3. NSSF HEALTH CARE
-- ============================================================================

INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en,
    scheme_type, calculation_method, calculation_base,
    employee_contribution, employer_contribution,
    foreign_worker_applicable, effective_from, legal_reference
) VALUES
((SELECT id FROM kf_country WHERE code='KH'),
 (SELECT id FROM kf_statutory_authority WHERE code='NSSF'),
 'NSSF_HEALTH', 'NSSF Health Care',
 'HEALTH', 'PERCENTAGE', 'GROSS',
 false, true,
 true, '2018-01-01', 'Law on Social Security Schemes')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    employee_rate, employer_rate,
    effective_from, source_reference, verified_date, notes
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='NSSF_HEALTH'),
 'HEALTH_STANDARD', 'All employers (100% employer-funded since 2018)',
 0.00000000, 0.02600000,
 '2025-01-01', 'NSSF Cambodia', '2025-12-27', 'Previously 1.3% each before Jan 2018')
ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

-- ============================================================================
-- 4. NSSF PENSION (Effective October 2022) - PHASED INCREASES
-- ============================================================================

INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en,
    scheme_type, calculation_method, calculation_base,
    foreign_worker_applicable, effective_from, legal_reference
) VALUES
((SELECT id FROM kf_country WHERE code='KH'),
 (SELECT id FROM kf_statutory_authority WHERE code='NSSF'),
 'NSSF_PENSION', 'NSSF Pension',
 'RETIREMENT', 'PERCENTAGE', 'GROSS',
 true, '2022-10-01', 'Law on Social Security Schemes')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

-- CRITICAL: Pension rates increase every 5 years
INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    employee_rate, employer_rate, total_rate,
    effective_from, effective_until,
    source_reference, verified_date, notes
) VALUES

-- Phase 1: Years 1-5 (Oct 2022 - Sep 2027)
((SELECT id FROM kf_statutory_scheme WHERE code='NSSF_PENSION'),
 'PENSION_PHASE1', 'Years 1-5 (2022-2027)',
 0.02000000, 0.02000000, 0.04000000,
 '2022-10-01', '2027-09-30',
 'NSSF Cambodia', '2025-12-27', 'Phase 1: 4% total'),

-- Phase 2: Years 6-10 (Oct 2027 - Sep 2032)
((SELECT id FROM kf_statutory_scheme WHERE code='NSSF_PENSION'),
 'PENSION_PHASE2', 'Years 6-10 (2027-2032)',
 0.03000000, 0.03000000, 0.06000000,
 '2027-10-01', '2032-09-30',
 'NSSF Cambodia', '2025-12-27', 'Phase 2: 6% total'),

-- Phase 3: Years 11+ (Oct 2032 onwards - FINAL)
((SELECT id FROM kf_statutory_scheme WHERE code='NSSF_PENSION'),
 'PENSION_PHASE3', 'Years 11+ (2032 onwards)',
 0.04000000, 0.04000000, 0.08000000,
 '2032-10-01', NULL,
 'NSSF Cambodia', '2025-12-27', 'Phase 3: 8% total (final)')

ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

-- ============================================================================
-- 5. NSSF WAGE CEILINGS (Applied to all schemes)
-- ============================================================================

INSERT INTO kf_statutory_ceiling (
    scheme_id, ceiling_type, ceiling_amount, min_amount,
    effective_from, source_reference
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='NSSF_ORC'),
 'MONTHLY', 1200000.00, 200000.00,
 '2025-01-01', 'NSSF Wage Range KHR'),

((SELECT id FROM kf_statutory_scheme WHERE code='NSSF_HEALTH'),
 'MONTHLY', 1200000.00, 200000.00,
 '2025-01-01', 'NSSF Wage Range KHR'),

((SELECT id FROM kf_statutory_scheme WHERE code='NSSF_PENSION'),
 'MONTHLY', 1200000.00, 200000.00,
 '2025-01-01', 'NSSF Wage Range KHR')

ON CONFLICT (scheme_id, ceiling_type, effective_from) DO NOTHING;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- SELECT s.code, s.name_en, r.tier_code, r.total_rate, r.effective_from, r.effective_until
-- FROM kf_statutory_scheme s
-- JOIN kf_statutory_rate r ON s.id = r.scheme_id
-- WHERE s.country_id = (SELECT id FROM kf_country WHERE code='KH')
--   AND s.code = 'NSSF_PENSION'
-- ORDER BY r.effective_from;
--
-- Expected: 3 pension rate phases (4%, 6%, 8%)
