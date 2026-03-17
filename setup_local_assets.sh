#!/usr/bin/env bash

# MIMIR local asset downloader – static fonts for exact match
# Run this from the project root (where index.html is located)

set -e

echo "=== Setting up local assets for MIMIR (static fonts) ==="

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
# 2. Google Fonts – static weights
# ----------------------------------------------------------------------
echo "Downloading static font files from Google Fonts..."

# Helper to fetch a static font file
fetch_static_font() {
    local family="$1"
    local weight="$2"
    local output_name="$3"
    # Request the specific weight, ensure we get WOFF2
    local css_url="https://fonts.googleapis.com/css2?family=${family}:wght@${weight}&display=swap"

    echo "  Fetching ${family} weight ${weight} ..."
    css=$(curl -s -L -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" "$css_url")

    # Extract the first .woff2 URL
    font_url=$(echo "$css" | grep -oE 'src: url\(["'\'']?https://fonts\.gstatic\.com[^)]+\.woff2' | head -1 | sed -E 's/src: url\(["'\'']?//; s/["'\'']?$//')

    if [ -z "$font_url" ]; then
        echo "    ERROR: Could not extract font URL for ${family} weight ${weight}"
        return 1
    fi

    echo "    Downloading $output_name ..."
    curl -L -o "fonts/$output_name" "$font_url"
}

# Inter weights: 300,400,500,600,700
fetch_static_font "Inter" "300" "inter-300.woff2"
fetch_static_font "Inter" "400" "inter-400.woff2"
fetch_static_font "Inter" "500" "inter-500.woff2"
fetch_static_font "Inter" "600" "inter-600.woff2"
fetch_static_font "Inter" "700" "inter-700.woff2"

# Montserrat weights: 400,500,600,700,800
fetch_static_font "Montserrat" "400" "montserrat-400.woff2"
fetch_static_font "Montserrat" "500" "montserrat-500.woff2"
fetch_static_font "Montserrat" "600" "montserrat-600.woff2"
fetch_static_font "Montserrat" "700" "montserrat-700.woff2"
fetch_static_font "Montserrat" "800" "montserrat-800.woff2"

# Source Sans Pro weights: 300,400,600,700
fetch_static_font "Source+Sans+Pro" "300" "source-sans-300.woff2"
fetch_static_font "Source+Sans+Pro" "400" "source-sans-400.woff2"
fetch_static_font "Source+Sans+Pro" "600" "source-sans-600.woff2"
fetch_static_font "Source+Sans+Pro" "700" "source-sans-700.woff2"

echo "=== All assets downloaded successfully ==="
echo "Now your site uses exactly the same static font files as the original Google Fonts."
