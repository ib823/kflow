# KerjaFlow Claude Code CLI Complete Action Plan

## EXTREME KIASU EXECUTION GUIDE

**Generated:** January 9, 2026  
**Repository:** https://github.com/ib823/kflow  
**Methodology:** Zero-Trust, Anti-Hallucination, 100% Evidence-Based  

---

## EXECUTIVE SUMMARY

### Current State Analysis

| Category | Spec Target | Current Implementation | Gap |
|----------|-------------|------------------------|-----|
| Backend Models | 20 files | 18 files | **-2 MISSING** |
| API Controllers | 10 files | 10 files | ✅ Complete |
| Mobile Screens | 27 screens | 17 screens | **-10 MISSING** |
| i18n Languages | 12 × 343 keys | Varies (102-343) | **11 INCOMPLETE** |
| JWT Algorithm | RS256 | HS256 | **🔴 CRITICAL** |
| CI/CD Pipelines | 4 active | 0 active (disabled) | **🔴 CRITICAL** |
| Test Coverage | ≥70% | Unknown | **⚠️ UNKNOWN** |

### Critical Blockers (4)

| Priority | Issue | Risk | Time |
|----------|-------|------|------|
| P0 | JWT uses HS256 instead of RS256 | Security vulnerability | 8h |
| P0 | CI/CD pipelines disabled | No quality gates | 4h |
| P0 | `kf_user_device.py` model missing | Import error will crash | 2h |
| P0 | Translation files incomplete | UI will show raw keys | 8h |

---

## PHASE 1: CRITICAL BLOCKERS (Day 1-2)

### TASK 1.1: Create Missing Model File `kf_user_device.py`

**Why Critical:** The `models/__init__.py` imports this file but it doesn't exist. Odoo will crash on startup.

```bash
# Claude Code CLI Command
claude code "Create the missing file backend/odoo/addons/kerjaflow/models/kf_user_device.py with the following requirements:
- Odoo model name: kf.user.device
- Fields: id, user_id (Many2one to kf.user), device_id (string), device_name, device_type (phone/tablet), os_version, app_version, push_token, last_active (datetime), is_trusted (boolean), created_at, updated_at
- Add biometric_enabled (boolean) and root_detected (boolean) fields
- Include security constraints and proper access rights
- Follow the existing patterns from kf_user.py
- Add to __manifest__.py data list if needed"
```

**Expected Output:** `backend/odoo/addons/kerjaflow/models/kf_user_device.py` (≈150 lines)

---

### TASK 1.2: Migrate JWT from HS256 to RS256

**Why Critical:** HS256 (symmetric) is insecure for distributed systems. RS256 (asymmetric) is required.

```bash
# Claude Code CLI Command
claude code "Migrate JWT authentication from HS256 to RS256:

1. Update backend/odoo/addons/kerjaflow/controllers/auth_controller.py:
   - Change algorithm='HS256' to algorithm='RS256'
   - Load private key from environment variable JWT_PRIVATE_KEY
   - Use public key for token verification
   - Add key rotation support

2. Update backend/kerjaflow/config.py:
   - Change _jwt_algorithm = 'HS256' to 'RS256'
   - Add methods to load RSA keys from environment or files

3. Create infrastructure/scripts/generate_jwt_keys.sh:
   - Generate RSA 2048-bit keypair
   - Output instructions for .env configuration
   
4. Update .env.example:
   - Add JWT_PRIVATE_KEY and JWT_PUBLIC_KEY placeholders
   - Add comments explaining RS256 requirement

5. Update mobile/lib/core/network/dio_client.dart:
   - Ensure token handling is compatible with RS256

Ensure all existing tests still pass after migration."
```

**Expected Files Modified/Created:**
- `backend/odoo/addons/kerjaflow/controllers/auth_controller.py`
- `backend/kerjaflow/config.py`
- `infrastructure/scripts/generate_jwt_keys.sh` (NEW)
- `.env.example`

---

### TASK 1.3: Enable CI/CD Pipelines

**Why Critical:** Quality gates are disabled. No automated testing or security scanning.

```bash
# Claude Code CLI Command
claude code "Enable and configure CI/CD pipelines:

1. Rename .github/workflows/e2e-tests.yml.disabled to e2e-tests.yml
2. Rename .github/workflows/release.yml.disabled to release.yml

3. Create .github/workflows/quality-gates.yml with:
   - Trigger on: push to main/develop, all PRs
   - Jobs:
     a) lint-backend: Run black, flake8, isort on backend/
     b) lint-mobile: Run flutter analyze on mobile/
     c) security-scan: Run bandit, safety, pip-audit on backend/
     d) test-backend: Run pytest with coverage
     e) test-mobile: Run flutter test with coverage
     f) build-mobile: Build APK and verify size < 50MB
   - Use matrix for Python 3.10, 3.11
   - Cache dependencies
   - Fail fast on security issues

4. Create .github/workflows/dependency-audit.yml:
   - Run weekly on Sunday
   - Check for vulnerable dependencies
   - Create issues for findings

5. Update .kbs/config.yaml to reference GitHub Actions

All workflows must use FREE GitHub Actions minutes only."
```

**Expected Files Created:**
- `.github/workflows/e2e-tests.yml` (renamed)
- `.github/workflows/release.yml` (renamed)
- `.github/workflows/quality-gates.yml` (NEW)
- `.github/workflows/dependency-audit.yml` (NEW)

---

### TASK 1.4: Complete ALL Translation Files

**Why Critical:** 11 of 12 languages are incomplete. Users will see raw keys.

```bash
# Claude Code CLI Command
claude code "Complete ALL translation ARB files to match app_en.arb baseline (343 keys):

CURRENT STATE (keys per file):
- en: 343 (BASELINE)
- ms: 279 (-64 keys)
- id: 279 (-64 keys)
- th: 178 (-165 keys)
- vi: 279 (-64 keys)
- tl: 126 (-217 keys)
- zh: 279 (-64 keys)
- ta: 144 (-199 keys)
- bn: 279 (-64 keys)
- ne: 279 (-64 keys)
- km: 105 (-238 keys)
- my: 102 (-241 keys)

REQUIREMENTS:
1. Extract ALL 343 keys from app_en.arb
2. For each language file, identify missing keys
3. Add translations following these rules:
   - Statutory terms (EPF, SOCSO, BPJS, CPF) must be preserved alongside local translation
   - Use authoritative government sources for official terms
   - Malaysian Malay ≠ Indonesian - treat as separate languages
   - Myanmar must use Unicode, NOT Zawgyi
   - Include proper pluralization where needed

4. For critical languages (km, my, th, ta, tl) that are severely incomplete:
   - Prioritize: navigation, login, payslip, leave, error messages
   - Add placeholder comments for terms needing native speaker review

5. Verify all ARB files are valid JSON
6. Run flutter gen-l10n to regenerate localizations

Use the verified translation files from the project knowledge for reference:
- KerjaFlow_BM_Translation_Verification.xlsx
- KerjaFlow_Translation_ID_Bahasa_Indonesia_Verified.xlsx
- KerjaFlow_i18n_*.xlsx files"
```

**Expected Files Modified:**
- `mobile/lib/l10n/app_ms.arb` (+64 keys)
- `mobile/lib/l10n/app_id.arb` (+64 keys)
- `mobile/lib/l10n/app_th.arb` (+165 keys)
- `mobile/lib/l10n/app_vi.arb` (+64 keys)
- `mobile/lib/l10n/app_tl.arb` (+217 keys)
- `mobile/lib/l10n/app_zh.arb` (+64 keys)
- `mobile/lib/l10n/app_ta.arb` (+199 keys)
- `mobile/lib/l10n/app_bn.arb` (+64 keys)
- `mobile/lib/l10n/app_ne.arb` (+64 keys)
- `mobile/lib/l10n/app_km.arb` (+238 keys)
- `mobile/lib/l10n/app_my.arb` (+241 keys)

---

## PHASE 2: MISSING SCREENS (Day 3-5)

### TASK 2.1: Create Document Management Screens

```bash
# Claude Code CLI Command
claude code "Create document management screens following the Mobile UX Specification:

1. Create mobile/lib/features/documents/presentation/screens/document_list_screen.dart:
   - Display user's documents in a grid/list
   - Show document type icons, expiry dates
   - Filter by category (work permit, contract, certificate, etc.)
   - Support pull-to-refresh
   - Use existing document_card widget if available, else create it

2. Create mobile/lib/features/documents/presentation/screens/document_upload_screen.dart:
   - Camera and gallery picker
   - Document type selector
   - Optional expiry date picker
   - Upload progress indicator
   - Error handling with retry

3. Create mobile/lib/features/documents/presentation/screens/document_viewer_screen.dart:
   - Full-screen image/PDF viewer
   - Pinch-to-zoom for images
   - PDF viewer using flutter_pdfview or similar
   - Share and download actions
   - Add FLAG_SECURE for sensitive documents

4. Add routes to app_router.dart:
   - /documents → DocumentListScreen
   - /documents/upload → DocumentUploadScreen
   - /documents/:id → DocumentViewerScreen

5. Create necessary providers using Riverpod

Follow existing patterns from payslip screens."
```

---

### TASK 2.2: Create Payslip PDF Viewer

```bash
# Claude Code CLI Command
claude code "Create payslip PDF viewer screen:

1. Create mobile/lib/features/payslip/presentation/screens/payslip_pdf_screen.dart:
   - Receive payslip ID as parameter
   - Fetch PDF from API endpoint /api/v1/payslip/{id}/pdf
   - Show loading state with skeleton
   - Display PDF using flutter_pdfview
   - Add FLAG_SECURE to prevent screenshots
   - Download button to save to device
   - Share button
   - Handle offline scenario with cached PDFs
   - Error state with retry

2. Add route to app_router.dart:
   - /payslip/:id/pdf → PayslipPdfScreen

3. Update payslip_detail_screen.dart:
   - Add 'View PDF' button that navigates to PDF viewer

4. Add l10n keys:
   - payslipViewPdf, payslipDownloadPdf, payslipSharePdf

Follow security requirements from CLAUDE.md."
```

---

### TASK 2.3: Create Leave Calendar Screen

```bash
# Claude Code CLI Command
claude code "Create leave calendar screen:

1. Create mobile/lib/features/leave/presentation/screens/leave_calendar_screen.dart:
   - Monthly calendar view using table_calendar package
   - Mark days with:
     - User's approved leave (green)
     - User's pending leave (yellow)
     - Team member leave (if manager, different color)
     - Public holidays (red)
   - Tap on date to see leave details
   - Filter by team/department (for managers)
   - Legend showing color meanings
   - Month navigation

2. Create mobile/lib/features/leave/data/models/calendar_event.dart:
   - Model for calendar events

3. Add route to app_router.dart:
   - /leave/calendar → LeaveCalendarScreen

4. Update leave_balance_screen.dart:
   - Add calendar icon in app bar that navigates to calendar

5. Add l10n keys for calendar-related UI

Consider accessibility: add semantic labels for screen readers."
```

---

### TASK 2.4: Create Approval Detail Screen

```bash
# Claude Code CLI Command
claude code "Create approval detail screen for managers:

1. Create mobile/lib/features/leave/presentation/screens/approval_detail_screen.dart:
   - Show complete leave request details
   - Employee info (name, department, job title)
   - Leave type, dates, duration
   - Reason/justification
   - Attachment viewer (if medical certificate attached)
   - Team calendar snippet showing impact
   - Approve button (green)
   - Reject button with mandatory reason dialog
   - Loading states for actions
   - Success/error feedback

2. Create mobile/lib/features/leave/presentation/widgets/rejection_reason_dialog.dart:
   - Text input for rejection reason
   - Confirm/Cancel buttons
   - Validation (reason required)

3. Add route to app_router.dart:
   - /approval/:id → ApprovalDetailScreen

4. Update notifications or approval list to navigate here

5. Add l10n keys:
   - approvalDetailTitle, approveButton, rejectButton, rejectionReason, etc.

Follow existing UI patterns from leave_request_screen.dart."
```

---

### TASK 2.5: Create Notification Detail Screen

```bash
# Claude Code CLI Command
claude code "Create notification detail screen:

1. Create mobile/lib/features/notifications/presentation/screens/notification_detail_screen.dart:
   - Show full notification content
   - Mark as read when opened
   - Deep link handling for different notification types:
     - LEAVE_APPROVED → navigate to leave detail
     - LEAVE_REJECTED → navigate to leave detail
     - PAYSLIP_AVAILABLE → navigate to payslip
     - DOCUMENT_EXPIRING → navigate to document
     - APPROVAL_PENDING → navigate to approval detail
   - Delete notification option
   - Timestamp display

2. Add route to app_router.dart:
   - /notifications/:id → NotificationDetailScreen

3. Update notifications_screen.dart:
   - Navigate to detail on tap

4. Add l10n keys for notification types

Handle notification actions properly."
```

---

### TASK 2.6: Create Settings Screens

```bash
# Claude Code CLI Command
claude code "Create complete settings screens:

1. Enhance mobile/lib/features/settings/presentation/screens/settings_screen.dart:
   - Language selector (navigates to language screen)
   - Theme toggle (light/dark/system)
   - Notification preferences
   - Biometric login toggle
   - Change PIN option
   - Change Password option
   - Clear cache option
   - App version display
   - Legal links (Privacy Policy, Terms of Service)
   - Logout button

2. Create mobile/lib/features/settings/presentation/screens/change_password_screen.dart:
   - Current password field
   - New password field with strength indicator
   - Confirm new password field
   - Validation rules display
   - Submit button with loading state
   - Success feedback and logout

3. Create mobile/lib/features/settings/presentation/screens/change_pin_screen.dart:
   - Current PIN entry (6 dots)
   - New PIN entry
   - Confirm new PIN entry
   - Validation for weak PINs (123456, 000000, etc.)
   - Success feedback

4. Create mobile/lib/features/settings/presentation/screens/about_screen.dart:
   - App logo
   - App name and version
   - Build number
   - Copyright info
   - Licenses button (shows licenses)
   - Links to support, website

5. Add routes to app_router.dart:
   - /settings → SettingsScreen
   - /settings/password → ChangePasswordScreen
   - /settings/pin → ChangePinScreen
   - /settings/about → AboutScreen

6. Add all l10n keys for settings"
```

---

## PHASE 3: SECURITY HARDENING (Day 6-7)

### TASK 3.1: Implement Certificate Pinning

```bash
# Claude Code CLI Command
claude code "Implement SSL certificate pinning in mobile app:

1. Update mobile/lib/core/network/dio_client.dart:
   - Add certificate pinning using dio_http2_adapter or manual validation
   - Pin both primary and backup certificates
   - Store certificate fingerprints in secure config

2. Create mobile/lib/core/security/certificate_pins.dart:
   - SHA-256 fingerprints for:
     - api.kerjaflow.my (production)
     - staging-api.kerjaflow.my (staging)
   - Include backup pins for certificate rotation

3. Add fallback behavior:
   - Log pinning failures to analytics
   - Block requests if pin validation fails

4. Create mobile/test/security/certificate_pinning_test.dart:
   - Test that invalid certificates are rejected
   - Test that valid certificates are accepted

Document the process for certificate rotation."
```

---

### TASK 3.2: Implement Root/Jailbreak Detection

```bash
# Claude Code CLI Command
claude code "Implement root/jailbreak detection:

1. Add flutter_jailbreak_detection package to pubspec.yaml

2. Create mobile/lib/core/security/device_security.dart:
   - Check for rooted/jailbroken device
   - Check for developer mode enabled
   - Check for USB debugging
   - Return security status object

3. Update mobile/lib/main.dart:
   - Run security check on app start
   - If rooted: show warning dialog, block access to payslip/PIN screens
   - Log device security status

4. Update mobile/lib/features/auth/presentation/screens/login_screen.dart:
   - Check device security before allowing login
   - Store root status in kf.user.device (root_detected field)

5. Create mobile/test/security/device_security_test.dart

Consider: Some users have legitimate rooted devices for work. Allow bypass with admin approval?"
```

---

### TASK 3.3: Implement Screenshot Prevention

```bash
# Claude Code CLI Command
claude code "Implement screenshot prevention on sensitive screens:

1. Create mobile/lib/core/security/secure_screen_mixin.dart:
   - Mixin that adds FLAG_SECURE on Android
   - Uses MethodChannel for native implementation

2. Create mobile/android/app/src/main/kotlin/.../SecureScreenPlugin.kt:
   - Native Android implementation for FLAG_SECURE

3. Apply to sensitive screens:
   - payslip_detail_screen.dart
   - payslip_pdf_screen.dart
   - pin_entry_screen.dart
   - pin_setup_screen.dart
   - change_pin_screen.dart
   - change_password_screen.dart
   - profile_screen.dart (personal info)

4. iOS equivalent:
   - Add blur overlay when app goes to background
   - Prevent screen recording

5. Test on actual devices

Document which screens have protection and why."
```

---

## PHASE 4: TEST COVERAGE (Day 8-10)

### TASK 4.1: Backend Unit Tests

```bash
# Claude Code CLI Command
claude code "Create comprehensive backend unit tests to achieve 70%+ coverage:

1. Create backend/tests/unit/test_statutory_calculator.py:
   - Test Malaysia EPF calculation (all brackets)
   - Test Malaysia SOCSO calculation (ceiling handling)
   - Test Malaysia EIS calculation
   - Test Singapore CPF calculation (all age brackets)
   - Test Indonesia BPJS calculation (all components)
   - Test Thailand SSO calculation
   - Test Philippines SSS calculation (bracket lookup)
   - Test date-based rate lookup (use payslip_date, not current date)
   - Test edge cases: minimum wage, ceiling, foreign workers
   - At least 50 test cases

2. Create backend/tests/unit/test_leave_calculator.py:
   - Test working days calculation
   - Test public holiday exclusion
   - Test half-day leave
   - Test pro-rata entitlement
   - Test carry-forward rules
   - Test balance calculation
   - At least 30 test cases

3. Create backend/tests/unit/test_payroll_engine.py:
   - Test gross to net calculation
   - Test line item generation
   - Test statutory deduction accuracy
   - Test rounding rules

4. Create pytest.ini with coverage settings:
   - Minimum 70% coverage required
   - Fail build if below threshold

5. Update backend/pyproject.toml with test dependencies

Run: pytest --cov=kerjaflow --cov-report=html"
```

---

### TASK 4.2: Mobile Widget Tests

```bash
# Claude Code CLI Command
claude code "Create comprehensive Flutter widget tests:

1. Create mobile/test/widget/auth/login_screen_test.dart:
   - Test email field validation
   - Test password field validation
   - Test login button state
   - Test error message display
   - Test remember me checkbox
   - Test forgot password navigation

2. Create mobile/test/widget/payslip/payslip_card_test.dart:
   - Test card display
   - Test month/year formatting
   - Test amount formatting with currency
   - Test tap action

3. Create mobile/test/widget/leave/leave_balance_card_test.dart:
   - Test balance display
   - Test progress bar
   - Test leave type name

4. Create mobile/test/widget/leave/leave_apply_form_test.dart:
   - Test form validation
   - Test date picker
   - Test leave type dropdown
   - Test submit button state

5. Create mobile/test/widget/common/error_widget_test.dart:
   - Test error message display
   - Test retry button

6. Configure test coverage in pubspec.yaml

Run: flutter test --coverage"
```

---

### TASK 4.3: Integration Tests

```bash
# Claude Code CLI Command
claude code "Create mobile integration tests:

1. Create mobile/integration_test/app_test.dart:
   - Test complete login flow
   - Test PIN setup flow
   - Test view payslip flow
   - Test apply leave flow
   - Test logout flow

2. Create mobile/integration_test/offline_test.dart:
   - Test offline mode detection
   - Test cached data display
   - Test sync when online

3. Add to CI/CD pipeline:
   - Run on emulator/simulator
   - Generate test report

Use flutter_driver or integration_test package."
```

---

## PHASE 5: DOCUMENTATION & POLISH (Day 11-12)

### TASK 5.1: Update README.md

```bash
# Claude Code CLI Command
claude code "Update README.md with comprehensive documentation:

1. Add project badges:
   - Build status
   - Test coverage
   - License
   - Flutter version
   - Python version

2. Add sections:
   - Features overview
   - Screenshots (placeholder links)
   - Quick start guide
   - Development setup (backend + mobile)
   - Environment variables reference
   - API documentation link
   - Contributing guide
   - License

3. Add architecture diagram (Mermaid)

4. Add deployment instructions

Make it professional and enterprise-ready."
```

---

### TASK 5.2: Create CHANGELOG.md

```bash
# Claude Code CLI Command
claude code "Create CHANGELOG.md following Keep a Changelog format:

## [1.0.0] - 2026-01-XX

### Added
- 9-country ASEAN statutory compliance
- 12-language support
- 27 mobile screens
- JWT RS256 authentication
- Certificate pinning
- Root detection
- Screenshot prevention
- Offline-first architecture

### Security
- Migrated from HS256 to RS256
- Added certificate pinning
- Added root/jailbreak detection
- Added FLAG_SECURE on sensitive screens

### Fixed
- Missing kf_user_device model
- Incomplete translation files

Include all features implemented."
```

---

### TASK 5.3: API Documentation

```bash
# Claude Code CLI Command
claude code "Generate comprehensive API documentation:

1. Update docs/specs/03_OpenAPI.yaml:
   - Verify all 39 endpoints are documented
   - Add request/response examples
   - Add error responses
   - Add authentication headers

2. Create docs/api/README.md:
   - API overview
   - Authentication guide
   - Rate limiting info
   - Error codes reference

3. Consider adding Swagger UI to development environment

Verify OpenAPI spec is valid using swagger-cli validate."
```

---

## PHASE 6: FINAL VERIFICATION (Day 13-14)

### TASK 6.1: Run Complete Quality Gates

```bash
# Claude Code CLI Command
claude code "Run all quality gates and fix any issues:

1. Backend:
   black --check backend/
   flake8 backend/
   isort --check-only backend/
   bandit -r backend/ -ll
   safety check -r backend/requirements.txt
   pip-audit -r backend/requirements.txt
   pytest --cov=kerjaflow --cov-fail-under=70

2. Mobile:
   flutter analyze --fatal-infos --fatal-warnings
   flutter test --coverage
   dart format --set-exit-if-changed lib/

3. Security:
   Check no secrets in codebase (use git-secrets or similar)
   Verify .env.example has all required variables
   Verify .gitignore excludes sensitive files

4. Build:
   flutter build apk --release
   Verify APK size < 50MB
   
Fix ALL issues found before proceeding."
```

---

### TASK 6.2: Create Verification Checklist

```bash
# Claude Code CLI Command
claude code "Create docs/VERIFICATION_CHECKLIST.md with all items verified:

## Pre-Production Checklist

### Security ✅
- [ ] JWT uses RS256
- [ ] Certificate pinning enabled
- [ ] Root detection enabled
- [ ] Screenshot prevention on sensitive screens
- [ ] No secrets in codebase
- [ ] Rate limiting configured

### Compliance ✅
- [ ] All 8 ASEAN countries configured
- [ ] Malaysia EPF foreign worker rates (Oct 2025)
- [ ] Singapore CPF 2026 rates
- [ ] Thailand SSO 2026 ceiling
- [ ] All statutory calculations use payslip_date

### Mobile ✅
- [ ] All 27 screens implemented
- [ ] All 12 languages complete (343 keys each)
- [ ] Offline mode tested
- [ ] APK size < 50MB
- [ ] Cold start < 3 seconds

### Backend ✅
- [ ] All 20 models present
- [ ] All 39 API endpoints working
- [ ] Test coverage ≥ 70%
- [ ] Database migrations applied

### CI/CD ✅
- [ ] Quality gates passing
- [ ] Security scans clean
- [ ] E2E tests passing

Mark each item as verified with date and evidence."
```

---

## FILES TO BE INCLUDED IN REPO (Complete List)

### New Files to Create (32)

```
backend/odoo/addons/kerjaflow/models/kf_user_device.py (NEW)
infrastructure/scripts/generate_jwt_keys.sh (NEW)
.github/workflows/quality-gates.yml (NEW)
.github/workflows/dependency-audit.yml (NEW)

mobile/lib/features/documents/presentation/screens/document_list_screen.dart (NEW)
mobile/lib/features/documents/presentation/screens/document_upload_screen.dart (NEW)
mobile/lib/features/documents/presentation/screens/document_viewer_screen.dart (NEW)
mobile/lib/features/payslip/presentation/screens/payslip_pdf_screen.dart (NEW)
mobile/lib/features/leave/presentation/screens/leave_calendar_screen.dart (NEW)
mobile/lib/features/leave/presentation/screens/approval_detail_screen.dart (NEW)
mobile/lib/features/leave/presentation/widgets/rejection_reason_dialog.dart (NEW)
mobile/lib/features/notifications/presentation/screens/notification_detail_screen.dart (NEW)
mobile/lib/features/settings/presentation/screens/change_password_screen.dart (NEW)
mobile/lib/features/settings/presentation/screens/change_pin_screen.dart (NEW)
mobile/lib/features/settings/presentation/screens/about_screen.dart (NEW)

mobile/lib/core/security/certificate_pins.dart (NEW)
mobile/lib/core/security/device_security.dart (NEW)
mobile/lib/core/security/secure_screen_mixin.dart (NEW)
mobile/android/app/src/main/kotlin/.../SecureScreenPlugin.kt (NEW)

backend/tests/unit/test_statutory_calculator.py (NEW - if not exists)
backend/tests/unit/test_leave_calculator.py (NEW - if not exists)
backend/tests/unit/test_payroll_engine.py (NEW - if not exists)
mobile/test/widget/auth/login_screen_test.dart (NEW)
mobile/test/widget/payslip/payslip_card_test.dart (NEW)
mobile/test/widget/leave/leave_balance_card_test.dart (NEW)
mobile/test/widget/leave/leave_apply_form_test.dart (NEW)
mobile/test/widget/common/error_widget_test.dart (NEW)
mobile/integration_test/app_test.dart (NEW)
mobile/integration_test/offline_test.dart (NEW)

CHANGELOG.md (NEW)
docs/VERIFICATION_CHECKLIST.md (NEW)
docs/api/README.md (NEW)
```

### Files to Modify (25)

```
backend/odoo/addons/kerjaflow/controllers/auth_controller.py (JWT RS256)
backend/kerjaflow/config.py (JWT RS256)
.env.example (JWT keys)
.github/workflows/e2e-tests.yml (rename from .disabled)
.github/workflows/release.yml (rename from .disabled)

mobile/lib/l10n/app_ms.arb (complete translations)
mobile/lib/l10n/app_id.arb (complete translations)
mobile/lib/l10n/app_th.arb (complete translations)
mobile/lib/l10n/app_vi.arb (complete translations)
mobile/lib/l10n/app_tl.arb (complete translations)
mobile/lib/l10n/app_zh.arb (complete translations)
mobile/lib/l10n/app_ta.arb (complete translations)
mobile/lib/l10n/app_bn.arb (complete translations)
mobile/lib/l10n/app_ne.arb (complete translations)
mobile/lib/l10n/app_km.arb (complete translations)
mobile/lib/l10n/app_my.arb (complete translations)

mobile/lib/core/router/app_router.dart (add new routes)
mobile/lib/core/network/dio_client.dart (certificate pinning)
mobile/lib/main.dart (security checks)
mobile/lib/features/payslip/presentation/screens/payslip_detail_screen.dart (PDF button, FLAG_SECURE)
mobile/lib/features/settings/presentation/screens/settings_screen.dart (complete settings)

mobile/pubspec.yaml (new dependencies)
README.md (comprehensive update)
docs/specs/03_OpenAPI.yaml (verify completeness)
```

---

## CLAUDE CODE CLI BATCH EXECUTION

### Execute All Tasks in Order

```bash
# Clone repository
git clone https://github.com/ib823/kflow.git
cd kflow

# Phase 1: Critical Blockers
claude code --task "TASK 1.1" --file CLAUDE.md
claude code --task "TASK 1.2" --file CLAUDE.md
claude code --task "TASK 1.3" --file CLAUDE.md
claude code --task "TASK 1.4" --file CLAUDE.md

# Phase 2: Missing Screens
claude code --task "TASK 2.1" --file CLAUDE.md
claude code --task "TASK 2.2" --file CLAUDE.md
claude code --task "TASK 2.3" --file CLAUDE.md
claude code --task "TASK 2.4" --file CLAUDE.md
claude code --task "TASK 2.5" --file CLAUDE.md
claude code --task "TASK 2.6" --file CLAUDE.md

# Phase 3: Security
claude code --task "TASK 3.1" --file CLAUDE.md
claude code --task "TASK 3.2" --file CLAUDE.md
claude code --task "TASK 3.3" --file CLAUDE.md

# Phase 4: Testing
claude code --task "TASK 4.1" --file CLAUDE.md
claude code --task "TASK 4.2" --file CLAUDE.md
claude code --task "TASK 4.3" --file CLAUDE.md

# Phase 5: Documentation
claude code --task "TASK 5.1" --file CLAUDE.md
claude code --task "TASK 5.2" --file CLAUDE.md
claude code --task "TASK 5.3" --file CLAUDE.md

# Phase 6: Verification
./.kbs/kbs.sh full
```

---

## TIMELINE SUMMARY

| Phase | Tasks | Duration | Cumulative |
|-------|-------|----------|------------|
| Phase 1: Critical Blockers | 4 tasks | 2 days | Day 1-2 |
| Phase 2: Missing Screens | 6 tasks | 3 days | Day 3-5 |
| Phase 3: Security | 3 tasks | 2 days | Day 6-7 |
| Phase 4: Testing | 3 tasks | 3 days | Day 8-10 |
| Phase 5: Documentation | 3 tasks | 2 days | Day 11-12 |
| Phase 6: Verification | 2 tasks | 2 days | Day 13-14 |
| **TOTAL** | **21 tasks** | **14 days** | **2 weeks** |

With 2 developers: **7 days (1 week)**  
With 4 developers: **3.5 days**

---

## SUCCESS CRITERIA

Before declaring production-ready:

1. ✅ All 4 critical blockers resolved
2. ✅ JWT uses RS256 (verified by test)
3. ✅ All 27 screens implemented in Flutter
4. ✅ All 12 language files have 343 keys
5. ✅ Test coverage ≥70% for backend and mobile
6. ✅ All CI/CD pipelines passing
7. ✅ Security scan shows 0 critical/high issues
8. ✅ APK size < 50MB
9. ✅ Cold start < 3 seconds
10. ✅ All statutory calculations verified against government rates

---

*This is the complete action plan for making KerjaFlow production-ready.*
*Execute with EXTREME KIASU methodology - no shortcuts, no assumptions.*
