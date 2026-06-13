#!/bin/bash

# Build and package KopiGajj as a macOS app

set -e

APP_NAME="KopiGajj"
BUILD_DIR="src/.build/debug"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Read version from Version.swift (single source of truth)
APP_VERSION=$(grep 'static let current' "$SCRIPT_DIR/src/Sources/KopiGajj/Version.swift" | sed 's/.*"\(.*\)".*/\1/')
echo -e "${YELLOW}Building KopiGajj v${APP_VERSION}...${NC}"
cd "$SCRIPT_DIR/src"
swift build

echo -e "${YELLOW}Creating app bundle...${NC}"

APP_PATH="$SCRIPT_DIR/build/$APP_NAME.app"
CONTENTS="$APP_PATH/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

# Clean existing app
rm -rf "$APP_PATH"

# Create app bundle structure
mkdir -p "$MACOS"
mkdir -p "$RESOURCES"

# Copy executable (find in build output)
EXECUTABLE=$(find "$SCRIPT_DIR/src/.build" -name "$APP_NAME" -type f | grep -v ".dSYM" | head -1)
if [ -z "$EXECUTABLE" ]; then
    echo "Error: Could not find built executable"
    exit 1
fi
cp "$EXECUTABLE" "$MACOS/"
chmod +x "$MACOS/$APP_NAME"

# Create Info.plist
cat > "$CONTENTS/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>KopiGajj</string>
    <key>CFBundleIdentifier</key>
    <string>com.keithbrings.KopiGajj</string>
    <key>CFBundleName</key>
    <string>KopiGajj</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>VERSION_PLACEHOLDER</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSBackgroundOnly</key>
    <true/>
    <key>NSAppleEventsUsageDescription</key>
    <string>KopiGajj needs accessibility permissions to monitor global keyboard shortcuts.</string>
    <key>NSAccessibilityUsageDescription</key>
    <string>KopiGajj needs accessibility permissions to monitor global keyboard shortcuts for Cmd+Shift+T.</string>
</dict>
</plist>
EOF

# Replace version placeholder in Info.plist
sed -i '' "s/VERSION_PLACEHOLDER/$APP_VERSION/" "$CONTENTS/Info.plist"

# Validate plist
plutil -lint "$CONTENTS/Info.plist" || { echo "Error: Invalid Info.plist"; exit 1; }

# Verify executable
test -x "$MACOS/$APP_NAME" || { echo "Error: Executable not found or not executable"; exit 1; }

echo -e "${GREEN}✓ App bundle created at: $APP_PATH${NC}"
echo ""
echo "To install:"
echo "  1. Copy $APP_PATH to /Applications/"
echo "  2. Launch from Applications"
echo "  3. Grant Accessibility permissions when prompted"
echo ""
echo "Or run directly:"
echo "  open $APP_PATH"