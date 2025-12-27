-- ============================================================================
-- Migration: 005_seed_malaysia_statutory.sql
-- KerjaFlow ASEAN Statutory Framework
-- Purpose: Seed Malaysia statutory rates (EPF, SOCSO, EIS, HRDF)
-- Author: Claude Code
-- Date: 2025-12-27
-- Sources: KWSP, PERKESO, EIS
-- Verified: 2025-12-27
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. STATUTORY AUTHORITIES
-- ============================================================================

INSERT INTO kf_statutory_authority (country_id, code, name_en, name_local, acronym, website_url) VALUES
((SELECT id FROM kf_country WHERE code='MY'), 'KWSP', 'Employees Provident Fund', 'Kumpulan Wang Simpanan Pekerja', 'EPF', 'https://www.kwsp.gov.my'),
((SELECT id FROM kf_country WHERE code='MY'), 'PERKESO', 'Social Security Organisation', 'Pertubuhan Keselamatan Sosial', 'SOCSO', 'https://www.perkeso.gov.my'),
((SELECT id FROM kf_country WHERE code='MY'), 'EIS', 'Employment Insurance System', 'Sistem Insurans Pekerjaan', 'EIS', 'https://www.perkeso.gov.my/eis'),
((SELECT id FROM kf_country WHERE code='MY'), 'HRDF', 'Human Resource Development Fund', 'Tabung Pembangunan Sumber Manusia', 'HRDF', 'https://www.hrdcorp.gov.my')
ON CONFLICT (country_id, code) DO NOTHING;

-- ============================================================================
-- 2. EPF (Employees Provident Fund)
-- ============================================================================

-- EPF Scheme
INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en, name_local,
    scheme_type, calculation_method, calculation_base,
    foreign_worker_applicable, effective_from, legal_reference
) VALUES
((SELECT id FROM kf_country WHERE code='MY'),
 (SELECT id FROM kf_statutory_authority WHERE code='KWSP'),
 'EPF', 'Employees Provident Fund', 'Kumpulan Wang Simpanan Pekerja',
 'RETIREMENT', 'TIERED_PERCENTAGE', 'GROSS',
 false, '2025-01-01', 'EPF Act 1991, Third Schedule')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

-- EPF Rates - Malaysian Citizens/PRs (Pre-October 2025)
INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    nationality_condition, min_age, max_age, max_salary,
    employee_rate, employer_rate,
    effective_from, effective_until, source_reference, verified_date
) VALUES
-- Under 60, Salary <= RM 5,000
((SELECT id FROM kf_statutory_scheme WHERE code='EPF' AND effective_from='2025-01-01'),
 'MY_UNDER60_UNDER5K', 'Malaysian/PR, Age < 60, Salary ≤ RM5,000',
 'ALL', NULL, 59, 5000.00,
 0.11000000, 0.13000000,
 '2025-01-01', '2099-12-31', 'EPF Third Schedule', '2025-12-27'),

-- Under 60, Salary > RM 5,000
((SELECT id FROM kf_statutory_scheme WHERE code='EPF' AND effective_from='2025-01-01'),
 'MY_UNDER60_OVER5K', 'Malaysian/PR, Age < 60, Salary > RM5,000',
 'ALL', NULL, 59, NULL,
 0.11000000, 0.12000000,
 '2025-01-01', '2099-12-31', 'EPF Third Schedule', '2025-12-27'),

-- Age 60+
((SELECT id FROM kf_statutory_scheme WHERE code='EPF' AND effective_from='2025-01-01'),
 'MY_OVER60', 'Malaysian/PR, Age ≥ 60',
 'ALL', 60, NULL, NULL,
 0.055000 00, 0.04000000,
 '2025-01-01', '2099-12-31', 'EPF Third Schedule', '2025-12-27')

ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

-- NEW: EPF Foreign Worker Mandate (Effective 1 October 2025)
INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en, name_local,
    scheme_type, calculation_method, calculation_base,
    foreign_worker_applicable, effective_from, legal_reference, notes
) VALUES
((SELECT id FROM kf_country WHERE code='MY'),
 (SELECT id FROM kf_statutory_authority WHERE code='KWSP'),
 'EPF_FOREIGN', 'EPF for Foreign Workers', 'KWSP untuk Pekerja Asing',
 'RETIREMENT', 'PERCENTAGE', 'GROSS',
 true, '2025-10-01', 'EPF Amendment Bill 2025',
 'CRITICAL: Foreign workers become EPF-eligible starting 1 October 2025')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    nationality_condition,
    employee_rate, employer_rate,
    effective_from, source_reference, verified_date, notes
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='EPF_FOREIGN'),
 'FOREIGN_2025', 'Foreign Workers (from Oct 2025)',
 'FOREIGN',
 0.02000000, 0.02000000,
 '2025-10-01', 'EPF Amendment Bill 2025', '2025-12-27',
 'Flat 2% employee + 2% employer for all foreign workers')
ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

-- ============================================================================
-- 3. SOCSO (Social Security Organisation)
-- ============================================================================

-- SOCSO Scheme
INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en, name_local,
    scheme_type, calculation_method, calculation_base,
    citizen_applicable, pr_applicable, foreign_worker_applicable,
    effective_from, legal_reference
) VALUES
((SELECT id FROM kf_country WHERE code='MY'),
 (SELECT id FROM kf_statutory_authority WHERE code='PERKESO'),
 'SOCSO', 'Social Security (SOCSO)', 'Pertubuhan Keselamatan Sosial',
 'SOCIAL_SECURITY', 'PERCENTAGE', 'GROSS',
 true, true, false,
 '2025-01-01', 'Employees Social Security Act 1969')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

-- SOCSO Rates
INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    employee_rate, employer_rate,
    effective_from, source_reference, verified_date
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='SOCSO'),
 'SOCSO_STANDARD', 'All SOCSO-covered employees',
 0.00500000, 0.01250000,
 '2025-01-01', 'PERKESO Schedule', '2025-12-27')
ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

-- SOCSO Ceiling
INSERT INTO kf_statutory_ceiling (
    scheme_id, ceiling_type, ceiling_amount,
    effective_from, source_reference
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='SOCSO'),
 'MONTHLY', 5000.00,
 '2025-01-01', 'SOCSO Act First Schedule')
ON CONFLICT (scheme_id, ceiling_type, effective_from) DO NOTHING;

-- ============================================================================
-- 4. EIS (Employment Insurance System)
-- ============================================================================

-- EIS Scheme
INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en, name_local,
    scheme_type, calculation_method, calculation_base,
    citizen_applicable, pr_applicable, foreign_worker_applicable,
    effective_from, legal_reference, notes
) VALUES
((SELECT id FROM kf_country WHERE code='MY'),
 (SELECT id FROM kf_statutory_authority WHERE code='EIS'),
 'EIS', 'Employment Insurance System', 'Sistem Insurans Pekerjaan',
 'UNEMPLOYMENT', 'PERCENTAGE', 'GROSS',
 true, true, false,
 '2024-10-01', 'Employment Insurance System Act 2017 (Second Schedule amended Oct 2024)',
 'Foreign workers explicitly EXCLUDED from EIS coverage')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

-- EIS Rates (Updated October 2024 - reduced from 0.4% to 0.2% each)
INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    employee_rate, employer_rate,
    effective_from, source_reference, verified_date, notes
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='EIS'),
 'EIS_STANDARD', 'All EIS-covered employees (citizens/PR only)',
 0.00200000, 0.00200000,
 '2024-10-01', 'EIS Act Second Schedule (Oct 2024 amendment)', '2025-12-27',
 'Reduced from 0.4% to 0.2% each, effective 1 October 2024')
ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

-- EIS Ceiling (Updated October 2024 - increased from RM4,000 to RM6,000)
INSERT INTO kf_statutory_ceiling (
    scheme_id, ceiling_type, ceiling_amount,
    effective_from, source_reference, notes
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='EIS'),
 'MONTHLY', 6000.00,
 '2024-10-01', 'EIS Act Second Schedule (Oct 2024)', 'Increased from RM4,000 to RM6,000')
ON CONFLICT (scheme_id, ceiling_type, effective_from) DO NOTHING;

-- ============================================================================
-- 5. HRDF (Human Resource Development Fund)
-- ============================================================================

-- HRDF Scheme
INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en, name_local,
    scheme_type, calculation_method, calculation_base,
    employee_contribution, employer_contribution,
    effective_from, legal_reference, notes
) VALUES
((SELECT id FROM kf_country WHERE code='MY'),
 (SELECT id FROM kf_statutory_authority WHERE code='HRDF'),
 'HRDF', 'Human Resource Development Levy', 'Levi Pembangunan Sumber Manusia',
 'LEVY', 'PERCENTAGE', 'GROSS',
 false, true,
 '2025-01-01', 'Pembangunan Sumber Manusia Berhad Act 2001',
 'Mandatory for employers with 10+ employees in manufacturing/services')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

-- HRDF Rates
INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    employee_count_min,
    employee_rate, employer_rate,
    effective_from, source_reference, verified_date
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='HRDF'),
 'HRDF_STANDARD', 'Companies with 10+ employees',
 10,
 0.00000000, 0.01000000,
 '2025-01-01', 'HRDF Act', '2025-12-27')
ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- SELECT s.code, s.name_en, COUNT(r.id) as rate_count
-- FROM kf_statutory_scheme s
-- LEFT JOIN kf_statutory_rate r ON s.id = r.scheme_id
-- WHERE s.country_id = (SELECT id FROM kf_country WHERE code='MY')
-- GROUP BY s.id, s.code, s.name_en
-- ORDER BY s.code;
--
-- Expected:
-- EPF: 3 rates (under60_under5k, under60_over5k, over60)
-- EPF_FOREIGN: 1 rate (foreign_2025)
-- SOCSO: 1 rate
-- EIS: 1 rate
-- HRDF: 1 rate
