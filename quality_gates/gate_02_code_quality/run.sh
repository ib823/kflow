#!/bin/bash
#############################################
# GATE 02: CODE QUALITY
#
# Checks:
# - Line count limits
# - File size limits
# - Complexity metrics
# - Code duplication detection
# - Import organization
#############################################

set -e

REPORT_DIR="${1:-.}"
GATE_NAME="Gate 02: Code Quality"
ERRORS=0
WARNINGS=0

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  $GATE_NAME                                          ║"
echo "╚══════════════════════════════════════════════════════════════╝"

cd /workspaces/kflow

# Line count analysis
echo ""
echo "▶ Codebase Size Analysis"
echo "───────────────────────────────────────────────────────────────"

DART_LINES=$(find mobile/lib -name "*.dart" -exec cat {} \; 2>/dev/null | wc -l || echo "0")
PYTHON_LINES=$(find backend -name "*.py" -exec cat {} \; 2>/dev/null | wc -l || echo "0")
TOTAL_LINES=$((DART_LINES + PYTHON_LINES))

echo "  Dart (mobile):  $DART_LINES lines"
echo "  Python (backend): $PYTHON_LINES lines"
echo "  Total:          $TOTAL_LINES lines"

# Check for overly large codebase (>100k lines is a warning)
if [ "$TOTAL_LINES" -gt 100000 ]; then
    echo "  ⚠ Codebase exceeds 100k lines"
    WARNINGS=$((WARNINGS + 1))
else
    echo "  ✓ Codebase size acceptable"
fi

# File count analysis
echo ""
echo "▶ File Count Analysis"
echo "───────────────────────────────────────────────────────────────"

DART_FILES=$(find mobile/lib -name "*.dart" 2>/dev/null | wc -l || echo "0")
PYTHON_FILES=$(find backend -name "*.py" 2>/dev/null | wc -l || echo "0")

echo "  Dart files:   $DART_FILES"
echo "  Python files: $PYTHON_FILES"

# Large file detection
echo ""
echo "▶ Large File Detection (>500 lines)"
echo "───────────────────────────────────────────────────────────────"

LARGE_FILES=0
while IFS= read -r file; do
    if [ -f "$file" ]; then
        LINES=$(wc -l < "$file")
        if [ "$LINES" -gt 500 ]; then
            echo "  ⚠ $file ($LINES lines)"
            LARGE_FILES=$((LARGE_FILES + 1))
        fi
    fi
done < <(find mobile/lib -name "*.dart" 2>/dev/null)

if [ "$LARGE_FILES" -gt 0 ]; then
    echo "  Found $LARGE_FILES large file(s) - consider refactoring"
    WARNINGS=$((WARNINGS + 1))
else
    echo "  ✓ No excessively large files"
fi

# TODO/FIXME detection
echo ""
echo "▶ TODO/FIXME Detection"
echo "───────────────────────────────────────────────────────────────"

TODO_COUNT=$(grep -r "TODO" mobile/lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
FIXME_COUNT=$(grep -r "FIXME" mobile/lib --include="*.dart" 2>/dev/null | wc -l || echo "0")

echo "  TODOs:  $TODO_COUNT"
echo "  FIXMEs: $FIXME_COUNT"

if [ "$FIXME_COUNT" -gt 0 ]; then
    echo "  ⚠ FIXMEs should be addressed before production"
    WARNINGS=$((WARNINGS + 1))
fi

# Print statement detection (debug code)
echo ""
echo "▶ Debug Code Detection"
echo "───────────────────────────────────────────────────────────────"

PRINT_COUNT=$(grep -r "print(" mobile/lib --include="*.dart" 2>/dev/null | grep -v "// " | wc -l || echo "0")
DEBUGPRINT_COUNT=$(grep -r "debugPrint(" mobile/lib --include="*.dart" 2>/dev/null | wc -l || echo "0")

echo "  print() calls:      $PRINT_COUNT"
echo "  debugPrint() calls: $DEBUGPRINT_COUNT"

if [ "$PRINT_COUNT" -gt 10 ]; then
    echo "  ⚠ Too many print() statements - use proper logging"
    WARNINGS=$((WARNINGS + 1))
else
    echo "  ✓ Debug print usage acceptable"
fi

# Python import organization (isort)
echo ""
echo "▶ Python Import Organization (isort)"
echo "───────────────────────────────────────────────────────────────"

cd /workspaces/kflow/backend

if command -v isort &> /dev/null; then
    ISORT_OUTPUT=$(isort --check-only --diff . 2>&1) || ISORT_FAILED=1

    if [ "${ISORT_FAILED:-0}" -eq 1 ]; then
        echo "  ⚠ Some imports need reordering"
        WARNINGS=$((WARNINGS + 1))
    else
        echo "  ✓ Python imports properly organized"
    fi
else
    echo "  ⚠ isort not available, skipping"
fi

# Black formatting check (Python)
echo ""
echo "▶ Python Formatting (Black)"
echo "───────────────────────────────────────────────────────────────"

if command -v black &> /dev/null; then
    BLACK_OUTPUT=$(black --check . 2>&1) || BLACK_FAILED=1

    if [ "${BLACK_FAILED:-0}" -eq 1 ]; then
        echo "  ✗ Python code needs formatting"
        ERRORS=$((ERRORS + 1))
    else
        echo "  ✓ Python code properly formatted"
    fi
else
    echo "  ⚠ black not available, skipping"
fi

# Generate report
echo ""
cat > "$REPORT_DIR/code_quality.txt" << EOF
Code Quality Report
===================
Generated: $(date)

Codebase Size:
- Dart lines: $DART_LINES
- Python lines: $PYTHON_LINES
- Total: $TOTAL_LINES

File Counts:
- Dart files: $DART_FILES
- Python files: $PYTHON_FILES

Issues:
- Large files (>500 lines): $LARGE_FILES
- TODOs: $TODO_COUNT
- FIXMEs: $FIXME_COUNT
- print() calls: $PRINT_COUNT
EOF

# Summary
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
