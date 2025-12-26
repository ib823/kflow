-- ============================================================================
-- KerjaFlow v3.0 - Compliance Monitoring Migration
-- 
-- Purpose: Add tables and data for:
--   1. Cambodia LPDP monitoring (regulatory change tracking)
--   2. Cambodia NSSF pension rate scheduled increase (Oct 2027)
--   3. Brunei PDPO grace period tracking
--
-- Run this migration on the CENTRAL database (Malaysia Hub)
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. REGULATORY MONITOR TABLE
-- Tracks pending legislation and regulatory changes
-- ============================================================================
CREATE TABLE IF NOT EXISTS kf_regulatory_monitor (
    id SERIAL PRIMARY KEY,
    country_code VARCHAR(2) NOT NULL,
    regulation_name VARCHAR(255) NOT NULL,
    regulation_type VARCHAR(50) NOT NULL,  -- 'data_protection', 'social_security', 'labor_law'
    status VARCHAR(50) NOT NULL DEFAULT 'monitoring',
    -- Status values: 'monitoring', 'enacted', 'effective', 'superseded'
    
    -- Timeline
    draft_announced_date DATE,
    expected_enactment_date DATE,
    actual_enactment_date DATE,
    effective_date DATE,
    grace_period_end DATE,
    
    -- Impact Assessment
    impact_level VARCHAR(20) NOT NULL DEFAULT 'medium',  -- 'critical', 'high', 'medium', 'low'
    requires_data_migration BOOLEAN DEFAULT FALSE,
    requires_infra_change BOOLEAN DEFAULT FALSE,
    requires_rate_change BOOLEAN DEFAULT FALSE,
    
    -- Action Items
    action_required TEXT,
    action_deadline DATE,
    action_completed BOOLEAN DEFAULT FALSE,
    action_completed_date DATE,
    
    -- Monitoring Schedule
    last_checked_date DATE,
    check_frequency_days INTEGER DEFAULT 30,
    next_check_date DATE,
    source_url TEXT,
    notes TEXT,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_status CHECK (status IN ('monitoring', 'enacted', 'effective', 'superseded')),
    CONSTRAINT chk_impact CHECK (impact_level IN ('critical', 'high', 'medium', 'low'))
);

CREATE INDEX IF NOT EXISTS idx_reg_monitor_status ON kf_regulatory_monitor(country_code, status);
CREATE INDEX IF NOT EXISTS idx_reg_monitor_check ON kf_regulatory_monitor(next_check_date) WHERE status = 'monitoring';

-- ============================================================================
-- 2. ENHANCED STATUTORY RATE TABLE
-- Supports future-dated rates with automatic activation
-- ============================================================================
-- Add new columns to existing table
ALTER TABLE kf_statutory_rate 
    ADD COLUMN IF NOT EXISTS effective_from DATE NOT NULL DEFAULT '2024-01-01',
    ADD COLUMN IF NOT EXISTS effective_to DATE,
    ADD COLUMN IF NOT EXISTS is_scheduled BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS regulatory_reference VARCHAR(255),
    ADD COLUMN IF NOT EXISTS rate_notes TEXT;

-- Create index for efficient date-based rate lookups
CREATE INDEX IF NOT EXISTS idx_stat_rate_lookup 
ON kf_statutory_rate(country_code, contribution_type, effective_from DESC);

-- ============================================================================
-- 3. COMPLIANCE ALERT TABLE
-- Stores alerts for admin dashboard
-- ============================================================================
CREATE TABLE IF NOT EXISTS kf_compliance_alert (
    id SERIAL PRIMARY KEY,
    alert_type VARCHAR(50) NOT NULL,  -- 'rate_change', 'law_enacted', 'deadline', 'review_due'
    severity VARCHAR(20) NOT NULL,    -- 'critical', 'warning', 'info'
    country_code VARCHAR(2),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    
    -- Related Records
    regulatory_monitor_id INTEGER REFERENCES kf_regulatory_monitor(id),
    
    -- Alert Status
    is_read BOOLEAN DEFAULT FALSE,
    is_acknowledged BOOLEAN DEFAULT FALSE,
    acknowledged_by INTEGER,
    acknowledged_at TIMESTAMP,
    
    -- Timing
    trigger_date DATE NOT NULL,
    expiry_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_alert_type CHECK (alert_type IN ('rate_change', 'law_enacted', 'deadline', 'review_due', 'action_required')),
    CONSTRAINT chk_severity CHECK (severity IN ('critical', 'warning', 'info'))
);

CREATE INDEX IF NOT EXISTS idx_alert_unread ON kf_compliance_alert(is_read, severity) WHERE is_read = FALSE;

-- ============================================================================
-- 4. PRE-LOAD CAMBODIA NSSF RATES (CURRENT + FUTURE)
-- ============================================================================

-- Delete any existing Cambodia NSSF pension rates to avoid duplicates
DELETE FROM kf_statutory_rate WHERE country_code = 'KH' AND contribution_type = 'NSSF_PENSION';

-- Current pension rate (Oct 2022 - Sep 2027)
INSERT INTO kf_statutory_rate (
    country_code, contribution_type, system_name,
    employee_rate, employer_rate, salary_cap, currency_code,
    effective_from, effective_to, is_scheduled, regulatory_reference, rate_notes
) VALUES (
    'KH', 'NSSF_PENSION', 'NSSF Pension Scheme',
    2.0, 2.0, 1200000, 'KHR',
    '2022-10-01', '2027-09-30', FALSE,
    'NSSF Pension Scheme Law 2022',
    'Initial 5-year rate period. Rate will increase to 4% each after Sep 2027.'
);

-- Future pension rate (Oct 2027 onwards) - AUTOMATICALLY ACTIVATES
INSERT INTO kf_statutory_rate (
    country_code, contribution_type, system_name,
    employee_rate, employer_rate, salary_cap, currency_code,
    effective_from, effective_to, is_scheduled, regulatory_reference, rate_notes
) VALUES (
    'KH', 'NSSF_PENSION', 'NSSF Pension Scheme',
    4.0, 4.0, 1200000, 'KHR',
    '2027-10-01', NULL, TRUE,
    'NSSF Pension Scheme Law 2022 - Phase 2',
    'SCHEDULED INCREASE: Employee 2%→4%, Employer 2%→4%. Auto-activates Oct 2027.'
);

-- Other Cambodia NSSF rates (unchanged, no future increase scheduled)
INSERT INTO kf_statutory_rate (
    country_code, contribution_type, system_name,
    employee_rate, employer_rate, salary_cap, currency_code,
    effective_from, effective_to, is_scheduled, rate_notes
) VALUES 
(
    'KH', 'NSSF_RISK', 'NSSF Occupational Risk',
    0.0, 0.8, 1200000, 'KHR',
    '2022-01-01', NULL, FALSE,
    'Employer-only contribution for occupational risks'
),
(
    'KH', 'NSSF_HEALTH', 'NSSF Health Care',
    0.0, 2.6, 1200000, 'KHR',
    '2018-01-01', NULL, FALSE,
    'Employer-only since Jan 2018 (was 1.3% each before)'
)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 5. PRE-LOAD CAMBODIA LPDP MONITORING RECORD
-- ============================================================================
INSERT INTO kf_regulatory_monitor (
    country_code, regulation_name, regulation_type, status,
    draft_announced_date, impact_level,
    requires_data_migration, requires_infra_change,
    action_required, check_frequency_days, 
    next_check_date, source_url, notes
) VALUES (
    'KH', 
    'Personal Data Protection Law (LPDP)', 
    'data_protection',
    'monitoring',
    '2025-07-01',
    'critical',
    TRUE,
    TRUE,
    'Monitor for enactment. If data residency required: (1) Provision Cambodia VPS ~$15-20/mo, (2) Migrate employee data from Vietnam VPS, (3) Update database router KH→Cambodia.',
    14,  -- Check every 2 weeks
    CURRENT_DATE + INTERVAL '14 days',
    'https://www.mptc.gov.kh',
    'GDPR-inspired framework announced July 2025. Expected 2-year implementation period after promulgation. Potential data residency requirement - impacts current architecture (KH data on Vietnam VPS). Budget contingency: $15-20/mo for Cambodia VPS if required.'
) ON CONFLICT DO NOTHING;

-- ============================================================================
-- 6. PRE-LOAD BRUNEI PDPO TRACKING RECORD  
-- ============================================================================
INSERT INTO kf_regulatory_monitor (
    country_code, regulation_name, regulation_type, status,
    actual_enactment_date, effective_date, grace_period_end,
    impact_level, requires_data_migration, requires_infra_change,
    action_required, action_deadline, check_frequency_days,
    next_check_date, source_url, notes
) VALUES (
    'BN',
    'Personal Data Protection Order (PDPO) 2025',
    'data_protection',
    'enacted',
    '2025-01-01',
    '2025-01-01',
    '2026-01-01',  -- 1-year grace period
    'high',
    FALSE,
    FALSE,
    'ACTION REQUIRED: (1) Appoint Data Protection Officer (DPO), (2) Ensure DPO has CIPM certification, (3) Designate local representative in Brunei, (4) Document data processing activities.',
    '2025-12-01',  -- 1 month before grace period ends
    30,
    CURRENT_DATE + INTERVAL '30 days',
    'https://www.aiti.gov.bn',
    'PDPO 2025 requires MANDATORY DPO for ALL data controllers/processors (stricter than GDPR). DPO must hold CIPM certification. Foreign entities must appoint local representative. 1-year grace period ends Jan 2026.'
) ON CONFLICT DO NOTHING;

-- ============================================================================
-- 7. CREATE INITIAL COMPLIANCE ALERTS
-- ============================================================================

-- Alert: Cambodia LPDP monitoring
INSERT INTO kf_compliance_alert (
    alert_type, severity, country_code, title, message,
    trigger_date, expiry_date
) VALUES (
    'review_due',
    'warning',
    'KH',
    'Cambodia LPDP - Regulatory Monitoring Active',
    'Cambodia Personal Data Protection Law (LPDP) is in draft stage. Monitor for enactment every 2 weeks. If enacted with data residency requirement, will need to provision Cambodia VPS and migrate data from Vietnam.',
    CURRENT_DATE,
    '2027-12-31'  -- Long expiry, will be updated when law status changes
);

-- Alert: Cambodia NSSF rate increase
INSERT INTO kf_compliance_alert (
    alert_type, severity, country_code, title, message,
    trigger_date, expiry_date
) VALUES (
    'rate_change',
    'info',
    'KH',
    'Cambodia NSSF Pension Rate Increase - October 2027',
    'NSSF Pension contribution rates will increase from 2% to 4% (both employee and employer) effective October 1, 2027. System is pre-configured to automatically apply new rates. No manual action required.',
    '2027-07-01',  -- Alert becomes visible 3 months before
    '2027-10-31'
);

-- Alert: Brunei PDPO deadline
INSERT INTO kf_compliance_alert (
    alert_type, severity, country_code, title, message,
    trigger_date, expiry_date
) VALUES (
    'deadline',
    'warning',
    'BN',
    'Brunei PDPO Compliance Deadline - January 2026',
    'Brunei PDPO 2025 grace period ends January 1, 2026. Ensure: (1) DPO appointed with CIPM certification, (2) Local representative designated, (3) Data processing documented.',
    CURRENT_DATE,
    '2026-01-31'
);

-- ============================================================================
-- 8. CREATE HELPER FUNCTION FOR RATE LOOKUP
-- ============================================================================
CREATE OR REPLACE FUNCTION get_statutory_rate(
    p_country_code VARCHAR(2),
    p_contribution_type VARCHAR(50),
    p_effective_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    employee_rate DECIMAL(5,2),
    employer_rate DECIMAL(5,2),
    salary_cap DECIMAL(15,2),
    currency_code VARCHAR(3),
    effective_from DATE,
    is_scheduled BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        sr.employee_rate,
        sr.employer_rate,
        sr.salary_cap,
        sr.currency_code,
        sr.effective_from,
        sr.is_scheduled
    FROM kf_statutory_rate sr
    WHERE sr.country_code = p_country_code
      AND sr.contribution_type = p_contribution_type
      AND sr.effective_from <= p_effective_date
      AND (sr.effective_to IS NULL OR sr.effective_to >= p_effective_date)
    ORDER BY sr.effective_from DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Example usage:
-- SELECT * FROM get_statutory_rate('KH', 'NSSF_PENSION', '2025-10-15');  -- Returns 2%
-- SELECT * FROM get_statutory_rate('KH', 'NSSF_PENSION', '2027-10-15');  -- Returns 4%

-- ============================================================================
-- 9. CREATE VIEW FOR ADMIN DASHBOARD
-- ============================================================================
CREATE OR REPLACE VIEW vw_compliance_dashboard AS
SELECT 
    'regulatory' as item_type,
    rm.country_code,
    rm.regulation_name as title,
    rm.status,
    rm.impact_level as severity,
    rm.action_deadline as deadline,
    rm.action_required as description,
    rm.requires_data_migration,
    rm.requires_infra_change,
    CASE 
        WHEN rm.action_deadline IS NOT NULL 
        THEN rm.action_deadline - CURRENT_DATE 
        ELSE NULL 
    END as days_until_deadline
FROM kf_regulatory_monitor rm
WHERE rm.status IN ('monitoring', 'enacted')

UNION ALL

SELECT 
    'rate_change' as item_type,
    sr.country_code,
    sr.contribution_type || ' Rate Change' as title,
    'scheduled' as status,
    CASE 
        WHEN sr.effective_from - CURRENT_DATE <= 90 THEN 'high'
        ELSE 'medium'
    END as severity,
    sr.effective_from as deadline,
    'Rate change: Employee ' || sr.employee_rate || '%, Employer ' || sr.employer_rate || '%' as description,
    FALSE as requires_data_migration,
    FALSE as requires_infra_change,
    sr.effective_from - CURRENT_DATE as days_until_deadline
FROM kf_statutory_rate sr
WHERE sr.is_scheduled = TRUE
  AND sr.effective_from > CURRENT_DATE

ORDER BY days_until_deadline ASC NULLS LAST;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check Cambodia NSSF rates are loaded correctly
-- SELECT * FROM kf_statutory_rate WHERE country_code = 'KH' ORDER BY contribution_type, effective_from;

-- Check regulatory monitoring records
-- SELECT country_code, regulation_name, status, action_deadline FROM kf_regulatory_monitor;

-- Check compliance alerts
-- SELECT country_code, title, severity, trigger_date FROM kf_compliance_alert;

-- Test rate lookup function for different dates
-- SELECT * FROM get_statutory_rate('KH', 'NSSF_PENSION', '2025-06-15');  -- Should return 2%
-- SELECT * FROM get_statutory_rate('KH', 'NSSF_PENSION', '2027-10-15');  -- Should return 4%

-- View compliance dashboard
-- SELECT * FROM vw_compliance_dashboard ORDER BY days_until_deadline;
