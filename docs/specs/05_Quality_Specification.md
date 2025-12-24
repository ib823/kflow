# KerjaFlow Quality Specification

**Error Catalog • Test Strategy • Quality Gates • CI/CD**

Version 1.0 — December 2025

---

## PART 1: ERROR CATALOG

### 1. Error Response Structure

```json
{
  "code": "INSUFFICIENT_BALANCE",
  "message": "Insufficient leave balance",
  "details": {
    "available": 2.0,
    "requested": 5.0,
    "leave_type": "Annual Leave"
  },
  "field_errors": null
}
```

### 2. Authentication Errors

| # | Error Code | HTTP | Description |
|---|------------|------|-------------|
| A01 | INVALID_CREDENTIALS | 401 | Username or password is incorrect |
| A02 | ACCOUNT_LOCKED | 423 | Account locked due to failed login attempts |
| A03 | ACCOUNT_INACTIVE | 403 | User account is deactivated |
| A04 | TOKEN_EXPIRED | 401 | Access token has expired |
| A05 | TOKEN_INVALID | 401 | Access token is malformed or tampered |
| A06 | REFRESH_TOKEN_EXPIRED | 401 | Refresh token has expired, re-login required |
| A07 | REFRESH_TOKEN_INVALID | 401 | Refresh token is invalid |
| A08 | SESSION_REVOKED | 401 | Session was terminated (new device login) |
| A09 | INVALID_PIN | 401 | PIN verification failed |
| A10 | PIN_REQUIRED | 403 | Operation requires PIN verification |
| A11 | PIN_NOT_SET | 400 | User has not set up a PIN |
| A12 | VERIFICATION_EXPIRED | 401 | PIN verification token expired (5 min) |
| A13 | PASSWORD_TOO_WEAK | 400 | Password does not meet requirements |
| A14 | PASSWORD_SAME | 400 | New password same as current password |

#### Localized Messages

| Code | English (en) | Bahasa Malaysia (ms) |
|------|--------------|---------------------|
| INVALID_CREDENTIALS | Invalid username or password | Nama pengguna atau kata laluan tidak sah |
| ACCOUNT_LOCKED | Account locked. Try again in {minutes} minutes | Akaun dikunci. Cuba lagi dalam {minutes} minit |
| TOKEN_EXPIRED | Session expired. Please login again | Sesi tamat. Sila log masuk semula |
| INVALID_PIN | Invalid PIN. {remaining} attempts remaining | PIN tidak sah. {remaining} percubaan lagi |
| PIN_REQUIRED | Please enter your PIN to continue | Sila masukkan PIN anda untuk meneruskan |

### 3. Leave Management Errors

| # | Error Code | HTTP | Description |
|---|------------|------|-------------|
| L01 | INSUFFICIENT_BALANCE | 400 | Not enough leave balance for request |
| L02 | LEAVE_OVERLAP | 400 | Dates overlap with existing leave |
| L03 | INSUFFICIENT_NOTICE | 400 | Leave type requires more advance notice |
| L04 | ATTACHMENT_REQUIRED | 400 | Leave type requires supporting document |
| L05 | MAX_DAYS_EXCEEDED | 400 | Request exceeds max days per request |
| L06 | NO_WORKING_DAYS | 400 | No working days in selected period |
| L07 | INVALID_DATE_RANGE | 400 | End date before start date |
| L08 | DATE_IN_PAST | 400 | Cannot apply leave for past dates |
| L09 | HALF_DAY_MULTI_DAY | 400 | Half day only allowed for single day |
| L10 | LEAVE_NOT_FOUND | 404 | Leave request not found |
| L11 | CANNOT_CANCEL | 400 | Cannot cancel (already started/rejected) |
| L12 | CANNOT_APPROVE | 403 | Not authorized to approve this request |
| L13 | ALREADY_PROCESSED | 400 | Leave request already approved/rejected |

#### Localized Messages

| Code | English (en) | Bahasa Malaysia (ms) |
|------|--------------|---------------------|
| INSUFFICIENT_BALANCE | Insufficient balance. Available: {available} days | Baki tidak mencukupi. Tersedia: {available} hari |
| LEAVE_OVERLAP | You have leave on {date}. Please select different dates | Anda ada cuti pada {date}. Sila pilih tarikh lain |
| INSUFFICIENT_NOTICE | This leave requires {days} days notice | Cuti ini memerlukan notis {days} hari |
| ATTACHMENT_REQUIRED | Please attach your medical certificate | Sila lampirkan sijil perubatan anda |

### 4. Payslip Errors

| # | Error Code | HTTP | Description |
|---|------------|------|-------------|
| P01 | PAYSLIP_NOT_FOUND | 404 | Payslip does not exist |
| P02 | PAYSLIP_NOT_PUBLISHED | 403 | Payslip exists but not yet published |
| P03 | PDF_NOT_AVAILABLE | 404 | PDF has not been generated yet |
| P04 | IMPORT_FAILED | 400 | Payslip import failed |
| P05 | DUPLICATE_PAYSLIP | 400 | Payslip already exists for this period |

### 5. File & Document Errors

| # | Error Code | HTTP | Description |
|---|------------|------|-------------|
| F01 | FILE_TOO_LARGE | 413 | File exceeds maximum size limit |
| F02 | INVALID_FILE_TYPE | 400 | File type not allowed |
| F03 | UPLOAD_FAILED | 500 | File upload failed |
| F04 | DOCUMENT_NOT_FOUND | 404 | Document does not exist |

### 6. Network & Sync Errors (Client-Side)

| # | Error Code | User Message (en) | Action |
|---|------------|-------------------|--------|
| N01 | NETWORK_ERROR | No internet connection. Please check your network. | Show retry button |
| N02 | TIMEOUT | Request timed out. Please try again. | Show retry button |
| N03 | SERVER_UNAVAILABLE | Server is temporarily unavailable. Try again later. | Show retry with backoff |
| N04 | RATE_LIMITED | Too many requests. Please wait a moment. | Disable UI briefly |
| N05 | SYNC_FAILED | Could not sync. Will retry automatically. | Show sync icon |

---

## PART 2: TEST STRATEGY

### 9. Test Pyramid

```
        ┌───────────┐
        │    E2E    │  5%
        │  (10-15)  │
    ┌─────────────────┐
    │   Integration   │  20%
    │    (50-100)     │
┌─────────────────────────┐
│       Unit Tests        │  75%
│       (200-400)         │
└─────────────────────────┘
```

### 10. Backend Test Cases

#### Authentication Tests

| ID | Test Case | Input | Expected |
|----|-----------|-------|----------|
| T-A01 | Login with valid credentials | valid user/pass | 200, tokens returned |
| T-A02 | Login with wrong password | valid user, wrong pass | 401, INVALID_CREDENTIALS |
| T-A03 | Login with unknown user | unknown user | 401, INVALID_CREDENTIALS |
| T-A04 | Login after 5 failed attempts | 5 wrong passwords | 423, ACCOUNT_LOCKED |
| T-A05 | Refresh token (valid) | valid refresh token | 200, new access token |
| T-A06 | Refresh token (expired) | expired refresh token | 401, REFRESH_TOKEN_EXPIRED |
| T-A07 | Access protected endpoint | valid access token | 200, data returned |
| T-A08 | Access with expired token | expired access token | 401, TOKEN_EXPIRED |
| T-A09 | PIN setup | valid password + 6-digit PIN | 200, PIN saved |
| T-A10 | PIN verify (correct) | correct PIN | 200, verification token |
| T-A11 | PIN verify (wrong) | wrong PIN | 401, INVALID_PIN |
| T-A12 | Payslip without PIN token | no X-Verification-Token | 403, PIN_REQUIRED |

#### Leave Management Tests

| ID | Test Case | Input | Expected |
|----|-----------|-------|----------|
| T-L01 | Get leave balances | authenticated user | 200, array of balances |
| T-L02 | Submit leave (valid) | valid dates, sufficient balance | 201, request created |
| T-L03 | Submit leave (insufficient) | request > balance | 400, INSUFFICIENT_BALANCE |
| T-L04 | Submit leave (overlap) | dates overlap existing | 400, LEAVE_OVERLAP |
| T-L05 | Submit leave (past date) | date_from in past | 400, DATE_IN_PAST |
| T-L06 | Submit MC without attachment | MC type, no attachment | 400, ATTACHMENT_REQUIRED |
| T-L07 | Submit half-day multi-day | half_day=AM, 3 days | 400, HALF_DAY_MULTI_DAY |
| T-L08 | Cancel pending leave | PENDING status | 200, status=CANCELLED |
| T-L09 | Cancel approved future | APPROVED, date_from > today | 200, status=CANCELLED |
| T-L10 | Cancel past leave | date_from < today | 400, CANNOT_CANCEL |
| T-L11 | Approve as supervisor | is approver of employee | 200, status=APPROVED |
| T-L12 | Approve as non-supervisor | not approver | 403, CANNOT_APPROVE |
| T-L13 | Working days calc (no holidays) | Mon-Fri range | 5 days |
| T-L14 | Working days calc (with holiday) | Mon-Fri with 1 holiday | 4 days |
| T-L15 | Pro-rata new joiner | joined mid-year | Proportional entitlement |

#### Payslip Tests

| ID | Test Case | Input | Expected |
|----|-----------|-------|----------|
| T-P01 | List payslips | authenticated user | 200, published payslips only |
| T-P02 | Get payslip detail | valid ID + PIN token | 200, full payslip data |
| T-P03 | Get payslip without PIN | valid ID, no PIN token | 403, PIN_REQUIRED |
| T-P04 | Get other user's payslip | other employee's payslip ID | 404, PAYSLIP_NOT_FOUND |
| T-P05 | Download PDF | valid ID + PIN token | 200, application/pdf |

### 11. Mobile App Test Cases

#### Unit Tests

| ID | Test Case | Class/Function | Assertions |
|----|-----------|----------------|------------|
| T-M01 | Parse login response | LoginResponse.fromJson | Tokens extracted correctly |
| T-M02 | Parse payslip list | PayslipSummary.fromJson | All fields mapped |
| T-M03 | Working days calculation | calculateWorkingDays() | Matches server logic |
| T-M04 | Date formatting (en) | formatDate() with en | DD/MM/YYYY format |
| T-M05 | Currency formatting | formatCurrency() | RM X,XXX.XX format |
| T-M06 | Leave balance calculation | LeaveBalance model | balance = entitled + carried + adj - taken |
| T-M07 | PIN validation | validatePin() | 6 digits only |
| T-M08 | Password validation | validatePassword() | 8+ chars, uppercase, number |
| T-M09 | Token expiry check | isTokenExpired() | Correctly identifies expired |

#### Widget Tests

| ID | Test Case | Widget | Assertions |
|----|-----------|--------|------------|
| T-W01 | Dashboard renders greeting | DashboardScreen | Shows 'Good morning, {name}' |
| T-W02 | Payslip card shows amount | PayslipCard | Displays net salary |
| T-W03 | Leave balance cards | LeaveBalanceCard | Shows balance for each type |
| T-W04 | Leave form validation | LeaveRequestForm | Shows error on invalid |
| T-W05 | PIN entry accepts digits | PinEntryWidget | Only 0-9, max 6 |
| T-W06 | Loading state | Various screens | Shows CircularProgressIndicator |
| T-W07 | Error state | Various screens | Shows error message + retry |
| T-W08 | Empty state | Lists | Shows 'No data' message |
| T-W09 | Offline banner | AppShell | Shows when offline |
| T-W10 | Pull to refresh | List screens | Triggers reload |

### 12. End-to-End Test Cases

| ID | User Journey | Steps |
|----|--------------|-------|
| E2E-01 | First-time login | 1. Open app → 2. Enter credentials → 3. Set up PIN → 4. See dashboard |
| E2E-02 | Returning user | 1. Open app → 2. Enter PIN → 3. See dashboard with cached data |
| E2E-03 | View payslip | 1. Dashboard → 2. Tap payslip → 3. Enter PIN → 4. View detail → 5. Download PDF |
| E2E-04 | Apply leave (happy) | 1. Leave tab → 2. Tap Apply → 3. Fill form → 4. Submit → 5. See pending |
| E2E-05 | Apply leave (error) | 1. Fill form with insufficient balance → 2. Submit → 3. See error |
| E2E-06 | Approve leave | 1. Manager receives push → 2. Open approval → 3. Approve → 4. Employee notified |
| E2E-07 | Offline leave | 1. Go offline → 2. Apply leave → 3. See queued → 4. Go online → 5. Auto-synced |
| E2E-08 | Change language | 1. Settings → 2. Select Bahasa → 3. All UI in Malay |
| E2E-09 | Session expiry | 1. Wait for token expiry → 2. Make request → 3. Auto-refresh or re-login |
| E2E-10 | Logout | 1. Settings → 2. Logout → 3. Confirm → 4. Return to login → 5. Cached data cleared |

---

## PART 3: QUALITY GATES

### 13.1 CI Pipeline Gates

| Gate | Criteria | Threshold | Blocking? |
|------|----------|-----------|-----------|
| Build | Compiles without errors | 0 errors | Yes |
| Lint (Backend) | flake8, black formatting | 0 violations | Yes |
| Lint (Mobile) | flutter analyze | 0 issues | Yes |
| Unit Tests | All unit tests pass | 100% | Yes |
| Code Coverage | Line coverage | ≥ 70% | Yes |
| Integration Tests | All integration tests pass | 100% | Yes |
| Security Scan | No high/critical vulnerabilities | 0 high/critical | Yes |
| Bundle Size | Mobile app APK size | < 50 MB | Warning |

### 13.2 Release Gates

| Gate | Criteria | Threshold | Blocking? |
|------|----------|-----------|-----------|
| E2E Tests | All critical paths pass | 100% | Yes |
| Performance | API response time (p95) | < 500ms | Yes |
| Performance | App startup time | < 3 seconds | Yes |
| Localization | All strings translated | 100% | Yes |
| Penetration Test | No critical findings | 0 critical | Yes |
| UAT Sign-off | Stakeholder approval | Signed | Yes |

### 13.3 Code Coverage Targets

| Component | MVP Target | Phase 2 Target |
|-----------|------------|----------------|
| Backend - Business Logic | 80% | 90% |
| Backend - API Controllers | 70% | 80% |
| Mobile - Use Cases | 80% | 90% |
| Mobile - Repositories | 70% | 80% |
| Mobile - Widgets | 50% | 70% |

---

## PART 4: CI/CD CONFIGURATION

### 14.1 Backend CI Pipeline

```yaml
# .github/workflows/backend-ci.yml
name: Backend CI
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
    steps:
      - uses: actions/checkout@v4
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: pip install -r requirements.txt -r requirements-dev.txt
      - name: Lint
        run: |
          black --check .
          flake8 .
      - name: Run tests with coverage
        run: pytest --cov=. --cov-report=xml --cov-fail-under=70
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

### 14.2 Mobile CI Pipeline

```yaml
# .github/workflows/mobile-ci.yml
name: Mobile CI
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
      - name: Get dependencies
        run: flutter pub get
      - name: Analyze
        run: flutter analyze --fatal-infos
      - name: Run tests
        run: flutter test --coverage
      - name: Check coverage
        run: |
          lcov --summary coverage/lcov.info | \
          awk '{if ($2 < 70) exit 1}'
      - name: Build APK
        run: flutter build apk --debug
```

---

## PART 5: GO-LIVE ACCEPTANCE CRITERIA

### 15.1 Functional Acceptance

| # | Criterion | Verification | Status |
|---|-----------|--------------|--------|
| F01 | Employee can login with username/password | E2E-01 | ☐ |
| F02 | Employee can set up and use PIN | E2E-01, E2E-02 | ☐ |
| F03 | Employee can view published payslips | E2E-03 | ☐ |
| F04 | Employee can download payslip PDF | E2E-03 | ☐ |
| F05 | Employee can view leave balances | T-L01 | ☐ |
| F06 | Employee can apply for leave | E2E-04 | ☐ |
| F07 | Employee can cancel pending leave | T-L08 | ☐ |
| F08 | Supervisor can approve/reject leave | E2E-06 | ☐ |
| F09 | Push notifications delivered | T-N05, T-N06, T-N07 | ☐ |
| F10 | App works offline (read cache) | E2E-07 | ☐ |
| F11 | Offline leave syncs when online | E2E-07 | ☐ |
| F12 | App supports EN, MS languages | E2E-08 | ☐ |

### 15.2 Non-Functional Acceptance

| # | Criterion | Target | Status |
|---|-----------|--------|--------|
| N01 | API response time (p95) | < 500ms | ☐ |
| N02 | App startup time (cold) | < 3 seconds | ☐ |
| N03 | App startup time (warm) | < 1 second | ☐ |
| N04 | System uptime | 99.5% SLA | ☐ |
| N05 | Concurrent users supported | 500+ | ☐ |
| N06 | Mobile app size (APK) | < 50 MB | ☐ |
| N07 | Database backup tested | Restore successful | ☐ |
| N08 | No critical security findings | Pentest passed | ☐ |
| N09 | All strings localized | 100% | ☐ |
| N10 | Documentation complete | Runbook exists | ☐ |

---

*— End of Quality Specification —*
