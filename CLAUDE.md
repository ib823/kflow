# CLAUDE.md - KerjaFlow v3.0 Development Instructions

## Project Overview

KerjaFlow is an enterprise workforce management platform for 9 ASEAN countries:
- 🇲🇾 Malaysia (Hub), 🇸🇬 Singapore, 🇮🇩 Indonesia, 🇹🇭 Thailand, 🇻🇳 Vietnam
- 🇵🇭 Philippines, 🇱🇦 Laos, 🇰🇭 Cambodia, 🇧🇳 Brunei

**Tech Stack:**
- Backend: Odoo 17 Community Edition (Python 3.10+)
- Mobile: Flutter 3.x (Dart)
- Database: PostgreSQL 15
- Cache: Redis 7
- Storage: MinIO (S3-compatible)
- Proxy: Nginx with rate limiting
- VPN: WireGuard mesh network

**Total Infrastructure Cost:** $109-114/month (100% open-source)

---

## Critical Architecture Rules

### 1. Hub-Spoke Data Model

**CENTRAL Tables (Malaysia Hub Only):**
```
kf_company              - Company master data
kf_department           - Department structure  
kf_job_position         - Job positions
kf_leave_type           - Leave type definitions
kf_public_holiday       - Public holiday calendar
kf_country_config       - Country configurations
kf_statutory_rate       - Statutory contribution rates
kf_regulatory_monitor   - Regulatory change tracking
kf_compliance_alert     - Compliance alerts
```

**REGIONAL Tables (Per-Country VPS):**
```
kf_employee             - Employee personal data
kf_user                 - User credentials and sessions
kf_foreign_worker_detail - Foreign worker permits
kf_document             - Document storage references
kf_payslip              - Payslip records
kf_payslip_line         - Payslip line items
kf_leave_balance        - Leave balances
kf_leave_request        - Leave requests
kf_notification         - User notifications
kf_audit_log            - Audit trail
```

### 2. Data Residency Routing (CRITICAL)

```python
# MANDATORY: Route employee data by country code
ROUTING_MAP = {
    'MY': '10.10.0.1',   # Malaysia Hub
    'SG': '10.10.1.1',   # Singapore VPS
    'ID': '10.10.2.1',   # Indonesia VPS - MANDATORY LOCAL STORAGE
    'TH': '10.10.3.1',   # Thailand VPS
    'LA': '10.10.3.1',   # Laos → Thailand (shared, no local requirement)
    'VN': '10.10.4.1',   # Vietnam VPS - MANDATORY LOCAL STORAGE
    'KH': '10.10.4.1',   # Cambodia → Vietnam (shared, monitor LPDP)
    'PH': '10.10.0.1',   # Philippines → Hub (no local requirement)
    'BN': '10.10.0.1',   # Brunei → Hub (no local requirement)
}

# Database router implementation
class KerjaFlowDatabaseRouter:
    def db_for_read(self, model, **hints):
        if model._name.startswith('kf.') and hasattr(model, 'country_code'):
            country = hints.get('country_code') or getattr(model, 'country_code', 'MY')
            return self._get_db_alias(country)
        return 'default'  # Central tables
    
    def _get_db_alias(self, country_code):
        mapping = {
            'MY': 'default', 'PH': 'default', 'BN': 'default',
            'SG': 'singapore', 'ID': 'indonesia',
            'TH': 'thailand', 'LA': 'thailand',
            'VN': 'vietnam', 'KH': 'vietnam',
        }
        return mapping.get(country_code, 'default')
```

### 3. Statutory Rate Selection (CRITICAL)

```python
# ALWAYS use payslip_date for rate lookup, NEVER use today's date
def get_statutory_rate(country_code, contribution_type, effective_date):
    """
    Automatically selects correct rate based on effective_date.
    
    Example: Cambodia NSSF Pension
    - get_rate('KH', 'NSSF_PENSION', date(2025, 6, 15)) → 2%
    - get_rate('KH', 'NSSF_PENSION', date(2027, 10, 15)) → 4% (auto!)
    """
    return self.env['kf.statutory.rate'].search([
        ('country_code', '=', country_code),
        ('contribution_type', '=', contribution_type),
        ('effective_from', '<=', effective_date),
        '|', ('effective_to', '=', False),
             ('effective_to', '>=', effective_date),
    ], order='effective_from desc', limit=1)
```

---

## Statutory Rates Reference

| Country | System | Employee % | Employer % | Total | Salary Cap |
|---------|--------|------------|------------|-------|------------|
| 🇲🇾 MY | EPF | 11.0 | 12.0-13.0 | 23-24% | No cap |
| 🇲🇾 MY | SOCSO | 0.5 | 1.25 | 1.75% | RM 5,000 |
| 🇲🇾 MY | EIS | 0.2 | 0.2 | 0.4% | RM 5,000 |
| 🇸🇬 SG | CPF | 20.0 | 17.0 | 37% | SGD 6,800 |
| 🇮🇩 ID | BPJS TK | 2.0 | 3.7 | 5.7% | Various |
| 🇮🇩 ID | BPJS Kes | 1.0 | 4.0 | 5% | IDR 12M |
| 🇹🇭 TH | SSF | 5.0 | 5.0 | 10% | THB 15,000 |
| 🇻🇳 VN | SI | 8.0 | 17.5 | 25.5% | 20x min wage |
| 🇻🇳 VN | HI | 1.5 | 3.0 | 4.5% | 20x min wage |
| 🇻🇳 VN | UI | 1.0 | 1.0 | 2% | 20x min wage |
| 🇵🇭 PH | SSS | 4.5 | 9.5 | 14% | PHP 30,000 |
| 🇵🇭 PH | PhilHealth | 2.5 | 2.5 | 5% | PHP 100,000 |
| 🇵🇭 PH | HDMF | 2.0 | 2.0 | 4% | PHP 5,000 |
| 🇱🇦 LA | LSSO | 4.5 | 5.0 | 9.5% | LAK 4.5M |
| 🇰🇭 KH | NSSF Risk | 0.0 | 0.8 | 0.8% | KHR 1.2M |
| 🇰🇭 KH | NSSF Health | 0.0 | 2.6 | 2.6% | KHR 1.2M |
| 🇰🇭 KH | NSSF Pension | 2.0→4.0* | 2.0→4.0* | 4→8%* | KHR 1.2M |
| 🇧🇳 BN | SPK | 8.5 | 8.5 | 17% | No cap |

*Cambodia NSSF Pension increases to 4% each on October 1, 2027 (pre-configured in database)

---

## Coding Standards

### Python (Odoo Backend)

```python
# File header
# -*- coding: utf-8 -*-
"""
KerjaFlow - [Module Description]
"""

from odoo import models, fields, api, _
from odoo.exceptions import UserError, ValidationError
from decimal import Decimal
from datetime import date, datetime
from typing import Dict, List, Optional
import logging

_logger = logging.getLogger(__name__)


class KfEmployee(models.Model):
    """Employee master data"""
    _name = 'kf.employee'
    _description = 'KerjaFlow Employee'
    _inherit = ['mail.thread', 'mail.activity.mixin']
    
    # ALWAYS include country_code for data routing
    country_id = fields.Many2one('kf.country.config', required=True, tracking=True)
    country_code = fields.Char(related='country_id.country_code', store=True, index=True)
    
    # Use Decimal for money fields
    basic_salary = fields.Monetary(currency_field='currency_id')
    
    # Type hints in methods
    def calculate_statutory(self, payslip_date: date) -> Dict[str, Decimal]:
        """Calculate statutory deductions for given payslip date"""
        self.ensure_one()
        # Implementation
        pass
    
    # Validation with user-friendly errors
    @api.constrains('country_code', 'ic_number')
    def _check_ic_format(self):
        for record in self:
            if record.country_code == 'MY' and record.ic_number:
                if not re.match(r'^\d{6}-\d{2}-\d{4}$', record.ic_number):
                    raise ValidationError(_('Malaysian IC must be in format XXXXXX-XX-XXXX'))
    
    # Audit logging for sensitive operations
    def write(self, vals):
        if any(f in vals for f in ['basic_salary', 'bank_account', 'ic_number']):
            _logger.info('Sensitive field updated', extra={
                'employee_id': self.id,
                'user_id': self.env.uid,
                'fields': [f for f in vals if f in ['basic_salary', 'bank_account', 'ic_number']],
            })
        return super().write(vals)
```

### Flutter (Mobile App)

```dart
// File: lib/models/employee_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee_model.freezed.dart';
part 'employee_model.g.dart';

@freezed
class Employee with _$Employee {
  const factory Employee({
    required int id,
    required String employeeCode,
    required String fullName,
    required String countryCode,
    String? icNumber,
    @Default(0) double basicSalary,
  }) = _Employee;

  factory Employee.fromJson(Map<String, dynamic> json) => 
      _$EmployeeFromJson(json);
}


// File: lib/services/employee_service.dart
import 'package:dartz/dartz.dart';

class EmployeeService {
  final ApiClient _api;
  
  EmployeeService(this._api);
  
  Future<Either<Failure, Employee>> getEmployee(int id) async {
    try {
      final response = await _api.get('/api/v1/employees/$id');
      return Right(Employee.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    }
  }
}


// File: lib/screens/employee/employee_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmployeeDetailScreen extends ConsumerWidget {
  final int employeeId;
  
  const EmployeeDetailScreen({required this.employeeId, super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeAsync = ref.watch(employeeProvider(employeeId));
    
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.employeeDetails)),
      body: employeeAsync.when(
        data: (employee) => _buildContent(context, employee),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorWidget(error: error),
      ),
    );
  }
}
```

### SQL (Migrations)

```sql
-- File: database/migrations/003_statutory_rates.sql
-- Migration: Add statutory rates for all 9 countries

BEGIN;

-- Create table with proper constraints
CREATE TABLE IF NOT EXISTS kf_statutory_rate (
    id SERIAL PRIMARY KEY,
    country_code VARCHAR(2) NOT NULL REFERENCES kf_country_config(country_code),
    contribution_type VARCHAR(50) NOT NULL,
    system_name VARCHAR(100),
    
    employee_rate DECIMAL(5,2) NOT NULL DEFAULT 0,
    employer_rate DECIMAL(5,2) NOT NULL DEFAULT 0,
    salary_cap DECIMAL(15,2),
    currency_code VARCHAR(3) NOT NULL,
    
    -- Date-based activation (CRITICAL for Cambodia NSSF Oct 2027)
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_scheduled BOOLEAN DEFAULT FALSE,
    
    regulatory_reference VARCHAR(255),
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT uk_statutory_rate UNIQUE (country_code, contribution_type, effective_from)
);

-- Index for efficient rate lookups
CREATE INDEX idx_statutory_rate_lookup 
ON kf_statutory_rate(country_code, contribution_type, effective_from DESC);

-- Function for automatic rate selection
CREATE OR REPLACE FUNCTION get_statutory_rate(
    p_country_code VARCHAR(2),
    p_contribution_type VARCHAR(50),
    p_effective_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    employee_rate DECIMAL(5,2),
    employer_rate DECIMAL(5,2),
    salary_cap DECIMAL(15,2),
    currency_code VARCHAR(3)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        sr.employee_rate,
        sr.employer_rate,
        sr.salary_cap,
        sr.currency_code
    FROM kf_statutory_rate sr
    WHERE sr.country_code = p_country_code
      AND sr.contribution_type = p_contribution_type
      AND sr.effective_from <= p_effective_date
      AND (sr.effective_to IS NULL OR sr.effective_to >= p_effective_date)
    ORDER BY sr.effective_from DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

COMMIT;
```

---

## Localization (11 Languages)

```yaml
# Supported locales with scripts
locales:
  en:       # English (default)
    script: Latin
    countries: [ALL]
    
  ms_MY:    # Bahasa Malaysia
    script: Latin
    countries: [MY, BN]
    
  id_ID:    # Bahasa Indonesia
    script: Latin
    countries: [ID]
    
  zh_CN:    # Simplified Chinese
    script: Han Simplified
    countries: [SG, MY]
    
  ta_IN:    # Tamil
    script: Tamil
    countries: [MY, SG]
    
  th_TH:    # Thai
    script: Thai
    countries: [TH]
    font: NotoSansThai
    
  vi_VN:    # Vietnamese
    script: Latin (diacritics)
    countries: [VN]
    
  tl_PH:    # Filipino/Tagalog
    script: Latin
    countries: [PH]
    
  lo_LA:    # Lao
    script: Lao
    countries: [LA]
    font: NotoSansLao
    unicode_range: U+0E80-U+0EFF
    
  km_KH:    # Khmer
    script: Khmer
    countries: [KH]
    font: NotoSansKhmer
    unicode_range: U+1780-U+17FF
    
  bn_BD:    # Bengali
    script: Bengali
    countries: [migrant workers]
    font: NotoSansBengali
```

### Translation Keys Pattern
```dart
// Use context.l10n for translations
Text(context.l10n.employeeList)        // "Employee List"
Text(context.l10n.leaveBalance)        // "Leave Balance"
Text(context.l10n.statutoryDeduction)  // "Statutory Deduction"

// With parameters
Text(context.l10n.welcomeUser(user.name))  // "Welcome, {name}"
Text(context.l10n.daysRemaining(5))        // "{count} days remaining"
```

---

## Security Requirements

### Authentication Flow
```
1. Mobile App → POST /api/v1/auth/login {email, password}
2. Server validates credentials
3. Server returns {access_token (15min), refresh_token (7day)}
4. Mobile stores tokens in secure storage (flutter_secure_storage)
5. All API calls include: Authorization: Bearer {access_token}
6. On 401, use refresh_token to get new access_token
7. On refresh failure, redirect to login
```

### PIN Authentication (Mobile)
```dart
// 6-digit PIN with lockout
class PinService {
  static const maxAttempts = 3;
  static const lockoutDuration = Duration(minutes: 15);
  
  Future<bool> verifyPin(String pin) async {
    if (await isLockedOut()) {
      throw PinLockoutException(remainingTime: await getLockoutRemaining());
    }
    
    final isValid = await _validatePin(pin);
    if (!isValid) {
      await _incrementFailedAttempts();
      if (await getFailedAttempts() >= maxAttempts) {
        await _setLockout();
      }
    } else {
      await _resetFailedAttempts();
    }
    return isValid;
  }
}
```

### Field-Level Encryption
```python
# Encrypt sensitive fields at rest
ENCRYPTED_FIELDS = [
    'ic_number',           # National ID
    'passport_number',     # Passport
    'bank_account_number', # Bank account
    'basic_salary',        # Salary (optional)
]

class KfEmployee(models.Model):
    _name = 'kf.employee'
    
    # Use encrypted field type
    ic_number = fields.Char(encrypted=True)
    bank_account_number = fields.Char(encrypted=True)
```

---

## API Response Format

```json
// Success response
{
  "success": true,
  "data": {
    "id": 123,
    "employee_code": "EMP001",
    "full_name": "Ahmad bin Abdullah",
    "country_code": "MY"
  },
  "meta": {
    "timestamp": "2025-12-26T10:30:00Z",
    "request_id": "req_abc123"
  }
}

// List response with pagination
{
  "success": true,
  "data": [...],
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 150,
    "total_pages": 8
  }
}

// Error response
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid country code",
    "details": {
      "field": "country_code",
      "value": "XX",
      "allowed": ["MY", "SG", "ID", "TH", "VN", "PH", "LA", "KH", "BN"]
    }
  },
  "meta": {
    "timestamp": "2025-12-26T10:30:00Z",
    "request_id": "req_abc123"
  }
}
```

---

## File Structure

```
kerjaflow/
├── CLAUDE.md                    # This file
├── README.md
├── .gitignore
│
├── docs/
│   ├── architecture/            # Architecture docs
│   ├── api/                     # API specs, OpenAPI
│   ├── specs/                   # Feature specifications
│   └── compliance/              # Compliance guides
│
├── backend/
│   ├── odoo.conf
│   ├── requirements.txt
│   └── addons/kerjaflow/
│       ├── __init__.py
│       ├── __manifest__.py
│       ├── models/
│       │   ├── __init__.py
│       │   ├── employee.py
│       │   ├── payslip.py
│       │   ├── statutory_rate.py
│       │   ├── compliance.py
│       │   └── country_config.py
│       ├── views/
│       ├── security/
│       ├── data/
│       └── controllers/
│
├── mobile/
│   ├── pubspec.yaml
│   └── lib/
│       ├── main.dart
│       ├── config/
│       ├── models/
│       ├── services/
│       ├── providers/
│       ├── screens/
│       ├── widgets/
│       └── l10n/
│
├── infrastructure/
│   ├── docker/
│   ├── wireguard/
│   ├── nginx/
│   └── scripts/
│
├── database/
│   ├── migrations/
│   ├── seeds/
│   └── router/
│
└── tests/
```

---

## Common Development Tasks

### Create New Odoo Model
```bash
claude "Create a new Odoo model kf.leave.request with fields for employee, leave_type, start_date, end_date, status, and approval workflow"
```

### Add API Endpoint
```bash
claude "Add REST API endpoint for leave requests with list, create, approve, and reject operations"
```

### Create Flutter Screen
```bash
claude "Create Flutter screen for leave request list with filtering by status and date range"
```

### Add New Language
```bash
claude "Add Khmer (km_KH) localization to the Flutter app with translations for all existing strings"
```

### Generate Migration
```bash
claude "Generate SQL migration to add audit logging for employee salary changes"
```

---

## Compliance Monitoring

### Cambodia LPDP (Draft Law)
- **Status:** Monitoring (check every 14 days)
- **If enacted with data residency:** Provision Cambodia VPS, migrate data from Vietnam
- **Code location:** `database/migrations/004_compliance_monitoring.sql`

### Cambodia NSSF Rate Change (Oct 2027)
- **Status:** Pre-configured, automatic
- **Action:** None required - system auto-selects 4% rate for Oct 2027+ payslips
- **Verification:** `SELECT * FROM get_statutory_rate('KH', 'NSSF_PENSION', '2027-10-15');`

### Brunei PDPO (Jan 2026 deadline)
- **Status:** Enacted, grace period until Jan 2026
- **Action:** Appoint DPO with CIPM certification before Dec 2025

---

## Important Reminders

1. ✅ **ALWAYS** include `country_code` in employee-related queries
2. ✅ **ALWAYS** use `payslip_date` for statutory rate lookup
3. ✅ **ALWAYS** use Decimal for money calculations
4. ✅ **ALWAYS** validate input before database operations
5. ✅ **ALWAYS** log sensitive data access
6. ❌ **NEVER** hardcode statutory rates
7. ❌ **NEVER** store passwords in plain text
8. ❌ **NEVER** expose internal errors to users
9. ❌ **NEVER** query Indonesian/Vietnamese data from wrong VPS
