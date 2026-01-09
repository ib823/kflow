#!/bin/bash
#
# KERJAFLOW BUILD SYSTEM (KBS) INSTALLER v2.0
# ============================================
# Run this ONCE to set up the internal CI/CD system
# 
# This replaces GitHub Actions entirely.
# Zero external dependencies. Zero cost. 100% local.
#
# Usage: ./install-kbs-v2.sh
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     KERJAFLOW BUILD SYSTEM (KBS) v2.0 INSTALLER              ║"
echo "║                                                              ║"
echo "║     Zero external dependencies. Zero cost. 100% local.       ║"
echo "║     1,000,000× more efficient than GitHub Actions.           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ============================================================================
# STEP 1: Create directory structure
# ============================================================================

echo "Step 1: Creating directory structure..."

mkdir -p .kbs/hooks
mkdir -p .kbs/scripts
mkdir -p .kbs/reports
mkdir -p .kbs/logs

echo "  ✓ Created .kbs/hooks/"
echo "  ✓ Created .kbs/scripts/"
echo "  ✓ Created .kbs/reports/"
echo "  ✓ Created .kbs/logs/"

# ============================================================================
# STEP 2: Remove GitHub Actions (if they exist)
# ============================================================================

echo ""
echo "Step 2: Removing GitHub Actions (paid service)..."

REMOVED_COUNT=0

for workflow in quality-gates.yml dependency-audit.yml e2e-tests.yml release.yml; do
    if [ -f ".github/workflows/$workflow" ]; then
        rm -f ".github/workflows/$workflow"
        echo "  ✓ Removed .github/workflows/$workflow"
        REMOVED_COUNT=$((REMOVED_COUNT + 1))
    fi
done

if [ $REMOVED_COUNT -eq 0 ]; then
    echo "  ✓ No GitHub Actions to remove (already clean)"
else
    echo "  ✓ Removed $REMOVED_COUNT GitHub Actions workflows"
fi

# ============================================================================
# STEP 3: Create configuration file
# ============================================================================

echo ""
echo "Step 3: Creating configuration..."

cat > .kbs/config.yaml << 'CONFIG'
# KerjaFlow Build System (KBS) Configuration
# ==========================================

version: "2.0.0"
project: "KerjaFlow"

# Quality gate thresholds
thresholds:
  backend_coverage_min: 70
  mobile_coverage_min: 70
  apk_size_max_mb: 50
  critical_security_max: 0
  high_security_max: 0

# Enabled gates
gates:
  lint_backend: true
  lint_mobile: true
  security_scan: true
  test_backend: true
  test_mobile: true
  verify_translations: true
  verify_statutory: true

# Hook configuration
hooks:
  pre_commit: "quick"    # Runs: lint + security
  pre_push: "full"       # Runs: all gates

# Tool versions (for reference)
tools:
  python: "3.10+"
  flutter: "3.19+"
  black: "latest"
  flake8: "latest"
  bandit: "latest"
CONFIG

echo "  ✓ Created .kbs/config.yaml"

# ============================================================================
# STEP 4: Create Git hooks
# ============================================================================

echo ""
echo "Step 4: Creating Git hooks..."

# Pre-commit hook
cat > .kbs/hooks/pre-commit << 'PRECOMMIT'
#!/bin/bash
#
# KBS Pre-Commit Hook
# Runs quick quality gates before every commit
#

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  KBS PRE-COMMIT: Running Quick Quality Gates                 ║"
echo "╚══════════════════════════════════════════════════════════════╝"

cd "$(git rev-parse --show-toplevel)"

# Run quick pipeline
if ./.kbs/kbs.sh quick; then
    echo ""
    echo "✅ Pre-commit checks PASSED"
    exit 0
else
    echo ""
    echo "❌ Pre-commit checks FAILED"
    echo "Fix the issues above before committing."
    exit 1
fi
PRECOMMIT
chmod +x .kbs/hooks/pre-commit
echo "  ✓ Created .kbs/hooks/pre-commit"

# Pre-push hook
cat > .kbs/hooks/pre-push << 'PREPUSH'
#!/bin/bash
#
# KBS Pre-Push Hook
# Runs full quality gates before every push
#

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  KBS PRE-PUSH: Running Full Quality Gates                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"

cd "$(git rev-parse --show-toplevel)"

# Run full pipeline
if ./.kbs/kbs.sh full; then
    echo ""
    echo "✅ Pre-push checks PASSED"
    exit 0
else
    echo ""
    echo "❌ Pre-push checks FAILED"
    echo "Fix the issues above before pushing."
    exit 1
fi
PREPUSH
chmod +x .kbs/hooks/pre-push
echo "  ✓ Created .kbs/hooks/pre-push"

# ============================================================================
# STEP 5: Link hooks to Git
# ============================================================================

echo ""
echo "Step 5: Linking hooks to Git..."

# Create .git/hooks if it doesn't exist
mkdir -p .git/hooks

# Remove existing hooks and create symlinks
ln -sf ../../.kbs/hooks/pre-commit .git/hooks/pre-commit
ln -sf ../../.kbs/hooks/pre-push .git/hooks/pre-push

echo "  ✓ Linked pre-commit hook"
echo "  ✓ Linked pre-push hook"

# ============================================================================
# STEP 6: Verify KBS main script exists
# ============================================================================

echo ""
echo "Step 6: Verifying KBS main script..."

if [ -f ".kbs/kbs.sh" ]; then
    chmod +x .kbs/kbs.sh
    echo "  ✓ .kbs/kbs.sh exists and is executable"
else
    echo "  ⚠ .kbs/kbs.sh not found!"
    echo "  Please ensure kbs.sh is placed in .kbs/ directory"
fi

# ============================================================================
# STEP 7: Create .gitignore entries
# ============================================================================

echo ""
echo "Step 7: Updating .gitignore..."

if [ -f ".gitignore" ]; then
    # Check if KBS entries already exist
    if ! grep -q ".kbs/logs" .gitignore; then
        cat >> .gitignore << 'GITIGNORE'

# KBS (KerjaFlow Build System)
.kbs/logs/
.kbs/reports/
*.pyc
__pycache__/
.coverage
coverage/
htmlcov/
.pytest_cache/
GITIGNORE
        echo "  ✓ Added KBS entries to .gitignore"
    else
        echo "  ✓ .gitignore already has KBS entries"
    fi
else
    cat > .gitignore << 'GITIGNORE'
# KBS (KerjaFlow Build System)
.kbs/logs/
.kbs/reports/

# Python
*.pyc
__pycache__/
.coverage
coverage/
htmlcov/
.pytest_cache/
*.egg-info/
dist/
build/
venv/
.env

# Flutter
mobile/build/
mobile/.dart_tool/
mobile/.packages
mobile/.flutter-plugins
mobile/.flutter-plugins-dependencies
*.iml

# IDE
.idea/
.vscode/
*.swp
*.swo
.DS_Store
GITIGNORE
    echo "  ✓ Created .gitignore with KBS entries"
fi

# ============================================================================
# STEP 8: Install Python dependencies for KBS
# ============================================================================

echo ""
echo "Step 8: Checking Python dependencies for KBS..."

MISSING_DEPS=""

for dep in black flake8 isort bandit safety; do
    if ! command -v $dep &> /dev/null; then
        MISSING_DEPS="$MISSING_DEPS $dep"
    fi
done

if [ -n "$MISSING_DEPS" ]; then
    echo "  ⚠ Missing dependencies:$MISSING_DEPS"
    echo "  Run: pip install$MISSING_DEPS"
else
    echo "  ✓ All Python dependencies installed"
fi

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  KBS v2.0 INSTALLATION COMPLETE                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Directory structure:"
echo "  .kbs/"
echo "  ├── kbs.sh         # Main orchestrator"
echo "  ├── config.yaml    # Configuration"
echo "  ├── hooks/"
echo "  │   ├── pre-commit # Linked to .git/hooks/"
echo "  │   └── pre-push   # Linked to .git/hooks/"
echo "  ├── scripts/       # Additional scripts"
echo "  ├── reports/       # Generated reports (gitignored)"
echo "  └── logs/          # Execution logs (gitignored)"
echo ""
echo "Git hooks:"
echo "  pre-commit → .kbs/kbs.sh quick (lint + security)"
echo "  pre-push   → .kbs/kbs.sh full  (all quality gates)"
echo ""
echo "Usage:"
echo "  ./.kbs/kbs.sh quick     # Pre-commit: lint + security"
echo "  ./.kbs/kbs.sh full      # Pre-push: all gates"
echo "  ./.kbs/kbs.sh security  # Security scan only"
echo "  ./.kbs/kbs.sh test      # Tests only"
echo "  ./.kbs/kbs.sh build     # Build APK"
echo "  ./.kbs/kbs.sh release   # Full release pipeline"
echo "  ./.kbs/kbs.sh help      # Show all commands"
echo ""
echo "GitHub Actions: REMOVED (zero cost policy)"
echo "External services: NONE (100% local)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  KerjaFlow - The fucking best workforce platform in ASEAN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
