#!/bin/bash
#
# KERJAFLOW COMPLETE REMEDIATION SCRIPT
# =====================================
# Execute with: ./remediate_kerjaflow.sh
# 
# This script provides all commands for Claude Code CLI to execute
# in order to bring KerjaFlow to production readiness.
#
# EXTREME KIASU MODE: Every task is verified, no shortcuts.
#

set -e  # Exit on error

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║        KERJAFLOW PRODUCTION READINESS REMEDIATION            ║"
echo "║                                                              ║"
echo "║  This is not just software. This is the future of ASEAN     ║"
echo "║  workforce management. Execute with zero tolerance for       ║"
echo "║  mediocrity.                                                 ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Verify we're in the right directory
if [ ! -f "CLAUDE.md" ]; then
    echo "ERROR: CLAUDE.md not found. Are you in the kflow repository root?"
    exit 1
fi

# =============================================================================
# PHASE 1: CRITICAL BLOCKERS
# =============================================================================

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║ PHASE 1: CRITICAL BLOCKERS (4 TASKS)                         ║"
echo "╚══════════════════════════════════════════════════════════════╝"

# -----------------------------------------------------------------------------
# TASK 1.1: Create missing kf_user_device.py
# -----------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TASK 1.1: Create missing model file kf_user_device.py"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cat << 'TASK_1_1'
claude code "Create the file backend/odoo/addons/kerjaflow/models/kf_user_device.py with:

# -*- coding: utf-8 -*-
from odoo import models, fields, api
from odoo.exceptions import ValidationError
import logging

_logger = logging.getLogger(__name__)

class KFUserDevice(models.Model):
    _name = 'kf.user.device'
    _description = 'User Device Registration'
    _order = 'last_active desc'
    _rec_name = 'device_name'

    # Relationships
    user_id = fields.Many2one('kf.user', string='User', required=True, ondelete='cascade', index=True)
    
    # Device Information
    device_id = fields.Char(string='Device ID', required=True, index=True, help='Unique device identifier (UUID)')
    device_name = fields.Char(string='Device Name', help='User-friendly device name (e.g., iPhone 15 Pro)')
    device_type = fields.Selection([
        ('phone', 'Phone'),
        ('tablet', 'Tablet'),
        ('desktop', 'Desktop'),
        ('unknown', 'Unknown')
    ], string='Device Type', default='phone')
    
    # Platform Information
    platform = fields.Selection([
        ('ios', 'iOS'),
        ('android', 'Android'),
        ('web', 'Web'),
        ('unknown', 'Unknown')
    ], string='Platform', default='unknown')
    os_version = fields.Char(string='OS Version')
    app_version = fields.Char(string='App Version')
    
    # Push Notifications
    push_token = fields.Char(string='Push Token', help='FCM/APNs token for push notifications')
    push_enabled = fields.Boolean(string='Push Enabled', default=True)
    
    # Security
    is_trusted = fields.Boolean(string='Trusted Device', default=False, help='Device verified by user')
    biometric_enabled = fields.Boolean(string='Biometric Enabled', default=False)
    root_detected = fields.Boolean(string='Root/Jailbreak Detected', default=False)
    
    # Activity Tracking
    last_active = fields.Datetime(string='Last Active', default=fields.Datetime.now)
    last_ip = fields.Char(string='Last IP Address')
    login_count = fields.Integer(string='Login Count', default=0)
    
    # Timestamps
    created_at = fields.Datetime(string='Created At', default=fields.Datetime.now, readonly=True)
    updated_at = fields.Datetime(string='Updated At', default=fields.Datetime.now)
    
    _sql_constraints = [
        ('unique_user_device', 'UNIQUE(user_id, device_id)', 'This device is already registered for this user.'),
    ]
    
    @api.model
    def register_device(self, user_id, device_data):
        \"\"\"Register or update a device for a user.\"\"\"
        existing = self.search([
            ('user_id', '=', user_id),
            ('device_id', '=', device_data.get('device_id'))
        ], limit=1)
        
        if existing:
            existing.write({
                'device_name': device_data.get('device_name'),
                'os_version': device_data.get('os_version'),
                'app_version': device_data.get('app_version'),
                'push_token': device_data.get('push_token'),
                'last_active': fields.Datetime.now(),
                'last_ip': device_data.get('ip_address'),
                'login_count': existing.login_count + 1,
                'updated_at': fields.Datetime.now(),
            })
            return existing
        
        return self.create({
            'user_id': user_id,
            'device_id': device_data.get('device_id'),
            'device_name': device_data.get('device_name'),
            'device_type': device_data.get('device_type', 'phone'),
            'platform': device_data.get('platform', 'unknown'),
            'os_version': device_data.get('os_version'),
            'app_version': device_data.get('app_version'),
            'push_token': device_data.get('push_token'),
            'last_ip': device_data.get('ip_address'),
            'root_detected': device_data.get('root_detected', False),
        })
    
    def mark_active(self):
        \"\"\"Update last_active timestamp.\"\"\"
        self.write({
            'last_active': fields.Datetime.now(),
            'updated_at': fields.Datetime.now(),
        })
    
    def set_push_token(self, token):
        \"\"\"Update push notification token.\"\"\"
        self.write({
            'push_token': token,
            'push_enabled': bool(token),
            'updated_at': fields.Datetime.now(),
        })
    
    @api.model
    def cleanup_inactive_devices(self, days=90):
        \"\"\"Remove devices inactive for more than specified days.\"\"\"
        from datetime import timedelta
        cutoff = fields.Datetime.now() - timedelta(days=days)
        inactive = self.search([
            ('last_active', '<', cutoff),
            ('is_trusted', '=', False)
        ])
        count = len(inactive)
        inactive.unlink()
        _logger.info(f'Cleaned up {count} inactive devices')
        return count

Verify the file is valid Python and follows Odoo conventions."
TASK_1_1

echo "✓ Task 1.1 command generated"

# -----------------------------------------------------------------------------
# TASK 1.2: JWT RS256 Migration
# -----------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TASK 1.2: Migrate JWT from HS256 to RS256"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cat << 'TASK_1_2'
claude code "Migrate JWT authentication from HS256 to RS256:

1. In backend/odoo/addons/kerjaflow/controllers/auth_controller.py:
   - Find all occurrences of algorithm='HS256' and change to algorithm='RS256'
   - Add import: from cryptography.hazmat.primitives import serialization
   - Add function to load RSA keys from environment:
     
     def _load_private_key():
         key_pem = os.environ.get('JWT_PRIVATE_KEY', '').replace('\\n', '\n')
         return serialization.load_pem_private_key(key_pem.encode(), password=None)
     
     def _load_public_key():
         key_pem = os.environ.get('JWT_PUBLIC_KEY', '').replace('\\n', '\n')
         return serialization.load_pem_public_key(key_pem.encode())
   
   - Update token generation to use private key
   - Update token verification to use public key

2. In backend/kerjaflow/config.py:
   - Change _jwt_algorithm = 'HS256' to _jwt_algorithm = 'RS256'

3. Create infrastructure/scripts/generate_jwt_keys.sh:
   #!/bin/bash
   openssl genrsa -out jwt_private.pem 2048
   openssl rsa -in jwt_private.pem -pubout -out jwt_public.pem
   echo 'Keys generated. Add to .env:'
   echo 'JWT_PRIVATE_KEY=$(cat jwt_private.pem | tr '\n' '\\n')'
   echo 'JWT_PUBLIC_KEY=$(cat jwt_public.pem | tr '\n' '\\n')'
   chmod +x the script

4. Update .env.example with:
   # JWT RS256 Keys (REQUIRED)
   # Generate with: ./infrastructure/scripts/generate_jwt_keys.sh
   JWT_PRIVATE_KEY=
   JWT_PUBLIC_KEY=
   JWT_ALGORITHM=RS256

Ensure cryptography package is in requirements.txt"
TASK_1_2

echo "✓ Task 1.2 command generated"

# -----------------------------------------------------------------------------
# TASK 1.3: Enable CI/CD Pipelines  
# -----------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TASK 1.3: Enable CI/CD Pipelines"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cat << 'TASK_1_3'
claude code "Enable and configure CI/CD pipelines:

1. Rename workflows:
   mv .github/workflows/e2e-tests.yml.disabled .github/workflows/e2e-tests.yml
   mv .github/workflows/release.yml.disabled .github/workflows/release.yml

2. Create .github/workflows/quality-gates.yml:

name: Quality Gates
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  lint-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - run: pip install black flake8 isort
      - run: black --check backend/
      - run: flake8 backend/ --max-line-length=120
      - run: isort --check-only backend/

  lint-mobile:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      - run: flutter pub get
        working-directory: mobile
      - run: flutter analyze --fatal-infos --fatal-warnings
        working-directory: mobile

  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - run: pip install bandit safety pip-audit
      - run: bandit -r backend/ -ll
      - run: safety check -r backend/requirements.txt
      - run: pip-audit -r backend/requirements.txt

  test-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - run: pip install -r backend/requirements.txt -r backend/requirements-dev.txt
      - run: pytest --cov=kerjaflow --cov-fail-under=70

  test-mobile:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      - run: flutter pub get
        working-directory: mobile
      - run: flutter test --coverage
        working-directory: mobile

  build-mobile:
    runs-on: ubuntu-latest
    needs: [lint-mobile, test-mobile]
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      - run: flutter pub get
        working-directory: mobile
      - run: flutter build apk --release
        working-directory: mobile
      - name: Check APK size
        run: |
          SIZE=$(stat -f%z mobile/build/app/outputs/flutter-apk/app-release.apk 2>/dev/null || stat -c%s mobile/build/app/outputs/flutter-apk/app-release.apk)
          MAX_SIZE=52428800  # 50MB
          if [ $SIZE -gt $MAX_SIZE ]; then
            echo 'APK too large: ${SIZE} bytes (max ${MAX_SIZE})'
            exit 1
          fi

3. Create .github/workflows/dependency-audit.yml for weekly security scans

Use only FREE GitHub Actions minutes."
TASK_1_3

echo "✓ Task 1.3 command generated"

# -----------------------------------------------------------------------------
# TASK 1.4: Complete Translation Files
# -----------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TASK 1.4: Complete ALL Translation Files"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cat << 'TASK_1_4'
claude code "Complete all translation ARB files to have 343 keys matching app_en.arb:

Current state:
- en: 343 keys (BASELINE)
- ms: 279 keys (-64 missing)
- id: 279 keys (-64 missing)
- th: 178 keys (-165 missing)
- vi: 279 keys (-64 missing)
- tl: 126 keys (-217 missing)
- zh: 279 keys (-64 missing)
- ta: 144 keys (-199 missing)
- bn: 279 keys (-64 missing)
- ne: 279 keys (-64 missing)
- km: 105 keys (-238 missing)
- my: 102 keys (-241 missing)

For each language file in mobile/lib/l10n/:

1. Parse app_en.arb to get all 343 keys
2. Parse the target language file
3. Identify missing keys
4. Add translations for missing keys following these rules:
   - Statutory terms (EPF, SOCSO, BPJS, CPF, PCB) must be preserved in parentheses
   - Use authoritative sources (government websites, official dictionaries)
   - Malaysian Malay ≠ Indonesian - use proper DBP/KBBI sources
   - Myanmar must use Unicode, NOT Zawgyi
   - Include pluralization where app_en.arb has it

Priority order for severely incomplete languages:
1. my (Myanmar) - 241 missing
2. km (Khmer) - 238 missing  
3. tl (Filipino) - 217 missing
4. ta (Tamil) - 199 missing
5. th (Thai) - 165 missing

For each language, ensure:
- Valid JSON format
- All @-prefixed metadata keys included
- Proper escaping for special characters
- No duplicate keys

After completing, run: flutter gen-l10n

Use the project knowledge translation files as reference:
- KerjaFlow_BM_Translation_Verification.xlsx
- KerjaFlow_Translation_ID_Bahasa_Indonesia_Verified.xlsx
- KerjaFlow_i18n_TH_Verified.xlsx (etc.)"
TASK_1_4

echo "✓ Task 1.4 command generated"

# =============================================================================
# PHASE 2: MISSING SCREENS
# =============================================================================

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║ PHASE 2: MISSING SCREENS (6 TASKS)                           ║"
echo "╚══════════════════════════════════════════════════════════════╝"

echo ""
echo "Screens to create:"
echo "  - Document List, Upload, Viewer"
echo "  - Payslip PDF Viewer"
echo "  - Leave Calendar"
echo "  - Approval Detail"
echo "  - Notification Detail"
echo "  - Settings: Change Password, Change PIN, About"
echo ""
echo "Commands for Phase 2 are in KERJAFLOW_CLAUDE_CODE_CLI_COMPLETE_ACTION_PLAN.md"

# =============================================================================
# PHASE 3: SECURITY HARDENING
# =============================================================================

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║ PHASE 3: SECURITY HARDENING (3 TASKS)                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"

echo ""
echo "Security tasks:"
echo "  - Certificate Pinning"
echo "  - Root/Jailbreak Detection"
echo "  - Screenshot Prevention on sensitive screens"
echo ""
echo "Commands for Phase 3 are in KERJAFLOW_CLAUDE_CODE_CLI_COMPLETE_ACTION_PLAN.md"

# =============================================================================
# PHASE 4: TEST COVERAGE
# =============================================================================

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║ PHASE 4: TEST COVERAGE (3 TASKS)                             ║"
echo "╚══════════════════════════════════════════════════════════════╝"

echo ""
echo "Testing tasks:"
echo "  - Backend Unit Tests (≥70% coverage)"
echo "  - Mobile Widget Tests"
echo "  - Integration Tests"
echo ""
echo "Commands for Phase 4 are in KERJAFLOW_CLAUDE_CODE_CLI_COMPLETE_ACTION_PLAN.md"

# =============================================================================
# PHASE 5: DOCUMENTATION & POLISH
# =============================================================================

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║ PHASE 5: DOCUMENTATION & POLISH (3 TASKS)                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"

echo ""
echo "Documentation tasks:"
echo "  - Update README.md"
echo "  - Create CHANGELOG.md"
echo "  - API Documentation"
echo ""
echo "Commands for Phase 5 are in KERJAFLOW_CLAUDE_CODE_CLI_COMPLETE_ACTION_PLAN.md"

# =============================================================================
# VERIFICATION
# =============================================================================

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║ VERIFICATION COMMANDS                                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "After all tasks complete, run:"
echo ""
echo "  # Backend verification"
echo "  cd backend && black --check . && flake8 . && pytest --cov=kerjaflow"
echo ""
echo "  # Mobile verification"
echo "  cd mobile && flutter analyze && flutter test --coverage"
echo ""
echo "  # Security verification"
echo "  bandit -r backend/ -ll && safety check"
echo ""
echo "  # Build verification"
echo "  cd mobile && flutter build apk --release"
echo ""

# =============================================================================
# SUMMARY
# =============================================================================

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                     EXECUTION SUMMARY                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Total Tasks: 21"
echo "Estimated Time: 14 days (1 developer) / 7 days (2 developers)"
echo ""
echo "Files to Create: 32"
echo "Files to Modify: 25"
echo ""
echo "Critical Blockers: 4"
echo "  1. kf_user_device.py missing"
echo "  2. JWT uses HS256 (must be RS256)"
echo "  3. CI/CD pipelines disabled"
echo "  4. Translation files incomplete"
echo ""
echo "For complete task details, see:"
echo "  KERJAFLOW_CLAUDE_CODE_CLI_COMPLETE_ACTION_PLAN.md"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  KerjaFlow - The fucking best workforce platform in ASEAN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
