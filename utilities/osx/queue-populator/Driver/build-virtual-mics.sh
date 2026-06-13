#!/bin/bash
#
# build-virtual-mics.sh
#
# Builds and installs four virtual microphone devices — Recording, Claude,
# Codex, Llama —
# as CoreAudio HAL loopback drivers, by customizing BlackHole (MIT licensed).
#
# Each device is both an OUTPUT and an INPUT (loopback): queue-populator renders
# your live mic into the device's output, and other apps (Zoom, OBS, browser, an
# LLM voice client, ...) pick it up as an input named "Recording" / "Claude" /
# "Codex" / "Llama".
#
# Requirements: Xcode (full app, not just CLT) and an admin password for install.
# Usage:
#   ./build-virtual-mics.sh            # build + install all four
#   ./build-virtual-mics.sh --no-install   # build only, leave bundles in ./build
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
SRC_DIR="$BUILD_DIR/BlackHole"
HAL_DIR="/Library/Audio/Plug-Ins/HAL"
BLACKHOLE_REPO="https://github.com/ExistentialAudio/BlackHole.git"
# Pin to a known tag for reproducible builds; bump deliberately.
BLACKHOLE_REF="${BLACKHOLE_REF:-v0.6.1}"
CHANNELS="${CHANNELS:-2}"

INSTALL=1
[ "${1:-}" = "--no-install" ] && INSTALL=0

# device name | bundle id suffix | uid prefix
DEVICES=(
  "Recording|recording|RobotAudioRecording"
  "Claude|claude|RobotAudioClaude"
  "Codex|codex|RobotAudioCodex"
  "Llama|llama|RobotAudioLlama"
)

command -v xcodebuild >/dev/null 2>&1 || {
  echo "error: xcodebuild not found. Install the full Xcode app from the App Store." >&2
  exit 1
}

mkdir -p "$BUILD_DIR"

if [ ! -d "$SRC_DIR/.git" ]; then
  echo "Cloning BlackHole ($BLACKHOLE_REF)..."
  git clone --depth 1 --branch "$BLACKHOLE_REF" "$BLACKHOLE_REPO" "$SRC_DIR"
fi

build_one() {
  local name="$1" suffix="$2" uid="$3"
  local work="$BUILD_DIR/$name"
  local bundle_id="com.noizu.robotaudio.$suffix"

  echo "==> Building \"$name\" ($bundle_id, ${CHANNELS}ch)"
  rm -rf "$work"
  cp -R "$SRC_DIR" "$work"

  # Each loopback device needs globally-unique UIDs or CoreAudio rejects duplicates.
  local c="$work/BlackHole/BlackHole.c"
  [ -f "$c" ] || c="$work/BlackHole.c"
  /usr/bin/sed -i '' \
    -e "s/\"BlackHole_UID\"/\"${uid}_UID\"/g" \
    -e "s/\"BlackHole_ModelUID\"/\"${uid}_ModelUID\"/g" \
    -e "s|#define[[:space:]]*kDriver_Name[[:space:]]*\"BlackHole\"|#define                             kDriver_Name                        \"${name}\"|g" \
    -e "s|#define[[:space:]]*kPlugIn_BundleID[[:space:]]*\"audio.existential.BlackHole2ch\"|#define                             kPlugIn_BundleID                    \"${bundle_id}\"|g" \
    -e "s|#define[[:space:]]*kHas_Driver_Name_Format[[:space:]]*true|#define                             kHas_Driver_Name_Format             false|g" \
    -e "s|#define[[:space:]]*kDevice_Name[[:space:]].*|#define                             kDevice_Name                        \"${name}\"|g" \
    -e "s|#define[[:space:]]*kDevice2_Name[[:space:]].*|#define                             kDevice2_Name                       \"${name} Mirror\"|g" \
    -e "s|#define[[:space:]]*kNumber_Of_Channels[[:space:]]*2|#define                             kNumber_Of_Channels                 ${CHANNELS}|g" \
    "$c"

  ( cd "$work"
    xcodebuild \
      -project BlackHole.xcodeproj \
      -scheme BlackHole \
      -configuration Release \
      -derivedDataPath "build" \
      PRODUCT_BUNDLE_IDENTIFIER="$bundle_id" \
      CODE_SIGN_IDENTITY="-" \
      CODE_SIGNING_REQUIRED=NO \
      CODE_SIGNING_ALLOWED=NO \
      build >/dev/null
  )

  local built
  built="$(find "$work/build" -name 'BlackHole.driver' -type d | head -n1)"
  [ -n "$built" ] || { echo "error: build produced no .driver for $name" >&2; exit 1; }

  local out="$BUILD_DIR/$name.driver"
  rm -rf "$out"
  cp -R "$built" "$out"
  # Ad-hoc sign so coreaudiod will load it locally.
  codesign --force --deep --sign - "$out" >/dev/null 2>&1 || true
  echo "    -> $out"
}

for entry in "${DEVICES[@]}"; do
  IFS='|' read -r name suffix uid <<< "$entry"
  build_one "$name" "$suffix" "$uid"
done

if [ "$INSTALL" -eq 0 ]; then
  echo "Built (not installed). Bundles in $BUILD_DIR. Re-run without --no-install to install."
  exit 0
fi

echo "==> Installing to $HAL_DIR (requires admin password)"
for entry in "${DEVICES[@]}"; do
  IFS='|' read -r name _ _ <<< "$entry"
  sudo rm -rf "$HAL_DIR/$name.driver"
  sudo cp -R "$BUILD_DIR/$name.driver" "$HAL_DIR/$name.driver"
done

echo "==> Restarting CoreAudio"
sudo killall -9 coreaudiod || true

echo "Done. Recording, Claude, Codex, and Llama should now appear in Audio MIDI Setup and app input lists."
