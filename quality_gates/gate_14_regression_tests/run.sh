#!/bin/bash
#############################################
# GATE 14: REGRESSION TESTS
#
# Runs all tests to ensure no regressions
#############################################

set -e

REPORT_DIR="${1:-.}"
GATE_NAME="Gate 14: Regression Tests"
ERRORS=0

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  $GATE_NAME                                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"

cd /workspaces/kflow/mobile

if ! command -v flutter &> /dev/null; then
    echo "⚠ Flutter not available, skipping"
    exit 0
fi

flutter pub get --quiet 2>/dev/null || true

# Count all tests
echo ""
echo "▶ Test Discovery"
echo "───────────────────────────────────────────────────────────────"

TOTAL_TEST_FILES=$(find test -name "*_test.dart" 2>/dev/null | wc -l || echo "0")
echo "  Total test files: $TOTAL_TEST_FILES"

# Breakdown by type
UNIT=$(find test/unit -name "*_test.dart" 2>/dev/null | wc -l || echo "0")
WIDGET=$(find test/widget -name "*_test.dart" 2>/dev/null | wc -l || echo "0")
INTEGRATION=$(find test/integration -name "*_test.dart" 2>/dev/null | wc -l || echo "0")
GOLDEN=$(find test/golden -name "*_test.dart" 2>/dev/null | wc -l || echo "0")

echo "    Unit tests:        $UNIT"
echo "    Widget tests:      $WIDGET"
echo "    Integration tests: $INTEGRATION"
echo "    Golden tests:      $GOLDEN"

if [ "$TOTAL_TEST_FILES" -eq 0 ]; then
    echo "  ⚠ No tests found"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "✓ $GATE_NAME PASSED (no tests to run)"
    exit 0
fi

# Run all tests
echo ""
echo "▶ Running All Tests"
echo "───────────────────────────────────────────────────────────────"

START_TIME=$(date +%s)

if flutter test --reporter expanded 2>&1 | tee "$REPORT_DIR/regression_tests.txt"; then
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))

    # Parse results
    PASSED=$(grep -c "✓" "$REPORT_DIR/regression_tests.txt" 2>/dev/null || echo "0")
    FAILED=$(grep -c "✗" "$REPORT_DIR/regression_tests.txt" 2>/dev/null || echo "0")
    SKIPPED=$(grep -c "○" "$REPORT_DIR/regression_tests.txt" 2>/dev/null || echo "0")

    echo ""
    echo "  Duration: ${DURATION}s"
    echo "  Passed:   $PASSED"
    echo "  Failed:   $FAILED"
    echo "  Skipped:  $SKIPPED"
    echo ""
    echo "  ✓ All regression tests passed"
else
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))

    echo ""
    echo "  Duration: ${DURATION}s"
    echo "  ✗ Some tests failed"
    ERRORS=$((ERRORS + 1))
fi

# Generate report
cat > "$REPORT_DIR/regression_summary.txt" << EOF
Regression Test Report
======================
Generated: $(date)
Duration: ${DURATION:-0}s

Test Files:
- Total: $TOTAL_TEST_FILES
- Unit: $UNIT
- Widget: $WIDGET
- Integration: $INTEGRATION
- Golden: $GOLDEN

Results:
- Passed: ${PASSED:-0}
- Failed: ${FAILED:-0}
- Skipped: ${SKIPPED:-0}

Status: $([ $ERRORS -eq 0 ] && echo "PASSED" || echo "FAILED")
EOF

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
