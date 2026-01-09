# KerjaFlow Repository File Manifest

## Complete list of files required for Gold Standard production readiness

---

## 📁 ROOT DIRECTORY

```
kflow/
├── CLAUDE.md                          # ← Claude Code CLI instructions (CRITICAL)
├── README.md                          # Project overview
├── LICENSE                            # License file
├── VERSION                            # Version number (e.g., 1.0.0)
├── CHANGELOG.md                       # Version history
├── .gitignore                         # Git ignore rules
├── .editorconfig                      # Editor configuration
├── docker-compose.yml                 # Development environment
├── docker-compose.prod.yml            # Production environment
├── Makefile                           # Common commands
└── pyproject.toml                     # Python project config
```

---

## 📁 .kbs/ - KerjaFlow Build System

```
.kbs/
├── kbs.sh                             # ← Main build script (CRITICAL)
├── config.yaml                        # Quality gate configuration
├── hooks/
│   ├── pre-commit                     # Git pre-commit hook
│   └── pre-push                       # Git pre-push hook
├── tools/
│   ├── install-backend-tools.sh       # Backend tool installer
│   ├── install-mobile-tools.sh        # Mobile tool installer
│   └── install-security-tools.sh      # Security tool installer
├── logs/                              # Build logs (gitignored)
├── reports/                           # Test reports (gitignored)
└── artifacts/                         # Build artifacts (gitignored)
```

---

## 📁 backend/ - Odoo Backend

```
backend/
├── Dockerfile                         # Backend container
├── requirements.txt                   # Python dependencies
├── pytest.ini                         # Pytest configuration
├── .env.example                       # Environment template
└── odoo/
    └── addons/
        └── kerjaflow/
            ├── __init__.py
            ├── __manifest__.py        # Odoo module manifest
            ├── config.py              # Module configuration
            │
            ├── models/
            │   ├── __init__.py
            │   ├── kf_company.py      # Company model
            │   ├── kf_employee.py     # Employee model
            │   ├── kf_user.py         # User model (PIN, auth)
            │   ├── kf_user_device.py  # ← MISSING - CREATE THIS
            │   ├── kf_payslip.py      # Payslip model
            │   ├── kf_payslip_line.py # Payslip line items
            │   ├── kf_leave_type.py   # Leave type model
            │   ├── kf_leave_request.py # Leave request model
            │   ├── kf_leave_balance.py # Leave balance model
            │   ├── kf_attendance.py   # Attendance model
            │   ├── kf_document.py     # Document model
            │   ├── kf_document_type.py # Document type model
            │   ├── kf_notification.py # Notification model
            │   ├── kf_audit_log.py    # Audit logging
            │   ├── kf_statutory_rate.py # Statutory rate lookup
            │   ├── kf_public_holiday.py # Public holiday model
            │   ├── kf_working_calendar.py # Working calendar
            │   └── kf_announcement.py # Announcements
            │
            ├── controllers/
            │   ├── __init__.py
            │   ├── auth_controller.py # Authentication API
            │   ├── user_controller.py # User profile API
            │   ├── payslip_controller.py # Payslip API
            │   ├── leave_controller.py # Leave API
            │   ├── attendance_controller.py # Attendance API
            │   ├── document_controller.py # Document API
            │   ├── notification_controller.py # Notification API
            │   ├── announcement_controller.py # Announcement API
            │   ├── statutory_controller.py # Statutory data API
            │   └── health_controller.py # Health check API
            │
            ├── services/
            │   ├── __init__.py
            │   ├── statutory_calculator.py # ← CRITICAL: Rate calculations
            │   ├── leave_calculator.py # Leave day calculations
            │   ├── payroll_engine.py   # Payroll processing
            │   ├── notification_service.py # Push notifications
            │   └── audit_service.py    # Audit logging service
            │
            ├── security/
            │   ├── ir.model.access.csv # Access control list
            │   └── security.xml        # Security groups
            │
            ├── views/
            │   ├── company_views.xml
            │   ├── employee_views.xml
            │   ├── payslip_views.xml
            │   ├── leave_views.xml
            │   └── menu.xml            # Menu structure
            │
            ├── data/
            │   ├── statutory_rates_my.xml  # Malaysia rates
            │   ├── statutory_rates_sg.xml  # Singapore rates
            │   ├── statutory_rates_id.xml  # Indonesia rates
            │   ├── statutory_rates_th.xml  # Thailand rates
            │   ├── statutory_rates_ph.xml  # Philippines rates
            │   ├── statutory_rates_vn.xml  # Vietnam rates
            │   ├── statutory_rates_kh.xml  # Cambodia rates
            │   ├── statutory_rates_mm.xml  # Myanmar rates
            │   ├── statutory_rates_bn.xml  # Brunei rates
            │   ├── public_holidays_2025.xml # 2025 holidays
            │   ├── public_holidays_2026.xml # 2026 holidays
            │   └── leave_types.xml         # Default leave types
            │
            └── tests/
                ├── __init__.py
                ├── test_statutory_calculator.py  # ← Must have 90%+ coverage
                ├── test_leave_calculator.py
                ├── test_payroll_engine.py
                ├── test_auth_controller.py
                ├── test_payslip_controller.py
                ├── test_leave_controller.py
                └── fixtures/
                    ├── employees.json
                    ├── payslips.json
                    └── statutory_rates.json
```

---

## 📁 mobile/ - Flutter Mobile App

```
mobile/
├── pubspec.yaml                       # Flutter dependencies
├── pubspec.lock                       # Locked dependencies
├── analysis_options.yaml              # Dart analysis rules
├── .env.example                       # Environment template
│
├── lib/
│   ├── main.dart                      # App entry point
│   ├── app.dart                       # App configuration
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   ├── api_constants.dart
│   │   │   └── statutory_constants.dart
│   │   │
│   │   ├── network/
│   │   │   ├── dio_client.dart        # ← Certificate pinning here
│   │   │   ├── api_interceptor.dart
│   │   │   ├── auth_interceptor.dart
│   │   │   └── error_interceptor.dart
│   │   │
│   │   ├── storage/
│   │   │   ├── secure_storage.dart    # FlutterSecureStorage wrapper
│   │   │   ├── local_database.dart    # Drift database
│   │   │   └── preferences.dart       # SharedPreferences wrapper
│   │   │
│   │   ├── security/
│   │   │   ├── root_detector.dart     # Root/jailbreak detection
│   │   │   ├── screenshot_guard.dart  # Screenshot prevention
│   │   │   └── biometric_auth.dart    # Biometric authentication
│   │   │
│   │   ├── utils/
│   │   │   ├── date_utils.dart
│   │   │   ├── currency_utils.dart
│   │   │   ├── validators.dart
│   │   │   └── extensions.dart
│   │   │
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       ├── colors.dart
│   │       └── typography.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── auth_repository.dart
│   │   │   │   └── auth_api.dart
│   │   │   ├── domain/
│   │   │   │   ├── auth_state.dart
│   │   │   │   └── user_model.dart
│   │   │   ├── presentation/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── pin_setup_screen.dart
│   │   │   │   ├── pin_entry_screen.dart
│   │   │   │   └── biometric_screen.dart
│   │   │   └── providers/
│   │   │       └── auth_provider.dart
│   │   │
│   │   ├── dashboard/
│   │   │   ├── data/
│   │   │   │   └── dashboard_repository.dart
│   │   │   ├── domain/
│   │   │   │   └── dashboard_model.dart
│   │   │   ├── presentation/
│   │   │   │   ├── dashboard_screen.dart
│   │   │   │   └── dashboard_detail_screen.dart  # ← IMPLEMENT
│   │   │   └── providers/
│   │   │       └── dashboard_provider.dart
│   │   │
│   │   ├── payslip/
│   │   │   ├── data/
│   │   │   │   ├── payslip_repository.dart
│   │   │   │   └── payslip_api.dart
│   │   │   ├── domain/
│   │   │   │   ├── payslip_model.dart
│   │   │   │   └── deduction_model.dart
│   │   │   ├── presentation/
│   │   │   │   ├── payslip_list_screen.dart
│   │   │   │   ├── payslip_detail_screen.dart
│   │   │   │   └── payslip_pdf_viewer.dart      # ← IMPLEMENT
│   │   │   └── providers/
│   │   │       └── payslip_provider.dart
│   │   │
│   │   ├── leave/
│   │   │   ├── data/
│   │   │   │   ├── leave_repository.dart
│   │   │   │   └── leave_api.dart
│   │   │   ├── domain/
│   │   │   │   ├── leave_request_model.dart
│   │   │   │   ├── leave_type_model.dart
│   │   │   │   └── leave_balance_model.dart
│   │   │   ├── presentation/
│   │   │   │   ├── leave_list_screen.dart
│   │   │   │   ├── leave_apply_screen.dart
│   │   │   │   ├── leave_detail_screen.dart
│   │   │   │   ├── leave_approval_screen.dart
│   │   │   │   └── leave_calendar_screen.dart   # ← IMPLEMENT
│   │   │   └── providers/
│   │   │       └── leave_provider.dart
│   │   │
│   │   ├── attendance/
│   │   │   ├── data/
│   │   │   │   └── attendance_repository.dart
│   │   │   ├── domain/
│   │   │   │   └── attendance_model.dart
│   │   │   ├── presentation/
│   │   │   │   ├── attendance_screen.dart
│   │   │   │   └── attendance_history_screen.dart
│   │   │   └── providers/
│   │   │       └── attendance_provider.dart
│   │   │
│   │   ├── documents/
│   │   │   ├── data/
│   │   │   │   └── document_repository.dart
│   │   │   ├── domain/
│   │   │   │   └── document_model.dart
│   │   │   ├── presentation/
│   │   │   │   ├── document_list_screen.dart    # ← IMPLEMENT
│   │   │   │   ├── document_upload_screen.dart  # ← IMPLEMENT
│   │   │   │   └── document_viewer_screen.dart  # ← IMPLEMENT
│   │   │   └── providers/
│   │   │       └── document_provider.dart
│   │   │
│   │   ├── notifications/
│   │   │   ├── data/
│   │   │   │   └── notification_repository.dart
│   │   │   ├── domain/
│   │   │   │   └── notification_model.dart
│   │   │   ├── presentation/
│   │   │   │   └── notification_list_screen.dart
│   │   │   └── providers/
│   │   │       └── notification_provider.dart
│   │   │
│   │   └── settings/
│   │       ├── data/
│   │       │   └── settings_repository.dart
│   │       ├── domain/
│   │       │   └── settings_model.dart
│   │       ├── presentation/
│   │       │   ├── settings_screen.dart
│   │       │   ├── profile_screen.dart
│   │       │   ├── language_settings_screen.dart  # ← IMPLEMENT
│   │       │   ├── privacy_settings_screen.dart   # ← IMPLEMENT
│   │       │   ├── about_screen.dart              # ← IMPLEMENT
│   │       │   └── terms_screen.dart              # ← IMPLEMENT
│   │       └── providers/
│   │           └── settings_provider.dart
│   │
│   ├── l10n/
│   │   ├── app_en.arb                 # English (BASELINE - 197+ keys)
│   │   ├── app_ms.arb                 # Bahasa Malaysia
│   │   ├── app_id.arb                 # Bahasa Indonesia
│   │   ├── app_th.arb                 # Thai
│   │   ├── app_vi.arb                 # Vietnamese
│   │   ├── app_tl.arb                 # Filipino/Tagalog
│   │   ├── app_zh.arb                 # Chinese Simplified
│   │   ├── app_ta.arb                 # Tamil
│   │   ├── app_bn.arb                 # Bengali
│   │   ├── app_ne.arb                 # Nepali
│   │   ├── app_km.arb                 # Khmer
│   │   └── app_my.arb                 # Myanmar Unicode
│   │
│   └── generated/                     # Generated l10n files (gitignored)
│
├── test/
│   ├── unit/
│   │   ├── statutory_calculator_test.dart
│   │   ├── date_utils_test.dart
│   │   └── validators_test.dart
│   │
│   ├── widget/
│   │   ├── login_screen_test.dart
│   │   ├── payslip_card_test.dart
│   │   ├── leave_form_test.dart
│   │   └── dashboard_test.dart
│   │
│   └── integration/
│       └── app_test.dart
│
└── android/
    └── app/
        └── src/
            └── main/
                └── AndroidManifest.xml  # Permissions
```

---

## 📁 infrastructure/

```
infrastructure/
├── docker/
│   ├── backend/
│   │   └── Dockerfile.prod           # Production backend image
│   ├── nginx/
│   │   ├── nginx.conf                # Nginx configuration
│   │   └── ssl/                      # SSL certificates
│   └── redis/
│       └── redis.conf                # Redis configuration
│
├── scripts/
│   ├── deploy.sh                     # Deployment script
│   ├── backup.sh                     # Database backup
│   ├── restore.sh                    # Database restore
│   └── health-check.sh               # Health check script
│
└── monitoring/
    ├── prometheus.yml                # Prometheus config
    ├── grafana/
    │   └── dashboards/
    │       └── kerjaflow.json        # KerjaFlow dashboard
    └── alertmanager.yml              # Alert configuration
```

---

## 📁 database/

```
database/
├── migrations/
│   ├── 001_initial_schema.sql
│   ├── 002_statutory_rates.sql
│   ├── 003_public_holidays.sql
│   ├── 004_leave_types.sql
│   ├── 005_user_devices.sql
│   ├── 006_audit_tables.sql
│   └── ...
│
├── seeds/
│   ├── statutory_rates_my.sql        # Malaysia rates
│   ├── statutory_rates_sg.sql        # Singapore rates
│   ├── public_holidays_2025.sql      # 2025 holidays
│   └── public_holidays_2026.sql      # 2026 holidays
│
└── scripts/
    ├── create_db.sh
    ├── migrate.sh
    └── seed.sh
```

---

## 📁 docs/ - Documentation

```
docs/
├── specs/
│   ├── 01_Data_Foundation.md
│   ├── 02_API_Contract.md
│   ├── 03_OpenAPI.yaml
│   ├── 04_Business_Logic.md
│   ├── 05_Quality_Specification.md
│   ├── 06_Security_Hardening.md
│   ├── 07_Operations_Runbook.md
│   ├── 08_Technical_Addendum.md
│   ├── 09_Mobile_UX_Specification.md
│   └── 10_Implementation_Plan.md
│
├── statutory/
│   ├── Malaysian_HR_Practitioner_Playbook.md
│   ├── Indonesian_HR_Practitioner_Playbook.md
│   ├── Singapore_HR_Operations_Guide.md
│   ├── ASEAN_Statutory_Database_2025_2026.md
│   └── ASEAN_Public_Holiday_Database.md
│
├── integration/
│   └── ERP_Integration_Architecture.md
│
├── audit/
│   └── PRODUCTION_READINESS_AUDIT_2025-12-28.md
│
├── api/
│   ├── authentication.md
│   ├── payslip.md
│   ├── leave.md
│   └── error_codes.md
│
└── translations/
    ├── KerjaFlow_EN_Baseline_Authoritative.xlsx
    ├── KerjaFlow_BM_Translation_Verification.xlsx
    ├── KerjaFlow_Translation_ID_Bahasa_Indonesia_Verified.xlsx
    ├── KerjaFlow_i18n_TH_Verified.xlsx
    ├── KerjaFlow_i18n_VI_Verified.xlsx
    ├── KerjaFlow_i18n_TL_Verified.xlsx
    ├── KerjaFlow_i18n_ZHCN_Verified.xlsx
    ├── KerjaFlow_i18n_TA_Verified.xlsx
    ├── KerjaFlow_i18n_BN_Verified.xlsx
    ├── KerjaFlow_i18n_NE_Verified.xlsx
    ├── KerjaFlow_i18n_KM_Verified.xlsx
    └── KerjaFlow_i18n_MY_Verified.xlsx
```

---

## 📁 .github/ (If using GitHub - Optional with KBS)

```
.github/
├── CODEOWNERS                        # Code ownership
├── PULL_REQUEST_TEMPLATE.md          # PR template
├── ISSUE_TEMPLATE/
│   ├── bug_report.md
│   └── feature_request.md
└── workflows/                        # Optional if using KBS
    ├── backend-ci.yml.disabled       # Disabled - use KBS instead
    └── mobile-ci.yml.disabled        # Disabled - use KBS instead
```

---

## 📄 CRITICAL FILES SUMMARY

### Must Create (Currently Missing)

| File | Priority | Purpose |
|------|----------|---------|
| `backend/.../kf_user_device.py` | BLOCKER | Device registration model |
| `mobile/.../document_list_screen.dart` | HIGH | Document listing |
| `mobile/.../document_upload_screen.dart` | HIGH | Document upload |
| `mobile/.../document_viewer_screen.dart` | HIGH | Document viewing |
| `mobile/.../payslip_pdf_viewer.dart` | HIGH | PDF payslip viewer |
| `mobile/.../leave_calendar_screen.dart` | MEDIUM | Leave calendar |
| `mobile/.../language_settings_screen.dart` | MEDIUM | Language settings |
| `mobile/.../privacy_settings_screen.dart` | MEDIUM | Privacy settings |
| `mobile/.../about_screen.dart` | LOW | About page |
| `mobile/.../terms_screen.dart` | LOW | Terms of service |

### Must Fix (Currently Broken)

| File | Issue | Fix |
|------|-------|-----|
| `backend/.../config.py` | JWT uses HS256 | Change to RS256 |
| `backend/.../auth_controller.py` | Refresh token 30 days | Change to 7 days |
| `mobile/lib/l10n/app_zh.arb` | Key mismatch | Align with EN baseline |
| `mobile/lib/l10n/app_km.arb` | Missing keys | Add missing 77 keys |

### Must Verify (Status Unknown)

| File | Verification Needed |
|------|---------------------|
| `mobile/.../dio_client.dart` | Certificate pinning implemented? |
| `mobile/.../root_detector.dart` | Root detection working? |
| `mobile/.../screenshot_guard.dart` | Screenshot prevention active? |

---

## 📊 FILE COUNT SUMMARY

| Directory | Expected Files | Current | Gap |
|-----------|----------------|---------|-----|
| Backend Models | 19 | 18 | 1 |
| Backend Controllers | 10 | 10 | 0 |
| Mobile Screens | 27 | 17 | 10 |
| ARB Files | 12 | 12 | 0 (but 2 misaligned) |
| Tests (Backend) | ~15 | ~22 | +7 |
| Tests (Mobile) | ~20 | ~14 | -6 |

---

*This manifest represents the complete file structure for KerjaFlow Gold Standard.*

*Last Updated: January 2026*
