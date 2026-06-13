#!/usr/bin/env bash
# Rebuilds styleguide-starter.tar.gz from the live styleguide-starter directory.
# Run from the repo root or this script's directory.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
STARTER="$REPO_ROOT/styleguide-starter"
OUTPUT="$REPO_ROOT/skills/user-experience-engineer/assets/styleguide-starter.tar.gz"

if [[ ! -d "$STARTER" ]]; then
  echo "Error: styleguide-starter not found at $STARTER"
  exit 1
fi

tar czf "$OUTPUT" \
  --exclude='node_modules' \
  --exclude='.next' \
  --exclude='out' \
  --exclude='.cache' \
  --exclude='src/app/design-system.generated.css' \
  --exclude='public/themes/*.css' \
  --exclude='package-lock.json' \
  --exclude='next-env.d.ts' \
  --exclude='.tool-versions' \
  --exclude='*.tsbuildinfo' \
  --exclude='.DS_Store' \
  -C "$STARTER" .

echo "Built: $OUTPUT ($(du -h "$OUTPUT" | cut -f1))"
