#!/bin/bash
#
# uninstall-virtual-mics.sh — remove the Recording/Claude/Codex/Llama virtual mic drivers.
#
set -euo pipefail

HAL_DIR="/Library/Audio/Plug-Ins/HAL"

echo "Removing virtual mic drivers from $HAL_DIR (requires admin password)"
for name in Recording Claude Codex Llama; do
  if [ -d "$HAL_DIR/$name.driver" ]; then
    sudo rm -rf "$HAL_DIR/$name.driver"
    echo "  removed $name.driver"
  fi
done

echo "Restarting CoreAudio"
sudo killall -9 coreaudiod || true
echo "Done."
