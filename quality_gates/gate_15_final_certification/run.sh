#!/bin/bash
#############################################
# GATE 15: FINAL CERTIFICATION
#
# Final production readiness check:
# - Build verification
# - Size constraints
# - Version check
# - Required files
#############################################

set -e

REPORT_DIR="${1:-.}"
GATE_NAME="Gate 15: Final Certification"
ERRORS=0
WARNINGS=0

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  $GATE_NAME                                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"

cd /workspaces/kflow/mobile

# Version check
echo ""
echo "▶ Version Check"
echo "───────────────────────────────────────────────────────────────"

VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //' | tr -d ' ' || echo "0.0.0")
echo "  App version: $VERSION"

# Parse version components
VERSION_NAME=$(echo "$VERSION" | cut -d'+' -f1)
VERSION_CODE=$(echo "$VERSION" | cut -d'+' -f2)

echo "  Version name: $VERSION_NAME"
echo "  Version code: $VERSION_CODE"

if [ "$VERSION_CODE" -gt 0 ] 2>/dev/null; then
    echo "  ✓ Version configured"
else
    echo "  ⚠ Version code should be > 0 for production"
    WARNINGS=$((WARNINGS + 1))
fi

# Required files check
echo ""
echo "▶ Required Files Check"
echo "───────────────────────────────────────────────────────────────"

REQUIRED_FILES=(
    "pubspec.yaml"
    "lib/main.dart"
    "android/app/build.gradle"
    "android/app/src/main/AndroidManifest.xml"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file"
    else
        echo "  ✗ $file - MISSING"
        ERRORS=$((ERRORS + 1))
    fi
done

# HMS configuration
echo ""
echo "▶ HMS Configuration"
echo "───────────────────────────────────────────────────────────────"

if [ -f "android/app/agconnect-services.json" ]; then
    echo "  ✓ agconnect-services.json present"

    # Check for placeholder values
    if grep -q "YOUR_APP_ID_HERE\|YOUR_CLIENT_ID" android/app/agconnect-services.json 2>/dev/null; then
        echo "  ⚠ Contains placeholder values - configure before release"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo "  ⚠ agconnect-services.json not found (HMS won't work)"
    WARNINGS=$((WARNINGS + 1))
fi

# Build APK
echo ""
echo "▶ Release Build Test"
echo "───────────────────────────────────────────────────────────────"

if command -v flutter &> /dev/null; then
    flutter pub get --quiet 2>/dev/null || true

    echo "  Building release APK..."

    if flutter build apk --release 2>&1 | tee "$REPORT_DIR/build_output.txt"; then
        echo "  ✓ Release build successful"

        # Check APK size
        APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
        if [ -f "$APK_PATH" ]; then
            APK_SIZE=$(stat -f%z "$APK_PATH" 2>/dev/null || stat -c%s "$APK_PATH" 2>/dev/null || echo "0")
            APK_SIZE_MB=$((APK_SIZE / 1024 / 1024))

            echo "  APK size: ${APK_SIZE_MB}MB"

            if [ "$APK_SIZE_MB" -gt 50 ]; then
                echo "  ✗ APK exceeds 50MB limit"
                ERRORS=$((ERRORS + 1))
            elif [ "$APK_SIZE_MB" -gt 40 ]; then
                echo "  ⚠ APK approaching 50MB limit"
                WARNINGS=$((WARNINGS + 1))
            else
                echo "  ✓ APK size within limits"
            fi
        fi
    else
        echo "  ✗ Release build failed"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "  ⚠ Flutter not available, skipping build"
fi

# Signing configuration
echo ""
echo "▶ Signing Configuration"
echo "───────────────────────────────────────────────────────────────"

if [ -f "android/key.properties" ]; then
    echo "  ✓ key.properties exists"
else
    echo "  ⚠ key.properties not found - APK will be unsigned"
    WARNINGS=$((WARNINGS + 1))
fi

# ProGuard/R8
echo ""
echo "▶ Code Shrinking (R8)"
echo "───────────────────────────────────────────────────────────────"

if grep -q "minifyEnabled true\|shrinkResources true" android/app/build.gradle 2>/dev/null; then
    echo "  ✓ Code shrinking enabled"
else
    echo "  ⚠ Consider enabling minifyEnabled and shrinkResources"
    WARNINGS=$((WARNINGS + 1))
fi

# Production checklist
echo ""
echo "▶ Production Checklist"
echo "───────────────────────────────────────────────────────────────"

CHECKLIST=(
    "Remove debug prints:$([ $(grep -r 'print(' lib --include='*.dart' 2>/dev/null | wc -l) -lt 10 ] && echo '✓' || echo '⚠')"
    "API URLs configured:$(grep -q 'api.kerjaflow.com' lib 2>/dev/null && echo '✓' || echo '⚠')"
    "Analytics enabled:$(grep -r 'Analytics' lib --include='*.dart' 2>/dev/null | grep -q . && echo '✓' || echo '⚠')"
    "Error reporting:$(grep -r 'crashlytics\|sentry\|bugsnag' lib --include='*.dart' 2>/dev/null | grep -q . && echo '✓' || echo '⚠')"
)

for item in "${CHECKLIST[@]}"; do
    echo "  $item"
done

# Generate certification report
cat > "$REPORT_DIR/certification.txt" << EOF
═══════════════════════════════════════════════════════════════════
                  KERJAFLOW PRODUCTION CERTIFICATION
═══════════════════════════════════════════════════════════════════

Generated: $(date)
Version: $VERSION

BUILD STATUS
────────────────────────────────────────────────────────────────────
APK Size: ${APK_SIZE_MB:-N/A}MB
Build: $([ -f "build/app/outputs/flutter-apk/app-release.apk" ] && echo "SUCCESS" || echo "FAILED")

CONFIGURATION
────────────────────────────────────────────────────────────────────
HMS Config: $([ -f "android/app/agconnect-services.json" ] && echo "Present" || echo "Missing")
Signing: $([ -f "android/key.properties" ] && echo "Configured" || echo "Not configured")

QUALITY METRICS
────────────────────────────────────────────────────────────────────
Errors: $ERRORS
Warnings: $WARNINGS

CERTIFICATION STATUS
────────────────────────────────────────────────────────────────────
$([ $ERRORS -eq 0 ] && echo "✓ CERTIFIED FOR PRODUCTION" || echo "✗ NOT CERTIFIED - FIX ERRORS")

═══════════════════════════════════════════════════════════════════
EOF

cat "$REPORT_DIR/certification.txt"

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  Errors:   $ERRORS"
echo "  Warnings: $WARNINGS"

if [ $ERRORS -eq 0 ]; then
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║     ✓ KERJAFLOW CERTIFIED FOR PRODUCTION                    ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "✓ $GATE_NAME PASSED"
    exit 0
else
    echo "✗ $GATE_NAME FAILED"
    exit 1
fi
