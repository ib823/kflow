-- ============================================================================
-- Migration: 008_seed_thailand_statutory.sql
-- KerjaFlow ASEAN Statutory Framework
-- Purpose: Seed Thailand statutory rates (SSF)
-- Author: Claude Code
-- Date: 2025-12-27
-- Sources: Social Security Office Thailand, Royal Gazette
-- Verified: 2025-12-27
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. STATUTORY AUTHORITIES
-- ============================================================================

INSERT INTO kf_statutory_authority (country_id, code, name_en, name_local, acronym, website_url) VALUES
((SELECT id FROM kf_country WHERE code='TH'), 'SSO', 'Social Security Office', 'สำนักงานประกันสังคม', 'SSO', 'https://www.sso.go.th')
ON CONFLICT (country_id, code) DO NOTHING;

-- ============================================================================
-- 2. SSF SECTION 33 (Employed Workers)
-- ============================================================================

INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en, name_local,
    scheme_type, calculation_method, calculation_base,
    foreign_worker_applicable, effective_from, legal_reference
) VALUES
((SELECT id FROM kf_country WHERE code='TH'),
 (SELECT id FROM kf_statutory_authority WHERE code='SSO'),
 'SSF_33', 'Social Security Fund Section 33', 'กองทุนประกันสังคม มาตรา 33',
 'SOCIAL_SECURITY', 'PERCENTAGE', 'GROSS',
 true, '1990-09-01', 'Social Security Act B.E. 2533')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

-- SSF Rates
INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    employee_rate, employer_rate,
    effective_from, source_reference, verified_date
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='SSF_33'),
 'SSF_STANDARD', 'All Section 33 employees',
 0.05000000, 0.05000000,
 '2025-01-01', 'SSO Thailand', '2025-12-27')
ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

-- ============================================================================
-- SSF CEILINGS - CRITICAL: 3-PHASE INCREASE STARTING JANUARY 2026
-- Per Royal Gazette 12 December 2025
-- ============================================================================

INSERT INTO kf_statutory_ceiling (
    scheme_id, ceiling_type, ceiling_amount, min_amount,
    effective_from, effective_until,
    source_reference, notes
) VALUES

-- Pre-2026 ceiling
((SELECT id FROM kf_statutory_scheme WHERE code='SSF_33'),
 'MONTHLY', 15000.00, 1650.00,
 '2020-01-01', '2025-12-31',
 'SSO Thailand', 'Pre-2026 ceiling'),

-- Phase 1: January 2026 - December 2028
((SELECT id FROM kf_statutory_scheme WHERE code='SSF_33'),
 'MONTHLY', 17500.00, 1650.00,
 '2026-01-01', '2028-12-31',
 'Royal Gazette 12 Dec 2025', 'Phase 1 of 3-phase increase'),

-- Phase 2: January 2029 - December 2031
((SELECT id FROM kf_statutory_scheme WHERE code='SSF_33'),
 'MONTHLY', 20000.00, 1650.00,
 '2029-01-01', '2031-12-31',
 'Royal Gazette 12 Dec 2025', 'Phase 2 of 3-phase increase'),

-- Phase 3: January 2032 onwards (FINAL)
((SELECT id FROM kf_statutory_scheme WHERE code='SSF_33'),
 'MONTHLY', 23000.00, 1650.00,
 '2032-01-01', NULL,
 'Royal Gazette 12 Dec 2025', 'Phase 3 - Final ceiling')

ON CONFLICT (scheme_id, ceiling_type, effective_from) DO NOTHING;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- SELECT c.ceiling_amount, c.effective_from, c.effective_until, c.notes
-- FROM kf_statutory_ceiling c
-- JOIN kf_statutory_scheme s ON c.scheme_id = s.id
-- WHERE s.code = 'SSF_33'
-- ORDER BY c.effective_from;
--
-- Expected: 4 ceiling rows (2025: ฿15K, 2026: ฿17.5K, 2029: ฿20K, 2032: ฿23K)
