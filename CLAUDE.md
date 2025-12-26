# CLAUDE.md - KerjaFlow v3.0 Development Instructions

> **Last Updated:** December 2025
> **Completeness:** Phase 1-3 Complete (100%), Phase 4-6 In Progress
> **Total Infrastructure Cost:** $109-114/month (100% open-source)

---

## PROJECT OVERVIEW

KerjaFlow is an enterprise workforce management platform for **9 ASEAN countries** targeting blue-collar workers, migrant workers (Bangladesh, Nepal), and manufacturing professionals.

### Countries & Data Routing

| Country | Flag | VPS Location | VPN IP | DB Alias | Monthly Cost |
|---------|------|--------------|--------|----------|--------------|
| Malaysia | MY | **Hub** (Shinjiru) | 10.10.0.1 | `default` | $59 |
| Singapore | SG | Singapore | 10.10.1.1 | `singapore` | $8 |
| Indonesia | ID | Indonesia | 10.10.2.1 | `indonesia` | $15 |
| Thailand | TH | Thailand | 10.10.3.1 | `thailand` | $12 |
| Laos | LA | -> Thailand | 10.10.3.1 | `thailand` | $0 |
| Vietnam | VN | Vietnam | 10.10.4.1 | `vietnam` | $15 |
| Cambodia | KH | -> Vietnam | 10.10.4.1 | `vietnam` | $0 |
| Philippines | PH | -> Hub | 10.10.0.1 | `default` | $0 |
| Brunei | BN | -> Hub | 10.10.0.1 | `default` | $0 |

**MANDATORY LOCAL STORAGE:** Indonesia (PP 71/2019), Vietnam (Cybersecurity Law)
**MONITOR:** Cambodia LPDP draft law (may require local VPS if enacted)

### Tech Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Backend | Odoo Community | 17.0 |
| Mobile | Flutter | 3.x |
| Database | PostgreSQL | 15 |
| Cache | Redis | 7 |
| Storage | MinIO | Latest |
| Proxy | Nginx | 1.25 |
| VPN | WireGuard | Latest |
| Language | Python | 3.10+ |

---

## IMPLEMENTATION STATUS

### PHASE 1: Database & Core Models - COMPLETE

**Location:** `backend/odoo/addons/kerjaflow/models/`

| Model | File | Status |
|-------|------|--------|
| kf.company | `kf_company.py` | Done |
| kf.department | `kf_department.py` | Done |
| kf.job.position | `kf_job_position.py` | Done |
| kf.country.config | `kf_country_config.py` | Done |
| kf.statutory.rate | `kf_statutory_rate.py` | Done |
| kf.employee | `kf_employee.py` | Done - 50+ fields, IC validation for 9 countries |
| kf.user | `kf_user.py` | Done |
| kf.foreign.worker.detail | `kf_foreign_worker_detail.py` | Done |
| kf.document | `kf_document.py` | Done |
| kf.leave.type | `kf_leave_type.py` | Done |
| kf.leave.balance | `kf_leave_balance.py` | Done |
| kf.leave.request | `kf_leave_request.py` | Done - State machine |
| kf.public.holiday | `kf_public_holiday.py` | Done |
| kf.payslip | `kf_payslip.py` | Done |
| kf.payslip.line | `kf_payslip_line.py` | Done |
| kf.notification | `kf_notification.py` | Done |
| kf.audit.log | `kf_audit_log.py` | Done |
| kf.regulatory.monitor | `compliance.py` | Done - Cambodia LPDP tracking |
| kf.compliance.alert | `compliance.py` | Done |

**Total: 19 models**

### PHASE 2: Authentication & Security - COMPLETE

**Location:** `backend/odoo/addons/kerjaflow/`

| Component | Location | Status |
|-----------|----------|--------|
| JWT tokens | `controllers/auth_controller.py` | Done |
| Login/Logout/Refresh | `controllers/auth_controller.py` | Done |
| PIN setup/verify | `controllers/auth_controller.py` | Done - 6-digit, bcrypt |
| Lockout (5 attempts) | `controllers/auth_controller.py` | Done - 15-min lockout |
| Single device session | `controllers/auth_controller.py` | Done |
| JWT config | `config.py` | Done |
| RS256 service | `auth_service.py` (root) | Done |

### PHASE 3: API Development - COMPLETE (32/32 Endpoints)

**Location:** `backend/odoo/addons/kerjaflow/controllers/`

| Controller | File | Endpoints | Status |
|------------|------|-----------|--------|
| Base | `main.py` | - | Done - API prefix, response helpers |
| Auth | `auth_controller.py` | 6 | Done |
| Profile | `profile_controller.py` | 4 | Done |
| Payslip | `payslip_controller.py` | 3 | Done |
| Leave | `leave_controller.py` | 8 | Done |
| Approval | `approval_controller.py` | 3 | Done |
| Notification | `notification_controller.py` | 4 | Done |
| Document | `document_controller.py` | 4 | Done |

**Total: 32/32 endpoints implemented**

#### Endpoint Details

**Authentication (6)**
- `POST /api/v1/auth/login` - User login with credentials
- `POST /api/v1/auth/refresh` - Refresh access token
- `POST /api/v1/auth/logout` - Invalidate session
- `POST /api/v1/auth/pin/setup` - Set up 6-digit PIN
- `POST /api/v1/auth/pin/verify` - Verify PIN for sensitive ops
- `POST /api/v1/auth/password/change` - Change password

**Profile & Dashboard (4)**
- `GET /api/v1/profile` - Get employee profile
- `PATCH /api/v1/profile` - Update profile fields
- `POST /api/v1/profile/photo` - Upload profile photo
- `GET /api/v1/dashboard` - Aggregated home screen data

**Payslips (3)**
- `GET /api/v1/payslips` - List payslips with pagination
- `GET /api/v1/payslips/{id}` - Payslip detail (PIN required)
- `GET /api/v1/payslips/{id}/pdf` - Download PDF (PIN required)

**Leave Management (8)**
- `GET /api/v1/leave/balances` - Get leave balances
- `GET /api/v1/leave/types` - Get available leave types
- `GET /api/v1/leave/requests` - List leave requests
- `POST /api/v1/leave/requests` - Submit new request
- `GET /api/v1/leave/requests/{id}` - Request detail
- `POST /api/v1/leave/requests/{id}/cancel` - Cancel request
- `GET /api/v1/public-holidays` - Get public holidays

**Approvals (3)**
- `GET /api/v1/approvals/pending` - Pending approvals list
- `POST /api/v1/approvals/{id}/approve` - Approve request
- `POST /api/v1/approvals/{id}/reject` - Reject with reason

**Notifications (4)**
- `GET /api/v1/notifications` - List with cursor pagination
- `GET /api/v1/notifications/unread-count` - Badge count
- `POST /api/v1/notifications/{id}/read` - Mark as read
- `POST /api/v1/notifications/read-all` - Mark all read

**Documents (4)**
- `GET /api/v1/documents` - List documents
- `POST /api/v1/documents` - Upload document
- `GET /api/v1/documents/{id}` - Document detail
- `GET /api/v1/documents/{id}/download` - Download file

### PHASE 4: Mobile App - IN PROGRESS

**Location:** `mobile/`

| Component | Status |
|-----------|--------|
| main.dart | Done - 11 locales, Riverpod |
| auth_service.dart | Done - JWT, secure storage |
| Screens | Not started |
| Offline cache | Not started |

### PHASE 5-6: Testing & Deployment - PENDING

---

## DATA ARCHITECTURE

### CENTRAL Tables (Malaysia Hub ONLY)

```
kf_company              kf_department           kf_job_position
kf_leave_type           kf_public_holiday       kf_country_config
kf_statutory_rate       kf_regulatory_monitor   kf_compliance_alert
```

### REGIONAL Tables (Per-Country VPS)

```
kf_employee             kf_user                 kf_foreign_worker_detail
kf_document             kf_payslip              kf_payslip_line
kf_leave_balance        kf_leave_request        kf_notification
kf_audit_log
```

### Routing Logic

```python
# ALWAYS route by country_code
COUNTRY_TO_DB = {
    'MY': 'default', 'PH': 'default', 'BN': 'default',
    'SG': 'singapore',
    'ID': 'indonesia',  # MANDATORY LOCAL
    'TH': 'thailand', 'LA': 'thailand',
    'VN': 'vietnam',    # MANDATORY LOCAL
    'KH': 'vietnam',    # Monitor LPDP
}
```

---

## STATUTORY RATES

| Country | System | EE% | ER% | Cap | Notes |
|---------|--------|-----|-----|-----|-------|
| MY | EPF | 11.0 | 12-13 | None | Age-based employer |
| MY | SOCSO | 0.5 | 1.25 | RM 5,000 | |
| MY | EIS | 0.2 | 0.2 | RM 5,000 | |
| SG | CPF | 20.0 | 17.0 | SGD 6,800 | Age-tiered |
| ID | BPJS TK | 2.0 | 3.7 | Various | |
| ID | BPJS Kes | 1.0 | 4.0 | IDR 12M | |
| TH | SSF | 5.0 | 5.0 | THB 15,000 | |
| VN | SI | 8.0 | 17.5 | 20x min | |
| VN | HI | 1.5 | 3.0 | 20x min | |
| VN | UI | 1.0 | 1.0 | 20x min | |
| PH | SSS | 4.5 | 9.5 | PHP 30,000 | |
| PH | PhilHealth | 2.5 | 2.5 | PHP 100,000 | |
| PH | HDMF | 2.0 | 2.0 | PHP 5,000 | |
| LA | LSSO | 4.5 | 5.0 | LAK 4.5M | |
| KH | NSSF Risk | 0.0 | 0.8 | KHR 1.2M | |
| KH | NSSF Health | 0.0 | 2.6 | KHR 1.2M | |
| KH | NSSF Pension | **2->4** | **2->4** | KHR 1.2M | **Oct 2027 auto-increase** |
| BN | SPK | 8.5 | 8.5 | None | TAP+SCP combined |

### Cambodia Oct 2027 Rate Change

Pre-configured in `004_compliance_monitoring.sql`:
- Current: 2% + 2% (until Sep 2027)
- Future: 4% + 4% (from Oct 2027) - **AUTO-ACTIVATES**
- Verification: `SELECT * FROM get_statutory_rate('KH', 'NSSF_PENSION', '2027-10-15');`

---

## CODING STANDARDS

### Python (Odoo)

```python
# -*- coding: utf-8 -*-
from odoo import models, fields, api, _
from odoo.exceptions import ValidationError
from decimal import Decimal
from datetime import date
from typing import Dict, List, Optional
import logging

_logger = logging.getLogger(__name__)

class KfEmployee(models.Model):
    _name = 'kf.employee'
    _description = 'KerjaFlow Employee'

    # ALWAYS include country_code (CRITICAL)
    country_id = fields.Many2one('kf.country.config', required=True)
    country_code = fields.Char(related='country_id.country_code', store=True, index=True)

    # Money = Decimal, NOT float
    basic_salary = fields.Monetary(currency_field='currency_id')

    # ALWAYS use payslip_date for rate lookup
    def get_statutory_rate(self, contribution_type, effective_date):
        """NEVER use date.today() - use payslip_date"""
        return self.env['kf.statutory.rate'].search([
            ('country_code', '=', self.country_code),
            ('contribution_type', '=', contribution_type),
            ('effective_from', '<=', effective_date),
            '|', ('effective_to', '=', False),
                 ('effective_to', '>=', effective_date),
        ], order='effective_from desc', limit=1)
```

### Flutter (Dart)

```dart
// Use freezed for models
@freezed
class Employee with _$Employee {
  const factory Employee({
    required int id,
    required String countryCode,
    required String fullName,
  }) = _Employee;
}

// Use Riverpod for state
final employeeProvider = FutureProvider.family<Employee, int>((ref, id) async {
  final api = ref.watch(apiServiceProvider);
  return api.getEmployee(id);
});

// Secure storage for tokens
final storage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);
```

### SQL

```sql
-- ALWAYS include country_code
SELECT * FROM kf_employee WHERE country_code = 'KH' AND company_id = %s;

-- NEVER use string concatenation
cursor.execute("SELECT * FROM kf_employee WHERE id = %s", (employee_id,))

-- Date-based rate lookup
SELECT * FROM get_statutory_rate('KH', 'NSSF_PENSION', '2027-10-15');
```

---

## IC FORMAT VALIDATION

| Country | Pattern | Example |
|---------|---------|---------|
| MY | `^\d{6}-\d{2}-\d{4}$` | 900101-01-1234 |
| SG | `^[STFGM]\d{7}[A-Z]$` | S1234567D |
| ID | `^\d{16}$` | 3201011234567890 |
| TH | `^\d{13}$` | 1234567890123 |
| VN | `^\d{9}\|\d{12}$` | 012345678 or 012345678901 |
| PH | `^\d{4}-\d{7}-\d{1}$` | 1234-5678901-2 |
| BN | `^\d{2}-\d{6}$` | 12-345678 |
| LA | `^.{6,20}$` | Variable |
| KH | `^.{6,20}$` | Variable |

---

## LOCALIZATION (11 Languages)

| Code | Language | Script | Countries |
|------|----------|--------|-----------|
| en | English | Latin | All |
| ms_MY | Bahasa Malaysia | Latin | MY, BN |
| id_ID | Bahasa Indonesia | Latin | ID |
| zh_CN | Chinese Simplified | Han | SG, MY |
| ta_IN | Tamil | Tamil | MY, SG |
| th_TH | Thai | Thai | TH |
| vi_VN | Vietnamese | Latin+diacritics | VN |
| tl_PH | Filipino | Latin | PH |
| lo_LA | Lao | **Lao script** | LA |
| km_KH | Khmer | **Khmer script** | KH |
| bn_BD | Bengali | Bengali | Migrant workers |

**Required fonts:** NotoSansLao, NotoSansKhmer, NotoSansThai, NotoSansBengali

---

## SECURITY REQUIREMENTS

### Authentication

| Item | Specification |
|------|---------------|
| Algorithm | RS256 (RSA + SHA256) |
| Access Token | 24 hours |
| Refresh Token | 7 days |
| PIN | 6 digits, bcrypt cost 10 |
| Lockout | 5 failures -> 15 min |
| Sessions | Single device only |

### Rate Limiting (Nginx)

| Endpoint | Limit |
|----------|-------|
| `/api/v1/auth/*` | 10/minute |
| `/api/v1/payslips/*` | 30/minute |
| General API | 60/minute |

### Field Encryption

Encrypt at rest: `ic_no`, `passport_no`, `bank_account_no`, `basic_salary`

---

## FILE STRUCTURE

```
kerjaflow/
├── CLAUDE.md                              <- THIS FILE
├── backend/
│   └── odoo/
│       └── addons/
│           └── kerjaflow/
│               ├── __init__.py
│               ├── __manifest__.py
│               ├── config.py              <- JWT configuration
│               ├── models/
│               │   ├── __init__.py
│               │   ├── kf_company.py
│               │   ├── kf_department.py
│               │   ├── kf_employee.py     <- 50+ fields, IC validation
│               │   ├── kf_user.py
│               │   ├── kf_statutory_rate.py
│               │   ├── kf_country_config.py
│               │   ├── kf_payslip.py
│               │   ├── kf_payslip_line.py
│               │   ├── kf_leave_type.py
│               │   ├── kf_leave_balance.py
│               │   ├── kf_leave_request.py
│               │   ├── kf_public_holiday.py
│               │   ├── kf_document.py
│               │   ├── kf_foreign_worker_detail.py
│               │   ├── kf_notification.py
│               │   ├── kf_audit_log.py
│               │   └── compliance.py      <- LPDP + rate monitoring
│               ├── controllers/
│               │   ├── __init__.py
│               │   ├── main.py            <- Base controller
│               │   ├── auth_controller.py
│               │   ├── profile_controller.py
│               │   ├── payslip_controller.py
│               │   ├── leave_controller.py
│               │   ├── approval_controller.py
│               │   ├── notification_controller.py
│               │   └── document_controller.py
│               ├── security/
│               │   ├── ir.model.access.csv
│               │   ├── kerjaflow_groups.xml
│               │   └── kerjaflow_security.xml
│               ├── data/
│               │   ├── kf_leave_type_data.xml
│               │   └── kf_public_holiday_data.xml
│               └── tests/
│                   ├── __init__.py
│                   ├── common.py
│                   ├── test_employee.py
│                   ├── test_leave.py
│                   ├── test_payslip.py
│                   └── integration/
│                       ├── test_auth_api.py
│                       ├── test_leave_api.py
│                       └── test_payslip_api.py
├── mobile/
│   └── lib/
│       ├── main.dart                      <- 11 locales
│       └── services/
│           └── auth_service.dart          <- JWT + PIN
├── infrastructure/
│   ├── docker/
│   │   ├── docker-compose.hub.yml
│   │   └── docker-compose.regional.yml
│   ├── nginx/nginx.conf
│   └── wireguard/wg0.conf.hub
├── database/
│   └── migrations/
│       └── 004_compliance_monitoring.sql
└── docs/
    ├── specs/                             <- 10 specification docs
    └── architecture/
```

---

## CRITICAL RULES

### ALWAYS

1. Include `country_code` in employee queries
2. Use `payslip_date` for statutory rate lookup (NEVER `date.today()`)
3. Use `Decimal` for money calculations
4. Validate input before database operations
5. Log sensitive data access (audit trail)
6. Route ID/VN data to local VPS

### NEVER

1. Hardcode statutory rates
2. Store passwords in plain text
3. Use `float` for money
4. Query ID/VN employee data from wrong VPS
5. Skip IC format validation
6. Use `date.today()` in payroll calculations

---

## COMMON TASKS

### Create API Endpoint

```bash
# Reference: docs/api/kerjaflow_openapi.yaml
# Pattern: /api/v1/{resource}

# Example: Leave request list
GET /api/v1/leave/requests
Authorization: Bearer {access_token}
Response: { success: true, data: [...], meta: { page, per_page, total } }
```

### Add New Country

1. Add to `kf_country_config` (country_code, vps_ip, db_alias)
2. Add IC pattern to `kf_employee.IC_FORMAT_PATTERNS`
3. Add statutory rates to `kf_statutory_rate`
4. Add to `COUNTRY_TO_DB` in router
5. Add locale to Flutter `supportedLocales`

### Calculate Payroll

```python
# CRITICAL: Use payslip date, not today
def calculate_deductions(employee, payslip_date):
    rates = employee.env['kf.statutory.rate'].search([
        ('country_code', '=', employee.country_code),
        ('effective_from', '<=', payslip_date),
        '|', ('effective_to', '=', False),
             ('effective_to', '>=', payslip_date),
    ])
    # Oct 2027 Cambodia payslip auto-uses 4% rate
```

---

## COMPLIANCE MONITORING

### Cambodia LPDP (Draft)

- **Status:** Monitoring (14-day review cycle)
- **If enacted with data residency:** Provision Cambodia VPS ($15-20/mo), migrate from Vietnam
- **Location:** `kf_regulatory_monitor` table

### Cambodia NSSF Oct 2027

- **Status:** Pre-configured, automatic
- **Action:** None - system auto-selects 4% for Oct 2027+ payslips
- **Verify:** `SELECT * FROM get_statutory_rate('KH', 'NSSF_PENSION', '2027-10-15');`

### Brunei PDPO

- **Status:** Enacted, grace period ends Jan 2026
- **Action:** Appoint DPO with CIPM certification by Dec 2025

---

## REFERENCE DOCUMENTS

| Document | Location |
|----------|----------|
| Data Foundation | `docs/specs/01_Data_Foundation.md` |
| API Contract | `docs/specs/02_API_Contract.md` |
| OpenAPI Spec | `docs/specs/03_OpenAPI.yaml` |
| Business Logic | `docs/specs/04_Business_Logic.md` |
| Quality Spec | `docs/specs/05_Quality_Specification.md` |
| Security Hardening | `docs/specs/06_Security_Hardening.md` |
| Operations Runbook | `docs/specs/07_Operations_Runbook.md` |
| Technical Addendum | `docs/specs/08_Technical_Addendum.md` |
| Mobile UX | `docs/specs/09_Mobile_UX_Specification.md` |
| Implementation Plan | `docs/specs/10_Implementation_Plan.md` |
| Architecture v3 | `docs/architecture/KerjaFlow_Budget_Enterprise_Architecture_v3.docx` |

---

## NEXT STEPS

**Current Position:** End of Phase 3, Starting Phase 4

**Phase 4 Tasks:**
1. Build Flutter screens for all 32 API endpoints
2. Implement offline-first caching with Hive/Isar
3. Add biometric authentication
4. Integrate FCM/HMS push notifications

**Phase 5 Tasks:**
1. Complete integration test coverage
2. Load testing with k6
3. Security audit

**Command to start Phase 4:**
```bash
claude "Create Flutter login screen with email/password fields, connecting to POST /api/v1/auth/login endpoint"
```

---

*KerjaFlow v3.0 - Built for Malaysian regulated industries*
*9 ASEAN countries | 11 languages | $109-114/month infrastructure*
