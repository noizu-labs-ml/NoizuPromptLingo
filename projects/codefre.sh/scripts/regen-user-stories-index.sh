#!/usr/bin/env bash
# Thin shell wrapper around scripts/regen-user-stories-index.py
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$HERE/regen-user-stories-index.py" "$@"
