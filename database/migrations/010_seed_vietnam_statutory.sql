-- ============================================================================
-- Migration: 010_seed_vietnam_statutory.sql
-- KerjaFlow ASEAN Statutory Framework
-- Purpose: Seed Vietnam statutory rates (BHXH, Trade Union)
-- Author: Claude Code
-- Date: 2025-12-27
-- Sources: Vietnam Social Security (VSS), Law on Social Insurance 2024
-- Verified: 2025-12-27
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. STATUTORY AUTHORITIES
-- ============================================================================

INSERT INTO kf_statutory_authority (country_id, code, name_en, name_local, acronym, website_url) VALUES
((SELECT id FROM kf_country WHERE code='VN'), 'VSS', 'Vietnam Social Security', 'Bảo hiểm Xã hội Việt Nam', 'BHXH', 'https://vss.gov.vn')
ON CONFLICT (country_id, code) DO NOTHING;

-- ============================================================================
-- 2. BHXH (Social Insurance) - Compulsory
-- ============================================================================

INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en, name_local,
    scheme_type, calculation_method, calculation_base,
    foreign_worker_applicable, effective_from, legal_reference
) VALUES
((SELECT id FROM kf_country WHERE code='VN'),
 (SELECT id FROM kf_statutory_authority WHERE code='VSS'),
 'BHXH', 'Social Insurance', 'Bảo hiểm Xã hội',
 'SOCIAL_SECURITY', 'PERCENTAGE', 'GROSS',
 true, '2025-07-01', 'Law on Social Insurance 2024 (Law 41/2024/QH15)')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

-- Vietnamese Employee Rates - VERIFIED (effective 1 July 2025)
-- Total: Employee 10.5% + Employer 21.5% = 32%
INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    nationality_condition,
    employee_rate, employer_rate,
    effective_from, source_reference, verified_date, notes
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='BHXH'),
 'BHXH_VN', 'Vietnamese Employees (Total 32%)',
 'CITIZEN',
 0.10500000, 0.21500000,
 '2025-07-01', 'Law on Social Insurance 2024 Art 32-34', '2025-12-27',
 'EE: 8% pension + 1% UI + 1.5% health. ER: 14% pension + 3% sickness/maternity + 0.5% OAD + 1% UI + 3% health'),

-- Foreign Employee Rates - VERIFIED (effective 1 July 2025)
-- Total: Employee 9.5% + Employer 20.5% = 30% (no unemployment insurance)
((SELECT id FROM kf_statutory_scheme WHERE code='BHXH'),
 'BHXH_FOREIGN', 'Foreign Employees (Total 30%)',
 'FOREIGN',
 0.09500000, 0.20500000,
 '2025-07-01', 'Decree 158/2025/ND-CP', '2025-12-27',
 'Foreign workers excluded from Unemployment Insurance. EE: 8% pension + 1.5% health. ER: 14% pension + 3% sickness/maternity + 0.5% OAD + 3% health')

ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

-- BHXH Ceiling - 20 times reference level
INSERT INTO kf_statutory_ceiling (
    scheme_id, ceiling_type, ceiling_amount,
    effective_from, source_reference, notes
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='BHXH'),
 'MONTHLY', 46800000.00,
 '2025-07-01', 'Law on Social Insurance 2024', '20 x reference level (VND 2,340,000)')
ON CONFLICT (scheme_id, ceiling_type, effective_from) DO NOTHING;

-- ============================================================================
-- 3. TRADE UNION FEE
-- ============================================================================

INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en, name_local,
    scheme_type, calculation_method, calculation_base,
    citizen_applicable, pr_applicable, foreign_worker_applicable,
    effective_from, legal_reference
) VALUES
((SELECT id FROM kf_country WHERE code='VN'),
 (SELECT id FROM kf_statutory_authority WHERE code='VSS'),
 'TRADE_UNION', 'Trade Union Fee', 'Kinh phí Công đoàn',
 'TRADE_UNION', 'PERCENTAGE', 'GROSS',
 true, true, false,
 '2025-07-01', 'Law on Trade Unions (amended) 2024')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

-- Trade Union Rates - VERIFIED (changed July 2025)
INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    employee_rate, employer_rate,
    effective_from, source_reference, verified_date, notes
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='TRADE_UNION'),
 'TU_2025', 'Trade Union 2025 (reduced from 1% to 0.5% EE)',
 0.00500000, 0.02000000,
 '2025-07-01', 'Decision 61/QD-TLD July 2025', '2025-12-27',
 'EE rate reduced from 1% to 0.5%. ER 2% unchanged.')
ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- SELECT s.code, s.name_en, r.tier_code, r.employee_rate, r.employer_rate
-- FROM kf_statutory_scheme s
-- JOIN kf_statutory_rate r ON s.id = r.scheme_id
-- WHERE s.country_id = (SELECT id FROM kf_country WHERE code='VN')
-- ORDER BY s.code, r.tier_code;
--
-- Expected:
-- BHXH: 2 rates (Vietnamese 32%, Foreign 30%)
-- TRADE_UNION: 1 rate (0.5% + 2%)
