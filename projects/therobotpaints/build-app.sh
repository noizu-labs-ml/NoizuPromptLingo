#!/bin/bash

set -e

APP_NAME="therobotpaints"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Building The Robot Paints...${NC}"
cd "$SCRIPT_DIR"
swift build

echo -e "${YELLOW}Creating app bundle...${NC}"

APP_PATH="$SCRIPT_DIR/build/$APP_NAME.app"
CONTENTS="$APP_PATH/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

rm -rf "$APP_PATH"
mkdir -p "$MACOS"
mkdir -p "$RESOURCES"

EXECUTABLE=$(find "$SCRIPT_DIR/.build" -name "$APP_NAME" -type f ! -path "*.dSYM/*" | head -1)
if [ -z "$EXECUTABLE" ]; then
    echo "Error: Could not find built executable"
    exit 1
fi
cp "$EXECUTABLE" "$MACOS/"
chmod +x "$MACOS/$APP_NAME"

cat > "$CONTENTS/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>therobotpaints</string>
    <key>CFBundleIdentifier</key>
    <string>com.therobotpaints.app</string>
    <key>CFBundleName</key>
    <string>The Robot Paints</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>0.1</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
</dict>
</plist>
EOF

plutil -lint "$CONTENTS/Info.plist" || { echo "Error: Invalid Info.plist"; exit 1; }
test -x "$MACOS/$APP_NAME" || { echo "Error: Executable not found or not executable"; exit 1; }

echo -e "${GREEN}✓ App bundle created at: $APP_PATH${NC}"
echo ""
echo "To run:"
echo "  open $APP_PATH"
