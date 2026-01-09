#!/bin/bash
#############################################
# GATE 10: i18n VERIFICATION
#
# Checks:
# - All 12 ASEAN languages present
# - Key consistency across files
# - No missing translations
# - No hardcoded strings in UI
#############################################

set -e

REPORT_DIR="${1:-.}"
GATE_NAME="Gate 10: i18n Verification"
ERRORS=0
WARNINGS=0

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  $GATE_NAME                                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"

cd /workspaces/kflow/mobile

# Required languages for ASEAN
REQUIRED_LANGS=("en" "ms" "id" "zh" "ta" "th" "vi" "tl" "my" "km" "ne" "bn")

# Check ARB files
echo ""
echo "▶ Language File Check (12 ASEAN Languages)"
echo "───────────────────────────────────────────────────────────────"

MISSING_LANGS=""
FOUND_LANGS=0

for lang in "${REQUIRED_LANGS[@]}"; do
    # Check multiple possible locations
    if [ -f "lib/l10n/app_${lang}.arb" ] || [ -f "lib/l10n/arb/app_${lang}.arb" ]; then
        echo "  ✓ $lang"
        FOUND_LANGS=$((FOUND_LANGS + 1))
    else
        echo "  ✗ $lang - MISSING"
        MISSING_LANGS="$MISSING_LANGS $lang"
    fi
done

echo ""
echo "  Found: $FOUND_LANGS / ${#REQUIRED_LANGS[@]} languages"

if [ -n "$MISSING_LANGS" ]; then
    echo "  ✗ Missing languages:$MISSING_LANGS"
    ERRORS=$((ERRORS + 1))
fi

# Check baseline file exists
echo ""
echo "▶ Baseline File Check"
echo "───────────────────────────────────────────────────────────────"

BASELINE_FILE=""
if [ -f "lib/l10n/app_en.arb" ]; then
    BASELINE_FILE="lib/l10n/app_en.arb"
elif [ -f "lib/l10n/arb/app_en.arb" ]; then
    BASELINE_FILE="lib/l10n/arb/app_en.arb"
fi

if [ -n "$BASELINE_FILE" ]; then
    BASELINE_KEYS=$(grep -E '^\s*"[^@]' "$BASELINE_FILE" 2>/dev/null | wc -l || echo "0")
    echo "  Baseline file: $BASELINE_FILE"
    echo "  Translation keys: $BASELINE_KEYS"
else
    echo "  ✗ No baseline (app_en.arb) found"
    ERRORS=$((ERRORS + 1))
fi

# Check for key consistency
echo ""
echo "▶ Key Consistency Check"
echo "───────────────────────────────────────────────────────────────"

if [ -n "$BASELINE_FILE" ]; then
    BASELINE_KEYS_LIST=$(grep -oE '^\s*"[^@"][^"]*"' "$BASELINE_FILE" 2>/dev/null | tr -d ' "' | sort || true)

    INCONSISTENT=0
    for lang in "${REQUIRED_LANGS[@]}"; do
        ARB_FILE=""
        if [ -f "lib/l10n/app_${lang}.arb" ]; then
            ARB_FILE="lib/l10n/app_${lang}.arb"
        elif [ -f "lib/l10n/arb/app_${lang}.arb" ]; then
            ARB_FILE="lib/l10n/arb/app_${lang}.arb"
        fi

        if [ -n "$ARB_FILE" ] && [ "$lang" != "en" ]; then
            LANG_KEYS=$(grep -oE '^\s*"[^@"][^"]*"' "$ARB_FILE" 2>/dev/null | tr -d ' "' | sort || true)
            MISSING=$(comm -23 <(echo "$BASELINE_KEYS_LIST") <(echo "$LANG_KEYS") 2>/dev/null | wc -l || echo "0")

            if [ "$MISSING" -gt 0 ] 2>/dev/null; then
                echo "  ⚠ $lang: $MISSING missing keys"
                INCONSISTENT=$((INCONSISTENT + 1))
            fi
        fi
    done

    if [ "$INCONSISTENT" -gt 0 ]; then
        WARNINGS=$((WARNINGS + 1))
    else
        echo "  ✓ All languages have consistent keys"
    fi
fi

# Check for hardcoded strings in UI
echo ""
echo "▶ Hardcoded String Detection"
echo "───────────────────────────────────────────────────────────────"

# Look for Text widgets with hardcoded strings (not using AppLocalizations)
HARDCODED=$(grep -rE "Text\(['\"][A-Za-z]" lib --include="*.dart" 2>/dev/null | grep -v "test\|mock\|example\|TODO" | wc -l || echo "0")
echo "  Potential hardcoded strings: $HARDCODED"

if [ "$HARDCODED" -gt 20 ]; then
    echo "  ⚠ Many hardcoded strings - use AppLocalizations"
    WARNINGS=$((WARNINGS + 1))
else
    echo "  ✓ Hardcoded strings acceptable"
fi

# Check l10n.yaml configuration
echo ""
echo "▶ l10n Configuration"
echo "───────────────────────────────────────────────────────────────"

if [ -f "l10n.yaml" ]; then
    echo "  ✓ l10n.yaml exists"
    cat l10n.yaml | head -10
else
    echo "  ⚠ l10n.yaml not found"
    WARNINGS=$((WARNINGS + 1))
fi

# Generate report
cat > "$REPORT_DIR/i18n.txt" << EOF
i18n Verification Report
========================
Generated: $(date)

Languages:
- Required: ${#REQUIRED_LANGS[@]}
- Found: $FOUND_LANGS
- Missing:$MISSING_LANGS

Baseline:
- File: ${BASELINE_FILE:-NOT FOUND}
- Keys: ${BASELINE_KEYS:-0}

Code:
- Hardcoded strings: $HARDCODED

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
