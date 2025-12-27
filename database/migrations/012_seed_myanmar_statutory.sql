-- ============================================================================
-- Migration: 012_seed_myanmar_statutory.sql
-- KerjaFlow ASEAN Statutory Framework
-- Purpose: Seed Myanmar statutory rates (SSB)
-- Author: Claude Code
-- Date: 2025-12-27
-- Sources: Social Security Board Myanmar
-- Verified: 2025-12-27
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. STATUTORY AUTHORITIES
-- ============================================================================

INSERT INTO kf_statutory_authority (country_id, code, name_en, name_local, acronym) VALUES
((SELECT id FROM kf_country WHERE code='MM'), 'SSB', 'Social Security Board', 'လူမှုဖူလုံရေးအဖွဲ့', 'SSB')
ON CONFLICT (country_id, code) DO NOTHING;

-- ============================================================================
-- 2. SSB SOCIAL SECURITY
-- ============================================================================

INSERT INTO kf_statutory_scheme (
    country_id, authority_id, code, name_en, name_local,
    scheme_type, calculation_method, calculation_base,
    foreign_worker_applicable, effective_from, legal_reference, notes
) VALUES
((SELECT id FROM kf_country WHERE code='MM'),
 (SELECT id FROM kf_statutory_authority WHERE code='SSB'),
 'SSB', 'Social Security', 'လူမှုဖူလုံရေး',
 'SOCIAL_SECURITY', 'PERCENTAGE', 'GROSS',
 true, '2012-01-01', 'Social Security Law 2012',
 'Mandatory for employers with 5+ employees')
ON CONFLICT (country_id, code, effective_from) DO NOTHING;

-- SSB Rates - VERIFIED
INSERT INTO kf_statutory_rate (
    scheme_id, tier_code, tier_description,
    employee_rate, employer_rate,
    effective_from, source_reference, verified_date, notes
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='SSB'),
 'SSB_STANDARD', 'All covered employees',
 0.02000000, 0.03000000,
 '2025-01-01', 'SSB Myanmar', '2025-12-27',
 'Max EE: MMK 6,000, Max ER: MMK 9,000 per month')
ON CONFLICT (scheme_id, tier_code, effective_from) DO NOTHING;

-- SSB Maximum Contributions (caps)
INSERT INTO kf_statutory_ceiling (
    scheme_id, ceiling_type, ceiling_amount,
    effective_from, source_reference, notes
) VALUES
((SELECT id FROM kf_statutory_scheme WHERE code='SSB'),
 'MONTHLY', 300000.00,
 '2025-01-01', 'SSB Myanmar', 'Implies max salary for full percentage: MMK 300,000')
ON CONFLICT (scheme_id, ceiling_type, effective_from) DO NOTHING;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- SELECT s.code, s.name_en, r.employee_rate, r.employer_rate
-- FROM kf_statutory_scheme s
-- JOIN kf_statutory_rate r ON s.id = r.scheme_id
-- WHERE s.country_id = (SELECT id FROM kf_country WHERE code='MM');
--
-- Expected: SSB 2% employee + 3% employer
