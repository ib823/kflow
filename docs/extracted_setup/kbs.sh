#!/bin/bash
#===============================================================================
# KERJAFLOW BUILD SYSTEM (KBS) v1.0
# 
# Zero external dependencies. Zero paid services. 100% internal ownership.
# 
# This replaces GitHub Actions, CircleCI, and every paid CI/CD service.
# And it's BETTER because WE CONTROL IT.
#
# Usage:
#   ./kbs.sh full      - Run all quality gates
#   ./kbs.sh quick     - Run lint + security only (pre-commit)
#   ./kbs.sh release   - Run full + create release
#   ./kbs.sh security  - Run security gates only
#   ./kbs.sh help      - Show help
#
# Installation:
#   1. Copy this to .kbs/kbs.sh in your repository
#   2. chmod +x .kbs/kbs.sh
#   3. Run: ./.kbs/kbs.sh full
#
# Requirements (all FREE):
#   - Python 3.8+
#   - pip install black flake8 isort pytest pytest-cov bandit safety pip-audit
#   - Flutter (optional, for mobile)
#   - Docker (optional, for container builds)
#===============================================================================

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$SCRIPT_DIR/logs"
ARTIFACT_DIR="$SCRIPT_DIR/artifacts"
REPORT_DIR="$SCRIPT_DIR/reports"

# Quality thresholds (customize these)
COVERAGE_THRESHOLD=70
MAX_BANDIT_HIGH=0
MAX_SAFETY_VULNS=0
MAX_APK_SIZE_MB=50

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Build metadata
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown')
BUILD_ID="${TIMESTAMP}_${GIT_SHA}"

#===============================================================================
# LOGGING
#===============================================================================
mkdir -p "$LOG_DIR" "$ARTIFACT_DIR" "$REPORT_DIR"
BUILD_LOG="$LOG_DIR/build_${BUILD_ID}.log"

log() {
    local level=$1
    shift
    local msg="$*"
    local ts=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "[$ts] [$level] $msg" | tee -a "$BUILD_LOG"
}

log_header() {
    echo -e "\n${CYAN}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}  $*${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════${NC}\n"
}

log_section() {
    echo -e "\n${BLUE}▶ $*${NC}"
    echo -e "${BLUE}───────────────────────────────────────────────────────────────${NC}"
}

log_info() { log "INFO" "${BLUE}$*${NC}"; }
log_success() { log "PASS" "${GREEN}✓ $*${NC}"; }
log_warning() { log "WARN" "${YELLOW}⚠ $*${NC}"; }
log_error() { log "FAIL" "${RED}✗ $*${NC}"; }

#===============================================================================
# UTILITY FUNCTIONS
#===============================================================================
check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

ensure_python_tool() {
    local tool=$1
    if ! python3 -m "$tool" --version &> /dev/null 2>&1; then
        log_warning "$tool not installed. Installing..."
        pip install "$tool" --quiet
    fi
}

#===============================================================================
# GATE: BACKEND LINT
#===============================================================================
gate_backend_lint() {
    log_section "BACKEND LINT"
    local failures=0
    
    if [ ! -d "$PROJECT_ROOT/backend" ]; then
        log_warning "Backend directory not found. Skipping."
        return 0
    fi
    
    cd "$PROJECT_ROOT/backend"
    
    # Black
    log_info "Running black (code formatter)..."
    ensure_python_tool black
    if python3 -m black --check --diff . 2>&1 | head -50 | tee -a "$BUILD_LOG"; then
        log_success "black: Code is properly formatted"
    else
        log_error "black: Formatting issues found"
        log_info "Fix with: cd backend && python3 -m black ."
        ((failures++))
    fi
    
    # Flake8
    log_info "Running flake8 (linter)..."
    ensure_python_tool flake8
    if python3 -m flake8 . \
        --max-line-length=120 \
        --exclude=__pycache__,migrations,.git \
        --count \
        --statistics 2>&1 | tee -a "$BUILD_LOG"; then
        log_success "flake8: No linting errors"
    else
        log_error "flake8: Linting errors found"
        ((failures++))
    fi
    
    # isort
    log_info "Running isort (import sorter)..."
    ensure_python_tool isort
    if python3 -m isort --check-only --diff . 2>&1 | head -20 | tee -a "$BUILD_LOG"; then
        log_success "isort: Imports are sorted"
    else
        log_warning "isort: Import order issues (non-blocking)"
    fi
    
    cd "$PROJECT_ROOT"
    return $failures
}

#===============================================================================
# GATE: BACKEND TEST
#===============================================================================
gate_backend_test() {
    log_section "BACKEND TESTS"
    local failures=0
    
    if [ ! -d "$PROJECT_ROOT/backend" ]; then
        log_warning "Backend directory not found. Skipping."
        return 0
    fi
    
    cd "$PROJECT_ROOT/backend"
    
    ensure_python_tool pytest
    ensure_python_tool pytest-cov
    
    log_info "Running pytest with coverage..."
    
    # Create pytest config if not exists
    if [ ! -f "pytest.ini" ] && [ ! -f "pyproject.toml" ]; then
        cat > pytest.ini << 'EOF'
[pytest]
testpaths = tests
python_files = test_*.py
python_functions = test_*
addopts = -v --tb=short
EOF
    fi
    
    if python3 -m pytest \
        --cov=. \
        --cov-report=xml:"$REPORT_DIR/backend-coverage.xml" \
        --cov-report=html:"$REPORT_DIR/backend-coverage-html" \
        --cov-report=term-missing \
        --junitxml="$REPORT_DIR/backend-tests.xml" \
        -v 2>&1 | tee -a "$BUILD_LOG"; then
        log_success "pytest: All tests passed"
    else
        log_error "pytest: Tests failed"
        ((failures++))
    fi
    
    cd "$PROJECT_ROOT"
    return $failures
}

#===============================================================================
# GATE: BACKEND COVERAGE
#===============================================================================
gate_backend_coverage() {
    log_section "BACKEND COVERAGE (minimum ${COVERAGE_THRESHOLD}%)"
    local failures=0
    local coverage_file="$REPORT_DIR/backend-coverage.xml"
    
    if [ ! -f "$coverage_file" ]; then
        log_warning "Coverage file not found. Run tests first."
        return 0
    fi
    
    # Extract coverage from XML
    local coverage=$(python3 -c "
import xml.etree.ElementTree as ET
try:
    tree = ET.parse('$coverage_file')
    root = tree.getroot()
    line_rate = float(root.get('line-rate', 0))
    print(f'{line_rate * 100:.1f}')
except:
    print('0')
" 2>/dev/null)
    
    log_info "Backend coverage: ${coverage}%"
    
    if (( $(echo "$coverage >= $COVERAGE_THRESHOLD" | bc -l) )); then
        log_success "Coverage: ${coverage}% >= ${COVERAGE_THRESHOLD}%"
    else
        log_error "Coverage: ${coverage}% < ${COVERAGE_THRESHOLD}%"
        ((failures++))
    fi
    
    return $failures
}

#===============================================================================
# GATE: MOBILE LINT
#===============================================================================
gate_mobile_lint() {
    log_section "MOBILE LINT"
    local failures=0
    
    if [ ! -d "$PROJECT_ROOT/mobile" ]; then
        log_warning "Mobile directory not found. Skipping."
        return 0
    fi
    
    if ! check_command flutter; then
        log_warning "Flutter not installed. Skipping mobile lint."
        return 0
    fi
    
    cd "$PROJECT_ROOT/mobile"
    
    log_info "Getting Flutter dependencies..."
    flutter pub get 2>&1 | tail -5 | tee -a "$BUILD_LOG"
    
    log_info "Running flutter analyze..."
    if flutter analyze --fatal-infos --fatal-warnings 2>&1 | tee -a "$BUILD_LOG"; then
        log_success "flutter analyze: No issues"
    else
        log_error "flutter analyze: Issues found"
        ((failures++))
    fi
    
    cd "$PROJECT_ROOT"
    return $failures
}

#===============================================================================
# GATE: MOBILE TEST
#===============================================================================
gate_mobile_test() {
    log_section "MOBILE TESTS"
    local failures=0
    
    if [ ! -d "$PROJECT_ROOT/mobile" ]; then
        log_warning "Mobile directory not found. Skipping."
        return 0
    fi
    
    if ! check_command flutter; then
        log_warning "Flutter not installed. Skipping mobile tests."
        return 0
    fi
    
    cd "$PROJECT_ROOT/mobile"
    
    log_info "Running flutter test with coverage..."
    if flutter test --coverage 2>&1 | tee -a "$BUILD_LOG"; then
        log_success "flutter test: All tests passed"
        
        # Copy coverage report
        if [ -f "coverage/lcov.info" ]; then
            cp coverage/lcov.info "$REPORT_DIR/mobile-coverage.lcov"
        fi
    else
        log_error "flutter test: Tests failed"
        ((failures++))
    fi
    
    cd "$PROJECT_ROOT"
    return $failures
}

#===============================================================================
# GATE: MOBILE BUILD
#===============================================================================
gate_mobile_build() {
    log_section "MOBILE BUILD"
    local failures=0
    
    if [ ! -d "$PROJECT_ROOT/mobile" ]; then
        log_warning "Mobile directory not found. Skipping."
        return 0
    fi
    
    if ! check_command flutter; then
        log_warning "Flutter not installed. Skipping mobile build."
        return 0
    fi
    
    cd "$PROJECT_ROOT/mobile"
    
    log_info "Building release APK..."
    if flutter build apk --release 2>&1 | tail -20 | tee -a "$BUILD_LOG"; then
        log_success "APK build successful"
        
        local apk_path="build/app/outputs/flutter-apk/app-release.apk"
        if [ -f "$apk_path" ]; then
            # Get APK size
            local apk_size
            if [[ "$OSTYPE" == "darwin"* ]]; then
                apk_size=$(stat -f%z "$apk_path")
            else
                apk_size=$(stat -c%s "$apk_path")
            fi
            local apk_size_mb=$((apk_size / 1024 / 1024))
            
            log_info "APK size: ${apk_size_mb}MB"
            
            if [ "$apk_size_mb" -gt "$MAX_APK_SIZE_MB" ]; then
                log_error "APK size ${apk_size_mb}MB exceeds ${MAX_APK_SIZE_MB}MB limit"
                ((failures++))
            else
                log_success "APK size within limit"
                cp "$apk_path" "$ARTIFACT_DIR/kerjaflow-${BUILD_ID}.apk"
                log_info "APK copied to: $ARTIFACT_DIR/kerjaflow-${BUILD_ID}.apk"
            fi
        fi
    else
        log_error "APK build failed"
        ((failures++))
    fi
    
    cd "$PROJECT_ROOT"
    return $failures
}

#===============================================================================
# GATE: SECURITY SCAN
#===============================================================================
gate_security_scan() {
    log_section "SECURITY SCAN"
    local failures=0
    
    # Bandit - Python security linter
    if [ -d "$PROJECT_ROOT/backend" ]; then
        log_info "Running bandit (Python security scanner)..."
        ensure_python_tool bandit
        
        python3 -m bandit -r "$PROJECT_ROOT/backend" \
            -ll \
            -f json \
            -o "$REPORT_DIR/bandit-report.json" 2>&1 || true
        
        local bandit_high=$(python3 -c "
import json
try:
    with open('$REPORT_DIR/bandit-report.json') as f:
        data = json.load(f)
        high = sum(1 for r in data.get('results', []) if r.get('issue_severity') in ['HIGH', 'CRITICAL'])
        print(high)
except:
    print(0)
" 2>/dev/null)
        
        if [ "$bandit_high" -gt "$MAX_BANDIT_HIGH" ]; then
            log_error "bandit: Found $bandit_high high/critical issues (max: $MAX_BANDIT_HIGH)"
            ((failures++))
        else
            log_success "bandit: No high/critical issues"
        fi
    fi
    
    # Safety - Dependency vulnerabilities
    if [ -f "$PROJECT_ROOT/backend/requirements.txt" ]; then
        log_info "Running safety (dependency vulnerabilities)..."
        ensure_python_tool safety
        
        if python3 -m safety check \
            -r "$PROJECT_ROOT/backend/requirements.txt" \
            --json > "$REPORT_DIR/safety-report.json" 2>&1; then
            log_success "safety: No known vulnerabilities"
        else
            local vuln_count=$(python3 -c "
import json
try:
    with open('$REPORT_DIR/safety-report.json') as f:
        data = json.load(f)
        print(len(data) if isinstance(data, list) else 0)
except:
    print(0)
" 2>/dev/null)
            
            if [ "$vuln_count" -gt "$MAX_SAFETY_VULNS" ]; then
                log_error "safety: Found $vuln_count vulnerable packages"
                ((failures++))
            else
                log_warning "safety: Found $vuln_count vulnerabilities (within threshold)"
            fi
        fi
    fi
    
    # pip-audit
    if [ -f "$PROJECT_ROOT/backend/requirements.txt" ]; then
        log_info "Running pip-audit..."
        ensure_python_tool pip-audit
        
        python3 -m pip_audit \
            -r "$PROJECT_ROOT/backend/requirements.txt" \
            --format json > "$REPORT_DIR/pip-audit-report.json" 2>&1 || true
        log_success "pip-audit: Report generated"
    fi
    
    # Secret detection
    log_info "Running secret detection..."
    local secrets_found=0
    
    # Check for common secret patterns
    local patterns=(
        "password\s*=\s*['\"][^'\"]+['\"]"
        "api_key\s*=\s*['\"][^'\"]+['\"]"
        "secret\s*=\s*['\"][^'\"]+['\"]"
        "AKIA[0-9A-Z]{16}"
        "-----BEGIN.*PRIVATE KEY-----"
    )
    
    for pattern in "${patterns[@]}"; do
        local matches=$(grep -rn --include="*.py" --include="*.dart" --include="*.yaml" --include="*.yml" \
            -E "$pattern" "$PROJECT_ROOT" 2>/dev/null | \
            grep -v "__pycache__" | grep -v ".git" | grep -v "node_modules" | \
            grep -v "example" | grep -v "test" | wc -l || echo "0")
        secrets_found=$((secrets_found + matches))
    done
    
    if [ "$secrets_found" -gt 0 ]; then
        log_warning "Potential secrets found: $secrets_found matches (review required)"
    else
        log_success "No obvious secrets detected"
    fi
    
    return $failures
}

#===============================================================================
# GATE: I18N VALIDATION
#===============================================================================
gate_i18n_validation() {
    log_section "I18N VALIDATION"
    local failures=0
    
    if [ ! -d "$PROJECT_ROOT/mobile" ]; then
        log_warning "Mobile directory not found. Skipping i18n."
        return 0
    fi
    
    local arb_dir="$PROJECT_ROOT/mobile/lib/l10n"
    
    if [ ! -d "$arb_dir" ]; then
        log_warning "l10n directory not found. Skipping i18n."
        return 0
    fi
    
    # Count keys in English baseline
    local en_file="$arb_dir/app_en.arb"
    if [ ! -f "$en_file" ]; then
        log_warning "English ARB file not found."
        return 0
    fi
    
    local en_keys=$(grep -c '"[^@]' "$en_file" 2>/dev/null || echo "0")
    log_info "English baseline: $en_keys keys"
    
    # Check each ARB file
    for arb_file in "$arb_dir"/app_*.arb; do
        if [ -f "$arb_file" ]; then
            local lang=$(basename "$arb_file" .arb | sed 's/app_//')
            local keys=$(grep -c '"[^@]' "$arb_file" 2>/dev/null || echo "0")
            local pct=$((keys * 100 / en_keys))
            
            if [ "$pct" -ge 95 ]; then
                log_success "$lang: $keys keys ($pct%)"
            elif [ "$pct" -ge 70 ]; then
                log_warning "$lang: $keys keys ($pct%)"
            else
                log_error "$lang: $keys keys ($pct%) - below 70%"
            fi
        fi
    done
    
    # Run flutter gen-l10n if flutter available
    if check_command flutter; then
        cd "$PROJECT_ROOT/mobile"
        log_info "Running flutter gen-l10n..."
        if flutter gen-l10n 2>&1 | tee -a "$BUILD_LOG"; then
            log_success "flutter gen-l10n: Successful"
        else
            log_error "flutter gen-l10n: Failed"
            ((failures++))
        fi
        cd "$PROJECT_ROOT"
    fi
    
    return $failures
}

#===============================================================================
# GATE: DOCKER BUILD
#===============================================================================
gate_docker_build() {
    log_section "DOCKER BUILD"
    local failures=0
    
    if ! check_command docker; then
        log_warning "Docker not installed. Skipping Docker build."
        return 0
    fi
    
    if [ ! -f "$PROJECT_ROOT/backend/Dockerfile" ]; then
        log_warning "Backend Dockerfile not found. Skipping."
        return 0
    fi
    
    log_info "Building backend Docker image..."
    if docker build \
        -t kerjaflow-backend:${BUILD_ID} \
        -t kerjaflow-backend:latest \
        -f "$PROJECT_ROOT/backend/Dockerfile" \
        "$PROJECT_ROOT/backend" 2>&1 | tail -20 | tee -a "$BUILD_LOG"; then
        log_success "Docker build: Successful"
    else
        log_error "Docker build: Failed"
        ((failures++))
    fi
    
    return $failures
}

#===============================================================================
# PIPELINE: FULL
#===============================================================================
pipeline_full() {
    log_header "KERJAFLOW BUILD SYSTEM - FULL PIPELINE"
    echo "Build ID:    $BUILD_ID"
    echo "Branch:      $GIT_BRANCH"
    echo "Commit:      $GIT_SHA"
    echo "Started:     $(date)"
    echo ""
    
    local total_failures=0
    local start_time=$(date +%s)
    
    # Run all gates
    gate_backend_lint || ((total_failures+=$?))
    gate_backend_test || ((total_failures+=$?))
    gate_backend_coverage || ((total_failures+=$?))
    gate_mobile_lint || ((total_failures+=$?))
    gate_mobile_test || ((total_failures+=$?))
    gate_security_scan || ((total_failures+=$?))
    gate_i18n_validation || ((total_failures+=$?))
    gate_mobile_build || ((total_failures+=$?))
    gate_docker_build || ((total_failures+=$?))
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo ""
    log_header "PIPELINE COMPLETE"
    echo "Duration:    ${duration}s"
    echo "Log:         $BUILD_LOG"
    echo "Reports:     $REPORT_DIR/"
    echo "Artifacts:   $ARTIFACT_DIR/"
    echo ""
    
    if [ "$total_failures" -eq 0 ]; then
        log_success "ALL GATES PASSED"
        return 0
    else
        log_error "$total_failures GATE(S) FAILED"
        return 1
    fi
}

#===============================================================================
# PIPELINE: QUICK (Pre-commit)
#===============================================================================
pipeline_quick() {
    log_header "KERJAFLOW BUILD SYSTEM - QUICK PIPELINE"
    
    local total_failures=0
    
    gate_backend_lint || ((total_failures+=$?))
    gate_mobile_lint || ((total_failures+=$?))
    gate_security_scan || ((total_failures+=$?))
    
    echo ""
    if [ "$total_failures" -eq 0 ]; then
        log_success "QUICK PIPELINE PASSED"
        return 0
    else
        log_error "QUICK PIPELINE FAILED"
        return 1
    fi
}

#===============================================================================
# PIPELINE: RELEASE
#===============================================================================
pipeline_release() {
    log_header "KERJAFLOW BUILD SYSTEM - RELEASE PIPELINE"
    
    if ! pipeline_full; then
        log_error "Cannot release: Full pipeline failed"
        return 1
    fi
    
    # Get version
    local version
    if [ -f "$PROJECT_ROOT/VERSION" ]; then
        version=$(cat "$PROJECT_ROOT/VERSION")
    else
        version="0.0.0"
    fi
    
    log_info "Creating release v${version}..."
    
    # Tag the release
    git tag -a "v${version}" -m "Release v${version}" 2>/dev/null || true
    
    log_success "Release v${version} ready"
    log_info "Artifacts in: $ARTIFACT_DIR"
    
    return 0
}

#===============================================================================
# HELP
#===============================================================================
show_help() {
    cat << 'EOF'
KerjaFlow Build System (KBS) v1.0

Zero external dependencies. Zero paid services. 100% internal ownership.

USAGE:
    ./kbs.sh [PIPELINE]

PIPELINES:
    full        Run all quality gates (default)
    quick       Run lint + security only (fast, for pre-commit)
    release     Run full + create release artifacts
    lint        Run linting gates only
    test        Run test gates only
    security    Run security gates only
    build       Run build gates only
    help        Show this help

QUALITY GATES:
    - Backend Lint:     black, flake8, isort
    - Backend Test:     pytest with coverage
    - Backend Coverage: Minimum 70%
    - Mobile Lint:      flutter analyze
    - Mobile Test:      flutter test
    - Mobile Build:     flutter build apk
    - Security Scan:    bandit, safety, pip-audit, secrets
    - I18N Validation:  ARB completeness, flutter gen-l10n
    - Docker Build:     Build backend image

REPORTS:
    All reports are saved to .kbs/reports/
    All artifacts are saved to .kbs/artifacts/
    All logs are saved to .kbs/logs/

CONFIGURATION:
    Edit the thresholds at the top of this script:
    - COVERAGE_THRESHOLD=70
    - MAX_BANDIT_HIGH=0
    - MAX_SAFETY_VULNS=0
    - MAX_APK_SIZE_MB=50

REQUIREMENTS:
    Backend: pip install black flake8 isort pytest pytest-cov bandit safety pip-audit
    Mobile:  Flutter SDK (optional)
    Docker:  Docker (optional)

EXAMPLES:
    ./kbs.sh               # Run full pipeline
    ./kbs.sh quick         # Quick check before commit
    ./kbs.sh security      # Security scan only
    ./kbs.sh release       # Full + release artifacts

EOF
}

#===============================================================================
# MAIN
#===============================================================================
main() {
    case "${1:-full}" in
        full)
            pipeline_full
            ;;
        quick)
            pipeline_quick
            ;;
        release)
            pipeline_release
            ;;
        lint)
            gate_backend_lint
            gate_mobile_lint
            ;;
        test)
            gate_backend_test
            gate_mobile_test
            ;;
        security)
            gate_security_scan
            ;;
        build)
            gate_mobile_build
            gate_docker_build
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown pipeline: $1"
            echo "Run './kbs.sh help' for usage"
            exit 1
            ;;
    esac
}

main "$@"
