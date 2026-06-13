#!/bin/bash
# Scaffold a new theme directory for the styleguide-engine
# Usage: ./scripts/create-theme.sh <slug>
# Example: ./scripts/create-theme.sh midnight-blue
set -e
cd "$(dirname "$0")/.."

# ─── Validate argument ────────────────────────────────────────────────────────

SLUG="$1"

if [ -z "$SLUG" ]; then
  echo "Error: theme slug required"
  echo "Usage: $0 <slug>  (e.g. midnight-blue)"
  exit 1
fi

if ! echo "$SLUG" | grep -qE '^[a-z][a-z0-9-]*$'; then
  echo "Error: slug must be lowercase letters, numbers, and hyphens only (no spaces, no leading hyphens)"
  echo "Got: $SLUG"
  exit 1
fi

THEME_DIR="src/config/theme-${SLUG}"

if [ -d "$THEME_DIR" ]; then
  echo "Error: theme directory already exists: $THEME_DIR"
  exit 1
fi

# ─── Title case helper ────────────────────────────────────────────────────────
# Splits slug on hyphens, capitalizes first letter of each word
title_case() {
  echo "$1" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}'
}

TITLE=$(title_case "$SLUG")
SLUG_UPPER=$(echo "$SLUG" | tr '[:lower:]' '[:upper:]' | tr '-' '_')

# ─── Create directory ─────────────────────────────────────────────────────────

mkdir -p "$THEME_DIR"

# ─── style-guide.meta.yaml ───────────────────────────────────────────────────

cat > "$THEME_DIR/style-guide.meta.yaml" <<EOF
name: ${SLUG}
slug: ${SLUG}
title: ${TITLE}
description: ""
base-theme: "theme-style-guide"
EOF

# ─── style-guide.vars.yaml ───────────────────────────────────────────────────

cat > "$THEME_DIR/style-guide.vars.yaml" <<'YAML_EOF'
vars:
  groups:
    - name: Theme Seeds
      vars:
        # Surface endpoints — gray ramp computed from these
        white: "#ffffff"
        black: "#000000"

        # Primaries
        red: "#e20613"
        blue: "#0047ab"
        yellow: "#f5a623"

        # Semantics
        success: "#22c55e"
        warning: "#eab308"
        error: "#ef4444"
        info: "#3b82f6"

        # Typography
        font-sans: "'Inter', -apple-system, sans-serif"

        # Spacing
        radius: "2px"
YAML_EOF

# ─── branding.yaml ───────────────────────────────────────────────────────────

cat > "$THEME_DIR/branding.yaml" <<EOF
name: ${SLUG}
logo-text: ${SLUG_UPPER}
intent: ""
perception: ""
audience: ""
tone: ""
keywords: []
EOF

# ─── style-guide.globals.yaml ────────────────────────────────────────────────

cat > "$THEME_DIR/style-guide.globals.yaml" <<'YAML_EOF'
globals: |
  /* Inherits from base theme — customize here */
YAML_EOF

# ─── Done ─────────────────────────────────────────────────────────────────────

echo "✓ Theme scaffolded: $THEME_DIR"
echo ""
echo "Next steps:"
echo "  1. Edit $THEME_DIR/style-guide.vars.yaml  — set your color seeds"
echo "  2. Edit $THEME_DIR/branding.yaml           — fill in intent, tone, audience"
echo "  3. Edit $THEME_DIR/style-guide.meta.yaml   — update description"
echo "  4. Run ./regen.sh to build the theme"
