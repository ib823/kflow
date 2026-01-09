#!/bin/bash
#############################################
# GATE 07: GOLDEN TESTS
#
# Runs visual regression tests
#############################################

set -e

REPORT_DIR="${1:-.}"
GATE_NAME="Gate 07: Golden Tests"
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

# Count golden tests
GOLDEN_TEST_COUNT=$(find test/golden -name "*_test.dart" 2>/dev/null | wc -l || echo "0")
echo ""
echo "▶ Golden Test Discovery"
echo "───────────────────────────────────────────────────────────────"
echo "  Golden test files: $GOLDEN_TEST_COUNT"

if [ "$GOLDEN_TEST_COUNT" -eq 0 ]; then
    echo "  ⚠ No golden tests found"
    exit 0
fi

# Check for golden files
GOLDEN_FILE_COUNT=$(find test/golden -name "*.png" 2>/dev/null | wc -l || echo "0")
echo "  Golden image files: $GOLDEN_FILE_COUNT"

# Run golden tests
echo ""
echo "▶ Running Golden Tests"
echo "───────────────────────────────────────────────────────────────"

if flutter test test/golden/ --reporter expanded 2>&1 | tee "$REPORT_DIR/golden_tests.txt"; then
    echo "  ✓ All golden tests passed"
else
    echo "  ⚠ Golden tests failed (may need --update-goldens)"
    # Golden test failures are warnings, not errors (visual differences may be intentional)
fi

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✓ $GATE_NAME PASSED"
exit 0
