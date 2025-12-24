# KerjaFlow

Enterprise Workforce Management Platform for Malaysian Regulated Industries

## Overview

KerjaFlow is a comprehensive mobile-first workforce management solution designed specifically for Malaysian businesses. It provides:

- **Employee Management** - Complete profiles with Malaysian statutory compliance (EPF, SOCSO, EIS, PCB)
- **Leave Management** - Malaysian public holidays, working days calculation, multi-level approval
- **Payslip Access** - PIN-protected salary information with PDF download
- **Push Notifications** - Real-time alerts via FCM and HMS
- **Offline Support** - Works without internet, syncs when connected

## Tech Stack

### Backend
- **Odoo 17** - Python-based ERP framework
- **PostgreSQL 15** - Primary database
- **Redis 7** - Session/token management
- **Nginx** - Reverse proxy with SSL

### Mobile
- **Flutter 3.19+** - Cross-platform mobile framework
- **Riverpod** - State management
- **Dio** - HTTP client
- **SQLite (Drift)** - Local database for offline support

### Infrastructure
- **Docker Compose** - Container orchestration
- **GitHub Actions** - CI/CD pipelines

## Quick Start

### Prerequisites

- Docker & Docker Compose
- Flutter 3.19+ (for mobile development)
- Python 3.11+ (for backend development)

### Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/kerjaflow.git
   cd kerjaflow
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Start the backend services**
   ```bash
   cd infrastructure
   docker-compose up -d
   ```

4. **Access Odoo**
   - URL: http://localhost:8069
   - Default admin: admin/admin

5. **Set up Flutter app**
   ```bash
   cd mobile
   flutter pub get
   flutter run
   ```

## Project Structure

```
kerjaflow/
├── .github/workflows/     # CI/CD pipelines
├── backend/
│   ├── odoo/addons/kerjaflow/
│   │   ├── models/        # 15 database models
│   │   ├── controllers/   # API endpoints
│   │   ├── security/      # RBAC rules
│   │   └── data/          # Seed data
│   ├── tests/             # pytest tests
│   └── Dockerfile
├── mobile/
│   ├── lib/
│   │   ├── core/          # Config, network, storage
│   │   ├── features/      # Feature modules
│   │   └── shared/        # Common widgets, theme
│   └── test/              # Flutter tests
├── infrastructure/
│   ├── docker-compose.yml
│   └── nginx/
└── docs/specs/            # Specifications
```

## API Documentation

The API provides 32 endpoints across 7 domains:

| Domain | Endpoints | Description |
|--------|-----------|-------------|
| Auth | 6 | Login, refresh, PIN, password |
| Profile | 4 | Profile, dashboard |
| Payslips | 3 | List, detail, PDF |
| Leave | 8 | Balances, requests, calendar |
| Approvals | 3 | Pending, approve, reject |
| Notifications | 4 | List, count, mark read |
| Documents | 4 | List, upload, download |

See `docs/specs/03_OpenAPI.yaml` for full API specification.

## Database Models

15 core entities:

1. **kf_company** - Organization/legal entity
2. **kf_department** - Organizational units
3. **kf_job_position** - Job titles/roles
4. **kf_employee** - Employee master (50+ fields)
5. **kf_user** - Authentication accounts
6. **kf_foreign_worker_detail** - Permit tracking
7. **kf_document** - Document management
8. **kf_leave_type** - Leave policies
9. **kf_leave_balance** - Entitlement tracking
10. **kf_leave_request** - Leave applications
11. **kf_public_holiday** - Holiday calendar
12. **kf_payslip** - Salary statements
13. **kf_payslip_line** - Earnings/deductions
14. **kf_notification** - In-app notifications
15. **kf_audit_log** - Audit trail

## Security

- **JWT Authentication** (RS256, 24h access, 7d refresh)
- **PIN Protection** (6-digit, bcrypt, for sensitive data)
- **Account Lockout** (5 failures → 15 min progressive)
- **Rate Limiting** (10/min auth, 60/min general)
- **RBAC** (5 roles: ADMIN, HR_MANAGER, HR_EXEC, SUPERVISOR, EMPLOYEE)

## Testing

### Backend
```bash
cd backend
pip install -r requirements-dev.txt
pytest --cov=. --cov-fail-under=70
```

### Mobile
```bash
cd mobile
flutter test --coverage
```

## CI/CD

Automated pipelines on push to main/develop:

- **Lint** - Black, flake8 (backend) / flutter analyze (mobile)
- **Test** - pytest / flutter test with coverage
- **Security** - Snyk vulnerability scanning
- **Build** - Docker image / APK/IPA

## Quality Gates

| Gate | Threshold |
|------|-----------|
| Build | 0 errors |
| Lint | 0 violations |
| Unit Tests | 100% pass |
| Code Coverage | ≥ 70% |
| Security Scan | 0 high/critical |

## Contributing

1. Create feature branch from `develop`
2. Follow conventional commits
3. Ensure all tests pass
4. Submit PR with description

## License

Proprietary - All rights reserved

## Support

- Documentation: `docs/specs/`
- Issues: GitHub Issues
- Email: support@kerjaflow.my
