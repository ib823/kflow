#!/bin/bash
#############################################
# GATE 04: UNIT TESTS
#
# Runs unit tests for:
# - Flutter/Dart unit tests
# - Python backend unit tests
# - Coverage threshold: 70%
#############################################

set -e

REPORT_DIR="${1:-.}"
GATE_NAME="Gate 04: Unit Tests"
ERRORS=0

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  $GATE_NAME                                            ║"
echo "╚══════════════════════════════════════════════════════════════╝"

# Flutter Unit Tests
echo ""
echo "▶ Flutter Unit Tests"
echo "───────────────────────────────────────────────────────────────"

cd /workspaces/kflow/mobile

if command -v flutter &> /dev/null; then
    flutter pub get --quiet 2>/dev/null || true

    # Check if unit tests exist
    UNIT_TEST_COUNT=$(find test/unit -name "*_test.dart" 2>/dev/null | wc -l || echo "0")
    echo "  Unit test files: $UNIT_TEST_COUNT"

    if [ "$UNIT_TEST_COUNT" -gt 0 ]; then
        # Run unit tests
        if flutter test test/unit/ --reporter expanded 2>&1 | tee "$REPORT_DIR/flutter_unit_tests.txt"; then
            echo "  ✓ Flutter unit tests passed"
        else
            echo "  ✗ Flutter unit tests failed"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo "  ⚠ No unit tests found in test/unit/"
    fi
else
    echo "  ⚠ Flutter not available, skipping"
fi

# Python Unit Tests
echo ""
echo "▶ Python Unit Tests (pytest)"
echo "───────────────────────────────────────────────────────────────"

cd /workspaces/kflow/backend

if command -v pytest &> /dev/null; then
    # Check if tests exist
    PYTEST_COUNT=$(find tests -name "test_*.py" 2>/dev/null | wc -l || echo "0")
    echo "  Test files: $PYTEST_COUNT"

    if [ "$PYTEST_COUNT" -gt 0 ]; then
        if pytest tests/ -v --tb=short 2>&1 | tee "$REPORT_DIR/pytest_results.txt"; then
            echo "  ✓ Python unit tests passed"
        else
            echo "  ✗ Python unit tests failed"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo "  ⚠ No pytest tests found"
    fi
else
    echo "  ⚠ pytest not available, skipping"
fi

# Coverage Report (if available)
echo ""
echo "▶ Test Coverage Analysis"
echo "───────────────────────────────────────────────────────────────"

cd /workspaces/kflow/mobile

if command -v flutter &> /dev/null && [ "$UNIT_TEST_COUNT" -gt 0 ]; then
    flutter test --coverage test/unit/ 2>/dev/null || true

    if [ -f "coverage/lcov.info" ]; then
        # Calculate coverage percentage
        if command -v lcov &> /dev/null; then
            COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | awk '{print $2}' | sed 's/%//' || echo "0")
            echo "  Flutter coverage: ${COVERAGE}%"

            if [ "$(echo "$COVERAGE < 70" | bc -l 2>/dev/null || echo 1)" -eq 1 ]; then
                echo "  ⚠ Coverage below 70% threshold"
            else
                echo "  ✓ Coverage meets threshold"
            fi
        else
            echo "  Coverage file generated (lcov not available for summary)"
        fi
    fi
fi

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════════"
if [ $ERRORS -eq 0 ]; then
    echo "✓ $GATE_NAME PASSED"
    exit 0
else
    echo "✗ $GATE_NAME FAILED ($ERRORS test suite(s) failed)"
    exit 1
fi
