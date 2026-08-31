#!/usr/bin/env bash
# Rebuild Resources/LLMToolkit.icns + LLMToolkit.iconset from Assets/LLMToolkitIcon-1024.png
# Same pipeline as timely.noizu.com/apps/macos/scripts/generate-app-icon.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MASTER="${1:-$ROOT/Assets/LLMToolkitIcon-1024.png}"
ICONSET="$ROOT/Resources/LLMToolkit.iconset"
ICNS="$ROOT/Resources/LLMToolkit.icns"

if [[ ! -f "$MASTER" ]]; then
  echo "Missing master icon: $MASTER" >&2
  exit 1
fi

mkdir -p "$ICONSET"
sips -s format png -z 1024 1024 "$MASTER" --out "$ROOT/Assets/LLMToolkitIcon-1024.png" >/dev/null
MASTER="$ROOT/Assets/LLMToolkitIcon-1024.png"

sips -z 16 16     "$MASTER" --out "$ICONSET/icon_16x16.png" >/dev/null
sips -z 32 32     "$MASTER" --out "$ICONSET/icon_16x16@2x.png" >/dev/null
sips -z 32 32     "$MASTER" --out "$ICONSET/icon_32x32.png" >/dev/null
sips -z 64 64     "$MASTER" --out "$ICONSET/icon_32x32@2x.png" >/dev/null
sips -z 64 64     "$MASTER" --out "$ICONSET/icon_64x64.png" >/dev/null
sips -z 128 128   "$MASTER" --out "$ICONSET/icon_128x128.png" >/dev/null
sips -z 256 256   "$MASTER" --out "$ICONSET/icon_128x128@2x.png" >/dev/null
sips -z 256 256   "$MASTER" --out "$ICONSET/icon_256x256.png" >/dev/null
sips -z 512 512   "$MASTER" --out "$ICONSET/icon_256x256@2x.png" >/dev/null
sips -z 512 512   "$MASTER" --out "$ICONSET/icon_512x512.png" >/dev/null
sips -z 1024 1024 "$MASTER" --out "$ICONSET/icon_512x512@2x.png" >/dev/null

iconutil -c icns "$ICONSET" -o "$ICNS"
echo "Wrote $ICNS"
