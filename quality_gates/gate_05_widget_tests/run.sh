#!/bin/bash
#############################################
# GATE 05: WIDGET TESTS
#
# Runs Flutter widget tests for UI components
#############################################

set -e

REPORT_DIR="${1:-.}"
GATE_NAME="Gate 05: Widget Tests"
ERRORS=0

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  $GATE_NAME                                          ║"
echo "╚══════════════════════════════════════════════════════════════╝"

cd /workspaces/kflow/mobile

if ! command -v flutter &> /dev/null; then
    echo "⚠ Flutter not available, skipping"
    exit 0
fi

flutter pub get --quiet 2>/dev/null || true

# Count widget tests
WIDGET_TEST_COUNT=$(find test/widget -name "*_test.dart" 2>/dev/null | wc -l || echo "0")
echo ""
echo "▶ Widget Test Discovery"
echo "───────────────────────────────────────────────────────────────"
echo "  Widget test files: $WIDGET_TEST_COUNT"

if [ "$WIDGET_TEST_COUNT" -eq 0 ]; then
    echo "  ⚠ No widget tests found in test/widget/"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "✓ $GATE_NAME PASSED (no tests to run)"
    exit 0
fi

# List test files
echo ""
echo "▶ Test Files"
echo "───────────────────────────────────────────────────────────────"
find test/widget -name "*_test.dart" 2>/dev/null | while read -r file; do
    TEST_COUNT=$(grep -c "testWidgets\|test(" "$file" 2>/dev/null || echo "0")
    echo "  $(basename "$file"): $TEST_COUNT test(s)"
done

# Run widget tests
echo ""
echo "▶ Running Widget Tests"
echo "───────────────────────────────────────────────────────────────"

if flutter test test/widget/ --reporter expanded 2>&1 | tee "$REPORT_DIR/widget_tests.txt"; then
    PASSED_TESTS=$(grep -c "✓" "$REPORT_DIR/widget_tests.txt" 2>/dev/null || echo "0")
    echo ""
    echo "  Tests passed: $PASSED_TESTS"
    echo "  ✓ All widget tests passed"
else
    echo "  ✗ Widget tests failed"
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
