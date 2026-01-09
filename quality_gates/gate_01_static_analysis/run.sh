#!/bin/bash
#############################################
# GATE 01: STATIC ANALYSIS
#
# Checks:
# - Flutter/Dart static analysis
# - Python flake8 linting
# - No analysis errors allowed
#############################################

set -e

REPORT_DIR="${1:-.}"
GATE_NAME="Gate 01: Static Analysis"
ERRORS=0

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  $GATE_NAME                                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"

# Flutter/Dart Analysis
echo ""
echo "▶ Flutter/Dart Analysis"
echo "───────────────────────────────────────────────────────────────"

cd /workspaces/kflow/mobile

if command -v flutter &> /dev/null; then
    flutter pub get --quiet 2>/dev/null || true

    # Run flutter analyze and capture output
    ANALYZE_OUTPUT=$(flutter analyze 2>&1) || true

    # Count errors and warnings
    ERROR_COUNT=$(echo "$ANALYZE_OUTPUT" | grep -c "error •" || echo "0")
    WARNING_COUNT=$(echo "$ANALYZE_OUTPUT" | grep -c "warning •" || echo "0")
    INFO_COUNT=$(echo "$ANALYZE_OUTPUT" | grep -c "info •" || echo "0")

    echo "  Errors:   $ERROR_COUNT"
    echo "  Warnings: $WARNING_COUNT"
    echo "  Info:     $INFO_COUNT"

    # Save report
    echo "$ANALYZE_OUTPUT" > "$REPORT_DIR/flutter_analyze.txt" 2>/dev/null || true

    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo "  ✗ Flutter analysis has errors"
        ERRORS=$((ERRORS + 1))
    else
        echo "  ✓ Flutter analysis passed"
    fi
else
    echo "  ⚠ Flutter not available, skipping"
fi

# Python Analysis (Backend)
echo ""
echo "▶ Python Analysis (flake8)"
echo "───────────────────────────────────────────────────────────────"

cd /workspaces/kflow/backend

if command -v flake8 &> /dev/null; then
    FLAKE8_OUTPUT=$(flake8 --max-line-length=120 --count --statistics . 2>&1) || true
    FLAKE8_COUNT=$(echo "$FLAKE8_OUTPUT" | tail -1 | grep -oE '^[0-9]+' || echo "0")

    echo "$FLAKE8_OUTPUT" > "$REPORT_DIR/flake8.txt" 2>/dev/null || true

    if [ "$FLAKE8_COUNT" -gt 0 ] 2>/dev/null; then
        echo "  Issues found: $FLAKE8_COUNT"
        echo "  ✗ Flake8 has issues"
        ERRORS=$((ERRORS + 1))
    else
        echo "  ✓ Flake8 passed (0 issues)"
    fi
else
    echo "  ⚠ flake8 not available, skipping"
fi

# Dart format check
echo ""
echo "▶ Dart Format Check"
echo "───────────────────────────────────────────────────────────────"

cd /workspaces/kflow/mobile

if command -v dart &> /dev/null; then
    FORMAT_OUTPUT=$(dart format --output=none --set-exit-if-changed lib/ 2>&1) || FORMAT_FAILED=1

    if [ "${FORMAT_FAILED:-0}" -eq 1 ]; then
        UNFORMATTED=$(echo "$FORMAT_OUTPUT" | grep -c "Changed" || echo "0")
        echo "  Unformatted files: $UNFORMATTED"
        echo "  ✗ Dart format check failed"
        ERRORS=$((ERRORS + 1))
    else
        echo "  ✓ All files properly formatted"
    fi
else
    echo "  ⚠ dart not available, skipping"
fi

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════════"
if [ $ERRORS -eq 0 ]; then
    echo "✓ $GATE_NAME PASSED"
    exit 0
else
    echo "✗ $GATE_NAME FAILED ($ERRORS check(s) failed)"
    exit 1
fi
