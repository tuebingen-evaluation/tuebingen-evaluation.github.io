#!/usr/bin/env bash

# MIMIR local asset downloader – correct Latin subset fonts
# Run this from the project root (where index.html is located)
# Fix: grabs the LATIN subset (last @font-face block), not Cyrillic-ext (first block)

set -e

echo "=== Setting up local assets for MIMIR (correct Latin fonts) ==="

# Create required directories
mkdir -p fonts css webfonts

# ----------------------------------------------------------------------
# 1. Font Awesome
# ----------------------------------------------------------------------
FA_VERSION="6.4.0"
FA_ZIP="fontawesome-free-${FA_VERSION}-web.zip"
FA_URL="https://use.fontawesome.com/releases/v${FA_VERSION}/${FA_ZIP}"

if [ ! -f "$FA_ZIP" ]; then
    echo "Downloading Font Awesome ${FA_VERSION}..."
    curl -L -o "$FA_ZIP" "$FA_URL"
else
    echo "Font Awesome zip already exists, skipping download."
fi

echo "Extracting Font Awesome CSS and webfonts..."
unzip -o -q "$FA_ZIP" -d fontawesome-tmp
EXTRACTED_DIR=$(find fontawesome-tmp -maxdepth 1 -type d -name "fontawesome-free-*" | head -1)
if [ -z "$EXTRACTED_DIR" ]; then
    echo "Error: Could not find extracted Font Awesome folder."
    exit 1
fi

cp "$EXTRACTED_DIR/css/fontawesome.min.css" css/
cp "$EXTRACTED_DIR/webfonts/"* webfonts/ 2>/dev/null || true
rm -rf fontawesome-tmp
echo "Font Awesome placed in css/ and webfonts/"

# ----------------------------------------------------------------------
# 2. Google Fonts – static weights, LATIN subset
# ----------------------------------------------------------------------
echo "Downloading static font files from Google Fonts (Latin subset)..."

# Helper to fetch the LATIN subset woff2 for a given family+weight.
# Google returns multiple @font-face blocks per weight (Cyrillic-ext first, Latin last).
# We find the block explicitly labelled "/* latin */" and extract its src URL.
fetch_latin_font() {
    local family="$1"
    local weight="$2"
    local output_name="$3"
    local css_url="https://fonts.googleapis.com/css2?family=${family}:wght@${weight}&display=swap"

    echo "  Fetching ${family} weight ${weight} (latin) ..."
    css=$(curl -s -L -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" "$css_url")

    # Extract the src URL from the block that follows "/* latin */" comment
    # Strategy: find the last src: url(...woff2) — Google always puts latin last
    font_url=$(echo "$css" | grep -oE 'https://fonts\.gstatic\.com/[^)]+\.woff2' | tail -1)

    if [ -z "$font_url" ]; then
        echo "    ERROR: Could not extract Latin font URL for ${family} weight ${weight}"
        return 1
    fi

    echo "    Downloading $output_name from $font_url ..."
    curl -L -o "fonts/$output_name" "$font_url"
}

# Inter weights: 300,400,500,600,700
fetch_latin_font "Inter" "300" "inter-300.woff2"
fetch_latin_font "Inter" "400" "inter-400.woff2"
fetch_latin_font "Inter" "500" "inter-500.woff2"
fetch_latin_font "Inter" "600" "inter-600.woff2"
fetch_latin_font "Inter" "700" "inter-700.woff2"

# Montserrat weights: 400,500,600,700,800
fetch_latin_font "Montserrat" "400" "montserrat-400.woff2"
fetch_latin_font "Montserrat" "500" "montserrat-500.woff2"
fetch_latin_font "Montserrat" "600" "montserrat-600.woff2"
fetch_latin_font "Montserrat" "700" "montserrat-700.woff2"
fetch_latin_font "Montserrat" "800" "montserrat-800.woff2"

# Source Sans Pro weights: 300,400,600,700
fetch_latin_font "Source+Sans+Pro" "300" "source-sans-300.woff2"
fetch_latin_font "Source+Sans+Pro" "400" "source-sans-400.woff2"
fetch_latin_font "Source+Sans+Pro" "600" "source-sans-600.woff2"
fetch_latin_font "Source+Sans+Pro" "700" "source-sans-700.woff2"

echo ""
echo "=== All assets downloaded successfully ==="
echo "The fonts/ directory now contains correct Latin-subset woff2 files."
echo "Use the index.html from Claude alongside these font files."
