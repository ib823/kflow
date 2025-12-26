"""
KerjaFlow v3.0 - Compliance Monitoring System
Handles:
1. Cambodia LPDP draft law monitoring
2. Cambodia NSSF pension rate scheduled increase (Oct 2027)
3. Brunei PDPO grace period tracking
"""

from datetime import date, datetime, timedelta
from decimal import Decimal
from enum import Enum
from typing import Optional, List, Dict, Any
from dataclasses import dataclass
import logging

# ============================================================================
# PART 1: DATABASE MODELS (Odoo-style)
# ============================================================================

"""
SQL Schema for Compliance Monitoring Tables
Run these migrations to add compliance tracking to KerjaFlow
"""

MIGRATION_SQL = """
-- ============================================================================
-- Table: kf_regulatory_monitor
-- Purpose: Track pending legislation and regulatory changes
-- ============================================================================
CREATE TABLE IF NOT EXISTS kf_regulatory_monitor (
    id SERIAL PRIMARY KEY,
    country_code VARCHAR(2) NOT NULL,
    regulation_name VARCHAR(255) NOT NULL,
    regulation_type VARCHAR(50) NOT NULL,  -- 'data_protection', 'social_security', 'labor_law'
    status VARCHAR(50) NOT NULL DEFAULT 'monitoring',  -- 'monitoring', 'enacted', 'effective', 'superseded'
    
    -- Draft/Pending Details
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
    
    -- Monitoring
    last_checked_date DATE,
    check_frequency_days INTEGER DEFAULT 30,
    next_check_date DATE,
    source_url TEXT,
    notes TEXT,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER,
    updated_by INTEGER,
    
    CONSTRAINT fk_country FOREIGN KEY (country_code) 
        REFERENCES kf_country_config(country_code)
);

-- Index for quick status lookups
CREATE INDEX idx_regulatory_status ON kf_regulatory_monitor(country_code, status);
CREATE INDEX idx_regulatory_next_check ON kf_regulatory_monitor(next_check_date);

-- ============================================================================
-- Table: kf_statutory_rate (ENHANCED)
-- Purpose: Support future-dated rates with automatic activation
-- ============================================================================
-- Add columns if not exists
ALTER TABLE kf_statutory_rate 
ADD COLUMN IF NOT EXISTS effective_from DATE NOT NULL DEFAULT '2024-01-01',
ADD COLUMN IF NOT EXISTS effective_to DATE,  -- NULL means currently active
ADD COLUMN IF NOT EXISTS is_scheduled BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS superseded_by INTEGER,
ADD COLUMN IF NOT EXISTS regulatory_reference VARCHAR(255),
ADD COLUMN IF NOT EXISTS notes TEXT;

-- Index for efficient rate lookups by date
CREATE INDEX IF NOT EXISTS idx_statutory_rate_dates 
ON kf_statutory_rate(country_code, contribution_type, effective_from, effective_to);

-- ============================================================================
-- Table: kf_compliance_alert
-- Purpose: Store alerts for admin dashboard
-- ============================================================================
CREATE TABLE IF NOT EXISTS kf_compliance_alert (
    id SERIAL PRIMARY KEY,
    alert_type VARCHAR(50) NOT NULL,  -- 'rate_change', 'law_enacted', 'deadline', 'action_required'
    severity VARCHAR(20) NOT NULL,    -- 'critical', 'warning', 'info'
    country_code VARCHAR(2),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    
    -- Related Records
    regulatory_monitor_id INTEGER REFERENCES kf_regulatory_monitor(id),
    statutory_rate_id INTEGER,
    
    -- Alert Status
    is_read BOOLEAN DEFAULT FALSE,
    is_acknowledged BOOLEAN DEFAULT FALSE,
    acknowledged_by INTEGER,
    acknowledged_at TIMESTAMP,
    
    -- Timing
    trigger_date DATE NOT NULL,
    expiry_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_compliance_alert_unread 
ON kf_compliance_alert(is_read, severity, trigger_date);

-- ============================================================================
-- Pre-load Cambodia NSSF Future Rates
-- ============================================================================
-- Current rates (effective Oct 2022)
INSERT INTO kf_statutory_rate (
    country_code, contribution_type, 
    employee_rate, employer_rate, salary_cap, currency_code,
    effective_from, effective_to, is_scheduled, regulatory_reference, notes
) VALUES 
-- Current pension rate
('KH', 'NSSF_PENSION', 2.0, 2.0, 1200000, 'KHR',
 '2022-10-01', '2027-09-30', FALSE, 
 'NSSF Pension Scheme 2022', 'Initial 5-year rate period'),

-- Future pension rate (auto-activates Oct 2027)
('KH', 'NSSF_PENSION', 4.0, 4.0, 1200000, 'KHR',
 '2027-10-01', NULL, TRUE,
 'NSSF Pension Scheme 2022 - Phase 2', 
 'Rate increase after 5-year initial period. Employee 2%→4%, Employer 2%→4%')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- Pre-load Cambodia LPDP Monitoring Record
-- ============================================================================
INSERT INTO kf_regulatory_monitor (
    country_code, regulation_name, regulation_type, status,
    draft_announced_date, impact_level,
    requires_data_migration, requires_infra_change,
    action_required, check_frequency_days, source_url, notes
) VALUES (
    'KH', 
    'Personal Data Protection Law (LPDP)', 
    'data_protection',
    'monitoring',
    '2025-07-01',  -- Draft announced July 2025
    'critical',
    TRUE,   -- May require data migration if local storage mandated
    TRUE,   -- May require Cambodia VPS if local storage mandated
    'Monitor for enactment. If data residency required, provision Cambodia VPS and migrate data.',
    14,     -- Check every 2 weeks
    'https://www.mptc.gov.kh',
    'GDPR-inspired framework. 2-year implementation period expected after promulgation. '
    'Potential data residency requirement - budget for Cambodia VPS ($15-20/mo) if enacted.'
) ON CONFLICT DO NOTHING;

-- ============================================================================
-- Pre-load Brunei PDPO Grace Period Tracking
-- ============================================================================
INSERT INTO kf_regulatory_monitor (
    country_code, regulation_name, regulation_type, status,
    actual_enactment_date, effective_date, grace_period_end,
    impact_level, requires_data_migration, requires_infra_change,
    action_required, action_deadline, check_frequency_days, notes
) VALUES (
    'BN',
    'Personal Data Protection Order (PDPO) 2025',
    'data_protection',
    'enacted',
    '2025-01-01',  -- Enacted January 2025
    '2025-01-01',
    '2026-01-01',  -- 1-year grace period
    'high',
    FALSE,  -- No data migration needed (using MY hub is compliant)
    FALSE,  -- No infra change needed
    'Ensure DPO appointed with CIPM certification. Designate local representative.',
    '2025-12-01',  -- Action deadline 1 month before grace period ends
    30,
    'Mandatory DPO for ALL data controllers (stricter than GDPR). '
    'DPO must hold CIPM certification. Foreign entities must appoint local representative.'
) ON CONFLICT DO NOTHING;
"""


# ============================================================================
# PART 2: STATUTORY RATE SERVICE
# ============================================================================

@dataclass
class StatutoryRate:
    """Represents a statutory contribution rate"""
    country_code: str
    contribution_type: str
    employee_rate: Decimal
    employer_rate: Decimal
    salary_cap: Optional[Decimal]
    currency_code: str
    effective_from: date
    effective_to: Optional[date]
    is_scheduled: bool = False
    notes: Optional[str] = None


class StatutoryRateService:
    """
    Service for retrieving statutory rates with automatic date-based selection.
    Handles scheduled future rates (like Cambodia NSSF Oct 2027 increase).
    """
    
    def __init__(self, db_connection):
        self.db = db_connection
        self.logger = logging.getLogger('kerjaflow.statutory')
    
    def get_rate(
        self, 
        country_code: str, 
        contribution_type: str, 
        effective_date: date = None
    ) -> Optional[StatutoryRate]:
        """
        Get the applicable statutory rate for a given date.
        Automatically selects the correct rate based on effective_from/effective_to.
        
        Args:
            country_code: ISO 2-letter country code (e.g., 'KH' for Cambodia)
            contribution_type: Type of contribution (e.g., 'NSSF_PENSION')
            effective_date: Date for which to get rate (defaults to today)
        
        Returns:
            StatutoryRate object or None if not found
        
        Example:
            # Get Cambodia pension rate for October 2027 payroll
            rate = service.get_rate('KH', 'NSSF_PENSION', date(2027, 10, 15))
            # Returns: employee_rate=4.0, employer_rate=4.0 (auto-selected future rate)
        """
        if effective_date is None:
            effective_date = date.today()
        
        query = """
            SELECT 
                country_code, contribution_type,
                employee_rate, employer_rate, salary_cap, currency_code,
                effective_from, effective_to, is_scheduled, notes
            FROM kf_statutory_rate
            WHERE country_code = %s
              AND contribution_type = %s
              AND effective_from <= %s
              AND (effective_to IS NULL OR effective_to >= %s)
            ORDER BY effective_from DESC
            LIMIT 1
        """
        
        result = self.db.execute(query, (
            country_code, contribution_type, effective_date, effective_date
        )).fetchone()
        
        if result:
            return StatutoryRate(
                country_code=result[0],
                contribution_type=result[1],
                employee_rate=Decimal(str(result[2])),
                employer_rate=Decimal(str(result[3])),
                salary_cap=Decimal(str(result[4])) if result[4] else None,
                currency_code=result[5],
                effective_from=result[6],
                effective_to=result[7],
                is_scheduled=result[8],
                notes=result[9]
            )
        return None
    
    def get_all_rates_for_country(
        self, 
        country_code: str, 
        effective_date: date = None,
        include_future: bool = False
    ) -> List[StatutoryRate]:
        """
        Get all statutory rates for a country.
        
        Args:
            country_code: ISO 2-letter country code
            effective_date: Date for rate selection (defaults to today)
            include_future: If True, also return scheduled future rates
        
        Returns:
            List of StatutoryRate objects
        """
        if effective_date is None:
            effective_date = date.today()
        
        if include_future:
            query = """
                SELECT DISTINCT ON (contribution_type)
                    country_code, contribution_type,
                    employee_rate, employer_rate, salary_cap, currency_code,
                    effective_from, effective_to, is_scheduled, notes
                FROM kf_statutory_rate
                WHERE country_code = %s
                  AND (effective_from <= %s OR is_scheduled = TRUE)
                ORDER BY contribution_type, effective_from DESC
            """
        else:
            query = """
                SELECT 
                    country_code, contribution_type,
                    employee_rate, employer_rate, salary_cap, currency_code,
                    effective_from, effective_to, is_scheduled, notes
                FROM kf_statutory_rate
                WHERE country_code = %s
                  AND effective_from <= %s
                  AND (effective_to IS NULL OR effective_to >= %s)
                ORDER BY contribution_type
            """
        
        results = self.db.execute(query, (
            country_code, effective_date, effective_date
        ) if not include_future else (country_code, effective_date)).fetchall()
        
        return [StatutoryRate(
            country_code=r[0], contribution_type=r[1],
            employee_rate=Decimal(str(r[2])), employer_rate=Decimal(str(r[3])),
            salary_cap=Decimal(str(r[4])) if r[4] else None,
            currency_code=r[5], effective_from=r[6], effective_to=r[7],
            is_scheduled=r[8], notes=r[9]
        ) for r in results]
    
    def get_upcoming_rate_changes(self, days_ahead: int = 90) -> List[Dict[str, Any]]:
        """
        Get all scheduled rate changes in the next N days.
        Used for admin dashboard alerts.
        
        Args:
            days_ahead: Number of days to look ahead
        
        Returns:
            List of upcoming rate changes with details
        """
        future_date = date.today() + timedelta(days=days_ahead)
        
        query = """
            SELECT 
                r.country_code, c.country_name, r.contribution_type,
                r.employee_rate, r.employer_rate, 
                r.effective_from, r.notes,
                -- Get current rate for comparison
                (SELECT employee_rate FROM kf_statutory_rate curr
                 WHERE curr.country_code = r.country_code 
                   AND curr.contribution_type = r.contribution_type
                   AND curr.effective_from <= CURRENT_DATE
                   AND (curr.effective_to IS NULL OR curr.effective_to >= CURRENT_DATE)
                 ORDER BY curr.effective_from DESC LIMIT 1) as current_employee_rate,
                (SELECT employer_rate FROM kf_statutory_rate curr
                 WHERE curr.country_code = r.country_code 
                   AND curr.contribution_type = r.contribution_type
                   AND curr.effective_from <= CURRENT_DATE
                   AND (curr.effective_to IS NULL OR curr.effective_to >= CURRENT_DATE)
                 ORDER BY curr.effective_from DESC LIMIT 1) as current_employer_rate
            FROM kf_statutory_rate r
            JOIN kf_country_config c ON r.country_code = c.country_code
            WHERE r.is_scheduled = TRUE
              AND r.effective_from > CURRENT_DATE
              AND r.effective_from <= %s
            ORDER BY r.effective_from
        """
        
        results = self.db.execute(query, (future_date,)).fetchall()
        
        return [{
            'country_code': r[0],
            'country_name': r[1],
            'contribution_type': r[2],
            'new_employee_rate': float(r[3]),
            'new_employer_rate': float(r[4]),
            'effective_from': r[5],
            'notes': r[6],
            'current_employee_rate': float(r[7]) if r[7] else None,
            'current_employer_rate': float(r[8]) if r[8] else None,
            'days_until_effective': (r[5] - date.today()).days
        } for r in results]


# ============================================================================
# PART 3: REGULATORY MONITORING SERVICE
# ============================================================================

class RegulatoryStatus(Enum):
    MONITORING = 'monitoring'      # Draft announced, watching for enactment
    ENACTED = 'enacted'            # Law passed, not yet effective
    EFFECTIVE = 'effective'        # Law is now in force
    SUPERSEDED = 'superseded'      # Replaced by newer regulation


@dataclass
class RegulatoryUpdate:
    """Represents a regulatory change being monitored"""
    id: int
    country_code: str
    regulation_name: str
    regulation_type: str
    status: RegulatoryStatus
    impact_level: str
    requires_data_migration: bool
    requires_infra_change: bool
    action_required: Optional[str]
    action_deadline: Optional[date]
    next_check_date: Optional[date]
    days_until_action: Optional[int] = None


class RegulatoryMonitorService:
    """
    Service for monitoring regulatory changes.
    Handles Cambodia LPDP tracking and similar pending legislation.
    """
    
    def __init__(self, db_connection):
        self.db = db_connection
        self.logger = logging.getLogger('kerjaflow.regulatory')
    
    def get_pending_regulations(
        self, 
        country_code: str = None,
        include_enacted: bool = True
    ) -> List[RegulatoryUpdate]:
        """
        Get all regulations being monitored or recently enacted.
        
        Args:
            country_code: Filter by country (None for all)
            include_enacted: Include enacted regulations in grace period
        
        Returns:
            List of RegulatoryUpdate objects
        """
        statuses = ['monitoring']
        if include_enacted:
            statuses.append('enacted')
        
        query = """
            SELECT 
                id, country_code, regulation_name, regulation_type,
                status, impact_level, requires_data_migration, requires_infra_change,
                action_required, action_deadline, next_check_date
            FROM kf_regulatory_monitor
            WHERE status = ANY(%s)
        """
        params = [statuses]
        
        if country_code:
            query += " AND country_code = %s"
            params.append(country_code)
        
        query += " ORDER BY impact_level DESC, action_deadline ASC NULLS LAST"
        
        results = self.db.execute(query, params).fetchall()
        
        updates = []
        for r in results:
            days_until = None
            if r[9]:  # action_deadline
                days_until = (r[9] - date.today()).days
            
            updates.append(RegulatoryUpdate(
                id=r[0], country_code=r[1], regulation_name=r[2],
                regulation_type=r[3], status=RegulatoryStatus(r[4]),
                impact_level=r[5], requires_data_migration=r[6],
                requires_infra_change=r[7], action_required=r[8],
                action_deadline=r[9], next_check_date=r[10],
                days_until_action=days_until
            ))
        
        return updates
    
    def update_regulation_status(
        self,
        regulation_id: int,
        new_status: RegulatoryStatus,
        effective_date: date = None,
        grace_period_end: date = None,
        notes: str = None
    ) -> bool:
        """
        Update regulation status when law is enacted.
        
        Example: When Cambodia LPDP is enacted:
            service.update_regulation_status(
                regulation_id=123,
                new_status=RegulatoryStatus.ENACTED,
                effective_date=date(2026, 1, 1),
                grace_period_end=date(2028, 1, 1),  # 2-year implementation
                notes="Enacted by National Assembly. Data residency required."
            )
        """
        query = """
            UPDATE kf_regulatory_monitor
            SET status = %s,
                actual_enactment_date = COALESCE(%s, actual_enactment_date),
                effective_date = COALESCE(%s, effective_date),
                grace_period_end = COALESCE(%s, grace_period_end),
                notes = COALESCE(%s || ' | ' || notes, notes),
                updated_at = CURRENT_TIMESTAMP
            WHERE id = %s
            RETURNING id
        """
        
        result = self.db.execute(query, (
            new_status.value,
            date.today() if new_status == RegulatoryStatus.ENACTED else None,
            effective_date,
            grace_period_end,
            notes,
            regulation_id
        )).fetchone()
        
        if result:
            self.logger.info(
                f"Regulatory status updated: {regulation_id} -> {new_status.value}"
            )
            # Trigger alert generation
            self._create_status_change_alert(regulation_id, new_status)
            return True
        return False
    
    def check_due_for_review(self) -> List[RegulatoryUpdate]:
        """
        Get regulations that are due for review.
        Called by scheduled job to prompt compliance team.
        """
        query = """
            SELECT 
                id, country_code, regulation_name, regulation_type,
                status, impact_level, requires_data_migration, requires_infra_change,
                action_required, action_deadline, next_check_date
            FROM kf_regulatory_monitor
            WHERE status = 'monitoring'
              AND next_check_date <= CURRENT_DATE
            ORDER BY impact_level DESC
        """
        
        results = self.db.execute(query).fetchall()
        return [RegulatoryUpdate(
            id=r[0], country_code=r[1], regulation_name=r[2],
            regulation_type=r[3], status=RegulatoryStatus(r[4]),
            impact_level=r[5], requires_data_migration=r[6],
            requires_infra_change=r[7], action_required=r[8],
            action_deadline=r[9], next_check_date=r[10]
        ) for r in results]
    
    def mark_checked(self, regulation_id: int, notes: str = None) -> bool:
        """
        Mark regulation as checked and schedule next review.
        """
        query = """
            UPDATE kf_regulatory_monitor
            SET last_checked_date = CURRENT_DATE,
                next_check_date = CURRENT_DATE + (check_frequency_days || ' days')::interval,
                notes = CASE WHEN %s IS NOT NULL 
                        THEN %s || ' | ' || COALESCE(notes, '')
                        ELSE notes END,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = %s
            RETURNING id
        """
        result = self.db.execute(query, (notes, notes, regulation_id)).fetchone()
        return result is not None
    
    def _create_status_change_alert(
        self, 
        regulation_id: int, 
        new_status: RegulatoryStatus
    ):
        """Create alert when regulation status changes"""
        query = """
            INSERT INTO kf_compliance_alert (
                alert_type, severity, country_code, title, message,
                regulatory_monitor_id, trigger_date
            )
            SELECT 
                'law_enacted',
                CASE WHEN impact_level = 'critical' THEN 'critical' ELSE 'warning' END,
                country_code,
                regulation_name || ' - Status Changed to ' || %s,
                'The regulation status has been updated. ' || COALESCE(action_required, ''),
                id,
                CURRENT_DATE
            FROM kf_regulatory_monitor
            WHERE id = %s
        """
        self.db.execute(query, (new_status.value, regulation_id))


# ============================================================================
# PART 4: COMPLIANCE ALERT SERVICE
# ============================================================================

class ComplianceAlertService:
    """
    Service for managing compliance alerts displayed on admin dashboard.
    """
    
    def __init__(self, db_connection):
        self.db = db_connection
        self.logger = logging.getLogger('kerjaflow.alerts')
    
    def get_active_alerts(
        self, 
        country_code: str = None,
        severity: str = None,
        unread_only: bool = False
    ) -> List[Dict[str, Any]]:
        """Get active compliance alerts for dashboard"""
        query = """
            SELECT 
                id, alert_type, severity, country_code, title, message,
                regulatory_monitor_id, is_read, is_acknowledged,
                trigger_date, created_at
            FROM kf_compliance_alert
            WHERE (expiry_date IS NULL OR expiry_date >= CURRENT_DATE)
        """
        params = []
        
        if country_code:
            query += " AND country_code = %s"
            params.append(country_code)
        if severity:
            query += " AND severity = %s"
            params.append(severity)
        if unread_only:
            query += " AND is_read = FALSE"
        
        query += " ORDER BY severity DESC, trigger_date DESC"
        
        results = self.db.execute(query, params).fetchall()
        
        return [{
            'id': r[0], 'alert_type': r[1], 'severity': r[2],
            'country_code': r[3], 'title': r[4], 'message': r[5],
            'regulatory_monitor_id': r[6], 'is_read': r[7],
            'is_acknowledged': r[8], 'trigger_date': r[9],
            'created_at': r[10]
        } for r in results]
    
    def generate_rate_change_alerts(self, days_ahead: int = 90):
        """
        Generate alerts for upcoming statutory rate changes.
        Called by scheduled job.
        """
        rate_service = StatutoryRateService(self.db)
        upcoming = rate_service.get_upcoming_rate_changes(days_ahead)
        
        for change in upcoming:
            # Check if alert already exists
            existing = self.db.execute("""
                SELECT id FROM kf_compliance_alert
                WHERE alert_type = 'rate_change'
                  AND country_code = %s
                  AND title LIKE %s
                  AND trigger_date = %s
            """, (
                change['country_code'],
                f"%{change['contribution_type']}%",
                change['effective_from']
            )).fetchone()
            
            if not existing:
                severity = 'warning' if change['days_until_effective'] > 30 else 'critical'
                
                self.db.execute("""
                    INSERT INTO kf_compliance_alert (
                        alert_type, severity, country_code, title, message, trigger_date
                    ) VALUES (%s, %s, %s, %s, %s, %s)
                """, (
                    'rate_change',
                    severity,
                    change['country_code'],
                    f"{change['country_name']} {change['contribution_type']} Rate Change",
                    f"Rate change effective {change['effective_from']}: "
                    f"Employee {change['current_employee_rate']}% → {change['new_employee_rate']}%, "
                    f"Employer {change['current_employer_rate']}% → {change['new_employer_rate']}%. "
                    f"{change['notes'] or ''}",
                    change['effective_from']
                ))
                
                self.logger.info(
                    f"Created rate change alert for {change['country_code']} "
                    f"{change['contribution_type']}"
                )


# ============================================================================
# PART 5: PAYROLL CALCULATION WITH AUTOMATIC RATE SELECTION
# ============================================================================

class PayrollCalculator:
    """
    Payroll calculator that automatically uses correct statutory rates
    based on payslip date.
    """
    
    def __init__(self, db_connection):
        self.rate_service = StatutoryRateService(db_connection)
        self.logger = logging.getLogger('kerjaflow.payroll')
    
    def calculate_statutory_deductions(
        self,
        country_code: str,
        gross_salary: Decimal,
        payslip_date: date
    ) -> Dict[str, Any]:
        """
        Calculate all statutory deductions for an employee.
        Automatically selects correct rates based on payslip date.
        
        Args:
            country_code: Employee's country code
            gross_salary: Gross monthly salary
            payslip_date: Date of the payslip (determines which rates apply)
        
        Returns:
            Dictionary with all deductions and contributions
        
        Example:
            # Cambodia payslip for October 2027 (after rate increase)
            result = calculator.calculate_statutory_deductions(
                country_code='KH',
                gross_salary=Decimal('1500000'),  # 1.5M KHR
                payslip_date=date(2027, 10, 31)
            )
            # Uses 4% pension rate (not 2%) because payslip_date is after Oct 2027
        """
        rates = self.rate_service.get_all_rates_for_country(
            country_code, 
            effective_date=payslip_date
        )
        
        deductions = {
            'country_code': country_code,
            'payslip_date': payslip_date,
            'gross_salary': float(gross_salary),
            'employee_deductions': {},
            'employer_contributions': {},
            'total_employee_deduction': Decimal('0'),
            'total_employer_contribution': Decimal('0'),
            'rates_used': []
        }
        
        for rate in rates:
            # Apply salary cap if exists
            applicable_salary = gross_salary
            if rate.salary_cap and gross_salary > rate.salary_cap:
                applicable_salary = rate.salary_cap
            
            employee_amount = applicable_salary * (rate.employee_rate / 100)
            employer_amount = applicable_salary * (rate.employer_rate / 100)
            
            deductions['employee_deductions'][rate.contribution_type] = {
                'rate': float(rate.employee_rate),
                'amount': float(employee_amount),
                'capped_at': float(rate.salary_cap) if rate.salary_cap else None
            }
            
            deductions['employer_contributions'][rate.contribution_type] = {
                'rate': float(rate.employer_rate),
                'amount': float(employer_amount),
                'capped_at': float(rate.salary_cap) if rate.salary_cap else None
            }
            
            deductions['total_employee_deduction'] += employee_amount
            deductions['total_employer_contribution'] += employer_amount
            
            deductions['rates_used'].append({
                'type': rate.contribution_type,
                'effective_from': rate.effective_from.isoformat(),
                'is_scheduled': rate.is_scheduled
            })
        
        deductions['total_employee_deduction'] = float(deductions['total_employee_deduction'])
        deductions['total_employer_contribution'] = float(deductions['total_employer_contribution'])
        deductions['net_salary'] = float(gross_salary) - deductions['total_employee_deduction']
        
        return deductions


# ============================================================================
# PART 6: SCHEDULED JOBS (CRON)
# ============================================================================

"""
Add these to your cron scheduler (e.g., Odoo ir.cron or Celery beat)
"""

def daily_compliance_check(db_connection):
    """
    Daily job to check for:
    1. Regulations due for review
    2. Upcoming rate changes
    3. Approaching deadlines
    """
    logger = logging.getLogger('kerjaflow.cron')
    
    # Check regulations due for review
    reg_service = RegulatoryMonitorService(db_connection)
    due_for_review = reg_service.check_due_for_review()
    
    for reg in due_for_review:
        logger.warning(
            f"COMPLIANCE CHECK DUE: {reg.country_code} - {reg.regulation_name}"
        )
        # Send notification to compliance team
        # notify_compliance_team(reg)
    
    # Generate rate change alerts
    alert_service = ComplianceAlertService(db_connection)
    alert_service.generate_rate_change_alerts(days_ahead=90)
    
    logger.info("Daily compliance check completed")


def weekly_regulatory_report(db_connection):
    """
    Weekly job to generate compliance status report for management.
    """
    reg_service = RegulatoryMonitorService(db_connection)
    pending = reg_service.get_pending_regulations()
    
    report = {
        'generated_at': datetime.now().isoformat(),
        'summary': {
            'monitoring': len([r for r in pending if r.status == RegulatoryStatus.MONITORING]),
            'enacted': len([r for r in pending if r.status == RegulatoryStatus.ENACTED]),
            'critical': len([r for r in pending if r.impact_level == 'critical']),
            'with_deadlines': len([r for r in pending if r.action_deadline])
        },
        'items': [{
            'country': r.country_code,
            'name': r.regulation_name,
            'status': r.status.value,
            'impact': r.impact_level,
            'days_until_action': r.days_until_action,
            'requires_migration': r.requires_data_migration,
            'requires_infra': r.requires_infra_change
        } for r in pending]
    }
    
    # Send report to management
    # send_weekly_report(report)
    return report


# ============================================================================
# PART 7: DATA MIGRATION READINESS (Cambodia LPDP)
# ============================================================================

class DataMigrationService:
    """
    Service to handle data migration when new data residency laws are enacted.
    Pre-built for Cambodia LPDP scenario.
    """
    
    def __init__(self, db_connection):
        self.db = db_connection
        self.logger = logging.getLogger('kerjaflow.migration')
    
    def estimate_migration_scope(self, country_code: str) -> Dict[str, Any]:
        """
        Estimate the scope of data migration if local storage becomes required.
        """
        tables_to_migrate = [
            'kf_employee', 'kf_user', 'kf_foreign_worker_detail',
            'kf_document', 'kf_payslip', 'kf_payslip_line',
            'kf_leave_balance', 'kf_leave_request', 
            'kf_notification', 'kf_audit_log'
        ]
        
        scope = {
            'country_code': country_code,
            'tables': {},
            'total_records': 0,
            'estimated_size_mb': 0
        }
        
        for table in tables_to_migrate:
            count_query = f"""
                SELECT COUNT(*) FROM {table} 
                WHERE country_code = %s OR 
                      employee_id IN (
                          SELECT id FROM kf_employee WHERE country_code = %s
                      )
            """
            try:
                count = self.db.execute(count_query, (country_code, country_code)).fetchone()[0]
                scope['tables'][table] = count
                scope['total_records'] += count
            except Exception as e:
                self.logger.warning(f"Could not count {table}: {e}")
                scope['tables'][table] = 'unknown'
        
        # Rough estimate: 1KB per record average
        scope['estimated_size_mb'] = scope['total_records'] / 1024
        
        return scope
    
    def generate_migration_plan(self, country_code: str) -> Dict[str, Any]:
        """
        Generate a migration plan for moving data to new regional VPS.
        """
        scope = self.estimate_migration_scope(country_code)
        
        return {
            'country_code': country_code,
            'scope': scope,
            'steps': [
                {
                    'step': 1,
                    'action': 'Provision new regional VPS',
                    'details': f'Provision Cambodia VPS (recommend: DPDC or GDMS, ~$15-20/mo)',
                    'estimated_time': '1-2 hours'
                },
                {
                    'step': 2,
                    'action': 'Configure WireGuard peer',
                    'details': 'Add new peer to VPN mesh (10.10.5.0/24 suggested)',
                    'estimated_time': '30 minutes'
                },
                {
                    'step': 3,
                    'action': 'Initialize PostgreSQL',
                    'details': 'Create regional database with KerjaFlow schema',
                    'estimated_time': '1 hour'
                },
                {
                    'step': 4,
                    'action': 'Migrate data',
                    'details': f'Export {scope["total_records"]} records from Vietnam VPS, '
                              f'import to Cambodia VPS (~{scope["estimated_size_mb"]:.1f} MB)',
                    'estimated_time': '2-4 hours'
                },
                {
                    'step': 5,
                    'action': 'Update database router',
                    'details': 'Change KH routing from Vietnam (10.10.4.1) to Cambodia (10.10.5.1)',
                    'estimated_time': '15 minutes'
                },
                {
                    'step': 6,
                    'action': 'Verify and cutover',
                    'details': 'Test all Cambodia operations, enable production traffic',
                    'estimated_time': '2 hours'
                }
            ],
            'total_estimated_time': '8-12 hours',
            'estimated_additional_cost': '$15-20/month',
            'rollback_plan': 'Revert router to Vietnam VPS, data remains on both'
        }


# ============================================================================
# PART 8: EXAMPLE USAGE
# ============================================================================

if __name__ == "__main__":
    """
    Example usage demonstrating the compliance monitoring system.
    """
    
    # Mock database connection for demonstration
    class MockDB:
        def execute(self, query, params=None):
            print(f"SQL: {query[:100]}...")
            return self
        def fetchone(self):
            return None
        def fetchall(self):
            return []
    
    db = MockDB()
    
    # Example 1: Get Cambodia pension rate for different dates
    print("\n=== Example 1: Automatic Rate Selection ===")
    rate_service = StatutoryRateService(db)
    
    # October 2025 - uses 2% rate
    print("Oct 2025 payslip: Would use 2% pension rate")
    
    # October 2027 - uses 4% rate (automatic!)
    print("Oct 2027 payslip: Would use 4% pension rate (auto-selected)")
    
    # Example 2: Check pending regulations
    print("\n=== Example 2: Regulatory Monitoring ===")
    reg_service = RegulatoryMonitorService(db)
    
    print("Monitoring: Cambodia LPDP (draft)")
    print("Action: Check every 14 days for enactment news")
    
    # Example 3: Generate migration plan
    print("\n=== Example 3: Migration Readiness ===")
    migration_service = DataMigrationService(db)
    
    print("If Cambodia LPDP requires local storage:")
    print("- Provision Cambodia VPS: $15-20/mo")
    print("- Migrate data from Vietnam VPS")
    print("- Update router: KH → Cambodia (10.10.5.1)")
    print("- Total additional cost: $15-20/mo")
    
    print("\n=== SQL Migration Script ===")
    print("Run the MIGRATION_SQL constant to create all tables")
