#!/bin/bash
# KerjaFlow Font Download Script
# Downloads required Noto Sans fonts for complex script rendering

set -e

FONTS_DIR="$(dirname "$0")/../assets/fonts"
mkdir -p "$FONTS_DIR"

echo "================================================"
echo "KerjaFlow Font Download Script"
echo "================================================"
echo ""

# Font download URLs from Google Fonts (direct GitHub releases)
# Base URL for Noto fonts from Google's GitHub
NOTO_BASE="https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf"

# Function to download a font
download_font() {
    local family=$1
    local weight=$2
    local output="${FONTS_DIR}/${family}-${weight}.ttf"

    if [ -f "$output" ]; then
        echo "  [SKIP] ${family}-${weight}.ttf already exists"
        return 0
    fi

    # Note: Google Fonts API doesn't allow direct TTF downloads
    # Users should manually download from fonts.google.com
    echo "  [INFO] ${family}-${weight}.ttf needs to be downloaded manually"
    return 1
}

echo "Font Status Check:"
echo ""

# Check for Roboto
echo "Primary Latin Font:"
for weight in Regular Medium Bold; do
    if [ -f "$FONTS_DIR/Roboto-${weight}.ttf" ]; then
        echo "  [OK] Roboto-${weight}.ttf"
    else
        echo "  [MISSING] Roboto-${weight}.ttf"
    fi
done
echo ""

# Complex script fonts
declare -A FONTS=(
    ["NotoSansKhmer"]="Khmer (Cambodia)"
    ["NotoSansMyanmar"]="Burmese (Myanmar)"
    ["NotoSansThai"]="Thai (Thailand)"
    ["NotoSansTamil"]="Tamil (Malaysia, Singapore)"
    ["NotoSansBengali"]="Bengali (Bangladesh migrants)"
    ["NotoSansDevanagari"]="Nepali (Nepal migrants)"
    ["NotoSansLao"]="Lao (Laos)"
)

echo "Complex Script Fonts:"
MISSING=0
for font in "${!FONTS[@]}"; do
    echo ""
    echo "$font - ${FONTS[$font]}:"
    for weight in Regular Medium Bold; do
        if [ -f "$FONTS_DIR/${font}-${weight}.ttf" ]; then
            echo "  [OK] ${font}-${weight}.ttf"
        else
            echo "  [MISSING] ${font}-${weight}.ttf"
            MISSING=$((MISSING + 1))
        fi
    done
done

echo ""
echo "================================================"

if [ $MISSING -gt 0 ]; then
    echo ""
    echo "ACTION REQUIRED: $MISSING font files are missing."
    echo ""
    echo "Download fonts from Google Fonts:"
    echo ""
    echo "  1. Roboto:"
    echo "     https://fonts.google.com/specimen/Roboto"
    echo ""
    echo "  2. Complex Script Fonts:"
    for font in "${!FONTS[@]}"; do
        font_url=$(echo $font | sed 's/\([A-Z]\)/ \1/g' | sed 's/^ //' | sed 's/ /+/g')
        echo "     https://fonts.google.com/noto/specimen/${font_url}"
    done
    echo ""
    echo "Download Regular, Medium, and Bold weights for each font."
    echo "Place .ttf files in: $FONTS_DIR"
    echo ""
    exit 1
else
    echo ""
    echo "All fonts are installed!"
    echo ""
fi
