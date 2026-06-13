#!/usr/bin/env bash
# Publish @noizu/styleguide to Verdaccio (https://npm.noizu.com).
# Copies engine source into pkg/ for npm, rewrites @styleguide-engine/ to relative paths.
set -euo pipefail

cd "$(dirname "$0")"
ENGINE_SRC="../src"

echo "=== Preparing package ==="

# Clean previous build
rm -rf dist/engine-src

# Copy engine source into package-local directory
mkdir -p dist/engine-src
cp -r "$ENGINE_SRC/components" dist/engine-src/components
cp -r "$ENGINE_SRC/lib" dist/engine-src/lib
cp -r "$ENGINE_SRC/config" dist/engine-src/config

echo "Copied engine source to dist/engine-src/"

# Rewrite @styleguide-engine/ imports to relative paths inside the copied source
# e.g. @styleguide-engine/lib/types → relative path to lib/types
find dist/engine-src -name '*.ts' -o -name '*.tsx' | while read f; do
  # Calculate the relative path from this file back to dist/engine-src/
  dir=$(dirname "$f")
  rel=$(python3 -c "import os.path; print(os.path.relpath('dist/engine-src', '$dir'))")
  sed -i '' "s|@styleguide-engine/|${rel}/|g" "$f"
done

echo "Rewrote @styleguide-engine/ to relative paths in dist/"

# Rewrite barrel exports to point at dist/engine-src/ instead of ../../src/
sed -i '' 's|../../src/|../dist/engine-src/|g' src/components.ts src/viewer.ts src/css-gen.ts src/types.ts src/index.ts

echo "Rewrote barrel exports"
echo ""
echo "=== Publishing ==="
npm publish

echo ""
echo "=== Restoring barrel exports ==="
sed -i '' 's|../dist/engine-src/|../../src/|g' src/components.ts src/viewer.ts src/css-gen.ts src/types.ts src/index.ts

echo "Done. Published @noizu/styleguide to Verdaccio (https://npm.noizu.com)."
