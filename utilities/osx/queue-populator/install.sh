#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="/Applications/Queue Populator.app"
APP_CONTENTS="$APP_DIR/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"
APP_BIN="$APP_MACOS/queue-populator"
PLIST_DST="$HOME/Library/LaunchAgents/com.noizu.queue-populator.plist"
DOMAIN="gui/$UID"

echo "Building queue-populator..."
cd "$SCRIPT_DIR"
swift build -c release

BINARY="$(swift build -c release --show-bin-path)/queue-populator"

mkdir -p "$APP_MACOS" "$APP_RESOURCES"
cp "$BINARY" "$APP_BIN"
chmod +x "$APP_BIN"
if [ -f "$SCRIPT_DIR/Assets/QueuePopulator.icns" ]; then
    cp "$SCRIPT_DIR/Assets/QueuePopulator.icns" "$APP_RESOURCES/QueuePopulator.icns"
fi
if [ -f "$SCRIPT_DIR/Assets/StatusIcon.png" ]; then
    cp "$SCRIPT_DIR/Assets/StatusIcon.png" "$APP_RESOURCES/StatusIcon.png"
fi
cat > "$APP_CONTENTS/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key>
	<string>queue-populator</string>
	<key>CFBundleIdentifier</key>
	<string>com.noizu.queue-populator</string>
	<key>CFBundleName</key>
	<string>Queue Populator</string>
	<key>CFBundleIconFile</key>
	<string>QueuePopulator.icns</string>
	<key>CFBundleIconName</key>
	<string>QueuePopulator</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>NSMicrophoneUsageDescription</key>
	<string>Queue Populator listens for your configured wake phrase and records spoken queue items.</string>
	<key>NSSpeechRecognitionUsageDescription</key>
	<string>Queue Populator transcribes speech so it can classify and route queue items.</string>
</dict>
</plist>
PLIST
echo "Installed app to $APP_DIR"

# Remove any previously-installed LaunchAgent so the app no longer auto-starts at login.
if [ -f "$PLIST_DST" ]; then
    launchctl bootout "$DOMAIN" "$PLIST_DST" 2>/dev/null || true
    launchctl unload "$PLIST_DST" 2>/dev/null || true
    rm -f "$PLIST_DST"
    echo "Removed old LaunchAgent (app is now launched manually)"
fi

echo "Done. Launch from /Applications, then run '$APP_BIN --authorize' to grant permissions."
echo "For the Recording/Claude/Codex/Llama virtual microphones, run: ./Driver/build-virtual-mics.sh (needs Xcode + admin)."
