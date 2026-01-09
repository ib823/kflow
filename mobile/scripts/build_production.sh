#!/bin/bash

#############################################
# KerjaFlow Production Build Script
#
# Builds release APK/AAB for AppGallery and
# Play Store distribution.
#
# Usage:
#   ./scripts/build_production.sh [options]
#
# Options:
#   --apk         Build APK only (default: builds both)
#   --aab         Build AAB only
#   --appgallery  Build for Huawei AppGallery (with HMS)
#   --playstore   Build for Google Play Store (with GMS)
#   --clean       Run flutter clean before build
#   --no-test     Skip running tests
#   --help        Show this help message
#############################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Default values
BUILD_APK=true
BUILD_AAB=true
TARGET_STORE="all"
RUN_CLEAN=false
RUN_TESTS=true

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --apk)
            BUILD_APK=true
            BUILD_AAB=false
            shift
            ;;
        --aab)
            BUILD_APK=false
            BUILD_AAB=true
            shift
            ;;
        --appgallery)
            TARGET_STORE="appgallery"
            shift
            ;;
        --playstore)
            TARGET_STORE="playstore"
            shift
            ;;
        --clean)
            RUN_CLEAN=true
            shift
            ;;
        --no-test)
            RUN_TESTS=false
            shift
            ;;
        --help)
            head -26 "$0" | tail -25
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  KerjaFlow Production Build${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

cd "$PROJECT_DIR"

# Check required files
echo -e "${YELLOW}Checking required files...${NC}"

if [[ ! -f "pubspec.yaml" ]]; then
    echo -e "${RED}Error: pubspec.yaml not found. Run from mobile directory.${NC}"
    exit 1
fi

if [[ ! -f "android/app/agconnect-services.json" ]]; then
    echo -e "${RED}Error: agconnect-services.json not found.${NC}"
    echo "Please configure HMS AppGallery Connect before building."
    exit 1
fi

# Check for keystore (for release builds)
if [[ ! -f "android/app/upload-keystore.jks" ]] && [[ ! -f "android/key.properties" ]]; then
    echo -e "${YELLOW}Warning: Release keystore not found.${NC}"
    echo "APK/AAB will be unsigned. Configure keystore for production."
fi

echo -e "${GREEN}Required files present.${NC}"
echo ""

# Clean if requested
if [[ "$RUN_CLEAN" == true ]]; then
    echo -e "${YELLOW}Cleaning build artifacts...${NC}"
    flutter clean
    flutter pub get
    echo -e "${GREEN}Clean complete.${NC}"
    echo ""
fi

# Run tests if not skipped
if [[ "$RUN_TESTS" == true ]]; then
    echo -e "${YELLOW}Running tests...${NC}"
    if flutter test; then
        echo -e "${GREEN}All tests passed.${NC}"
    else
        echo -e "${RED}Tests failed! Fix tests before building production.${NC}"
        exit 1
    fi
    echo ""
fi

# Run static analysis
echo -e "${YELLOW}Running static analysis...${NC}"
if flutter analyze --no-fatal-infos; then
    echo -e "${GREEN}Static analysis passed.${NC}"
else
    echo -e "${RED}Static analysis failed!${NC}"
    exit 1
fi
echo ""

# Get version info
VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //' | tr -d ' ')
echo -e "${BLUE}Building version: ${VERSION}${NC}"
echo ""

# Build timestamp
BUILD_TIME=$(date +"%Y%m%d_%H%M%S")
BUILD_DIR="build/outputs/${BUILD_TIME}"
mkdir -p "$BUILD_DIR"

# Build APK
if [[ "$BUILD_APK" == true ]]; then
    echo -e "${YELLOW}Building release APK...${NC}"

    flutter build apk --release --split-per-abi \
        --build-name="${VERSION%+*}" \
        --build-number="${VERSION#*+}"

    # Copy APKs to output directory
    cp -r build/app/outputs/flutter-apk/*.apk "$BUILD_DIR/"

    # Check APK sizes
    echo ""
    echo -e "${BLUE}APK Sizes:${NC}"
    for apk in "$BUILD_DIR"/*.apk; do
        size=$(ls -lh "$apk" | awk '{print $5}')
        name=$(basename "$apk")
        echo "  $name: $size"

        # Check size limit (50MB)
        size_mb=$(stat -f%z "$apk" 2>/dev/null || stat -c%s "$apk")
        size_mb=$((size_mb / 1024 / 1024))
        if [[ $size_mb -gt 50 ]]; then
            echo -e "${RED}  Warning: APK exceeds 50MB limit!${NC}"
        fi
    done
    echo ""
    echo -e "${GREEN}APK build complete.${NC}"
    echo ""
fi

# Build AAB
if [[ "$BUILD_AAB" == true ]]; then
    echo -e "${YELLOW}Building release AAB...${NC}"

    flutter build appbundle --release \
        --build-name="${VERSION%+*}" \
        --build-number="${VERSION#*+}"

    # Copy AAB to output directory
    cp build/app/outputs/bundle/release/*.aab "$BUILD_DIR/"

    # Check AAB size
    echo ""
    echo -e "${BLUE}AAB Size:${NC}"
    for aab in "$BUILD_DIR"/*.aab; do
        size=$(ls -lh "$aab" | awk '{print $5}')
        name=$(basename "$aab")
        echo "  $name: $size"
    done
    echo ""
    echo -e "${GREEN}AAB build complete.${NC}"
    echo ""
fi

# Generate build report
REPORT_FILE="$BUILD_DIR/build_report.txt"
cat > "$REPORT_FILE" << EOF
KerjaFlow Production Build Report
==================================

Build Time: $(date)
Version: ${VERSION}
Target Store: ${TARGET_STORE}

Files Generated:
EOF

for file in "$BUILD_DIR"/*.{apk,aab} 2>/dev/null; do
    if [[ -f "$file" ]]; then
        name=$(basename "$file")
        size=$(ls -lh "$file" | awk '{print $5}')
        sha256=$(shasum -a 256 "$file" | awk '{print $1}')
        echo "  $name" >> "$REPORT_FILE"
        echo "    Size: $size" >> "$REPORT_FILE"
        echo "    SHA256: $sha256" >> "$REPORT_FILE"
    fi
done

cat >> "$REPORT_FILE" << EOF

Build Configuration:
  Flutter: $(flutter --version | head -1)
  Dart: $(dart --version 2>&1)
  Clean Build: ${RUN_CLEAN}
  Tests Run: ${RUN_TESTS}

Build Artifacts Location:
  ${BUILD_DIR}
EOF

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  Production Build Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Build artifacts: $BUILD_DIR"
echo "Build report: $REPORT_FILE"
echo ""

# Final checklist
echo -e "${YELLOW}Pre-release Checklist:${NC}"
echo "  [ ] Verify APK/AAB installs correctly on test device"
echo "  [ ] Test HMS Push notifications (AppGallery)"
echo "  [ ] Verify analytics events are tracked"
echo "  [ ] Test offline functionality"
echo "  [ ] Check all 12 language translations"
echo "  [ ] Verify payslip PDF viewing"
echo "  [ ] Test biometric authentication"
echo "  [ ] Review privacy policy and compliance"
echo ""
echo -e "${BLUE}Upload to:${NC}"
echo "  Huawei AppGallery: https://developer.huawei.com/consumer/en/appgallery"
echo "  Google Play Console: https://play.google.com/console"
echo ""
