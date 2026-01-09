#!/bin/bash
#############################################
# GATE 08: PERFORMANCE TESTS
#
# Checks:
# - Anti-patterns (setState in loops)
# - Widget rebuild detection
# - Memory leak patterns
# - Large asset detection
# - Build size estimation
#############################################

set -e

REPORT_DIR="${1:-.}"
GATE_NAME="Gate 08: Performance Tests"
ERRORS=0
WARNINGS=0

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  $GATE_NAME                                      ║"
echo "╚══════════════════════════════════════════════════════════════╝"

cd /workspaces/kflow/mobile

# Anti-pattern: setState in loops
echo ""
echo "▶ Anti-Pattern Detection: setState in Loops"
echo "───────────────────────────────────────────────────────────────"

SETSTATE_LOOP=$(grep -rE "for.*setState|while.*setState|forEach.*setState" lib --include="*.dart" 2>/dev/null || true)
if [ -n "$SETSTATE_LOOP" ]; then
    echo "  ✗ setState called inside loops detected:"
    echo "$SETSTATE_LOOP" | head -5
    ERRORS=$((ERRORS + 1))
else
    echo "  ✓ No setState in loops"
fi

# Anti-pattern: build method too complex
echo ""
echo "▶ Complex Build Methods Detection"
echo "───────────────────────────────────────────────────────────────"

COMPLEX_BUILDS=0
for file in $(find lib -name "*.dart" 2>/dev/null); do
    BUILD_LINES=$(awk '/Widget build\(BuildContext/{found=1} found{count++} /^  \}$/{if(found) print count; found=0; count=0}' "$file" 2>/dev/null | head -1 || echo "0")
    if [ "$BUILD_LINES" -gt 100 ] 2>/dev/null; then
        echo "  ⚠ $(basename "$file"): build() has $BUILD_LINES lines"
        COMPLEX_BUILDS=$((COMPLEX_BUILDS + 1))
    fi
done

if [ "$COMPLEX_BUILDS" -gt 0 ]; then
    echo "  Found $COMPLEX_BUILDS complex build methods"
    WARNINGS=$((WARNINGS + 1))
else
    echo "  ✓ No overly complex build methods"
fi

# StreamController without dispose
echo ""
echo "▶ Memory Leak Patterns: StreamController"
echo "───────────────────────────────────────────────────────────────"

STREAM_COUNT=$(grep -r "StreamController" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
DISPOSE_COUNT=$(grep -r "\.close()\|\.dispose()" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")

echo "  StreamControllers: $STREAM_COUNT"
echo "  close()/dispose() calls: $DISPOSE_COUNT"

if [ "$STREAM_COUNT" -gt "$DISPOSE_COUNT" ] 2>/dev/null; then
    echo "  ⚠ Potential memory leaks - more streams than dispose calls"
    WARNINGS=$((WARNINGS + 1))
else
    echo "  ✓ Stream cleanup looks OK"
fi

# Large assets check
echo ""
echo "▶ Large Assets Detection"
echo "───────────────────────────────────────────────────────────────"

LARGE_ASSETS=0
while IFS= read -r asset; do
    SIZE=$(stat -f%z "$asset" 2>/dev/null || stat -c%s "$asset" 2>/dev/null || echo "0")
    SIZE_KB=$((SIZE / 1024))
    if [ "$SIZE_KB" -gt 500 ]; then
        echo "  ⚠ $(basename "$asset"): ${SIZE_KB}KB"
        LARGE_ASSETS=$((LARGE_ASSETS + 1))
    fi
done < <(find assets -type f 2>/dev/null || true)

if [ "$LARGE_ASSETS" -gt 0 ]; then
    echo "  Found $LARGE_ASSETS large assets (>500KB)"
    WARNINGS=$((WARNINGS + 1))
else
    echo "  ✓ No excessively large assets"
fi

# Unnecessary rebuilds (const missing)
echo ""
echo "▶ Optimization: const Usage"
echo "───────────────────────────────────────────────────────────────"

CONST_WIDGETS=$(grep -r "const " lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
WIDGET_INSTANCES=$(grep -rE "^\s+(Text|Icon|SizedBox|Padding|Container)\(" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")

echo "  const usages: $CONST_WIDGETS"
echo "  Widget instantiations: $WIDGET_INSTANCES"

# Build size estimate
echo ""
echo "▶ Build Size Estimation"
echo "───────────────────────────────────────────────────────────────"

DART_SIZE=$(find lib -name "*.dart" -exec cat {} \; 2>/dev/null | wc -c || echo "0")
DART_SIZE_KB=$((DART_SIZE / 1024))
ASSET_SIZE=$(find assets -type f -exec stat -f%z {} \; 2>/dev/null | awk '{s+=$1}END{print s}' || echo "0")
ASSET_SIZE_KB=$((ASSET_SIZE / 1024))

echo "  Dart code: ${DART_SIZE_KB}KB"
echo "  Assets: ${ASSET_SIZE_KB}KB"
echo "  Estimated APK overhead: ~15-20MB (Flutter runtime)"

# Generate report
cat > "$REPORT_DIR/performance.txt" << EOF
Performance Analysis Report
===========================
Generated: $(date)

Anti-Patterns:
- setState in loops: $([ -n "$SETSTATE_LOOP" ] && echo "FOUND" || echo "None")
- Complex build methods: $COMPLEX_BUILDS

Memory:
- StreamControllers: $STREAM_COUNT
- Dispose calls: $DISPOSE_COUNT

Assets:
- Large assets (>500KB): $LARGE_ASSETS

Optimization:
- const usages: $CONST_WIDGETS

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
