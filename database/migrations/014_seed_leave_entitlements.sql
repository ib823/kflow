-- ============================================================================
-- Migration: 014_seed_leave_entitlements.sql
-- KerjaFlow ASEAN Statutory Framework
-- Purpose: Seed statutory leave entitlements for all 9 ASEAN countries
-- Author: Claude Code
-- Date: 2025-12-27
-- Verified: 2025-12-27
-- ============================================================================

BEGIN;

-- ============================================================================
-- MALAYSIA (Employment Act 1955, as amended 2022)
-- ============================================================================

INSERT INTO kf_country_leave_entitlement (
    country_id, leave_type_code, leave_type_name_en, leave_type_name_local,
    service_years_from, service_years_to, days_entitled,
    legal_reference, effective_from
) VALUES

-- Annual Leave
((SELECT id FROM kf_country WHERE code='MY'), 'ANNUAL', 'Annual Leave', 'Cuti Tahunan', 0, 2, 8, 'EA 1955 s60E(1)(a)', '2023-01-01'),
((SELECT id FROM kf_country WHERE code='MY'), 'ANNUAL', 'Annual Leave', 'Cuti Tahunan', 2, 5, 12, 'EA 1955 s60E(1)(b)', '2023-01-01'),
((SELECT id FROM kf_country WHERE code='MY'), 'ANNUAL', 'Annual Leave', 'Cuti Tahunan', 5, NULL, 16, 'EA 1955 s60E(1)(c)', '2023-01-01'),

-- Sick Leave
((SELECT id FROM kf_country WHERE code='MY'), 'SICK', 'Sick Leave', 'Cuti Sakit', 0, 2, 14, 'EA 1955 s60F(1)(a)', '2023-01-01'),
((SELECT id FROM kf_country WHERE code='MY'), 'SICK', 'Sick Leave', 'Cuti Sakit', 2, 5, 18, 'EA 1955 s60F(1)(b)', '2023-01-01'),
((SELECT id FROM kf_country WHERE code='MY'), 'SICK', 'Sick Leave', 'Cuti Sakit', 5, NULL, 22, 'EA 1955 s60F(1)(c)', '2023-01-01'),

-- Hospitalization
((SELECT id FROM kf_country WHERE code='MY'), 'HOSPITALIZATION', 'Hospitalization Leave', 'Cuti Hospital', 0, NULL, 60, 'EA 1955 s60F(1)', '2023-01-01'),

-- Maternity
((SELECT id FROM kf_country WHERE code='MY'), 'MATERNITY', 'Maternity Leave', 'Cuti Bersalin', 0, NULL, 98, 'EA 1955 s37(1)(a)', '2023-01-01'),

-- Paternity
((SELECT id FROM kf_country WHERE code='MY'), 'PATERNITY', 'Paternity Leave', 'Cuti Paterniti', 0, NULL, 7, 'EA 1955 s60FA', '2023-01-01')

ON CONFLICT (country_id, leave_type_code, service_years_from, effective_from) DO NOTHING;

-- ============================================================================
-- SINGAPORE (Employment Act)
-- ============================================================================

INSERT INTO kf_country_leave_entitlement (
    country_id, leave_type_code, leave_type_name_en,
    service_years_from, service_years_to, days_entitled,
    legal_reference, effective_from
) VALUES

-- Annual Leave - Progressive based on service years
((SELECT id FROM kf_country WHERE code='SG'), 'ANNUAL', 'Annual Leave', 1, 2, 7, 'EA s88A', '2023-01-01'),
((SELECT id FROM kf_country WHERE code='SG'), 'ANNUAL', 'Annual Leave', 2, 3, 8, 'EA s88A', '2023-01-01'),
((SELECT id FROM kf_country WHERE code='SG'), 'ANNUAL', 'Annual Leave', 3, 4, 9, 'EA s88A', '2023-01-01'),
((SELECT id FROM kf_country WHERE code='SG'), 'ANNUAL', 'Annual Leave', 4, 5, 10, 'EA s88A', '2023-01-01'),
((SELECT id FROM kf_country WHERE code='SG'), 'ANNUAL', 'Annual Leave', 5, 6, 11, 'EA s88A', '2023-01-01'),
((SELECT id FROM kf_country WHERE code='SG'), 'ANNUAL', 'Annual Leave', 6, 7, 12, 'EA s88A', '2023-01-01'),
((SELECT id FROM kf_country WHERE code='SG'), 'ANNUAL', 'Annual Leave', 7, 8, 13, 'EA s88A', '2023-01-01'),
((SELECT id FROM kf_country WHERE code='SG'), 'ANNUAL', 'Annual Leave', 8, NULL, 14, 'EA s88A', '2023-01-01'),

-- Sick Leave
((SELECT id FROM kf_country WHERE code='SG'), 'SICK', 'Outpatient Sick Leave', 0, NULL, 14, 'EA s89(2)', '2023-01-01'),
((SELECT id FROM kf_country WHERE code='SG'), 'HOSPITALIZATION', 'Hospitalization Leave', 0, NULL, 60, 'EA s89(2)', '2023-01-01'),

-- Maternity
((SELECT id FROM kf_country WHERE code='SG'), 'MATERNITY', 'Maternity Leave', 0, NULL, 112, 'CDCSA', '2023-01-01')

ON CONFLICT (country_id, leave_type_code, service_years_from, effective_from) DO NOTHING;

-- ============================================================================
-- INDONESIA (Labor Law)
-- ============================================================================

INSERT INTO kf_country_leave_entitlement (
    country_id, leave_type_code, leave_type_name_en, leave_type_name_local,
    service_years_from, days_entitled,
    legal_reference, effective_from, notes
) VALUES

-- Annual Leave
((SELECT id FROM kf_country WHERE code='ID'), 'ANNUAL', 'Annual Leave', 'Cuti Tahunan', 1, 12, 'UU Ketenagakerjaan No. 13/2003', '2023-01-01', 'After 12 months service'),

-- Maternity
((SELECT id FROM kf_country WHERE code='ID'), 'MATERNITY', 'Maternity Leave', 'Cuti Melahirkan', 0, 90, 'UU Ketenagakerjaan No. 13/2003', '2023-01-01', '3 months'),

-- Paternity
((SELECT id FROM kf_country WHERE code='ID'), 'PATERNITY', 'Paternity Leave', 'Cuti Ayah', 0, 2, 'UU Ketenagakerjaan No. 13/2003', '2023-01-01', NULL)

ON CONFLICT (country_id, leave_type_code, service_years_from, effective_from) DO NOTHING;

-- ============================================================================
-- THAILAND (Labor Protection Act)
-- ============================================================================

INSERT INTO kf_country_leave_entitlement (
    country_id, leave_type_code, leave_type_name_en, leave_type_name_local,
    service_years_from, days_entitled,
    legal_reference, effective_from
) VALUES

-- Annual Leave
((SELECT id FROM kf_country WHERE code='TH'), 'ANNUAL', 'Annual Leave', 'วันหยุดพักผ่อนประจำปี', 1, 6, 'Labor Protection Act B.E. 2541', '2023-01-01'),

-- Sick Leave
((SELECT id FROM kf_country WHERE code='TH'), 'SICK', 'Sick Leave', 'การลาป่วย', 0, 30, 'Labor Protection Act B.E. 2541', '2023-01-01'),

-- Maternity
((SELECT id FROM kf_country WHERE code='TH'), 'MATERNITY', 'Maternity Leave', 'การลาคลอด', 0, 98, 'Labor Protection Act B.E. 2541', '2019-04-07')

ON CONFLICT (country_id, leave_type_code, service_years_from, effective_from) DO NOTHING;

-- ============================================================================
-- PHILIPPINES (Labor Code)
-- ============================================================================

INSERT INTO kf_country_leave_entitlement (
    country_id, leave_type_code, leave_type_name_en,
    service_years_from, days_entitled,
    legal_reference, effective_from, notes
) VALUES

-- Service Incentive Leave
((SELECT id FROM kf_country WHERE code='PH'), 'SIL', 'Service Incentive Leave', 1, 5, 'Labor Code Art. 95', '2023-01-01', 'Convertible to cash if unused'),

-- Maternity
((SELECT id FROM kf_country WHERE code='PH'), 'MATERNITY', 'Maternity Leave', 0, 105, 'RA 11210', '2019-03-11', '105 days, +15 for solo parents'),

-- Paternity
((SELECT id FROM kf_country WHERE code='PH'), 'PATERNITY', 'Paternity Leave', 0, 7, 'RA 8187', '2023-01-01', NULL)

ON CONFLICT (country_id, leave_type_code, service_years_from, effective_from) DO NOTHING;

-- ============================================================================
-- VIETNAM (Labor Code 2019)
-- ============================================================================

INSERT INTO kf_country_leave_entitlement (
    country_id, leave_type_code, leave_type_name_en, leave_type_name_local,
    service_years_from, days_entitled, is_calendar_days,
    legal_reference, effective_from
) VALUES

-- Annual Leave
((SELECT id FROM kf_country WHERE code='VN'), 'ANNUAL', 'Annual Leave', 'Nghỉ phép năm', 1, 12, false, 'Labor Code 2019 Art. 113', '2021-01-01'),

-- Maternity
((SELECT id FROM kf_country WHERE code='VN'), 'MATERNITY', 'Maternity Leave', 'Nghỉ thai sản', 0, 180, true, 'Labor Code 2019 Art. 139', '2021-01-01'),

-- Paternity
((SELECT id FROM kf_country WHERE code='VN'), 'PATERNITY', 'Paternity Leave', 'Nghỉ cho bố', 0, 5, false, 'Labor Code 2019', '2021-01-01')

ON CONFLICT (country_id, leave_type_code, service_years_from, effective_from) DO NOTHING;

-- ============================================================================
-- CAMBODIA (Labor Law)
-- ============================================================================

INSERT INTO kf_country_leave_entitlement (
    country_id, leave_type_code, leave_type_name_en,
    service_years_from, days_entitled,
    legal_reference, effective_from
) VALUES

-- Annual Leave
((SELECT id FROM kf_country WHERE code='KH'), 'ANNUAL', 'Annual Leave', 1, 18, 'Labor Law Art. 166', '2023-01-01'),

-- Maternity
((SELECT id FROM kf_country WHERE code='KH'), 'MATERNITY', 'Maternity Leave', 0, 90, 'Labor Law Art. 182', '2023-01-01')

ON CONFLICT (country_id, leave_type_code, service_years_from, effective_from) DO NOTHING;

-- ============================================================================
-- MYANMAR (Leave and Holidays Act)
-- ============================================================================

INSERT INTO kf_country_leave_entitlement (
    country_id, leave_type_code, leave_type_name_en,
    service_years_from, days_entitled,
    legal_reference, effective_from
) VALUES

-- Annual Leave
((SELECT id FROM kf_country WHERE code='MM'), 'ANNUAL', 'Annual Leave', 1, 10, 'Leave and Holidays Act', '2023-01-01'),

-- Sick Leave
((SELECT id FROM kf_country WHERE code='MM'), 'SICK', 'Sick Leave', 0, 30, 'Leave and Holidays Act', '2023-01-01'),

-- Maternity
((SELECT id FROM kf_country WHERE code='MM'), 'MATERNITY', 'Maternity Leave', 0, 98, 'Leave and Holidays Act', '2023-01-01')

ON CONFLICT (country_id, leave_type_code, service_years_from, effective_from) DO NOTHING;

-- ============================================================================
-- BRUNEI (Employment Order 2009)
-- ============================================================================

INSERT INTO kf_country_leave_entitlement (
    country_id, leave_type_code, leave_type_name_en,
    service_years_from, days_entitled,
    legal_reference, effective_from
) VALUES

-- Annual Leave
((SELECT id FROM kf_country WHERE code='BN'), 'ANNUAL', 'Annual Leave', 1, 7, 'Employment Order 2009', '2023-01-01'),

-- Sick Leave
((SELECT id FROM kf_country WHERE code='BN'), 'SICK', 'Sick Leave', 0, 14, 'Employment Order 2009', '2023-01-01'),

-- Maternity
((SELECT id FROM kf_country WHERE code='BN'), 'MATERNITY', 'Maternity Leave', 0, 63, 'Employment Order 2009', '2023-01-01')

ON CONFLICT (country_id, leave_type_code, service_years_from, effective_from) DO NOTHING;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- SELECT c.code as country, l.leave_type_code, l.service_years_from, l.days_entitled
-- FROM kf_country_leave_entitlement l
-- JOIN kf_country c ON l.country_id = c.id
-- ORDER BY c.code, l.leave_type_code, l.service_years_from;
--
-- Expected: ~40 leave entitlement records across 9 countries
