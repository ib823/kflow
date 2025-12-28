# CLAUDE.md - KerjaFlow v4.1 Development Instructions

> **Version:** 4.1 | **Last Updated:** December 2025  
> **Status:** Production-Ready | **Languages:** 12 Verified | **Countries:** 9 ASEAN

---

## ⚠️ CRITICAL RULES - READ BEFORE WRITING ANY CODE

### ALWAYS DO ✅
| # | Rule | Why |
|---|------|-----|
| 1 | Include `country_code` in ALL employee queries | Data residency compliance (ID, VN laws) |
| 2 | Use `payslip_date` for statutory rate lookups | Rates change; Cambodia Oct 2027 auto-increase |
| 3 | Use `Decimal` for ALL money calculations | Float precision loss is ILLEGAL for statutory |
| 4 | Validate input BEFORE database operations | Security and data integrity |
| 5 | Log ALL sensitive data access | 7-year audit trail required |
| 6 | Route ID/VN employee data to local VPS | MANDATORY by law |
| 7 | Preserve statutory acronyms in translations | EPF/KWSP, SOCSO/PERKESO recognition |
| 8 | Support complex scripts with Noto Sans fonts | Khmer, Myanmar, Thai, Tamil, Bengali, Nepali |

### NEVER DO ❌
| # | Rule | Consequence |
|---|------|-------------|
| 1 | NEVER use `float` for money | Statutory calculation errors = ILLEGAL |
| 2 | NEVER hardcode statutory rates | Rates change; use `kf.statutory.rate` lookup |
| 3 | NEVER use `date.today()` for payroll | Wrong rate for historical payslips |
| 4 | NEVER skip audit logging | Compliance violation, legal liability |
| 5 | NEVER query ID/VN data from wrong VPS | Data residency violation = ILLEGAL |
| 6 | NEVER translate statutory IDs | "EPF Number" stays in English |

---

## PART I: PROJECT OVERVIEW

### 1.1 What is KerjaFlow?
Enterprise workforce management platform serving:
- **9 ASEAN countries**: MY, SG, ID, TH, PH, VN, KH, MM, BN
- **Target users**: Blue-collar workers, migrant workers (BD, NP, MM, ID)
- **Industries**: Manufacturing, plantations, construction, retail, logistics

### 1.2 Architecture Position
KerjaFlow = **headless canonical calculation engine** + ERP adapters

| Customer Type | Solution |
|---------------|----------|
| SME without ERP | KerjaFlow IS the system of record |
| Enterprise with SAP/Oracle/Workday | ERP = system of record; KerjaFlow = ASEAN compliance layer |

---

## PART II: DATA RESIDENCY & ROUTING

### 2.1 Country Configuration

| Country | Code | VPS | DB Alias | Data Residency Law |
|---------|------|-----|----------|-------------------|
| Malaysia | MY | Hub (KL) | `default` | PDPA 2010 |
| Singapore | SG | Singapore | `singapore` | PDPA 2012 |
| Indonesia | ID | Indonesia | `indonesia` | **PP 71/2019 - MANDATORY LOCAL** |
| Thailand | TH | Thailand | `thailand` | PDPA 2019 |
| Laos | LA | → Thailand | `thailand` | No specific law |
| Vietnam | VN | Vietnam | `vietnam` | **Cybersecurity Law - MANDATORY LOCAL** |
| Cambodia | KH | → Vietnam | `vietnam` | LPDP Draft - MONITOR |
| Philippines | PH | → Hub | `default` | Data Privacy Act 2012 |
| Brunei | BN | → Hub | `default` | PDPO - Grace period ends Jan 2026 |

### 2.2 Data Routing Implementation
```python
# FILE: backend/odoo/addons/kerjaflow/utils/data_router.py
COUNTRY_TO_DB = {
    'MY': 'default', 'PH': 'default', 'BN': 'default',
    'SG': 'singapore',
    'ID': 'indonesia',  # MANDATORY LOCAL
    'TH': 'thailand', 'LA': 'thailand',
    'VN': 'vietnam',    # MANDATORY LOCAL
    'KH': 'vietnam',
}

def get_database_for_country(country_code: str) -> str:
    """Returns database alias. NEVER query ID/VN from wrong VPS."""
    return COUNTRY_TO_DB[country_code]
```

### 2.3 Table Distribution
**CENTRAL (Hub only):** kf_company, kf_department, kf_job_position, kf_leave_type, kf_public_holiday, kf_country_config, kf_statutory_rate, kf_regulatory_monitor, kf_compliance_alert

**REGIONAL (Per-country):** kf_employee, kf_user, kf_foreign_worker_detail, kf_document, kf_payslip, kf_payslip_line, kf_leave_balance, kf_leave_request, kf_notification, kf_audit_log

---

## PART III: IMPLEMENTATION STATUS

| Phase | Description | Status | Completion |
|-------|-------------|--------|------------|
| Phase 1 | Database & Core Models | ✅ COMPLETE | 19/19 models |
| Phase 2 | Authentication & Security | ✅ COMPLETE | JWT, PIN, lockout |
| Phase 3 | API Development | ✅ COMPLETE | 32/32 endpoints |
| Phase 4 | Mobile App | 🔄 IN PROGRESS | ~45% (auth done) |
| Phase 5 | Testing | ⏳ PENDING | 0% |
| Phase 6 | Deployment | ⏳ PENDING | 0% |

### Backend Models (19 Complete)
**Location:** `backend/odoo/addons/kerjaflow/models/`

| Model | File | Key Notes |
|-------|------|-----------|
| kf.employee | kf_employee.py | 50+ fields, IC validation 9 countries |
| kf.user | kf_user.py | JWT, PIN, sessions, single device |
| kf.statutory.rate | kf_statutory_rate.py | Date-effective, wage brackets |
| kf.payslip | kf_payslip.py | Multi-currency, statutory contributions |
| kf.leave.request | kf_leave_request.py | State machine workflow |
| kf.public.holiday | kf_public_holiday.py | 381+ entries 2025-2026 |
| kf.audit.log | kf_audit_log.py | 7-year retention |

Others: kf_company, kf_department, kf_job_position, kf_country_config, kf_foreign_worker_detail, kf_document, kf_leave_type, kf_leave_balance, kf_payslip_line, kf_notification, compliance.py (regulatory_monitor, compliance_alert)

### API Endpoints (32 Complete)
**Base URL:** `/api/v1`

| Category | Count | Endpoints |
|----------|-------|-----------|
| Auth | 6 | login, refresh, logout, pin/setup, pin/verify, password/change |
| Profile | 4 | GET profile, PATCH profile, photo, dashboard |
| Payslip | 3 | list, detail (PIN), pdf (PIN) |
| Leave | 8 | types, balances, requests (CRUD), calendar, holidays |
| Approval | 3 | list, approve, reject |
| Notification | 4 | list, count, read, read-all |
| Document | 4 | list, upload, download, delete |

---

## PART IV: STATUTORY RATES

### 4.1 Complete Rate Table

| Country | System | Code | Employee % | Employer % | Wage Cap |
|---------|--------|------|------------|------------|----------|
| MY | EPF | EPF_EE/ER | 11.0 | 12.0/13.0 | None |
| MY | SOCSO | SOCSO_EE/ER | 0.5 | 1.25 | RM5,000 |
| MY | EIS | EIS_EE/ER | 0.2 | 0.2 | RM5,000 |
| SG | CPF | CPF_EE/ER | 20.0 | 17.0 | SGD 6,800 |
| ID | BPJS TK | BPJS_TK | 2.0 | 3.7 | Various |
| ID | BPJS Kes | BPJS_KES | 1.0 | 4.0 | IDR 12M |
| TH | SSF | SSF | 5.0 | 5.0 | THB 15,000 |
| VN | SI/HI/UI | Multiple | 10.5 | 21.5 | 20× min wage |
| PH | SSS | SSS | 4.5 | 9.5 | PHP 30,000 |
| PH | PhilHealth | PH | 2.5 | 2.5 | PHP 100,000 |
| PH | HDMF | HDMF | 2.0 | 2.0 | PHP 5,000 |
| KH | NSSF | NSSF_PENSION | 2.0→**4.0** | 2.0→**4.0** | KHR 1.2M |
| BN | TAP/SCP | TAP/SCP | 8.5 | 8.5 | None |
| LA | LSSO | LSSO | 4.5 | 5.0 | LAK 4.5M |

**Note:** Cambodia NSSF Pension increases to 4% in **October 2027** (pre-configured in database)

### 4.2 Statutory Rate Lookup (MANDATORY PATTERN)
```python
# FILE: backend/odoo/addons/kerjaflow/utils/statutory_calculator.py

class StatutoryCalculator:
    def get_rate(self, country_code: str, rate_code: str, 
                 effective_date: date, wage_amount: Decimal = None) -> Decimal:
        """ALWAYS use payslip_date, NEVER date.today()"""
        domain = [
            ('country_code', '=', country_code),
            ('rate_code', '=', rate_code),
            ('effective_from', '<=', effective_date),
            '|', ('effective_to', '=', False), ('effective_to', '>=', effective_date),
        ]
        rate = self.env['kf.statutory.rate'].search(domain, order='effective_from desc', limit=1)
        return Decimal(str(rate.employee_rate or rate.employer_rate))
    
    def calculate_contribution(self, country_code: str, rate_code: str,
                               payslip_date: date, gross_wage: Decimal) -> Decimal:
        rate = self.get_rate(country_code, rate_code, payslip_date, gross_wage)
        return (gross_wage * rate / Decimal('100')).quantize(Decimal('0.01'))

# CORRECT USAGE:
epf = calc.calculate_contribution('MY', 'EPF_EE', payslip.pay_date, gross)

# WRONG (NEVER DO):
epf = gross * Decimal('0.11')  # Hardcoded rate
epf = calc.calculate_contribution('MY', 'EPF_EE', date.today(), gross)  # Wrong date
```

---

## PART V: LOCALIZATION (12 Languages)

### 5.1 Language Configuration

| Code | Language | Script | Font | Market |
|------|----------|--------|------|--------|
| en | English | Latin | Roboto | Universal |
| ms_MY | Bahasa Malaysia | Latin | Roboto | MY, BN |
| id_ID | Bahasa Indonesia | Latin | Roboto | ID |
| zh_CN | Chinese Simplified | Han | Roboto | SG, MY |
| ta_IN | Tamil | Tamil | NotoSansTamil | MY, SG |
| th_TH | Thai | Thai | NotoSansThai | TH |
| vi_VN | Vietnamese | Latin | Roboto | VN |
| tl_PH | Filipino | Latin | Roboto | PH |
| km_KH | Khmer | Khmer | NotoSansKhmer | KH |
| my_MM | Burmese | Myanmar | NotoSansMyanmar | MM |
| bn_BD | Bengali | Bengali | NotoSansBengali | BD migrants |
| ne_NP | Nepali | Devanagari | NotoSansDevanagari | NP migrants |

### 5.2 ARB Files
**Location:** `mobile/l10n/app_{code}.arb` (197+ keys each)

### 5.3 Statutory Term Handling
**Rule:** Preserve official acronyms with translated descriptions

```dart
// CORRECT
'epf_employee': 'KWSP Pekerja'          // Malaysia
'epf_employee': 'EPF (雇员公积金)'       // Chinese

// WRONG - loses recognition
'epf_employee': 'Kumpulan Wang Simpanan Pekerja'
```

### 5.4 Font Configuration
```dart
// FILE: mobile/lib/core/theme/fonts.dart
static const Map<String, String> scriptFonts = {
  'km': 'NotoSansKhmer',
  'my': 'NotoSansMyanmar',
  'th': 'NotoSansThai',
  'ta': 'NotoSansTamil',
  'bn': 'NotoSansBengali',
  'ne': 'NotoSansDevanagari',
};
```

---

## PART VI: IC VALIDATION

| Country | Pattern | Example |
|---------|---------|---------|
| MY | `^\d{6}-\d{2}-\d{4}$` | 900101-01-1234 |
| SG | `^[STFGM]\d{7}[A-Z]$` | S1234567D (checksum validated) |
| ID | `^\d{16}$` | 3201011234567890 |
| TH | `^\d{13}$` | 1234567890123 |
| VN | `^\d{9}$\|^\d{12}$` | 012345678 |
| PH | `^\d{4}-\d{7}-\d{1}$` | 1234-5678901-2 |
| BN | `^\d{2}-\d{6}$` | 12-345678 |
| LA/KH | `^.{6,20}$` | Variable |

**Implementation:** `backend/odoo/addons/kerjaflow/utils/ic_validator.py`

---

## PART VII: MOBILE SCREENS (27 Total)

### Screen Inventory

| ID | Screen | API Endpoint | Status |
|----|--------|--------------|--------|
| **Auth (6)** |||
| S-001 | Login | POST /auth/login | ✅ |
| S-002 | PIN Setup | POST /auth/pin/setup | ✅ |
| S-003 | PIN Entry | POST /auth/pin/verify | ✅ |
| S-004 | Forgot Password | — | ⏳ |
| S-005 | Reset Password | POST /auth/password/change | ⏳ |
| S-006 | Biometric | Local | ✅ |
| **Dashboard (2)** |||
| S-010 | Dashboard | GET /dashboard | ⏳ |
| S-011 | Offline Banner | Local | ⏳ |
| **Payslip (3)** |||
| S-020 | Payslip List | GET /payslips | ⏳ |
| S-021 | Payslip Detail | GET /payslips/{id} (PIN) | ⏳ |
| S-022 | Payslip PDF | GET /payslips/{id}/pdf (PIN) | ⏳ |
| **Leave (6)** |||
| S-030 | Leave Balance | GET /leave/balances | ⏳ |
| S-031 | Leave History | GET /leave/requests | ⏳ |
| S-032 | Leave Apply | POST /leave/requests | ⏳ |
| S-033 | Leave Detail | GET /leave/requests/{id} | ⏳ |
| S-034 | Leave Calendar | GET /leave/calendar | ⏳ |
| S-035 | Leave Approval | GET /approvals | ⏳ |
| **Notification (2)** |||
| S-050 | Notification List | GET /notifications | ⏳ |
| S-051 | Notification Detail | — | ⏳ |
| **Document (3)** |||
| S-060 | Document List | GET /documents | ⏳ |
| S-061 | Document Upload | POST /documents | ⏳ |
| S-062 | Document Viewer | GET /documents/{id} | ⏳ |
| **Profile (3)** |||
| S-070 | Profile View | GET /profile | ⏳ |
| S-071 | Profile Edit | PATCH /profile | ⏳ |
| S-080 | Settings | Local | ⏳ |
| **System (2)** |||
| SYS-01 | Offline Banner | Local | ⏳ |
| SYS-02 | Error Screen | Local | ⏳ |

---

## PART VIII: SECURITY

### 8.1 Authentication
| Item | Specification |
|------|---------------|
| JWT Algorithm | RS256 (RSA + SHA256) |
| Access Token TTL | 24 hours |
| Refresh Token TTL | 7 days |
| PIN Format | 6 digits, bcrypt cost 10 |
| Lockout | 5 failed attempts → 15 min |
| Sessions | Single device only |

### 8.2 Encryption (AES-256-GCM)
- `ic_no` - National ID
- `passport_no` - Passport
- `bank_account_no` - Bank account
- `basic_salary` - Salary

### 8.3 Rate Limits (Nginx)
| Endpoint | Limit | Burst |
|----------|-------|-------|
| `/api/v1/auth/*` | 10/min | 5 |
| `/api/v1/payslips/*` | 30/min | 10 |
| General | 60/min | 20 |

### 8.4 Audit Logging (MANDATORY)
```python
self.env['kf.audit.log'].create({
    'user_id': self.env.user.id,
    'employee_id': employee.id,
    'action': 'VIEW_PAYSLIP',
    'resource_type': 'kf.payslip',
    'resource_id': payslip.id,
    'ip_address': request.httprequest.remote_addr,
    'country_code': employee.country_code,
})
```

---

## PART IX: CODING STANDARDS

### 9.1 Python (Odoo)
```python
from decimal import Decimal
from datetime import date

# Money: ALWAYS Decimal
amount = Decimal(str(self.basic_salary))

# Queries: ALWAYS include country_code
employees = self.env['kf.employee'].search([
    ('country_code', '=', 'MY'),
    ('company_id', '=', company_id),
])

# Rates: ALWAYS use payslip_date
rate = calc.get_rate('MY', 'EPF_EE', payslip.pay_date)
```

### 9.2 Flutter (Dart)
```dart
// Models: Use freezed
@freezed
class Payslip with _$Payslip {
  const factory Payslip({
    required int id,
    required String netSalary,  // Money as String
  }) = _Payslip;
}

// State: Use Riverpod
final payslipsProvider = FutureProvider<List<Payslip>>((ref) async {
  return ref.watch(payslipRepositoryProvider).getPayslips();
});

// Storage: Use FlutterSecureStorage for tokens
```

---

## PART X: FILE STRUCTURE

```
kerjaflow/
├── CLAUDE.md                           ← THIS FILE
├── backend/odoo/addons/kerjaflow/
│   ├── models/                         # 19 models
│   ├── controllers/                    # 8 controllers
│   ├── utils/                          # data_router, statutory_calculator, ic_validator
│   ├── security/                       # RBAC
│   └── tests/
├── mobile/
│   ├── lib/
│   │   ├── core/                       # config, network, storage, theme, localization
│   │   ├── features/                   # auth, dashboard, payslip, leave, etc.
│   │   └── shared/                     # widgets, utils
│   ├── l10n/                           # 12 ARB files
│   └── pubspec.yaml
├── integrations/                       # ERP adapters
│   ├── common/                         # canonical_model, base_adapter
│   ├── sap_successfactors/
│   ├── oracle_hcm/
│   └── workday/
├── database/migrations/                # 14 SQL files
└── docs/specs/                         # 10 specification documents
```

---

## PART XI: ERP INTEGRATION

### Priority Tiers
| Tier | Systems | Timeline |
|------|---------|----------|
| 1 | SAP SuccessFactors, Oracle HCM, Workday | 6-12 months |
| 2 | Microsoft Dynamics 365, SAP S/4HANA, ADP | 12-18 months |
| 3 | UKG Pro, Infor, Ceridian | 18-24 months |
| 4 | BambooHR, Gusto, Paylocity | 24+ months |

### Canonical Models
**Location:** `integrations/common/canonical_model.py`
- CanonicalEmployee, CanonicalLeaveBalance, CanonicalLeaveRequest, CanonicalPayslip, CanonicalDocument

### Base Adapter Interface
**Location:** `integrations/common/base_adapter.py`
- authenticate(), sync_employees(), push_leave_request(), sync_payslips(), health_check()

**Full specs:** `docs/architecture/KerjaFlow_ERP_Integration_Architecture_Complete.docx`

---

## PART XII: VALIDATION COMMANDS

### Flutter
```bash
flutter analyze              # Expected: No issues found
flutter test --coverage      # Expected: All pass
flutter gen-l10n             # Expected: 12 locales generated
flutter build apk --debug    # Expected: BUILD SUCCESSFUL
```

### Python
```bash
flake8 backend/odoo/addons/kerjaflow
pytest backend/kerjaflow/tests/ -v --cov  # Expected: >80% coverage
python validation/statutory_rate_validator.py --all
```

---

## PART XIII: QUICK REFERENCE

### Start Mobile Screen
```bash
claude "Create S-010 Dashboard screen with GET /api/v1/dashboard. Use Riverpod + freezed. Include loading, error, offline states."
```

### Verify Completion
```bash
claude "Audit KerjaFlow: verify 19 models, 32 endpoints, 27 screens, 12 ARB files. Check for float in money, date.today() in payroll, missing country_code in queries."
```

### Critical Files
| Purpose | Location |
|---------|----------|
| Data routing | `utils/data_router.py` |
| Rate lookup | `utils/statutory_calculator.py` |
| IC validation | `utils/ic_validator.py` |
| Fonts | `lib/core/theme/fonts.dart` |
| Statutory terms | `lib/core/localization/statutory_terms.dart` |

### Reference Documents
| Doc | Location |
|-----|----------|
| API Contract | `docs/specs/02_API_Contract.md` |
| OpenAPI | `docs/specs/03_OpenAPI.yaml` |
| Business Logic | `docs/specs/04_Business_Logic.md` |
| Mobile UX | `docs/specs/09_Mobile_UX_Specification.md` |
| ERP Integration | `docs/architecture/KerjaFlow_ERP_Integration_Architecture_Complete.docx` |

---

*KerjaFlow v4.1 — 9 ASEAN countries | 12 languages | $109-114/month infrastructure*