-- ============================================================================
-- Migration: 007_seed_indonesia_statutory.sql
-- KerjaFlow ASEAN Statutory Framework
-- Purpose: Seed Indonesia statutory rates (BPJS TK, BPJS Kesehatan)
-- Author: Claude Code
-- Date: 2025-12-27
-- Sources: BPJS Ketenagakerjaan, BPJS Kesehatan
-- Verified: 2025-12-27
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. STATUTORY AUTHORITIES
-- ============================================================================

INSERT INTO kf_statutory_authority (country_id, code, name_en, name_local, acronym, website_url) VALUES
((SELECT id FROM kf_country WHERE code='ID'), 'BPJSTK', 'Workers Social Security', 'BPJS Ketenagakerjaan', 'BPJS TK', 'https://www.bpjsketenagakerjaan.go.id'),
((SELECT id FROM kf_country WHERE code='ID'), 'BPJSKES', 'Health Social Security', 'BPJS Kesehatan', 'BPJS Kes', 'https://www.bpjs-kesehatan.go.id')
ON CONFLICT (country_id, code) DO NOTHING;

-- ============================================================================
-- 2. BPJS TK - JKK (Jaminan Kecelakaan Kerja / Work Accident Insurance)
-- ============================================================================

INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en, name_local,
    scheme_type, calculation_method, calculation_base,
    employee_contribution, employer_contribution,
    foreign_worker_applicable, effective_from, legal_reference
) VALUES
((SELECT id FROM kf_country WHERE code='ID'),
 (SELECT id FROM kf_statutory_authority WHERE code='BPJSTK'),
 'JKK', 'Work Accident Insurance', 'Jaminan Kecelakaan Kerja',
 'SOCIAL_SECURITY', 'TIERED_PERCENTAGE', 'GROSS',
 false, true,
 true, '2015-07-01', 'PP No. 44 Tahun 2015')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

-- JKK Rates - Risk-based tiers
INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    risk_category,
    employee_rate, employer_rate,
    effective_from, source_reference, verified_date
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='JKK'),
 'JKK_VERY_LOW', 'Very Low Risk (e.g., office work)',
 'VERY_LOW',
 0.00000000, 0.00240000,
 '2015-07-01', 'BPJS TK', '2025-12-27'),

((SELECT id FROM kf_statutory_scheme WHERE code='JKK'),
 'JKK_LOW', 'Low Risk',
 'LOW',
 0.00000000, 0.00540000,
 '2015-07-01', 'BPJS TK', '2025-12-27'),

((SELECT id FROM kf_statutory_scheme WHERE code='JKK'),
 'JKK_MEDIUM', 'Medium Risk (e.g., manufacturing)',
 'MEDIUM',
 0.00000000, 0.00890000,
 '2015-07-01', 'BPJS TK', '2025-12-27'),

((SELECT id FROM kf_statutory_scheme WHERE code='JKK'),
 'JKK_HIGH', 'High Risk',
 'HIGH',
 0.00000000, 0.01270000,
 '2015-07-01', 'BPJS TK', '2025-12-27'),

((SELECT id FROM kf_statutory_scheme WHERE code='JKK'),
 'JKK_VERY_HIGH', 'Very High Risk (e.g., construction, mining)',
 'VERY_HIGH',
 0.00000000, 0.01740000,
 '2015-07-01', 'BPJS TK', '2025-12-27')

ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

-- ============================================================================
-- 3. BPJS TK - JKM (Jaminan Kematian / Death Insurance)
-- ============================================================================

INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en, name_local,
    scheme_type, calculation_method, calculation_base,
    employee_contribution, employer_contribution,
    foreign_worker_applicable, effective_from, legal_reference
) VALUES
((SELECT id FROM kf_country WHERE code='ID'),
 (SELECT id FROM kf_statutory_authority WHERE code='BPJSTK'),
 'JKM', 'Death Insurance', 'Jaminan Kematian',
 'SOCIAL_SECURITY', 'PERCENTAGE', 'GROSS',
 false, true,
 true, '2015-07-01', 'PP No. 44 Tahun 2015')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    employee_rate, employer_rate,
    effective_from, source_reference, verified_date
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='JKM'),
 'JKM_STANDARD', 'All employees',
 0.00000000, 0.00300000,
 '2015-07-01', 'BPJS TK', '2025-12-27')
ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

-- ============================================================================
-- 4. BPJS TK - JHT (Jaminan Hari Tua / Old Age Savings)
-- ============================================================================

INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en, name_local,
    scheme_type, calculation_method, calculation_base,
    foreign_worker_applicable, effective_from, legal_reference
) VALUES
((SELECT id FROM kf_country WHERE code='ID'),
 (SELECT id FROM kf_statutory_authority WHERE code='BPJSTK'),
 'JHT', 'Old Age Savings', 'Jaminan Hari Tua',
 'RETIREMENT', 'PERCENTAGE', 'GROSS',
 true, '2015-07-01', 'PP No. 46 Tahun 2015')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    employee_rate, employer_rate,
    effective_from, source_reference, verified_date
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='JHT'),
 'JHT_STANDARD', 'All employees',
 0.02000000, 0.03700000,
 '2015-07-01', 'BPJS TK', '2025-12-27')
ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

-- ============================================================================
-- 5. BPJS TK - JP (Jaminan Pensiun / Pension Insurance)
-- ============================================================================

INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en, name_local,
    scheme_type, calculation_method, calculation_base,
    employee_contribution, employer_contribution,
    foreign_worker_applicable, effective_from, legal_reference
) VALUES
((SELECT id FROM kf_country WHERE code='ID'),
 (SELECT id FROM kf_statutory_authority WHERE code='BPJSTK'),
 'JP', 'Pension Insurance', 'Jaminan Pensiun',
 'RETIREMENT', 'PERCENTAGE', 'GROSS',
 true, true,
 false, '2015-07-01', 'PP No. 45 Tahun 2015')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    employee_rate, employer_rate,
    effective_from, source_reference, verified_date
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='JP'),
 'JP_STANDARD', 'All employees',
 0.01000000, 0.02000000,
 '2025-01-01', 'BPJS TK', '2025-12-27')
ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

-- JP Ceiling - VERIFIED March 2025 update
INSERT INTO kf_statutory_ceiling (
    scheme_id, ceiling_type, ceiling_amount,
    effective_from, source_reference, notes
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='JP'),
 'MONTHLY', 10547400.00,
 '2025-03-01', 'BPJS TK Ceiling Mar 2025', '+5.03% GDP adjustment from IDR 10,042,300')
ON CONFLICT (scheme_id, ceiling_type, effective_from) DO NOTHING;

-- ============================================================================
-- 6. BPJS KESEHATAN (Health Insurance)
-- ============================================================================

INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en, name_local,
    scheme_type, calculation_method, calculation_base,
    foreign_worker_applicable, effective_from, legal_reference
) VALUES
((SELECT id FROM kf_country WHERE code='ID'),
 (SELECT id FROM kf_statutory_authority WHERE code='BPJSKES'),
 'BPJS_KES', 'Health Insurance', 'BPJS Kesehatan',
 'HEALTH', 'PERCENTAGE', 'GROSS',
 true, '2014-01-01', 'UU No. 24 Tahun 2011')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    employee_rate, employer_rate,
    effective_from, source_reference, verified_date
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='BPJS_KES'),
 'BPJS_KES_STANDARD', 'All employees',
 0.01000000, 0.04000000,
 '2025-01-01', 'BPJS Kesehatan', '2025-12-27')
ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

INSERT INTO kf_statutory_ceiling (
    scheme_id, ceiling_type, ceiling_amount,
    effective_from, source_reference
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='BPJS_KES'),
 'MONTHLY', 12000000.00,
 '2025-01-01', 'BPJS Kesehatan Ceiling')
ON CONFLICT (scheme_id, ceiling_type, effective_from) DO NOTHING;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- SELECT s.code, s.name_en, COUNT(r.id) as rate_count
-- FROM kf_statutory_scheme s
-- LEFT JOIN kf_statutory_rate r ON s.id = r.scheme_id
-- WHERE s.country_id = (SELECT id FROM kf_country WHERE code='ID')
-- GROUP BY s.id, s.code, s.name_en
-- ORDER BY s.code;
--
-- Expected:
-- JKK: 5 rates (5 risk tiers)
-- JKM: 1 rate
-- JHT: 1 rate
-- JP: 1 rate
-- BPJS_KES: 1 rate
