#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="/Applications/Queue Populator.app"
APP_CONTENTS="$APP_DIR/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_BIN="$APP_MACOS/queue-populator"
PLIST_SRC="$SCRIPT_DIR/com.noizu.queue-populator.plist"
PLIST_DST="$HOME/Library/LaunchAgents/com.noizu.queue-populator.plist"
LABEL="com.noizu.queue-populator"
DOMAIN="gui/$UID"

echo "Building queue-populator..."
cd "$SCRIPT_DIR"
swift build -c release

BINARY="$(swift build -c release --show-bin-path)/queue-populator"

mkdir -p "$APP_MACOS"
cp "$BINARY" "$APP_BIN"
chmod +x "$APP_BIN"
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

if [ -f "$PLIST_SRC" ]; then
    mkdir -p "$HOME/Library/LaunchAgents"
    sed "s|__BINARY__|$APP_BIN|g" "$PLIST_SRC" > "$PLIST_DST"
    launchctl bootout "$DOMAIN" "$PLIST_DST" 2>/dev/null || true
    launchctl unload "$PLIST_DST" 2>/dev/null || true
    if launchctl bootstrap "$DOMAIN" "$PLIST_DST" 2>/dev/null; then
        launchctl kickstart -k "$DOMAIN/$LABEL" 2>/dev/null || true
    else
        launchctl load "$PLIST_DST"
    fi
    echo "LaunchAgent installed, loaded, and started"
else
    echo "No plist found — skipping LaunchAgent setup"
fi

echo "Done. Run 'queue-populator --authorize' to grant permissions."
