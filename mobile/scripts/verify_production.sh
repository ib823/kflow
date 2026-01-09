#!/bin/bash

#############################################
# KerjaFlow Production Verification Script
#
# Verifies production readiness by checking:
# - Code quality gates
# - Security requirements
# - Build artifacts
# - Configuration files
#
# Usage:
#   ./scripts/verify_production.sh [options]
#
# Options:
#   --fix         Auto-fix formatting issues
#   --verbose     Show detailed output
#   --help        Show this help message
#############################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Default values
AUTO_FIX=false
VERBOSE=false

# Counters
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --fix)
            AUTO_FIX=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            head -22 "$0" | tail -21
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Logging functions
log_pass() {
    echo -e "  ${GREEN}✓${NC} $1"
    ((PASS_COUNT++))
}

log_fail() {
    echo -e "  ${RED}✗${NC} $1"
    ((FAIL_COUNT++))
}

log_warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
    ((WARN_COUNT++))
}

log_info() {
    echo -e "  ${BLUE}ℹ${NC} $1"
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  KerjaFlow Production Verification${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

cd "$PROJECT_DIR"

# ===========================================
# 1. Project Structure Checks
# ===========================================
echo -e "${YELLOW}1. Project Structure${NC}"

# Check required files
if [[ -f "pubspec.yaml" ]]; then
    log_pass "pubspec.yaml exists"
else
    log_fail "pubspec.yaml missing"
fi

if [[ -f "android/app/agconnect-services.json" ]]; then
    log_pass "agconnect-services.json exists"
else
    log_fail "agconnect-services.json missing (HMS)"
fi

if [[ -f "android/app/src/main/AndroidManifest.xml" ]]; then
    log_pass "AndroidManifest.xml exists"
else
    log_fail "AndroidManifest.xml missing"
fi

if [[ -d "lib/services/hms" ]]; then
    log_pass "HMS services directory exists"
else
    log_fail "HMS services directory missing"
fi

if [[ -d "lib/l10n" ]]; then
    log_pass "Localization directory exists"
else
    log_fail "Localization directory missing"
fi

echo ""

# ===========================================
# 2. Dependency Checks
# ===========================================
echo -e "${YELLOW}2. Dependencies${NC}"

# Get dependencies
flutter pub get > /dev/null 2>&1

if grep -q "huawei_push:" pubspec.yaml; then
    log_pass "HMS Push Kit dependency"
else
    log_fail "HMS Push Kit dependency missing"
fi

if grep -q "huawei_analytics:" pubspec.yaml; then
    log_pass "HMS Analytics Kit dependency"
else
    log_fail "HMS Analytics Kit dependency missing"
fi

if grep -q "flutter_riverpod:" pubspec.yaml; then
    log_pass "Riverpod state management"
else
    log_fail "Riverpod dependency missing"
fi

if grep -q "flutter_secure_storage:" pubspec.yaml; then
    log_pass "Secure storage dependency"
else
    log_fail "Secure storage dependency missing"
fi

if grep -q "dio:" pubspec.yaml; then
    log_pass "Dio HTTP client dependency"
else
    log_fail "Dio HTTP client missing"
fi

# Check for outdated packages
echo ""
log_info "Checking for outdated packages..."
if flutter pub outdated --no-color 2>/dev/null | grep -q "No outdated"; then
    log_pass "All packages up to date"
else
    log_warn "Some packages may be outdated (run: flutter pub outdated)"
fi

echo ""

# ===========================================
# 3. Code Quality Checks
# ===========================================
echo -e "${YELLOW}3. Code Quality${NC}"

# Format check
if [[ "$AUTO_FIX" == true ]]; then
    dart format . > /dev/null 2>&1
    log_pass "Code formatted (auto-fix applied)"
else
    if dart format --output=none --set-exit-if-changed . > /dev/null 2>&1; then
        log_pass "Code formatting correct"
    else
        log_fail "Code formatting issues (run: dart format .)"
    fi
fi

# Static analysis
if flutter analyze --no-fatal-infos > /dev/null 2>&1; then
    log_pass "Static analysis passed"
else
    log_fail "Static analysis issues (run: flutter analyze)"
fi

echo ""

# ===========================================
# 4. Localization Checks
# ===========================================
echo -e "${YELLOW}4. Localization (i18n)${NC}"

# Count ARB files
ARB_COUNT=$(find lib/l10n -name "app_*.arb" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$ARB_COUNT" -ge 12 ]]; then
    log_pass "Found $ARB_COUNT language files (target: 12)"
else
    log_warn "Found $ARB_COUNT language files (target: 12)"
fi

# Check for required languages
REQUIRED_LANGS=("en" "ms" "id" "th" "vi" "tl" "zh" "ta" "bn" "ne" "km" "my")
for lang in "${REQUIRED_LANGS[@]}"; do
    if [[ -f "lib/l10n/app_${lang}.arb" ]]; then
        if [[ "$VERBOSE" == true ]]; then
            log_pass "Language file: $lang"
        fi
    else
        log_fail "Missing language file: app_${lang}.arb"
    fi
done

if [[ "$VERBOSE" != true ]] && [[ "$FAIL_COUNT" -eq 0 ]]; then
    log_pass "All 12 ASEAN language files present"
fi

echo ""

# ===========================================
# 5. Security Checks
# ===========================================
echo -e "${YELLOW}5. Security${NC}"

# Check for hardcoded secrets
if grep -rn "API_KEY.*=" lib/ 2>/dev/null | grep -v "YOUR_" | grep -q .; then
    log_fail "Potential hardcoded API keys found"
else
    log_pass "No hardcoded API keys"
fi

if grep -rn "password.*=" lib/ 2>/dev/null | grep -vi "Password" | grep -q .; then
    log_warn "Check for hardcoded passwords"
else
    log_pass "No obvious hardcoded passwords"
fi

# Check agconnect-services.json for placeholder values
if grep -q "YOUR_APP_ID_HERE" android/app/agconnect-services.json 2>/dev/null; then
    log_warn "agconnect-services.json has placeholder values"
else
    log_pass "agconnect-services.json configured"
fi

# Check for secure storage usage
if grep -rq "flutter_secure_storage" lib/ 2>/dev/null; then
    log_pass "Using secure storage for sensitive data"
else
    log_warn "Consider using secure storage for tokens"
fi

echo ""

# ===========================================
# 6. HMS Configuration Checks
# ===========================================
echo -e "${YELLOW}6. HMS Configuration${NC}"

# Check HMS service files
if [[ -f "lib/services/hms/hms_availability.dart" ]]; then
    log_pass "HMS availability service"
else
    log_fail "HMS availability service missing"
fi

if [[ -f "lib/services/hms/push_service.dart" ]]; then
    log_pass "HMS push service"
else
    log_fail "HMS push service missing"
fi

if [[ -f "lib/services/hms/analytics_service.dart" ]]; then
    log_pass "HMS analytics service"
else
    log_fail "HMS analytics service missing"
fi

if [[ -f "lib/providers/hms_providers.dart" ]]; then
    log_pass "HMS providers"
else
    log_fail "HMS providers missing"
fi

echo ""

# ===========================================
# 7. Test Coverage
# ===========================================
echo -e "${YELLOW}7. Testing${NC}"

# Check test directories
if [[ -d "test/unit" ]]; then
    UNIT_TESTS=$(find test/unit -name "*_test.dart" 2>/dev/null | wc -l | tr -d ' ')
    log_pass "Unit tests: $UNIT_TESTS files"
else
    log_warn "Unit test directory missing"
fi

if [[ -d "test/widget" ]]; then
    WIDGET_TESTS=$(find test/widget -name "*_test.dart" 2>/dev/null | wc -l | tr -d ' ')
    log_pass "Widget tests: $WIDGET_TESTS files"
else
    log_warn "Widget test directory missing"
fi

if [[ -d "test/integration" ]]; then
    INT_TESTS=$(find test/integration -name "*_test.dart" 2>/dev/null | wc -l | tr -d ' ')
    log_pass "Integration tests: $INT_TESTS files"
else
    log_warn "Integration test directory missing"
fi

if [[ -d "test/golden" ]]; then
    log_pass "Golden tests present"
else
    log_warn "Golden tests missing"
fi

# Run tests
echo ""
log_info "Running tests..."
if flutter test > /dev/null 2>&1; then
    log_pass "All tests passing"
else
    log_fail "Some tests failing (run: flutter test)"
fi

echo ""

# ===========================================
# 8. Build Configuration
# ===========================================
echo -e "${YELLOW}8. Build Configuration${NC}"

# Check version
VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //' | tr -d ' ')
log_info "Version: $VERSION"

# Check build scripts
if [[ -f "scripts/build_production.sh" ]]; then
    log_pass "Production build script exists"
else
    log_warn "Production build script missing"
fi

# Check for release keystore
if [[ -f "android/key.properties" ]] || [[ -f "android/app/upload-keystore.jks" ]]; then
    log_pass "Release signing configured"
else
    log_warn "Release signing not configured"
fi

echo ""

# ===========================================
# Summary
# ===========================================
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Verification Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "  ${GREEN}Passed:${NC}  $PASS_COUNT"
echo -e "  ${RED}Failed:${NC}  $FAIL_COUNT"
echo -e "  ${YELLOW}Warnings:${NC} $WARN_COUNT"
echo ""

if [[ $FAIL_COUNT -eq 0 ]]; then
    echo -e "${GREEN}✓ Production verification PASSED${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Run: ./scripts/build_production.sh"
    echo "  2. Test APK on physical device"
    echo "  3. Upload to AppGallery Connect"
    exit 0
else
    echo -e "${RED}✗ Production verification FAILED${NC}"
    echo ""
    echo "Please fix the issues above before building for production."
    exit 1
fi
