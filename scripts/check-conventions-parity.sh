#!/usr/bin/env bash
# check-conventions-parity.sh — byte-compare the 8 NPL convention files between
# conventions/ (SOURCE), backend/priv/conventions/, and any extra dirs passed as args
# (e.g. the agent-kit-mcp priv copy). Exit 1 on any drift or missing file.
#
# Usage: scripts/check-conventions-parity.sh [OTHER_DIR ...]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILES=(npl.yaml syntax.yaml declarations.yaml pumps.yaml directives.yaml prefixes.yaml prompt-sections.yaml special-sections.yaml)

DIRS=("$REPO_ROOT/conventions" "$REPO_ROOT/backend/priv/conventions")
if [ "$#" -gt 0 ]; then
  DIRS+=("$@")
fi

SRC="${DIRS[0]}"
status=0
for other in "${DIRS[@]:1}"; do
  for f in "${FILES[@]}"; do
    if [ ! -f "$other/$f" ]; then
      echo "DRIFT: missing $other/$f"
      status=1
    elif ! cmp -s "$SRC/$f" "$other/$f"; then
      echo "DRIFT: $SRC/$f != $other/$f"
      status=1
    fi
  done
done

if [ "$status" -eq 0 ]; then
  echo "conventions parity OK: ${#FILES[@]} files across ${#DIRS[@]} dirs"
fi
exit "$status"
