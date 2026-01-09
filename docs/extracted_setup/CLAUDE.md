# CLAUDE.md - KerjaFlow Project Instructions

> **This file instructs Claude Code CLI on how to work with the KerjaFlow codebase.**
> **Read EVERYTHING before making any changes.**

---

## 🎯 PROJECT IDENTITY

**KerjaFlow** is an Enterprise Workforce Management Platform for ASEAN markets.

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   KERJAFLOW = THE FUCKING BEST WORKFORCE PLATFORM IN ASEAN     │
│                                                                 │
│   Every competitor becomes obsolete the moment we launch.       │
│   This is not a product. This is a market-defining platform.   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Target Markets:** Malaysia, Singapore, Indonesia, Thailand, Philippines, Vietnam, Cambodia, Myanmar, Brunei

**Target Users:**
- Blue-collar workers (factory, plantation, construction, retail)
- Foreign migrant workers (Bangladesh, Nepal, Myanmar, Indonesia, Philippines)
- HR departments managing multi-country compliance
- Enterprise clients in regulated industries

**Core Value Proposition:**
- 9-country ASEAN statutory compliance engine
- 12-language support including migrant worker scripts
- 16 Malaysian state holiday calendars
- Deep EPF/SOCSO/BPJS/CPF/SSO calculations
- Offline-first mobile architecture
- 12 major ERP system integrations

---

## 🏗️ ARCHITECTURE

### Tech Stack

| Layer | Technology | Version |
|-------|------------|---------|
| **Backend** | Odoo | 17.x |
| **Backend Language** | Python | 3.10+ |
| **Database** | PostgreSQL | 15+ |
| **Cache** | Redis | 7.x |
| **Mobile** | Flutter | 3.19+ |
| **Mobile Language** | Dart | 3.x |
| **State Management** | Riverpod | 2.x |
| **Local DB** | Drift (SQLite) | Latest |
| **HTTP Client** | Dio | Latest |
| **Container** | Docker | Latest |
| **Reverse Proxy** | Nginx | Latest |

### Directory Structure

```
kflow/
├── backend/
│   └── odoo/
│       └── addons/
│           └── kerjaflow/
│               ├── models/           # Odoo models (19 files)
│               ├── controllers/      # API controllers (10 files)
│               ├── security/         # RBAC, access rules
│               ├── views/            # Odoo views
│               ├── data/             # Seed data
│               └── __manifest__.py   # Module manifest
├── mobile/
│   ├── lib/
│   │   ├── core/                     # Core utilities
│   │   │   ├── network/              # Dio client, interceptors
│   │   │   ├── storage/              # Secure storage
│   │   │   └── utils/                # Helpers
│   │   ├── features/                 # Feature modules
│   │   │   ├── auth/                 # Login, PIN, biometric
│   │   │   ├── dashboard/            # Home dashboard
│   │   │   ├── payslip/              # Payslip viewing
│   │   │   ├── leave/                # Leave management
│   │   │   ├── attendance/           # Clock in/out
│   │   │   ├── documents/            # Document management
│   │   │   └── settings/             # User settings
│   │   ├── l10n/                     # ARB translation files
│   │   └── main.dart
│   └── test/                         # Flutter tests
├── infrastructure/
│   ├── docker/                       # Docker configs
│   ├── nginx/                        # Nginx configs
│   └── terraform/                    # IaC (optional)
├── database/
│   └── migrations/                   # SQL migrations
├── docs/
│   ├── specs/                        # Specification documents
│   ├── audit/                        # Audit reports
│   └── api/                          # API documentation
├── .kbs/                             # KerjaFlow Build System
│   ├── kbs.sh                        # Main build script
│   ├── hooks/                        # Git hooks
│   ├── logs/                         # Build logs
│   ├── reports/                      # Test/coverage reports
│   └── artifacts/                    # Build artifacts
└── CLAUDE.md                         # THIS FILE
```

---

## 🔒 SECURITY REQUIREMENTS (NON-NEGOTIABLE)

### Authentication

| Requirement | Implementation | Status |
|-------------|----------------|--------|
| JWT Algorithm | **RS256** (NOT HS256) | REQUIRED |
| Access Token TTL | 15 minutes | REQUIRED |
| Refresh Token TTL | 7 days | REQUIRED |
| PIN Storage | bcrypt, cost factor ≥12 | REQUIRED |
| PIN Length | 6 digits | REQUIRED |
| Weak PIN Detection | Block 123456, 000000, etc. | REQUIRED |

### Mobile Security

| Requirement | Implementation |
|-------------|----------------|
| Certificate Pinning | SHA-256 fingerprint validation |
| Root/Jailbreak Detection | Block rooted devices |
| Screenshot Prevention | FLAG_SECURE on sensitive screens |
| Secure Storage | FlutterSecureStorage (Keychain/Keystore) |
| Biometric Auth | Local authentication package |
| Session Timeout | 5 minutes inactive = re-auth |

### API Security

| Requirement | Implementation |
|-------------|----------------|
| Rate Limiting | 10/min auth, 60/min API |
| Input Validation | Sanitize all inputs |
| SQL Injection | Use ORM, parameterized queries |
| XSS Prevention | Escape all outputs |
| CORS | Whitelist allowed origins |
| HTTPS | TLS 1.3, HSTS enabled |

### Data Protection

| Country | Requirement |
|---------|-------------|
| Indonesia | **MANDATORY** local VPS (PP 71/2019) |
| Vietnam | **MANDATORY** local VPS (Cybersecurity Law) |
| Malaysia | Can use regional hub |
| Singapore | Can use regional hub |
| Others | Can use regional hub |

---

## 🌏 ASEAN STATUTORY COMPLIANCE

### Critical: Use Payslip Date for Rate Lookup

```python
# ❌ WRONG - Uses current date
def calculate_epf(salary):
    rate = get_current_epf_rate()  # WRONG!
    return salary * rate

# ✅ CORRECT - Uses payslip date
def calculate_epf(salary, payslip_date):
    rate = get_epf_rate_for_date(payslip_date)  # CORRECT!
    return salary * rate
```

### Malaysia Statutory Components

| Component | Authority | Key Rules |
|-----------|-----------|-----------|
| EPF (KWSP) | kwsp.gov.my | Employee 11%, Employer 12%/13%, Foreign workers 2%/2% from Oct 2025 |
| SOCSO (PERKESO) | perkeso.gov.my | Ceiling RM6,000 (from Oct 2024), Employment Injury + Invalidity |
| EIS (SIP) | eis.perkeso.gov.my | 0.2% each, ceiling RM6,000 |
| PCB (MTD) | hasil.gov.my | Monthly tax deduction, use e-PCB tables |
| HRDF | hrdf.com.my | 1% for >10 employees in specified sectors |

### Singapore Statutory Components

| Component | Authority | Key Rules |
|-----------|-----------|-----------|
| CPF | cpf.gov.sg | Age-tiered rates (37% total for ≤55, decreasing above) |
| SDL | ssg.gov.sg | 0.25%, min $2, max $11.25 |
| CDAC/MBMF/SINDA | respective sites | Ethnicity-based, employee only |

### Indonesia Statutory Components

| Component | Authority | Key Rules |
|-----------|-----------|-----------|
| BPJS-TK | bpjsketenagakerjaan.go.id | JKK (0.24-1.74%), JKM (0.3%), JHT (5.7%), JP (3%) |
| BPJS-KES | bpjs-kesehatan.go.id | 5% (4% employer, 1% employee), ceiling applies |
| PPh 21 | pajak.go.id | Progressive tax 5%-35% |

### Thailand Statutory Components

| Component | Authority | Key Rules |
|-----------|-----------|-----------|
| SSO | sso.go.th | 5% each, ceiling 15,000 THB |
| PIT | rd.go.th | Progressive 0%-35% |

### Philippines Statutory Components

| Component | Authority | Key Rules |
|-----------|-----------|-----------|
| SSS | sss.gov.ph | Contribution table based on salary bracket |
| PhilHealth | philhealth.gov.ph | 5% total, shared equally |
| Pag-IBIG | pagibigfund.gov.ph | 2% each up to ceiling |

### Holiday Pay Differentials (Critical!)

| Country | Regular Holiday | Special Holiday |
|---------|-----------------|-----------------|
| Malaysia | 2x + 1 day leave | N/A |
| Philippines | 200% if worked | 130% if worked |
| Indonesia | 2x basic rate | N/A |

---

## 🌐 INTERNATIONALIZATION (i18n)

### Supported Languages (12)

| Code | Language | Script | Target Users |
|------|----------|--------|--------------|
| en | English | Latin | Default, professionals |
| ms | Bahasa Malaysia | Latin | Malaysian workers |
| id | Bahasa Indonesia | Latin | Indonesian workers |
| th | Thai | Thai | Thai workers |
| vi | Vietnamese | Latin+diacritics | Vietnamese workers |
| tl | Filipino/Tagalog | Latin | Filipino workers |
| zh | Chinese Simplified | Han | Chinese speakers |
| ta | Tamil | Tamil | Malaysian Indians |
| bn | Bengali | Bengali | Bangladeshi workers |
| ne | Nepali | Devanagari | Nepali workers |
| km | Khmer | Khmer | Cambodian workers |
| my | Myanmar | Myanmar Unicode | Myanmar workers |

### Translation Rules

1. **Preserve statutory abbreviations**: EPF, SOCSO, PCB, CPF, BPJS must appear alongside translations
2. **Use Myanmar Unicode**: Never Zawgyi (government mandate)
3. **Malaysian ≠ Indonesian Malay**: Treat as separate languages
4. **Authoritative sources only**: Government sites > dictionaries > adaptation

### ARB File Requirements

```json
// mobile/lib/l10n/app_en.arb (BASELINE - 197+ keys)
{
  "@@locale": "en",
  "appTitle": "KerjaFlow",
  "login": "Login",
  "epfContribution": "EPF Contribution",
  "@epfContribution": {
    "description": "Employee Provident Fund contribution label"
  }
}
```

**Every language file MUST have 100% of baseline keys.**

---

## ✅ QUALITY GATES

### Coverage Requirements

| Component | Minimum | Target |
|-----------|---------|--------|
| Backend | 70% | 85% |
| Mobile | 70% | 85% |
| Critical paths | 90% | 95% |

### Linting Standards

**Backend (Python):**
```bash
black --check .                    # Formatting
flake8 --max-line-length=120 .    # Linting
isort --check-only .              # Import sorting
```

**Mobile (Dart):**
```bash
flutter analyze --fatal-infos --fatal-warnings
```

### Security Scanning

```bash
bandit -r backend/ -ll            # Python security
safety check -r requirements.txt  # Dependency vulnerabilities
pip-audit -r requirements.txt     # Package audit
```

### Build Constraints

| Artifact | Constraint |
|----------|------------|
| APK Size | < 50MB |
| Docker Image | < 500MB |
| Cold Start | < 3 seconds |

---

## 📝 CODING STANDARDS

### Python (Backend)

```python
# Use type hints
def calculate_epf(
    salary: Decimal,
    payslip_date: date,
    employee_type: str
) -> Decimal:
    """Calculate EPF contribution.
    
    Args:
        salary: Gross salary amount
        payslip_date: Date of payslip for rate lookup
        employee_type: 'local' or 'foreign'
    
    Returns:
        EPF contribution amount
    
    Raises:
        ValueError: If employee_type is invalid
    """
    pass

# Use Decimal for money, NEVER float
from decimal import Decimal
salary = Decimal("5000.00")  # ✅ CORRECT
salary = 5000.00             # ❌ WRONG (float)

# Always include country_code in employee queries
employees = self.env['kf.employee'].search([
    ('company_id', '=', company_id),
    ('country_code', '=', 'MY'),  # REQUIRED
])
```

### Dart (Mobile)

```dart
// Use Riverpod for state management
final payslipProvider = FutureProvider.autoDispose
    .family<Payslip, String>((ref, payslipId) async {
  final repository = ref.watch(payslipRepositoryProvider);
  return repository.getPayslip(payslipId);
});

// Use freezed for immutable models
@freezed
class Payslip with _$Payslip {
  const factory Payslip({
    required String id,
    required DateTime payPeriodStart,
    required DateTime payPeriodEnd,
    required Decimal grossSalary,
    required Decimal netSalary,
    required List<Deduction> deductions,
  }) = _Payslip;

  factory Payslip.fromJson(Map<String, dynamic> json) =>
      _$PayslipFromJson(json);
}

// Always handle errors
try {
  final payslip = await repository.getPayslip(id);
  return payslip;
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    throw UnauthorizedException();
  }
  throw NetworkException(e.message);
} catch (e) {
  throw UnexpectedException(e.toString());
}
```

---

## 🚫 ABSOLUTE DON'Ts

### Never Do These

```python
# ❌ NEVER use float for money
amount = 5000.00

# ❌ NEVER use current date for rate lookup
rate = get_current_rate()

# ❌ NEVER hardcode secrets
API_KEY = "sk-1234567890"

# ❌ NEVER use HS256 for JWT
jwt.encode(payload, secret, algorithm="HS256")

# ❌ NEVER skip country_code in queries
employees = self.env['kf.employee'].search([])

# ❌ NEVER assume Malaysian = Indonesian Malay
translation_id = translation_ms  # WRONG!

# ❌ NEVER use Zawgyi for Myanmar
font = "Zawgyi"  # Use Myanmar Unicode!

# ❌ NEVER skip input validation
user_input = request.params.get('data')  # Validate first!

# ❌ NEVER commit .env files
# ❌ NEVER commit secrets
# ❌ NEVER commit node_modules or __pycache__
```

### Always Do These

```python
# ✅ ALWAYS use Decimal for money
from decimal import Decimal
amount = Decimal("5000.00")

# ✅ ALWAYS use payslip_date for rate lookup
rate = get_rate_for_date(payslip_date)

# ✅ ALWAYS use environment variables
API_KEY = os.environ.get("API_KEY")

# ✅ ALWAYS use RS256 for JWT
jwt.encode(payload, private_key, algorithm="RS256")

# ✅ ALWAYS include country_code
employees = self.env['kf.employee'].search([
    ('country_code', '=', country_code),
])

# ✅ ALWAYS treat languages separately
translation_id = get_translation('id')  # Indonesian
translation_ms = get_translation('ms')  # Malaysian

# ✅ ALWAYS validate input
user_input = sanitize(request.params.get('data'))
```

---

## 🧪 TESTING REQUIREMENTS

### Backend Test Structure

```
backend/tests/
├── unit/
│   ├── test_statutory_calculator.py   # Must have 90%+ coverage
│   ├── test_leave_calculator.py
│   └── test_payroll_engine.py
├── integration/
│   ├── test_api_auth.py
│   ├── test_api_payslip.py
│   └── test_api_leave.py
└── fixtures/
    ├── employees.json
    ├── payslips.json
    └── statutory_rates.json
```

### Mobile Test Structure

```
mobile/test/
├── unit/
│   ├── statutory_calculator_test.dart
│   └── date_utils_test.dart
├── widget/
│   ├── login_screen_test.dart
│   ├── payslip_card_test.dart
│   └── leave_form_test.dart
└── integration/
    └── app_test.dart
```

### E2E Test Scenarios

| ID | Scenario | Priority |
|----|----------|----------|
| E2E-01 | Login with credentials | CRITICAL |
| E2E-02 | PIN setup and entry | CRITICAL |
| E2E-03 | View payslip | CRITICAL |
| E2E-04 | Apply for leave | HIGH |
| E2E-05 | Approve leave (manager) | HIGH |
| E2E-06 | Upload document | HIGH |
| E2E-07 | Offline mode sync | HIGH |
| E2E-08 | Language switch | MEDIUM |
| E2E-09 | Push notification | MEDIUM |
| E2E-10 | Session timeout | MEDIUM |

---

## 📚 REFERENCE DOCUMENTATION

### Specification Documents (in `docs/specs/`)

| File | Purpose |
|------|---------|
| 01_Data_Foundation.md | Data models, RBAC matrix |
| 02_API_Contract.md | API endpoints, request/response |
| 03_OpenAPI.yaml | Full OpenAPI specification |
| 04_Business_Logic.md | Calculation rules, leave logic |
| 05_Quality_Specification.md | Test strategy, error codes |
| 06_Security_Hardening.md | Security requirements |
| 07_Operations_Runbook.md | Deployment, monitoring |
| 08_Technical_Addendum.md | Technical details |
| 09_Mobile_UX_Specification.md | UI/UX spec, 27 screens |
| 10_Implementation_Plan.md | 20-week roadmap |

### External References

| Document | Location |
|----------|----------|
| ERP Integration Architecture | /docs/ERP_Integration_Architecture.docx |
| Malaysian HR Practitioner Playbook | /docs/Malaysian_HR_Playbook.md |
| Indonesian HR Practitioner Playbook | /docs/Indonesian_HR_Playbook.md |
| Singapore HR Operations Guide | /docs/Singapore_HR_Guide.md |
| ASEAN Public Holiday Database | /docs/ASEAN_Holidays_2025_2026.md |
| ASEAN Statutory Database | /docs/ASEAN_Statutory_Database.docx |

---

## 🔧 BUILD SYSTEM

### KerjaFlow Build System (KBS)

All CI/CD is **internal**. Zero external paid services.

```bash
# Run full quality gates
.kbs/kbs.sh full

# Quick lint + security (pre-commit)
.kbs/kbs.sh quick

# Security scan only
.kbs/kbs.sh security

# Create release
.kbs/kbs.sh release
```

### Git Hooks (Automatic)

| Hook | Trigger | Pipeline |
|------|---------|----------|
| pre-commit | `git commit` | quick (lint + security) |
| pre-push | `git push` | full (all gates) |

---

## 🎯 CURRENT PRIORITIES

### BLOCKERS (Fix First)

1. **JWT Algorithm**: Migrate HS256 → RS256
2. **Missing Model**: Create `kf_user_device.py`
3. **CI/CD**: Enable `.kbs/kbs.sh` pipelines
4. **Flutter**: Ensure Flutter tests pass

### HIGH Priority

1. Document management screens (list, upload, viewer)
2. Payslip PDF viewer
3. Certificate pinning implementation
4. Translation key alignment (ZH-CN, KM)
5. 70% test coverage

### MEDIUM Priority

1. Leave calendar screen
2. Settings screens
3. Root detection
4. Screenshot prevention

---

## 💡 WORKING WITH CLAUDE CODE

### Before Making Changes

1. **Read relevant spec documents** in `docs/specs/`
2. **Check existing tests** for the area you're modifying
3. **Run linting** to understand current state
4. **Search codebase** for similar implementations

### When Implementing Features

1. **Write tests first** (TDD when possible)
2. **Follow existing patterns** in the codebase
3. **Use Decimal for money** (never float)
4. **Include country_code** in all employee queries
5. **Preserve statutory abbreviations** in translations
6. **Run quality gates** before committing

### When Fixing Bugs

1. **Write a failing test first** that reproduces the bug
2. **Fix the bug** with minimal changes
3. **Verify the test passes**
4. **Check for similar bugs** in related code
5. **Update documentation** if behavior changed

### Commit Messages

```
feat(statutory): Add October 2025 foreign worker EPF rates

- Add 2%/2% EPF rates for foreign workers effective Oct 2025
- Update rate lookup to use payslip_date
- Add migration for rate table

Refs: KWSP Circular 2024/05
```

```
fix(mobile): Prevent screenshot on payslip screen

- Add FLAG_SECURE to PayslipViewScreen
- Add to PayslipPDFViewer
- Add security test

Security: Prevents sensitive data exposure
```

---

## 📞 CONTACTS & RESOURCES

### Government Portals (Authoritative Sources)

| Country | Portal | URL |
|---------|--------|-----|
| Malaysia EPF | KWSP | kwsp.gov.my |
| Malaysia SOCSO | PERKESO | perkeso.gov.my |
| Malaysia Tax | LHDN | hasil.gov.my |
| Singapore CPF | CPF Board | cpf.gov.sg |
| Indonesia Social | BPJS | bpjsketenagakerjaan.go.id |
| Thailand SSO | Social Security | sso.go.th |
| Philippines SSS | SSS | sss.gov.ph |

### Language Authorities

| Language | Authority |
|----------|-----------|
| Bahasa Malaysia | Dewan Bahasa dan Pustaka (DBP) |
| Bahasa Indonesia | KBBI Online |
| Filipino | Komisyon sa Wikang Filipino (KWF) |
| Thai | Royal Institute of Thailand |

---

## 🏁 FINAL CHECKLIST

Before any PR/merge, verify:

- [ ] All tests pass (`pytest`, `flutter test`)
- [ ] Coverage ≥70%
- [ ] Linting passes (`black`, `flake8`, `flutter analyze`)
- [ ] Security scan clean (`bandit`, `safety`)
- [ ] No secrets in code
- [ ] Decimal used for all money
- [ ] country_code in all employee queries
- [ ] Payslip date used for rate lookup
- [ ] Translations preserve statutory abbreviations
- [ ] Documentation updated
- [ ] CHANGELOG updated

---

*KerjaFlow - Changing the game in ASEAN workforce management.*

*This is not just software. This is the future of how ASEAN manages its workforce.*
