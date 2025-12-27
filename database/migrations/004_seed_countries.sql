-- ============================================================================
-- Migration: 004_seed_countries.sql
-- KerjaFlow ASEAN Statutory Framework
-- Purpose: Seed all 9 ASEAN countries master data
-- Author: Claude Code
-- Date: 2025-12-27
-- Verified: 2025-12-27
-- ============================================================================

BEGIN;

-- ============================================================================
-- COUNTRY MASTER DATA - 9 ASEAN COUNTRIES
-- ============================================================================

INSERT INTO kf_country (
    code, name_en, name_local, currency_code, currency_symbol,
    currency_decimal_places, currency_subunit_name, default_locale,
    timezone, payment_deadline_default_day, data_residency_required
) VALUES
    -- Malaysia
    ('MY', 'Malaysia', 'Malaysia', 'MYR', 'RM', 2, 'Sen', 'ms_MY',
     'Asia/Kuala_Lumpur', 15, false),

    -- Singapore
    ('SG', 'Singapore', 'Singapore', 'SGD', 'S$', 2, 'Cent', 'en_SG',
     'Asia/Singapore', 14, false),

    -- Indonesia
    ('ID', 'Indonesia', 'Indonesia', 'IDR', 'Rp', 0, 'Sen', 'id_ID',
     'Asia/Jakarta', 15, true),  -- MANDATORY local storage per PP 71/2019

    -- Thailand
    ('TH', 'Thailand', 'ประเทศไทย', 'THB', '฿', 2, 'Satang', 'th_TH',
     'Asia/Bangkok', 15, false),

    -- Philippines
    ('PH', 'Philippines', 'Pilipinas', 'PHP', '₱', 2, 'Centavo', 'en_PH',
     'Asia/Manila', 15, false),

    -- Vietnam
    ('VN', 'Vietnam', 'Việt Nam', 'VND', '₫', 0, 'Hào', 'vi_VN',
     'Asia/Ho_Chi_Minh', 15, true),  -- MANDATORY local storage per Cybersecurity Law

    -- Cambodia
    ('KH', 'Cambodia', 'កម្ពុជា', 'KHR', '៛', 0, 'Sen', 'km_KH',
     'Asia/Phnom_Penh', 15, false),  -- Monitor LPDP draft law

    -- Myanmar
    ('MM', 'Myanmar', 'မြန်မာ', 'MMK', 'K', 0, 'Pya', 'my_MM',
     'Asia/Yangon', 15, false),

    -- Brunei
    ('BN', 'Brunei', 'Brunei Darussalam', 'BND', 'B$', 2, 'Sen', 'ms_BN',
     'Asia/Brunei', 15, false)

ON CONFLICT (code) DO UPDATE SET
    name_en = EXCLUDED.name_en,
    currency_code = EXCLUDED.currency_code,
    updated_at = NOW();

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- SELECT code, name_en, currency_code, data_residency_required
-- FROM kf_country
-- ORDER BY code;
--
-- Expected: 9 rows (MY, SG, ID, TH, PH, VN, KH, MM, BN)
