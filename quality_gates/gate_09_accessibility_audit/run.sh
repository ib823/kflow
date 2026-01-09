#!/bin/bash
#############################################
# GATE 09: ACCESSIBILITY AUDIT
#
# Checks:
# - Semantics usage
# - Touch target sizes
# - Color contrast considerations
# - Screen reader support
#############################################

set -e

REPORT_DIR="${1:-.}"
GATE_NAME="Gate 09: Accessibility Audit"
ERRORS=0
WARNINGS=0

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  $GATE_NAME                                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"

cd /workspaces/kflow/mobile

# Semantics usage
echo ""
echo "▶ Semantics Widget Usage"
echo "───────────────────────────────────────────────────────────────"

SEMANTICS_COUNT=$(grep -r "Semantics(" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
SEMANTIC_LABEL=$(grep -r "semanticsLabel" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
EXCLUDE_SEMANTICS=$(grep -r "ExcludeSemantics" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")

echo "  Semantics widgets: $SEMANTICS_COUNT"
echo "  semanticsLabel properties: $SEMANTIC_LABEL"
echo "  ExcludeSemantics: $EXCLUDE_SEMANTICS"

TOTAL_SEMANTICS=$((SEMANTICS_COUNT + SEMANTIC_LABEL))
if [ "$TOTAL_SEMANTICS" -lt 10 ]; then
    echo "  ⚠ Low semantics usage - consider adding more for screen readers"
    WARNINGS=$((WARNINGS + 1))
else
    echo "  ✓ Good semantics coverage"
fi

# Touch target sizes
echo ""
echo "▶ Touch Target Analysis"
echo "───────────────────────────────────────────────────────────────"

# Check for small touch targets (< 48x48)
SMALL_TARGETS=$(grep -rE "height:\s*(2[0-9]|3[0-9]|4[0-7])[^0-9]|width:\s*(2[0-9]|3[0-9]|4[0-7])[^0-9]" lib --include="*.dart" 2>/dev/null | grep -i "button\|tap\|press\|click" | wc -l || echo "0")

echo "  Potentially small touch targets: $SMALL_TARGETS"

if [ "$SMALL_TARGETS" -gt 5 ]; then
    echo "  ⚠ Some buttons may be too small (minimum 48x48 recommended)"
    WARNINGS=$((WARNINGS + 1))
else
    echo "  ✓ Touch targets look appropriate"
fi

# Color contrast (looking for hardcoded light colors on white)
echo ""
echo "▶ Color Usage Analysis"
echo "───────────────────────────────────────────────────────────────"

LIGHT_COLORS=$(grep -rE "Colors\.(grey\[200\]|grey\[100\]|white)|0xFFE|0xFFF" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Light color usages: $LIGHT_COLORS"

# Text scaling support
echo ""
echo "▶ Text Scaling Support"
echo "───────────────────────────────────────────────────────────────"

MEDIA_QUERY_TEXT=$(grep -r "MediaQuery.*textScaleFactor\|textScaler" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
echo "  Text scale considerations: $MEDIA_QUERY_TEXT"

# Tooltip usage for icon buttons
echo ""
echo "▶ Icon Button Accessibility"
echo "───────────────────────────────────────────────────────────────"

ICON_BUTTONS=$(grep -r "IconButton(" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
TOOLTIPS=$(grep -r "tooltip:" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")

echo "  IconButtons: $ICON_BUTTONS"
echo "  With tooltips: $TOOLTIPS"

if [ "$ICON_BUTTONS" -gt 0 ] && [ "$TOOLTIPS" -lt "$ICON_BUTTONS" ]; then
    echo "  ⚠ Some IconButtons missing tooltips"
    WARNINGS=$((WARNINGS + 1))
else
    echo "  ✓ IconButtons have tooltips"
fi

# Focus management
echo ""
echo "▶ Focus Management"
echo "───────────────────────────────────────────────────────────────"

FOCUS_NODE=$(grep -r "FocusNode\|focusNode" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")
AUTOFOCUS=$(grep -r "autofocus:" lib --include="*.dart" 2>/dev/null | wc -l || echo "0")

echo "  FocusNode usage: $FOCUS_NODE"
echo "  Autofocus properties: $AUTOFOCUS"

# Generate report
cat > "$REPORT_DIR/accessibility.txt" << EOF
Accessibility Audit Report
==========================
Generated: $(date)

Semantics:
- Semantics widgets: $SEMANTICS_COUNT
- semanticsLabel: $SEMANTIC_LABEL
- ExcludeSemantics: $EXCLUDE_SEMANTICS

Touch Targets:
- Small targets: $SMALL_TARGETS

Icons:
- IconButtons: $ICON_BUTTONS
- With tooltips: $TOOLTIPS

Focus:
- FocusNode usage: $FOCUS_NODE
- Autofocus: $AUTOFOCUS

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
