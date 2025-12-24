# KerjaFlow Implementation Plan

## Complete Development Roadmap with CI/CD & QA Standards

**Version 1.0 — December 2025**

---

## Executive Summary

### Specification Completeness: ✅ READY FOR IMPLEMENTATION

| Specification Area | Status | Source Document |
|-------------------|--------|-----------------|
| Data Model / ERD | ✅ COMPLETE | 01_Data_Foundation.md |
| API Contract (32 endpoints) | ✅ COMPLETE | 02_API_Contract.md + 03_OpenAPI.yaml |
| Authentication Design | ✅ COMPLETE | 02_API_Contract.md |
| RBAC Matrix (5 roles) | ✅ COMPLETE | 01_Data_Foundation.md |
| Leave Business Rules | ✅ COMPLETE | 04_Business_Logic.md |
| Payroll Import Specification | ✅ COMPLETE | 04_Business_Logic.md |
| Error Catalog (Localized) | ✅ COMPLETE | 05_Quality_Specification.md |
| Test Strategy & Cases | ✅ COMPLETE | 05_Quality_Specification.md |
| Security Hardening | ✅ COMPLETE | 06_Security_Hardening.md |
| Operations Runbook | ✅ COMPLETE | 07_Operations_Runbook.md |
| Technical Addendum | ✅ COMPLETE | 08_Technical_Addendum.md |
| Mobile UX Specification | ✅ COMPLETE | 09_Mobile_UX_Specification.md |

---

## Implementation Timeline Overview

| Phase | Description | Duration | Weeks |
|-------|-------------|----------|-------|
| Phase 0 | Environment Setup & Infrastructure | 10 days | Week 1-2 |
| Phase 1 | Database & Core Models | 10 days | Week 3-4 |
| Phase 2 | Authentication & Security | 10 days | Week 5-6 |
| Phase 3 | API Development (32 endpoints) | 20 days | Week 7-10 |
| Phase 4 | Mobile App Development | 30 days | Week 11-16 |
| Phase 5 | Integration & E2E Testing | 10 days | Week 17-18 |
| Phase 6 | Platform Compliance & Store Submission | 10 days | Week 19-20 |
| **TOTAL** | **Complete MVP Development** | **100 days** | **20 Weeks** |

---

## Phase 0: Environment Setup

**Duration: Week 1-2 (10 days) | Priority: CRITICAL**

### Project Structure

```
kerjaflow/
├── .github/
│   └── workflows/
│       ├── backend-ci.yml
│       ├── mobile-ci.yml
│       ├── e2e-tests.yml
│       └── release.yml
├── backend/
│   ├── odoo/
│   │   └── addons/
│   │       └── kerjaflow/
│   │           ├── models/
│   │           ├── controllers/
│   │           ├── security/
│   │           └── data/
│   ├── tests/
│   ├── requirements.txt
│   └── Dockerfile
├── mobile/
│   ├── lib/
│   │   ├── core/
│   │   ├── features/
│   │   ├── shared/
│   │   └── main.dart
│   ├── test/
│   ├── integration_test/
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
├── infrastructure/
│   ├── docker-compose.yml
│   ├── docker-compose.prod.yml
│   ├── nginx/
│   └── scripts/
├── docs/
│   └── specs/
└── README.md
```

### Environment Tasks

| ID | Task | Est. | Priority |
|----|------|------|----------|
| E001 | Initialize Git repository with branch protection rules | 2h | HIGH |
| E002 | Create monorepo folder structure | 1h | HIGH |
| E003 | Create docker-compose.yml (PostgreSQL, Redis, Odoo, Nginx) | 4h | HIGH |
| E004 | Configure nginx reverse proxy with SSL termination | 4h | HIGH |
| E005 | Create Odoo Dockerfile with Python dependencies | 4h | HIGH |
| E006 | Initialize Flutter project with folder structure | 4h | HIGH |
| E007 | Set up GitHub Actions CI pipeline (backend) | 4h | HIGH |
| E008 | Set up GitHub Actions CI pipeline (mobile) | 4h | HIGH |
| E009 | Configure pre-commit hooks (black, flake8, flutter analyze) | 2h | MEDIUM |
| E010 | Create .env.example with all required variables | 1h | HIGH |
| E011 | Set up development database with seed data | 4h | HIGH |
| E012 | Configure code coverage reporting (Codecov) | 2h | MEDIUM |
| E013 | Create README.md with setup instructions | 2h | MEDIUM |
| E014 | Verify full stack starts with docker-compose up | 2h | HIGH |

### Docker Configuration

```yaml
# infrastructure/docker-compose.yml
version: '3.8'
services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: kerjaflow
      POSTGRES_USER: odoo
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U odoo -d kerjaflow"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data

  odoo:
    build: ./backend
    depends_on:
      db:
        condition: service_healthy
    environment:
      - HOST=db
      - USER=odoo
      - PASSWORD=${DB_PASSWORD}
    volumes:
      - ./backend/odoo/addons:/mnt/extra-addons
      - odoo_data:/var/lib/odoo
    ports:
      - "8069:8069"

  nginx:
    image: nginx:alpine
    volumes:
      - ./infrastructure/nginx/nginx.conf:/etc/nginx/nginx.conf
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - odoo

volumes:
  postgres_data:
  redis_data:
  odoo_data:
```

---

## Phase 1: Database & Core Models

**Duration: Week 3-4 (10 days) | Reference: 01_Data_Foundation.md**

### Entity Implementation Order

Implement in dependency order (parent entities first):

| Order | Entity | Table Name | Dependencies |
|-------|--------|------------|--------------|
| 1 | Company | kf_company | None |
| 2 | Department | kf_department | Company |
| 3 | JobPosition | kf_job_position | Company |
| 4 | Employee | kf_employee | Company, Dept, Job |
| 5 | User | kf_user | Employee |
| 6 | ForeignWorkerDetail | kf_foreign_worker_detail | Employee |
| 7 | Document | kf_document | Employee, User |
| 8 | LeaveType | kf_leave_type | Company |
| 9 | LeaveBalance | kf_leave_balance | Employee, LeaveType |
| 10 | LeaveRequest | kf_leave_request | Employee, LeaveType, Doc |
| 11 | PublicHoliday | kf_public_holiday | Company |
| 12 | Payslip | kf_payslip | Employee |
| 13 | PayslipLine | kf_payslip_line | Payslip |
| 14 | Notification | kf_notification | User |
| 15 | AuditLog | kf_audit_log | User |

### Database Tasks

| ID | Task | Est. | Priority |
|----|------|------|----------|
| D001 | Create Odoo module skeleton (__init__.py, __manifest__.py) | 2h | HIGH |
| D002 | Implement kf_company model with all fields | 4h | HIGH |
| D003 | Implement kf_department model with hierarchy support | 3h | HIGH |
| D004 | Implement kf_job_position model | 2h | HIGH |
| D005 | Implement kf_employee model (50+ fields) | 8h | HIGH |
| D006 | Implement kf_user model with password hashing | 4h | HIGH |
| D007 | Implement kf_foreign_worker_detail model | 3h | MEDIUM |
| D008 | Implement kf_document model with file handling | 4h | HIGH |
| D009 | Implement kf_leave_type model with all configuration fields | 4h | HIGH |
| D010 | Implement kf_leave_balance model with computed fields | 4h | HIGH |
| D011 | Implement kf_leave_request model with state machine | 6h | HIGH |
| D012 | Implement kf_public_holiday model | 2h | MEDIUM |
| D013 | Implement kf_payslip model | 4h | HIGH |
| D014 | Implement kf_payslip_line model | 2h | HIGH |
| D015 | Implement kf_notification model | 3h | MEDIUM |
| D016 | Implement kf_audit_log model | 3h | MEDIUM |
| D017 | Create all indexes as specified in Data Foundation | 4h | HIGH |
| D018 | Create security rules (ir.model.access.csv) | 4h | HIGH |
| D019 | Create record rules for RBAC | 6h | HIGH |
| D020 | Write unit tests for all models (≥80% coverage) | 8h | HIGH |

---

## Phase 2: Authentication & Security

**Duration: Week 5-6 (10 days) | Reference: 02_API_Contract.md, 06_Security_Hardening.md**

### JWT Token Implementation

| Token Type | Lifetime | Storage | Refresh Strategy |
|------------|----------|---------|------------------|
| Access Token | 24 hours | SecureStorage | Auto when <1h left |
| Refresh Token | 7 days | SecureStorage | Re-login on expiry |
| PIN Verification | 5 minutes | Memory only | Re-verify each op |

### Security Tasks

| ID | Task | Est. | Priority |
|----|------|------|----------|
| S001 | Implement JWT token generation with payload (sub, emp, cid, role) | 4h | HIGH |
| S002 | Implement POST /auth/login endpoint | 4h | HIGH |
| S003 | Implement POST /auth/refresh endpoint | 3h | HIGH |
| S004 | Implement POST /auth/logout endpoint | 2h | HIGH |
| S005 | Implement POST /auth/pin/setup endpoint | 4h | HIGH |
| S006 | Implement POST /auth/pin/verify endpoint | 4h | HIGH |
| S007 | Implement POST /auth/password/change endpoint | 3h | HIGH |
| S008 | Implement failed login lockout (5 attempts → 15 min) | 4h | HIGH |
| S009 | Implement failed PIN lockout (5 attempts → password re-auth) | 3h | HIGH |
| S010 | Implement password validation (8 chars, 1 upper, 1 number) | 2h | HIGH |
| S011 | Implement single device session (invalidate old on new login) | 4h | HIGH |
| S012 | Create JWT middleware for protected endpoints | 4h | HIGH |
| S013 | Create PIN verification middleware for sensitive endpoints | 3h | HIGH |
| S014 | Implement rate limiting (10/min auth, 60/min general) | 4h | HIGH |
| S015 | Write security test cases (T-A01 to T-A12) | 6h | HIGH |

---

## Phase 3: API Development

**Duration: Week 7-10 (20 days) | Reference: 02_API_Contract.md, 03_OpenAPI.yaml**

### Endpoint Summary

| Domain | Count | Endpoints | Priority |
|--------|-------|-----------|----------|
| Authentication | 6 | /auth/* | ✅ Done Phase 2 |
| Profile | 4 | /profile, /dashboard | HIGH |
| Payslips | 3 | /payslips/* | HIGH |
| Leave | 8 | /leave/* | HIGH |
| Approvals | 3 | /approvals/* | MEDIUM |
| Notifications | 4 | /notifications/* | MEDIUM |
| Documents | 4 | /documents/* | MEDIUM |

### Profile & Dashboard Tasks

| ID | Task | Est. | Priority |
|----|------|------|----------|
| A001 | GET /profile - Return employee profile with company info | 4h | HIGH |
| A002 | PATCH /profile - Update limited fields (phone, email, address) | 4h | HIGH |
| A003 | POST /profile/photo - Upload with resize to 500x500 | 4h | HIGH |
| A004 | GET /dashboard - Aggregated home screen data | 6h | HIGH |

### Payslip Tasks

| ID | Task | Est. | Priority |
|----|------|------|----------|
| A005 | GET /payslips - List with offset pagination | 4h | HIGH |
| A006 | GET /payslips/{id} - Detail with PIN verification | 4h | HIGH |
| A007 | GET /payslips/{id}/pdf - Download PDF with PIN | 4h | HIGH |
| A008 | Implement payslip import from CSV/Excel | 8h | HIGH |

### Leave Management Tasks

| ID | Task | Est. | Priority |
|----|------|------|----------|
| A009 | GET /leave/balances - All leave type balances for year | 4h | HIGH |
| A010 | GET /leave/types - Available leave types | 2h | HIGH |
| A011 | GET /leave/requests - List with status filter | 4h | HIGH |
| A012 | POST /leave/requests - Submit with all 7 validation rules | 8h | HIGH |
| A013 | GET /leave/requests/{id} - Request details | 2h | HIGH |
| A014 | POST /leave/requests/{id}/cancel - Cancel with rules | 4h | HIGH |
| A015 | GET /leave/calendar - Calendar view with team leaves | 6h | MEDIUM |
| A016 | GET /public-holidays - Company holidays for year | 2h | MEDIUM |
| A017 | Implement working days calculation | 4h | HIGH |
| A018 | Implement pro-rata calculation for new joiners | 4h | HIGH |

### Approval Tasks

| ID | Task | Est. | Priority |
|----|------|------|----------|
| A019 | GET /approvals/pending - Pending for supervisor/HR | 4h | MEDIUM |
| A020 | POST /approvals/{id}/approve - Approve with notification | 4h | MEDIUM |
| A021 | POST /approvals/{id}/reject - Reject with reason | 4h | MEDIUM |

### Notification & Document Tasks

| ID | Task | Est. | Priority |
|----|------|------|----------|
| A022 | GET /notifications - Cursor-paginated list | 4h | MEDIUM |
| A023 | GET /notifications/unread-count - Badge count | 2h | MEDIUM |
| A024 | POST /notifications/{id}/read - Mark single as read | 2h | MEDIUM |
| A025 | POST /notifications/read-all - Mark all as read | 2h | MEDIUM |
| A026 | GET /documents - List my documents | 3h | MEDIUM |
| A027 | POST /documents - Upload with type validation | 4h | MEDIUM |
| A028 | GET /documents/{id} - Document details | 2h | MEDIUM |
| A029 | GET /documents/{id}/download - Download file | 3h | MEDIUM |

---

## Phase 4: Mobile App Development

**Duration: Week 11-16 (30 days) | Reference: 09_Mobile_UX_Specification.md**

### Flutter Architecture

```
lib/
├── core/
│   ├── config/
│   │   ├── app_config.dart
│   │   └── api_config.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── dio_client.dart
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       ├── error_interceptor.dart
│   │       └── logging_interceptor.dart
│   ├── storage/
│   │   ├── secure_storage.dart
│   │   └── local_database.dart
│   ├── error/
│   │   ├── api_exception.dart
│   │   └── error_handler.dart
│   └── localization/
│       ├── app_localizations.dart
│       ├── l10n_en.dart
│       └── l10n_ms.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── dashboard/
│   ├── payslip/
│   ├── leave/
│   ├── notifications/
│   └── profile/
├── shared/
│   ├── widgets/
│   ├── theme/
│   └── utils/
└── main.dart
```

### Core Infrastructure Tasks

| ID | Task | Est. | Priority |
|----|------|------|----------|
| M001 | Set up Flutter project with folder structure | 4h | HIGH |
| M002 | Configure Dio HTTP client with base URL | 3h | HIGH |
| M003 | Implement AuthInterceptor for JWT injection | 4h | HIGH |
| M004 | Implement ErrorInterceptor per Quality Spec | 4h | HIGH |
| M005 | Implement SecureStorage for token persistence | 3h | HIGH |
| M006 | Implement SQLite local database for offline cache | 6h | HIGH |
| M007 | Set up Riverpod for state management | 4h | HIGH |
| M008 | Implement localization (EN, MS) with error messages | 6h | HIGH |
| M009 | Create app theme (colors, typography, spacing) | 4h | HIGH |
| M010 | Implement connectivity monitoring service | 3h | HIGH |

### Authentication Screen Tasks

| ID | Task | Est. | Priority |
|----|------|------|----------|
| M011 | Splash screen with logo and version | 2h | HIGH |
| M012 | Login screen with username/password form | 6h | HIGH |
| M013 | PIN setup screen (6-digit input) | 4h | HIGH |
| M014 | PIN entry dialog for sensitive operations | 4h | HIGH |
| M015 | Change password screen | 3h | MEDIUM |
| M016 | Implement auto-logout on token expiry | 3h | HIGH |

### Main Feature Screen Tasks

| ID | Task | Est. | Priority |
|----|------|------|----------|
| M017 | Dashboard screen with summary cards | 8h | HIGH |
| M018 | Payslip list screen with year filter | 6h | HIGH |
| M019 | Payslip detail screen (requires PIN) | 8h | HIGH |
| M020 | Payslip PDF viewer and share | 4h | HIGH |
| M021 | Leave balance screen with cards per type | 6h | HIGH |
| M022 | Leave request list with status tabs | 6h | HIGH |
| M023 | Leave apply form with date picker and validation | 8h | HIGH |
| M024 | Leave detail screen with cancel option | 4h | HIGH |
| M025 | Leave calendar view | 8h | MEDIUM |
| M026 | Approval list screen (for supervisors) | 6h | MEDIUM |
| M027 | Approval detail with approve/reject buttons | 4h | MEDIUM |
| M028 | Notification list screen | 4h | MEDIUM |
| M029 | Profile view screen | 4h | HIGH |
| M030 | Profile edit screen (editable fields only) | 6h | HIGH |
| M031 | Settings screen with language switch and logout | 4h | HIGH |

### Push Notification Tasks

| ID | Task | Est. | Priority |
|----|------|------|----------|
| M032 | Configure Firebase Cloud Messaging (FCM) | 4h | HIGH |
| M033 | Implement foreground notification handling | 3h | HIGH |
| M034 | Implement background notification handling | 3h | HIGH |
| M035 | Implement deep linking from notifications | 4h | HIGH |
| M036 | Configure Huawei Push Kit (HMS Core) | 6h | MEDIUM |

---

## Phase 5: Integration & E2E Testing

**Duration: Week 17-18 (10 days) | Reference: 05_Quality_Specification.md**

### Integration Test Tasks

| ID | Task | Est. | Priority |
|----|------|------|----------|
| I001 | Backend integration tests for auth flow | 8h | HIGH |
| I002 | Backend integration tests for leave management | 8h | HIGH |
| I003 | Backend integration tests for payslip access | 6h | HIGH |
| I004 | Mobile integration tests for API communication | 8h | HIGH |
| I005 | Mobile integration tests for offline sync | 6h | HIGH |

### E2E Test Tasks

| ID | Task | Est. | Priority |
|----|------|------|----------|
| E2E001 | First-time login journey (E2E-01) | 4h | HIGH |
| E2E002 | Returning user PIN login (E2E-02) | 3h | HIGH |
| E2E003 | View payslip journey (E2E-03) | 4h | HIGH |
| E2E004 | Apply leave happy path (E2E-04) | 4h | HIGH |
| E2E005 | Apply leave with error (E2E-05) | 3h | HIGH |
| E2E006 | Approve leave journey (E2E-06) | 4h | HIGH |
| E2E007 | Offline leave apply (E2E-07) | 4h | HIGH |
| E2E008 | Change language (E2E-08) | 2h | MEDIUM |
| E2E009 | Session expiry handling (E2E-09) | 3h | HIGH |
| E2E010 | Logout journey (E2E-10) | 2h | HIGH |

---

## Phase 6: Platform Compliance & Store Submission

**Duration: Week 19-20 (10 days)**

### Google Play Store Requirements

| ID | Requirement | Implementation | Priority |
|----|-------------|----------------|----------|
| G001 | Target API Level | Android 14 (API 34) minimum | HIGH |
| G002 | 64-bit Support | Build arm64-v8a and x86_64 ABIs | HIGH |
| G003 | App Bundle Format | Publish as .aab not .apk | HIGH |
| G004 | Privacy Policy URL | Publicly accessible privacy policy | HIGH |
| G005 | Data Safety Declaration | Complete data collection disclosure | HIGH |
| G006 | Permissions Justification | Justify camera, storage, notification | HIGH |
| G007 | Content Rating | Complete IARC questionnaire | HIGH |
| G008 | App Signing | Use Google Play App Signing | HIGH |

### Apple App Store Requirements

| ID | Requirement | Implementation | Priority |
|----|-------------|----------------|----------|
| A001 | iOS Minimum Version | iOS 13.0 minimum deployment target | HIGH |
| A002 | App Transport Security | All connections HTTPS | HIGH |
| A003 | Privacy Nutrition Labels | Complete App Privacy disclosure | HIGH |
| A004 | Privacy Policy URL | Link in App Store Connect | HIGH |
| A005 | Push Notification Entitlement | Configure in Apple Developer portal | HIGH |
| A006 | IPv6 Compatibility | Test on IPv6-only network | HIGH |
| A007 | App Icons | All required sizes (1024x1024 master) | HIGH |
| A008 | Launch Screen | Storyboard-based launch screen | HIGH |

### Huawei AppGallery Requirements

| ID | Requirement | Implementation | Priority |
|----|-------------|----------------|----------|
| H001 | HMS Core Integration | Add HMS Core SDK dependencies | HIGH |
| H002 | Huawei Push Kit | Replace FCM with HMS Push Kit | HIGH |
| H003 | App Signing Certificate | Register SHA-256 in AppGallery Connect | HIGH |
| H004 | agconnect-services.json | Configure HMS SDK initialization | HIGH |
| H005 | GMS/HMS Detection | Runtime check for available services | HIGH |

---

## CI/CD Pipeline Configuration

### Backend CI Pipeline

```yaml
# .github/workflows/backend-ci.yml
name: Backend CI

on:
  push:
    branches: [main, develop]
    paths: ['backend/**']
  pull_request:
    branches: [main, develop]
    paths: ['backend/**']

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: pip install black flake8 isort
      - name: Check formatting
        run: |
          black --check backend/
          isort --check-only backend/
          flake8 backend/

  test:
    runs-on: ubuntu-latest
    needs: lint
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: test
          POSTGRES_DB: kerjaflow_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
    steps:
      - uses: actions/checkout@v4
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: pip install -r backend/requirements.txt -r backend/requirements-dev.txt
      - name: Run tests with coverage
        run: |
          cd backend
          pytest --cov=. --cov-report=xml --cov-fail-under=70
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: backend/coverage.xml
          flags: backend

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Snyk security scan
        uses: snyk/actions/python@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high backend/
```

### Mobile CI Pipeline

```yaml
# .github/workflows/mobile-ci.yml
name: Mobile CI

on:
  push:
    branches: [main, develop]
    paths: ['mobile/**']
  pull_request:
    branches: [main, develop]
    paths: ['mobile/**']

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
      - name: Get dependencies
        run: cd mobile && flutter pub get
      - name: Analyze
        run: cd mobile && flutter analyze --fatal-infos

  test:
    runs-on: ubuntu-latest
    needs: analyze
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      - name: Get dependencies
        run: cd mobile && flutter pub get
      - name: Run tests with coverage
        run: |
          cd mobile
          flutter test --coverage
      - name: Check coverage threshold
        run: |
          sudo apt-get install lcov
          lcov --summary mobile/coverage/lcov.info | \
            grep -E 'lines.*: [0-9]+' | \
            awk '{if ($2 < 70) exit 1}'
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: mobile/coverage/lcov.info
          flags: mobile

  build-android:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      - name: Build APK
        run: cd mobile && flutter build apk --release
      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: app-release.apk
          path: mobile/build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    runs-on: macos-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      - name: Build iOS
        run: cd mobile && flutter build ios --release --no-codesign
```

---

## Quality Gates

| Gate | Criteria | Threshold | Blocking |
|------|----------|-----------|----------|
| Build | Compiles without errors | 0 errors | YES |
| Lint (Backend) | flake8, black formatting | 0 violations | YES |
| Lint (Mobile) | flutter analyze | 0 issues | YES |
| Unit Tests | All unit tests pass | 100% | YES |
| Code Coverage | Line coverage | ≥ 70% | YES |
| Integration Tests | All integration tests pass | 100% | YES |
| Security Scan | No high/critical vulns | 0 | YES |
| Bundle Size | Mobile app APK size | < 50 MB | WARNING |

---

## Go-Live Acceptance Criteria

### Functional Acceptance (12 criteria)

| ID | Criterion | Verification | Required |
|----|-----------|--------------|----------|
| F01 | Employee can login with username/password | E2E-01 | ✅ |
| F02 | Employee can set up and use PIN | E2E-01, E2E-02 | ✅ |
| F03 | Employee can view published payslips | E2E-03 | ✅ |
| F04 | Employee can download payslip PDF | E2E-03 | ✅ |
| F05 | Employee can view leave balances | T-L01 | ✅ |
| F06 | Employee can apply for leave | E2E-04 | ✅ |
| F07 | Employee can cancel pending leave | T-L08 | ✅ |
| F08 | Supervisor can approve/reject leave | E2E-06 | ✅ |
| F09 | Push notifications delivered | T-N05, T-N06, T-N07 | ✅ |
| F10 | App works offline (read cache) | E2E-07 | ✅ |
| F11 | Offline leave syncs when online | E2E-07 | ✅ |
| F12 | App supports EN, MS languages | E2E-08 | ✅ |

### Non-Functional Acceptance (10 criteria)

| ID | Criterion | Target | Required |
|----|-----------|--------|----------|
| N01 | API response time (p95) | < 500ms | ✅ |
| N02 | App startup time (cold) | < 3 seconds | ✅ |
| N03 | App startup time (warm) | < 1 second | ✅ |
| N04 | System uptime | 99.5% SLA | ✅ |
| N05 | Concurrent users supported | 500+ | ✅ |
| N06 | Mobile app size (APK) | < 50 MB | ✅ |
| N07 | Database backup tested | Restore OK | ✅ |
| N08 | No critical security findings | Pentest OK | ✅ |
| N09 | All strings localized | 100% | ✅ |
| N10 | Documentation complete | Runbook OK | ✅ |

---

## Task Summary

| Phase | Task Count | Total Hours | Weeks |
|-------|------------|-------------|-------|
| Phase 0: Environment | 14 tasks | ~40h | 1-2 |
| Phase 1: Database | 20 tasks | ~72h | 3-4 |
| Phase 2: Security | 15 tasks | ~54h | 5-6 |
| Phase 3: API | 29 tasks | ~112h | 7-10 |
| Phase 4: Mobile | 36 tasks | ~168h | 11-16 |
| Phase 5: Testing | 15 tasks | ~60h | 17-18 |
| Phase 6: Compliance | 21 tasks | ~40h | 19-20 |
| **TOTAL** | **150 tasks** | **~546h** | **20 weeks** |

---

*Implementation Plan v1.0 — December 2025*
