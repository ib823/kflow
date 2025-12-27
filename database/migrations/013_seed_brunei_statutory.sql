-- ============================================================================
-- Migration: 013_seed_brunei_statutory.sql
-- KerjaFlow ASEAN Statutory Framework
-- Purpose: Seed Brunei statutory rates (SPK)
-- Author: Claude Code
-- Date: 2025-12-27
-- Sources: TAP Board Brunei
-- Verified: 2025-12-27
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. STATUTORY AUTHORITIES
-- ============================================================================

INSERT INTO kf_statutory_authority (country_id, code, name_en, name_local, acronym, website_url) VALUES
((SELECT id FROM kf_country WHERE code='BN'), 'TAP', 'Employees Trust Fund', 'Tabung Amanah Pekerja', 'TAP', 'https://www.tap.com.bn')
ON CONFLICT (country_id, code) DO NOTHING;

-- ============================================================================
-- 2. SPK (National Retirement Scheme)
-- Replaced TAP/SCP in July 2023
-- ============================================================================

INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en, name_local,
    scheme_type, calculation_method, calculation_base,
    citizen_applicable, pr_applicable, foreign_worker_applicable,
    effective_from, legal_reference, notes
) VALUES
((SELECT id FROM kf_country WHERE code='BN'),
 (SELECT id FROM kf_statutory_authority WHERE code='TAP'),
 'SPK', 'National Retirement Scheme', 'Skim Persaraan Kebangsaan',
 'RETIREMENT', 'TIERED_PERCENTAGE', 'GROSS',
 true, true, false,
 '2023-07-15', 'SPK Regulations 2023',
 'Replaced TAP (5%) + SCP (3.5%). Removed contribution caps.')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

-- SPK Rates - Tiered Employer Rates - VERIFIED
INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    min_salary, max_salary,
    employee_rate, employer_rate, employer_fixed,
    effective_from, source_reference, verified_date, notes
) VALUES

-- Tier 1: Salary ≤ BND 500
((SELECT id FROM kf_statutory_scheme WHERE code='SPK'),
 'SPK_TIER1', 'Salary ≤ BND 500',
 NULL, 500.00,
 0.08500000, NULL, 57.50,
 '2023-07-15', 'TAP Board SPK', '2025-12-27', 'Employer pays minimum BND 57.50'),

-- Tier 2: Salary BND 500.01 - 1,500
((SELECT id FROM kf_statutory_scheme WHERE code='SPK'),
 'SPK_TIER2', 'Salary BND 500.01-1,500',
 500.01, 1500.00,
 0.08500000, 0.10500000, NULL,
 '2023-07-15', 'TAP Board SPK', '2025-12-27', NULL),

-- Tier 3: Salary BND 1,500.01 - 2,800
((SELECT id FROM kf_statutory_scheme WHERE code='SPK'),
 'SPK_TIER3', 'Salary BND 1,500.01-2,800',
 1500.01, 2800.00,
 0.08500000, 0.09500000, NULL,
 '2023-07-15', 'TAP Board SPK', '2025-12-27', NULL),

-- Tier 4: Salary > BND 2,800
((SELECT id FROM kf_statutory_scheme WHERE code='SPK'),
 'SPK_TIER4', 'Salary > BND 2,800',
 2800.01, NULL,
 0.08500000, 0.08500000, NULL,
 '2023-07-15', 'TAP Board SPK', '2025-12-27', 'No cap - replaced old BND 98 max')

ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- SELECT s.code, r.tier_code, r.min_salary, r.max_salary, r.employee_rate, r.employer_rate, r.employer_fixed
-- FROM kf_statutory_scheme s
-- JOIN kf_statutory_rate r ON s.id = r.scheme_id
-- WHERE s.country_id = (SELECT id FROM kf_country WHERE code='BN')
-- ORDER BY r.min_salary NULLS FIRST;
--
-- Expected: 4 SPK tiers with varying employer rates
