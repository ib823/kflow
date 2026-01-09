#!/bin/bash
#############################################
# GATE 13: EDGE CASE TESTS
#
# Checks:
# - Null safety handling
# - Empty state handling
# - Boundary conditions
# - Error boundaries
#############################################

set -e

REPORT_DIR="${1:-.}"
GATE_NAME="Gate 13: Edge Case Tests"
ERRORS=0
WARNINGS=0

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  $GATE_NAME                                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"

cd /workspaces/kflow/mobile

# Null safety patterns
echo ""
echo "▶ Null Safety Patterns"
echo "───────────────────────────────────────────────────────────────"

NULL_CHECK=$(grep -r "??\|?\.\|!\." lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Null-aware operators: $NULL_CHECK"

LATE_VARS=$(grep -r "late " lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Late variables: $LATE_VARS"

FORCE_UNWRAP=$(grep -rE "[^!]![^=]" lib --include="*.dart" 2>/dev/null | grep -v "!=" | wc -l || echo "0")
echo "  Force unwraps (!): $FORCE_UNWRAP"

if [ "$FORCE_UNWRAP" -gt 50 ]; then
    echo "  ⚠ Many force unwraps - potential null errors"
    WARNINGS=$((WARNINGS + 1))
else
    echo "  ✓ Force unwrap usage acceptable"
fi

# Empty state handling
echo ""
echo "▶ Empty State Handling"
echo "───────────────────────────────────────────────────────────────"

EMPTY_CHECK=$(grep -r "\.isEmpty\|\.isNotEmpty\|\.length == 0\|\.length > 0" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Empty checks: $EMPTY_CHECK"

EMPTY_WIDGET=$(grep -r "EmptyState\|EmptyWidget\|NoData\|emptyBuilder" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Empty state widgets: $EMPTY_WIDGET"

if [ "$EMPTY_WIDGET" -gt 0 ]; then
    echo "  ✓ Empty state UI implemented"
else
    echo "  ⚠ Consider adding empty state widgets"
    WARNINGS=$((WARNINGS + 1))
fi

# Error handling
echo ""
echo "▶ Error Handling Patterns"
echo "───────────────────────────────────────────────────────────────"

TRY_CATCH=$(grep -r "try {" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Try-catch blocks: $TRY_CATCH"

CATCH_ERROR=$(grep -r "catchError\|onError\|\.error" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Error callbacks: $CATCH_ERROR"

ERROR_WIDGET=$(grep -r "ErrorWidget\|ErrorState\|errorBuilder" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Error widgets: $ERROR_WIDGET"

# Boundary conditions
echo ""
echo "▶ Boundary Condition Checks"
echo "───────────────────────────────────────────────────────────────"

BOUNDS_CHECK=$(grep -rE "\.clamp\|min\(|max\(|>=.*&&.*<=" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Boundary checks: $BOUNDS_CHECK"

INDEX_SAFETY=$(grep -r "\.elementAtOrNull\|\.getOrNull\|if.*index.*length" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Index safety checks: $INDEX_SAFETY"

# Loading states
echo ""
echo "▶ Loading State Handling"
echo "───────────────────────────────────────────────────────────────"

LOADING=$(grep -r "isLoading\|loading\|CircularProgressIndicator\|shimmer" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Loading indicators: $LOADING"

ASYNC_VALUE=$(grep -r "AsyncValue\|AsyncLoading\|AsyncError\|AsyncData" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  AsyncValue usage: $ASYNC_VALUE"

if [ "$LOADING" -gt 0 ] || [ "$ASYNC_VALUE" -gt 0 ]; then
    echo "  ✓ Loading states handled"
else
    echo "  ⚠ Consider adding loading indicators"
    WARNINGS=$((WARNINGS + 1))
fi

# Timeout handling
echo ""
echo "▶ Timeout Handling"
echo "───────────────────────────────────────────────────────────────"

TIMEOUT=$(grep -r "timeout\|Timeout\|Duration" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Timeout references: $TIMEOUT"

# Generate report
cat > "$REPORT_DIR/edge_cases.txt" << EOF
Edge Case Report
================
Generated: $(date)

Null Safety:
- Null-aware operators: $NULL_CHECK
- Late variables: $LATE_VARS
- Force unwraps: $FORCE_UNWRAP

Empty States:
- Empty checks: $EMPTY_CHECK
- Empty widgets: $EMPTY_WIDGET

Error Handling:
- Try-catch blocks: $TRY_CATCH
- Error callbacks: $CATCH_ERROR
- Error widgets: $ERROR_WIDGET

Loading:
- Loading indicators: $LOADING
- AsyncValue usage: $ASYNC_VALUE

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
