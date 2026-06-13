#!/usr/bin/env bash
# Build UMD bundles from engine components → $DIST_TARGET
set -euo pipefail

cd "$(dirname "$0")"

DIST_TARGET="${DIST_TARGET:-/home/keith/Github/noizu/assets/dist}"

# Check Vite is available (engine devDependencies)
if [ ! -f ../node_modules/.bin/vite ]; then
  echo "Installing build dependencies..."
  cd ..
  npm install
  cd pkg
fi

# 1. Build primitives bundle (sg.js + sg.css)
echo "=== Building sg.js (primitives) ==="
npx vite build --config vite.config.js
echo ""

# 2. Build viewer bundle (sg-viewer.js + sg-viewer.css)
echo "=== Building sg-viewer.js (viewer components) ==="
npx vite build --config vite.config.viewer.js
echo ""

echo "Output:"
ls -lh dist/sg.js dist/sg.css dist/sg-viewer.js dist/sg-viewer.css 2>/dev/null || ls -lh dist/

# Copy to dist target
if [ -d "$DIST_TARGET" ]; then
  cp dist/sg.js dist/sg.css "$DIST_TARGET/"
  cp dist/sg-viewer.js "$DIST_TARGET/" 2>/dev/null || true
  cp dist/sg-viewer.css "$DIST_TARGET/" 2>/dev/null || true
  echo ""
  echo "Deployed to $DIST_TARGET/"
  ls -lh "$DIST_TARGET"/sg*.js "$DIST_TARGET"/sg*.css 2>/dev/null
else
  echo ""
  echo "DIST_TARGET=$DIST_TARGET not found — skipping deploy."
  echo "  Set DIST_TARGET env var or create the directory."
fi
