#!/bin/bash
set -euo pipefail

APP="/Applications/Queue Populator.app"
OLD_BIN="$HOME/.local/bin/queue-populator"
PLIST="$HOME/Library/LaunchAgents/com.noizu.queue-populator.plist"
CONFIG_DIR="$HOME/.config/queue-populator"

if [ -f "$PLIST" ]; then
    launchctl unload "$PLIST" 2>/dev/null || true
    rm -f "$PLIST"
    echo "LaunchAgent removed"
fi

if [ -d "$APP" ]; then
    rm -rf "$APP"
    echo "App removed"
fi

if [ -f "$OLD_BIN" ]; then
    rm -f "$OLD_BIN"
    echo "Old binary removed"
fi

echo "Config at $CONFIG_DIR left intact."
echo "Done."
