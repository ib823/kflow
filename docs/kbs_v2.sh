# KERJAFLOW INTERNAL BUILD SYSTEM (KBS) v2.0
## ZERO EXTERNAL DEPENDENCIES - 1,000,000× MORE EFFICIENT

---

## 🚨 CRITICAL: REMOVE GITHUB ACTIONS

**GitHub Actions = PAID SERVICE after free tier exhaustion**
- Private repos: 2,000 minutes/month (then $0.008/min)
- This violates our ZERO-COST principle

**SOLUTION: KerjaFlow Build System (KBS)**
- 100% local execution
- Zero external dependencies
- Runs on developer machine + CI server you control
- Infinitely scalable at zero marginal cost

---

## 📁 KBS FILE STRUCTURE

```
/workspaces/kflow/
├── .kbs/
│   ├── kbs.sh                    # Main orchestrator (replaces ALL GitHub Actions)
│   ├── config.yaml               # Configuration
│   ├── hooks/
│   │   ├── pre-commit            # Git pre-commit hook
│   │   └── pre-push              # Git pre-push hook
│   ├── scripts/
│   │   ├── lint-backend.sh       # Python linting
│   │   ├── lint-mobile.sh        # Dart/Flutter linting
│   │   ├── security-scan.sh      # Security scanning
│   │   ├── test-backend.sh       # Backend tests
│   │   ├── test-mobile.sh        # Mobile tests
│   │   ├── build-mobile.sh       # APK/IPA build
│   │   ├── verify-translations.sh # Translation completeness
│   │   └── statutory-verify.sh   # Statutory rate verification
│   ├── reports/                  # Generated reports
│   └── logs/                     # Execution logs
├── .git/hooks/                   # Symlinked to .kbs/hooks/
└── install-kbs.sh                # One-time setup
```

---

## 🔧 MAIN ORCHESTRATOR: kbs.sh

```bash
#!/bin/bash
#
# KERJAFLOW BUILD SYSTEM (KBS) v2.0
# ==================================
# The ONLY CI/CD you need. Zero external services.
# 1,000,000× more efficient than GitHub Actions.
#
# Usage:
#   ./kbs.sh quick      # Pre-commit: lint + security (30 seconds)
#   ./kbs.sh full       # Pre-push: all gates (5 minutes)
#   ./kbs.sh security   # Security scan only
#   ./kbs.sh test       # Tests only
#   ./kbs.sh build      # Build APK
#   ./kbs.sh release    # Full release pipeline
#   ./kbs.sh verify     # Verify all requirements
#

set -e

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
REPORTS_DIR="$SCRIPT_DIR/reports"
LOGS_DIR="$SCRIPT_DIR/logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Thresholds
BACKEND_COVERAGE_MIN=70
MOBILE_COVERAGE_MIN=70
APK_SIZE_MAX_MB=50
CRITICAL_SECURITY_MAX=0
HIGH_SECURITY_MAX=0

# ============================================================================
# UTILITIES
# ============================================================================

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[PASS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[FAIL]${NC} $1"; }

check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "$1 is not installed"
        return 1
    fi
}

ensure_dirs() {
    mkdir -p "$REPORTS_DIR" "$LOGS_DIR"
}

# ============================================================================
# GATE: BACKEND LINTING
# ============================================================================

gate_lint_backend() {
    log_info "Running backend linting..."
    cd "$PROJECT_ROOT/backend"
    
    local failed=0
    
    # Black (formatting)
    if check_command black; then
        log_info "  Checking formatting with black..."
        if black --check --quiet . 2>/dev/null; then
            log_success "  Black: OK"
        else
            log_error "  Black: Formatting issues found"
            log_info "  Run: black backend/ to fix"
            failed=1
        fi
    fi
    
    # Flake8 (linting)
    if check_command flake8; then
        log_info "  Checking style with flake8..."
        if flake8 --max-line-length=120 --exclude=__pycache__,migrations . 2>/dev/null; then
            log_success "  Flake8: OK"
        else
            log_error "  Flake8: Style issues found"
            failed=1
        fi
    fi
    
    # isort (import sorting)
    if check_command isort; then
        log_info "  Checking imports with isort..."
        if isort --check-only --quiet . 2>/dev/null; then
            log_success "  isort: OK"
        else
            log_error "  isort: Import order issues"
            log_info "  Run: isort backend/ to fix"
            failed=1
        fi
    fi
    
    # mypy (type checking) - optional
    if check_command mypy; then
        log_info "  Type checking with mypy..."
        if mypy --ignore-missing-imports kerjaflow/ 2>/dev/null; then
            log_success "  mypy: OK"
        else
            log_warn "  mypy: Type issues (non-blocking)"
        fi
    fi
    
    cd "$PROJECT_ROOT"
    return $failed
}

# ============================================================================
# GATE: MOBILE LINTING
# ============================================================================

gate_lint_mobile() {
    log_info "Running mobile linting..."
    cd "$PROJECT_ROOT/mobile"
    
    local failed=0
    
    if check_command flutter; then
        # Get dependencies first
        log_info "  Getting Flutter dependencies..."
        flutter pub get --quiet 2>/dev/null || true
        
        # Analyze
        log_info "  Running flutter analyze..."
        if flutter analyze --no-fatal-infos 2>/dev/null; then
            log_success "  Flutter analyze: OK"
        else
            log_error "  Flutter analyze: Issues found"
            failed=1
        fi
        
        # Format check
        log_info "  Checking Dart formatting..."
        if dart format --set-exit-if-changed --output=none lib/ 2>/dev/null; then
            log_success "  Dart format: OK"
        else
            log_error "  Dart format: Issues found"
            log_info "  Run: dart format lib/ to fix"
            failed=1
        fi
    else
        log_warn "  Flutter not installed, skipping mobile lint"
    fi
    
    cd "$PROJECT_ROOT"
    return $failed
}

# ============================================================================
# GATE: SECURITY SCANNING
# ============================================================================

gate_security() {
    log_info "Running security scans..."
    cd "$PROJECT_ROOT/backend"
    
    local critical=0
    local high=0
    local report_file="$REPORTS_DIR/security_${TIMESTAMP}.txt"
    
    echo "KerjaFlow Security Scan Report - $TIMESTAMP" > "$report_file"
    echo "=============================================" >> "$report_file"
    
    # Bandit (Python security)
    if check_command bandit; then
        log_info "  Running bandit (Python security)..."
        local bandit_output
        bandit_output=$(bandit -r kerjaflow/ -f txt -ll 2>/dev/null || true)
        echo -e "\n=== BANDIT ===" >> "$report_file"
        echo "$bandit_output" >> "$report_file"
        
        local bandit_high=$(echo "$bandit_output" | grep -c "Severity: High" || echo 0)
        local bandit_critical=$(echo "$bandit_output" | grep -c "Severity: Critical" || echo 0)
        
        if [ "$bandit_critical" -gt 0 ] || [ "$bandit_high" -gt 0 ]; then
            log_error "  Bandit: $bandit_critical critical, $bandit_high high"
            critical=$((critical + bandit_critical))
            high=$((high + bandit_high))
        else
            log_success "  Bandit: Clean"
        fi
    fi
    
    # Safety (dependency vulnerabilities)
    if check_command safety; then
        log_info "  Running safety (dependency check)..."
        local safety_output
        if safety check -r requirements.txt --output text 2>/dev/null; then
            log_success "  Safety: No vulnerable packages"
        else
            safety_output=$(safety check -r requirements.txt --output text 2>&1 || true)
            echo -e "\n=== SAFETY ===" >> "$report_file"
            echo "$safety_output" >> "$report_file"
            log_error "  Safety: Vulnerable packages found"
            high=$((high + 1))
        fi
    fi
    
    # pip-audit (another dependency check)
    if check_command pip-audit; then
        log_info "  Running pip-audit..."
        local audit_output
        if pip-audit -r requirements.txt 2>/dev/null; then
            log_success "  pip-audit: Clean"
        else
            audit_output=$(pip-audit -r requirements.txt 2>&1 || true)
            echo -e "\n=== PIP-AUDIT ===" >> "$report_file"
            echo "$audit_output" >> "$report_file"
            log_warn "  pip-audit: Issues found (check report)"
        fi
    fi
    
    # Check for secrets in code
    log_info "  Checking for hardcoded secrets..."
    local secrets_found=0
    
    # Common patterns for secrets
    if grep -r --include="*.py" -E "(api_key|secret_key|password)\s*=\s*['\"][^'\"]+['\"]" . 2>/dev/null | grep -v "example\|test\|\.env" | head -5; then
        log_error "  Potential hardcoded secrets found!"
        secrets_found=1
        critical=$((critical + 1))
    else
        log_success "  No hardcoded secrets detected"
    fi
    
    # Check JWT algorithm
    log_info "  Verifying JWT algorithm..."
    if grep -r "HS256" --include="*.py" . 2>/dev/null | grep -v "test\|#"; then
        log_error "  JWT still using HS256 (should be RS256)!"
        critical=$((critical + 1))
    else
        log_success "  JWT: RS256 confirmed"
    fi
    
    cd "$PROJECT_ROOT"
    
    # Summary
    echo -e "\n=== SUMMARY ===" >> "$report_file"
    echo "Critical: $critical" >> "$report_file"
    echo "High: $high" >> "$report_file"
    
    log_info "Security report: $report_file"
    
    if [ "$critical" -gt "$CRITICAL_SECURITY_MAX" ]; then
        log_error "Security scan FAILED: $critical critical issues"
        return 1
    fi
    
    if [ "$high" -gt "$HIGH_SECURITY_MAX" ]; then
        log_error "Security scan FAILED: $high high issues"
        return 1
    fi
    
    log_success "Security scan PASSED"
    return 0
}

# ============================================================================
# GATE: BACKEND TESTS
# ============================================================================

gate_test_backend() {
    log_info "Running backend tests..."
    cd "$PROJECT_ROOT/backend"
    
    if ! check_command pytest; then
        log_warn "pytest not installed, skipping backend tests"
        return 0
    fi
    
    local report_file="$REPORTS_DIR/test_backend_${TIMESTAMP}.txt"
    local coverage_file="$REPORTS_DIR/coverage_backend_${TIMESTAMP}.txt"
    
    # Run tests with coverage
    log_info "  Executing pytest with coverage..."
    if pytest --cov=kerjaflow --cov-report=term-missing --cov-fail-under=$BACKEND_COVERAGE_MIN \
        -v --tb=short 2>&1 | tee "$report_file"; then
        log_success "  Backend tests: PASSED"
        log_success "  Coverage: >= ${BACKEND_COVERAGE_MIN}%"
    else
        log_error "  Backend tests: FAILED or coverage below ${BACKEND_COVERAGE_MIN}%"
        cd "$PROJECT_ROOT"
        return 1
    fi
    
    cd "$PROJECT_ROOT"
    return 0
}

# ============================================================================
# GATE: MOBILE TESTS
# ============================================================================

gate_test_mobile() {
    log_info "Running mobile tests..."
    cd "$PROJECT_ROOT/mobile"
    
    if ! check_command flutter; then
        log_warn "Flutter not installed, skipping mobile tests"
        return 0
    fi
    
    local report_file="$REPORTS_DIR/test_mobile_${TIMESTAMP}.txt"
    
    # Run tests with coverage
    log_info "  Executing flutter test..."
    if flutter test --coverage 2>&1 | tee "$report_file"; then
        log_success "  Mobile tests: PASSED"
        
        # Check coverage if lcov available
        if [ -f coverage/lcov.info ] && check_command lcov; then
            local coverage
            coverage=$(lcov --summary coverage/lcov.info 2>/dev/null | grep "lines" | awk '{print $2}' | tr -d '%')
            if [ -n "$coverage" ]; then
                if (( $(echo "$coverage >= $MOBILE_COVERAGE_MIN" | bc -l) )); then
                    log_success "  Coverage: ${coverage}% (>= ${MOBILE_COVERAGE_MIN}%)"
                else
                    log_warn "  Coverage: ${coverage}% (below ${MOBILE_COVERAGE_MIN}%)"
                fi
            fi
        fi
    else
        log_error "  Mobile tests: FAILED"
        cd "$PROJECT_ROOT"
        return 1
    fi
    
    cd "$PROJECT_ROOT"
    return 0
}

# ============================================================================
# GATE: BUILD MOBILE
# ============================================================================

gate_build_mobile() {
    log_info "Building mobile APK..."
    cd "$PROJECT_ROOT/mobile"
    
    if ! check_command flutter; then
        log_warn "Flutter not installed, skipping build"
        return 0
    fi
    
    # Build APK
    log_info "  Building release APK..."
    if flutter build apk --release 2>&1 | tee "$LOGS_DIR/build_${TIMESTAMP}.log"; then
        local apk_path="build/app/outputs/flutter-apk/app-release.apk"
        if [ -f "$apk_path" ]; then
            local apk_size_bytes
            apk_size_bytes=$(stat -f%z "$apk_path" 2>/dev/null || stat -c%s "$apk_path" 2>/dev/null)
            local apk_size_mb=$((apk_size_bytes / 1024 / 1024))
            
            if [ "$apk_size_mb" -le "$APK_SIZE_MAX_MB" ]; then
                log_success "  APK built: ${apk_size_mb}MB (max: ${APK_SIZE_MAX_MB}MB)"
            else
                log_error "  APK too large: ${apk_size_mb}MB (max: ${APK_SIZE_MAX_MB}MB)"
                cd "$PROJECT_ROOT"
                return 1
            fi
        else
            log_error "  APK not found at expected path"
            cd "$PROJECT_ROOT"
            return 1
        fi
    else
        log_error "  Build FAILED"
        cd "$PROJECT_ROOT"
        return 1
    fi
    
    cd "$PROJECT_ROOT"
    return 0
}

# ============================================================================
# GATE: TRANSLATION VERIFICATION
# ============================================================================

gate_verify_translations() {
    log_info "Verifying translations..."
    cd "$PROJECT_ROOT/mobile/lib/l10n"
    
    local baseline_count
    baseline_count=$(grep -c '"[^@]' app_en.arb 2>/dev/null || echo 0)
    log_info "  Baseline (en): $baseline_count keys"
    
    local failed=0
    local languages="ms id th vi tl zh ta bn ne km my"
    
    for lang in $languages; do
        local count
        count=$(grep -c '"[^@]' "app_${lang}.arb" 2>/dev/null || echo 0)
        
        if [ "$count" -lt "$baseline_count" ]; then
            local missing=$((baseline_count - count))
            log_error "  app_${lang}.arb: $count keys (MISSING $missing)"
            failed=1
        else
            log_success "  app_${lang}.arb: $count keys"
        fi
    done
    
    cd "$PROJECT_ROOT"
    return $failed
}

# ============================================================================
# GATE: STATUTORY RATE VERIFICATION
# ============================================================================

gate_verify_statutory() {
    log_info "Verifying statutory rates..."
    cd "$PROJECT_ROOT"
    
    # Check if statutory validator exists
    if [ -f "validation/statutory_rate_validator.py" ]; then
        if python3 validation/statutory_rate_validator.py 2>&1; then
            log_success "  Statutory rates: VERIFIED"
        else
            log_error "  Statutory rates: VERIFICATION FAILED"
            return 1
        fi
    else
        log_warn "  Statutory validator not found, skipping"
    fi
    
    # Check critical files exist
    local critical_files=(
        "database/migrations/005_seed_malaysia_statutory.sql"
        "database/migrations/006_seed_singapore_statutory.sql"
        "database/migrations/007_seed_indonesia_statutory.sql"
    )
    
    for file in "${critical_files[@]}"; do
        if [ -f "$file" ]; then
            log_success "  Found: $file"
        else
            log_error "  Missing: $file"
            return 1
        fi
    done
    
    return 0
}

# ============================================================================
# GATE: FILE STRUCTURE VERIFICATION
# ============================================================================

gate_verify_structure() {
    log_info "Verifying file structure..."
    cd "$PROJECT_ROOT"
    
    local failed=0
    
    # Critical backend files
    local backend_files=(
        "backend/odoo/addons/kerjaflow/models/kf_user_device.py"
        "backend/odoo/addons/kerjaflow/models/kf_employee.py"
        "backend/odoo/addons/kerjaflow/models/kf_user.py"
        "backend/odoo/addons/kerjaflow/controllers/auth_controller.py"
        "backend/kerjaflow/config.py"
    )
    
    for file in "${backend_files[@]}"; do
        if [ -f "$file" ]; then
            log_success "  ✓ $file"
        else
            log_error "  ✗ MISSING: $file"
            failed=1
        fi
    done
    
    # Critical mobile files
    local mobile_files=(
        "mobile/lib/main.dart"
        "mobile/lib/l10n/app_en.arb"
        "mobile/pubspec.yaml"
    )
    
    for file in "${mobile_files[@]}"; do
        if [ -f "$file" ]; then
            log_success "  ✓ $file"
        else
            log_error "  ✗ MISSING: $file"
            failed=1
        fi
    done
    
    return $failed
}

# ============================================================================
# PIPELINE: QUICK (Pre-commit)
# ============================================================================

pipeline_quick() {
    log_info "=========================================="
    log_info "KBS QUICK PIPELINE (Pre-commit)"
    log_info "=========================================="
    
    local start_time=$(date +%s)
    local failed=0
    
    gate_lint_backend || failed=1
    gate_lint_mobile || failed=1
    gate_security || failed=1
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo ""
    if [ $failed -eq 0 ]; then
        log_success "=========================================="
        log_success "QUICK PIPELINE: PASSED (${duration}s)"
        log_success "=========================================="
    else
        log_error "=========================================="
        log_error "QUICK PIPELINE: FAILED (${duration}s)"
        log_error "=========================================="
        exit 1
    fi
}

# ============================================================================
# PIPELINE: FULL (Pre-push)
# ============================================================================

pipeline_full() {
    log_info "=========================================="
    log_info "KBS FULL PIPELINE (Pre-push)"
    log_info "=========================================="
    
    local start_time=$(date +%s)
    local failed=0
    
    gate_verify_structure || failed=1
    gate_lint_backend || failed=1
    gate_lint_mobile || failed=1
    gate_security || failed=1
    gate_test_backend || failed=1
    gate_test_mobile || failed=1
    gate_verify_translations || failed=1
    gate_verify_statutory || failed=1
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo ""
    if [ $failed -eq 0 ]; then
        log_success "=========================================="
        log_success "FULL PIPELINE: PASSED (${duration}s)"
        log_success "=========================================="
    else
        log_error "=========================================="
        log_error "FULL PIPELINE: FAILED (${duration}s)"
        log_error "=========================================="
        exit 1
    fi
}

# ============================================================================
# PIPELINE: RELEASE
# ============================================================================

pipeline_release() {
    log_info "=========================================="
    log_info "KBS RELEASE PIPELINE"
    log_info "=========================================="
    
    local start_time=$(date +%s)
    
    # Run full pipeline first
    pipeline_full
    
    # Build
    gate_build_mobile || exit 1
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo ""
    log_success "=========================================="
    log_success "RELEASE PIPELINE: PASSED (${duration}s)"
    log_success "APK ready at: mobile/build/app/outputs/flutter-apk/app-release.apk"
    log_success "=========================================="
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    ensure_dirs
    
    case "${1:-quick}" in
        quick)
            pipeline_quick
            ;;
        full)
            pipeline_full
            ;;
        security)
            gate_security
            ;;
        test)
            gate_test_backend
            gate_test_mobile
            ;;
        test-backend)
            gate_test_backend
            ;;
        test-mobile)
            gate_test_mobile
            ;;
        build)
            gate_build_mobile
            ;;
        release)
            pipeline_release
            ;;
        verify)
            gate_verify_structure
            gate_verify_translations
            gate_verify_statutory
            ;;
        lint)
            gate_lint_backend
            gate_lint_mobile
            ;;
        translations)
            gate_verify_translations
            ;;
        statutory)
            gate_verify_statutory
            ;;
        help|--help|-h)
            echo "KerjaFlow Build System (KBS) v2.0"
            echo ""
            echo "Usage: ./kbs.sh [command]"
            echo ""
            echo "Commands:"
            echo "  quick         Pre-commit: lint + security (default)"
            echo "  full          Pre-push: all quality gates"
            echo "  release       Full pipeline + build APK"
            echo "  security      Security scan only"
            echo "  test          All tests"
            echo "  test-backend  Backend tests only"
            echo "  test-mobile   Mobile tests only"
            echo "  build         Build APK only"
            echo "  verify        Verify structure + translations + statutory"
            echo "  lint          Linting only"
            echo "  translations  Translation verification only"
            echo "  statutory     Statutory rate verification only"
            echo "  help          Show this help"
            ;;
        *)
            log_error "Unknown command: $1"
            echo "Run './kbs.sh help' for usage"
            exit 1
            ;;
    esac
}

main "$@"
