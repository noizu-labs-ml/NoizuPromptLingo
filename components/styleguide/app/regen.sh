#!/bin/bash
# Regenerate CSS + JSX from YAML config, clear all caches
set -e
cd "$(dirname "$0")"
rm -rf .cache/
rm -f src/app/design-system.generated.css
rm -f public/themes/*.css
npx tsx src/scripts/generate-css.ts
touch src/app/globals.css
echo "✓ Cache cleared, CSS regenerated, Tailwind nudged"
