#!/bin/bash
#############################################
# GATE 11: API CONTRACT TESTS
#
# Checks:
# - API endpoints defined
# - Request/response models exist
# - Error handling implemented
# - Auth interceptors present
#############################################

set -e

REPORT_DIR="${1:-.}"
GATE_NAME="Gate 11: API Contract Tests"
ERRORS=0
WARNINGS=0

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  $GATE_NAME                                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"

cd /workspaces/kflow/mobile

# API Config check
echo ""
echo "▶ API Configuration"
echo "───────────────────────────────────────────────────────────────"

API_CONFIG="lib/data/datasources/remote/api_config.dart"
if [ -f "$API_CONFIG" ]; then
    echo "  ✓ API config exists"

    # Count endpoints
    ENDPOINT_COUNT=$(grep -E "static.*String.*=" "$API_CONFIG" 2>/dev/null | wc -l || echo "0")
    echo "  Endpoints defined: $ENDPOINT_COUNT"

    # Check for required endpoints
    REQUIRED_ENDPOINTS=("login" "logout" "refresh" "profile" "payslip" "leave")
    for ep in "${REQUIRED_ENDPOINTS[@]}"; do
        if grep -qi "$ep" "$API_CONFIG" 2>/dev/null; then
            echo "    ✓ $ep endpoint"
        else
            echo "    ✗ $ep endpoint missing"
            WARNINGS=$((WARNINGS + 1))
        fi
    done
else
    echo "  ✗ API config not found"
    ERRORS=$((ERRORS + 1))
fi

# HTTP Client check
echo ""
echo "▶ HTTP Client Implementation"
echo "───────────────────────────────────────────────────────────────"

CLIENT_FILES=$(find lib -name "*client*.dart" -o -name "*dio*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Client files: $CLIENT_FILES"

# Check for Dio usage
DIO_USAGE=$(grep -r "Dio\|dio" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Dio references: $DIO_USAGE"

if [ "$DIO_USAGE" -eq 0 ]; then
    echo "  ⚠ No Dio HTTP client found"
    WARNINGS=$((WARNINGS + 1))
else
    echo "  ✓ Dio HTTP client in use"
fi

# Interceptors check
echo ""
echo "▶ Interceptors"
echo "───────────────────────────────────────────────────────────────"

AUTH_INTERCEPTOR=$(grep -r "Interceptor\|interceptors" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Interceptor references: $AUTH_INTERCEPTOR"

if [ "$AUTH_INTERCEPTOR" -gt 0 ]; then
    echo "  ✓ Interceptors implemented"
else
    echo "  ⚠ No interceptors found"
    WARNINGS=$((WARNINGS + 1))
fi

# Error handling
echo ""
echo "▶ Error Handling"
echo "───────────────────────────────────────────────────────────────"

API_EXCEPTION=$(grep -r "ApiException\|DioException\|catch.*Dio" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Error handling references: $API_EXCEPTION"

if [ "$API_EXCEPTION" -gt 0 ]; then
    echo "  ✓ API error handling present"
else
    echo "  ⚠ Limited API error handling"
    WARNINGS=$((WARNINGS + 1))
fi

# Repository pattern
echo ""
echo "▶ Repository Pattern"
echo "───────────────────────────────────────────────────────────────"

REPO_COUNT=$(find lib -name "*repository*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Repository files: $REPO_COUNT"

if [ "$REPO_COUNT" -gt 0 ]; then
    echo "  ✓ Repository pattern in use"
    find lib -name "*repository*.dart" 2>/dev/null | while read -r file; do
        echo "    - $(basename "$file")"
    done
else
    echo "  ⚠ No repositories found"
    WARNINGS=$((WARNINGS + 1))
fi

# Models check
echo ""
echo "▶ Data Models"
echo "───────────────────────────────────────────────────────────────"

MODEL_COUNT=$(find lib -path "*/models/*" -name "*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Model files: $MODEL_COUNT"

FREEZED_USAGE=$(grep -r "@freezed\|@Freezed" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Freezed models: $FREEZED_USAGE"

# Generate report
cat > "$REPORT_DIR/api_contract.txt" << EOF
API Contract Report
===================
Generated: $(date)

Configuration:
- API config: $([ -f "$API_CONFIG" ] && echo "Present" || echo "Missing")
- Endpoints: $ENDPOINT_COUNT

Implementation:
- Client files: $CLIENT_FILES
- Dio references: $DIO_USAGE
- Interceptors: $AUTH_INTERCEPTOR

Patterns:
- Repository files: $REPO_COUNT
- Model files: $MODEL_COUNT
- Freezed models: $FREEZED_USAGE

Errors: $ERRORS
Warnings: $WARNINGS
EOF

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  Errors:   $ERRORS"
echo "  Warnings: $WARNINGS"

if [ $ERRORS -eq 0 ]; then
    echo "✓ $GATE_NAME PASSED"
    exit 0
else
    echo "✗ $GATE_NAME FAILED"
    exit 1
fi
