#!/bin/bash
# REPLAY_AUDIT.sh - KerjaFlow Production Readiness Audit Replay Script
# Generated: 2025-12-28
# Execute from repository root: /home/user/kflow

set -euo pipefail
set -x

echo "=== SECTION 0: PROVENANCE ==="
git rev-parse --abbrev-ref HEAD
git rev-parse HEAD
git status --porcelain

echo "=== TOOL VERSIONS ==="
python3 --version || echo "Python not found"
pip3 list 2>/dev/null | grep -i odoo || echo "Odoo packages not found"
flutter --version 2>&1 || echo "Flutter not found"
dart --version 2>&1 || echo "Dart not found"
psql --version 2>&1 || echo "PostgreSQL client not found"
node --version 2>&1 || echo "Node not found"

echo "=== REPOSITORY STRUCTURE ==="
ls -la /home/user/kflow/
find /home/user/kflow -maxdepth 2 -type d

echo "=== BACKEND VERIFICATION ==="
ls -la /home/user/kflow/backend/odoo/addons/kerjaflow/
ls -la /home/user/kflow/backend/odoo/addons/kerjaflow/models/
ls -la /home/user/kflow/backend/odoo/addons/kerjaflow/controllers/
ls -la /home/user/kflow/backend/odoo/addons/kerjaflow/security/

echo "=== MODEL COUNT ==="
find /home/user/kflow/backend/odoo/addons/kerjaflow/models -name "*.py" -type f | wc -l

echo "=== CONTROLLER ROUTE COUNT ==="
grep -c "@http.route\|route(" /home/user/kflow/backend/odoo/addons/kerjaflow/controllers/*.py 2>/dev/null || true

echo "=== MOBILE VERIFICATION ==="
ls -la /home/user/kflow/mobile/lib/
find /home/user/kflow/mobile/lib/features -name "*_screen.dart" -o -name "*_page.dart" | wc -l
find /home/user/kflow/mobile/lib -name "*.dart" | wc -l

echo "=== i18n VERIFICATION ==="
for f in /home/user/kflow/mobile/lib/l10n/app_*.arb; do
  echo -n "$f: "
  wc -l < "$f"
done

echo "=== CI/CD VERIFICATION ==="
ls -la /home/user/kflow/.github/workflows/

echo "=== SECURITY CHECKS ==="
grep -n "HS256\|RS256" /home/user/kflow/backend/odoo/addons/kerjaflow/config.py || true
grep -n "algorithm=" /home/user/kflow/backend/odoo/addons/kerjaflow/controllers/auth_controller.py || true
grep -n "bcrypt\|gensalt" /home/user/kflow/backend/odoo/addons/kerjaflow/models/kf_user.py || true

echo "=== INFRASTRUCTURE ==="
ls -la /home/user/kflow/infrastructure/
ls -la /home/user/kflow/database/migrations/

echo "=== TEST COLLECTION ==="
find /home/user/kflow/backend -name "test_*.py" | wc -l
find /home/user/kflow/mobile/test -name "*_test.dart" | wc -l

echo "=== MISSING FILE CHECK ==="
ls /home/user/kflow/backend/odoo/addons/kerjaflow/models/kf_user_device.py 2>/dev/null && echo "EXISTS" || echo "kf_user_device.py NOT FOUND"

echo "=== .GITIGNORE CHECK ==="
ls -la /home/user/kflow/.gitignore 2>/dev/null || echo ".gitignore NOT FOUND"

echo "=== BACKEND LINT (if black available) ==="
black --check /home/user/kflow/backend/ 2>&1 || echo "black not available or failures"
flake8 /home/user/kflow/backend/ 2>&1 || echo "flake8 not available or failures"

echo "=== MOBILE BUILD (if flutter available) ==="
cd /home/user/kflow/mobile
flutter pub get 2>&1 || echo "Flutter not available"
flutter analyze 2>&1 || echo "Flutter not available"

echo "=== AUDIT COMPLETE ==="
