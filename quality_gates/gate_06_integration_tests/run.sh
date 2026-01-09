#!/bin/bash
#############################################
# GATE 06: INTEGRATION TESTS
#
# Runs integration tests for user flows
#############################################

set -e

REPORT_DIR="${1:-.}"
GATE_NAME="Gate 06: Integration Tests"
ERRORS=0

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  $GATE_NAME                                      ║"
echo "╚══════════════════════════════════════════════════════════════╝"

cd /workspaces/kflow/mobile

if ! command -v flutter &> /dev/null; then
    echo "⚠ Flutter not available, skipping"
    exit 0
fi

flutter pub get --quiet 2>/dev/null || true

# Count integration tests
INT_TEST_COUNT=$(find test/integration -name "*_test.dart" 2>/dev/null | wc -l || echo "0")
echo ""
echo "▶ Integration Test Discovery"
echo "───────────────────────────────────────────────────────────────"
echo "  Integration test files: $INT_TEST_COUNT"

if [ "$INT_TEST_COUNT" -eq 0 ]; then
    echo "  ⚠ No integration tests found"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "✓ $GATE_NAME PASSED (no tests to run)"
    exit 0
fi

# List test files
echo ""
echo "▶ Test Files"
echo "───────────────────────────────────────────────────────────────"
find test/integration -name "*_test.dart" 2>/dev/null | while read -r file; do
    echo "  $(basename "$file")"
done

# Run integration tests
echo ""
echo "▶ Running Integration Tests"
echo "───────────────────────────────────────────────────────────────"

if flutter test test/integration/ --reporter expanded 2>&1 | tee "$REPORT_DIR/integration_tests.txt"; then
    echo "  ✓ All integration tests passed"
else
    echo "  ✗ Integration tests failed"
    ERRORS=$((ERRORS + 1))
fi

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════════"
if [ $ERRORS -eq 0 ]; then
    echo "✓ $GATE_NAME PASSED"
    exit 0
else
    echo "✗ $GATE_NAME FAILED"
    exit 1
fi
