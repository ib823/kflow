-- ============================================================================
-- Migration: 006_seed_singapore_statutory.sql
-- KerjaFlow ASEAN Statutory Framework
-- Purpose: Seed Singapore statutory rates (CPF, SDL)
-- Author: Claude Code
-- Date: 2025-12-27
-- Sources: cpf.gov.sg
-- Verified: 2025-12-27
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. STATUTORY AUTHORITIES
-- ============================================================================

INSERT INTO kf_statutory_authority (country_id, code, name_en, acronym, website_url) VALUES
((SELECT id FROM kf_country WHERE code='SG'), 'CPF', 'Central Provident Fund Board', 'CPF', 'https://www.cpf.gov.sg'),
((SELECT id FROM kf_country WHERE code='SG'), 'SDL', 'Skills Development Levy', 'SDL', 'https://www.skillsfuture.gov.sg')
ON CONFLICT (country_id, code) DO NOTHING;

-- ============================================================================
-- 2. CPF (Central Provident Fund)
-- ============================================================================

-- CPF Scheme
INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en,
    scheme_type, calculation_method, calculation_base,
    citizen_applicable, pr_applicable, foreign_worker_applicable,
    effective_from, legal_reference, notes
) VALUES
((SELECT id FROM kf_country WHERE code='SG'),
 (SELECT id FROM kf_statutory_authority WHERE code='CPF'),
 'CPF', 'Central Provident Fund',
 'RETIREMENT', 'TIERED_PERCENTAGE', 'ORDINARY_WAGES',
 true, true, false,
 '2025-01-01', 'CPF Act Cap 36',
 'Age-tiered rates with 2026 increases for senior workers')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

-- ============================================================================
-- CPF RATES 2025
-- ============================================================================

INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    min_age, max_age,
    employee_rate, employer_rate, total_rate,
    effective_from, effective_until,
    source_reference, verified_date, notes
) VALUES

-- Age < 55 (2025)
((SELECT id FROM kf_statutory_scheme WHERE code='CPF'),
 'SG_CITIZEN_UNDER55_2025', 'Citizens/PRs Age ≤ 55',
 NULL, 55,
 0.20000000, 0.17000000, 0.37000000,
 '2025-01-01', '2099-12-31',
 'CPF Board', '2025-12-27', NULL),

-- Age 55-60 (2025)
((SELECT id FROM kf_statutory_scheme WHERE code='CPF'),
 'SG_CITIZEN_55_60_2025', 'Citizens/PRs Age 55-60 (2025)',
 56, 60,
 0.16500000, 0.15000000, 0.31500000,
 '2025-01-01', '2025-12-31',
 'CPF Board', '2025-12-27', 'Will increase to 33% in 2026'),

-- Age 60-65 (2025)
((SELECT id FROM kf_statutory_scheme WHERE code='CPF'),
 'SG_CITIZEN_60_65_2025', 'Citizens/PRs Age 60-65 (2025)',
 61, 65,
 0.11500000, 0.11500000, 0.23000000,
 '2025-01-01', '2025-12-31',
 'CPF Board', '2025-12-27', 'Will increase to 25.5% in 2026'),

-- Age 65-70 (2025)
((SELECT id FROM kf_statutory_scheme WHERE code='CPF'),
 'SG_CITIZEN_65_70_2025', 'Citizens/PRs Age 65-70 (2025)',
 66, 70,
 0.08500000, 0.09500000, 0.18000000,
 '2025-01-01', '2025-12-31',
 'CPF Board', '2025-12-27', 'Will increase to 20% in 2026'),

-- Age 70+ (2025)
((SELECT id FROM kf_statutory_scheme WHERE code='CPF'),
 'SG_CITIZEN_OVER70_2025', 'Citizens/PRs Age > 70 (2025)',
 71, NULL,
 0.06500000, 0.08000000, 0.14500000,
 '2025-01-01', '2025-12-31',
 'CPF Board', '2025-12-27', 'Will increase to 16% in 2026')

ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

-- ============================================================================
-- CPF RATES 2026 (SENIOR WORKER INCREASES)
-- ============================================================================

INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    min_age, max_age,
    employee_rate, employer_rate, total_rate,
    effective_from,
    source_reference, verified_date, notes
) VALUES

-- Age 55-60 (2026) - +1.5% increase
((SELECT id FROM kf_statutory_scheme WHERE code='CPF'),
 'SG_CITIZEN_55_60_2026', 'Citizens/PRs Age 55-60 (2026)',
 56, 60,
 0.17000000, 0.16000000, 0.33000000,
 '2026-01-01',
 'CPF Board 2026 Increase', '2025-12-27', '+1.5% total from 2025'),

-- Age 60-65 (2026) - +2.5% increase
((SELECT id FROM kf_statutory_scheme WHERE code='CPF'),
 'SG_CITIZEN_60_65_2026', 'Citizens/PRs Age 60-65 (2026)',
 61, 65,
 0.13000000, 0.12500000, 0.25500000,
 '2026-01-01',
 'CPF Board 2026 Increase', '2025-12-27', '+2.5% total from 2025'),

-- Age 65-70 (2026) - +2% increase
((SELECT id FROM kf_statutory_scheme WHERE code='CPF'),
 'SG_CITIZEN_65_70_2026', 'Citizens/PRs Age 65-70 (2026)',
 66, 70,
 0.09500000, 0.10500000, 0.20000000,
 '2026-01-01',
 'CPF Board 2026 Increase', '2025-12-27', '+2% total from 2025'),

-- Age 70+ (2026) - +1.5% increase
((SELECT id FROM kf_statutory_scheme WHERE code='CPF'),
 'SG_CITIZEN_OVER70_2026', 'Citizens/PRs Age > 70 (2026)',
 71, NULL,
 0.07500000, 0.08500000, 0.16000000,
 '2026-01-01',
 'CPF Board 2026 Increase', '2025-12-27', '+1.5% total from 2025')

ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

-- ============================================================================
-- CPF ORDINARY WAGES (OW) CEILING
-- ============================================================================

INSERT INTO kf_statutory_ceiling (
    scheme_id, ceiling_type, ceiling_amount,
    effective_from, effective_until,
    source_reference, notes
) VALUES

-- 2025 ceiling
((SELECT id FROM kf_statutory_scheme WHERE code='CPF'),
 'OW_MONTHLY', 7400.00,
 '2025-01-01', '2025-12-31',
 'CPF Board', 'OW ceiling S$7,400 (2025)'),

-- 2026 ceiling (FINAL increase)
((SELECT id FROM kf_statutory_scheme WHERE code='CPF'),
 'OW_MONTHLY', 8000.00,
 '2026-01-01', NULL,
 'CPF Board', 'OW ceiling S$8,000 (2026) - FINAL increase')

ON CONFLICT (scheme_id, ceiling_type, effective_from) DO NOTHING;

-- Additional Wages (AW) ceiling - unchanged
INSERT INTO kf_statutory_ceiling (
    scheme_id, ceiling_type, ceiling_amount,
    effective_from,
    source_reference
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='CPF'),
 'AW_ANNUAL', 102000.00,
 '2016-01-01',
 'CPF Act')
ON CONFLICT (scheme_id, ceiling_type, effective_from) DO NOTHING;

-- ============================================================================
-- 3. SDL (Skills Development Levy)
-- ============================================================================

-- SDL Scheme
INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en,
    scheme_type, calculation_method, calculation_base,
    employee_contribution, employer_contribution,
    effective_from, legal_reference
) VALUES
((SELECT id FROM kf_country WHERE code='SG'),
 (SELECT id FROM kf_statutory_authority WHERE code='SDL'),
 'SDL', 'Skills Development Levy',
 'LEVY', 'PERCENTAGE', 'GROSS',
 false, true,
 '2025-01-01', 'Skills Development Levy Act')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

-- SDL Rates
INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    max_salary,
    employee_rate, employer_rate,
    effective_from, source_reference, verified_date
) VALUES

-- Salary ≤ S$4,500
((SELECT id FROM kf_statutory_scheme WHERE code='SDL'),
 'SDL_UNDER4500', 'Monthly salary ≤ S$4,500',
 4500.00,
 0.00000000, 0.00250000,
 '2025-01-01', 'SDL Act', '2025-12-27'),

-- Salary > S$4,500
((SELECT id FROM kf_statutory_scheme WHERE code='SDL'),
 'SDL_OVER4500', 'Monthly salary > S$4,500',
 NULL,
 0.00000000, 0.00500000,
 '2025-01-01', 'SDL Act', '2025-12-27')

ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- SELECT s.code, s.name_en, r.tier_code, r.employee_rate, r.employer_rate, r.effective_from
-- FROM kf_statutory_scheme s
-- JOIN kf_statutory_rate r ON s.id = r.scheme_id
-- WHERE s.country_id = (SELECT id FROM kf_country WHERE code='SG')
-- ORDER BY s.code, r.effective_from, r.min_age NULLS FIRST;
--
-- Expected:
-- CPF: 9 rate tiers (5 for 2025, 4 for 2026)
-- SDL: 2 rate tiers
