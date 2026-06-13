#!/bin/sh
# Activate zellij-cct-tmux compatibility mode.
# Source this script inside a Zellij session to make Claude Code Agent Teams
# believe it's running under tmux.
#
# Usage:
#   source scripts/activate-tmux-compat.sh
#
# To deactivate, start a new shell or run:
#   unset TMUX TMUX_PANE
#   export PATH="$ZELLIJ_CCT_ORIG_PATH"

if [ -z "$ZELLIJ" ]; then
    echo "ERROR: not inside a Zellij session. Activate from within Zellij." >&2
    return 1 2>/dev/null || exit 1
fi

# Find the shim binary
SHIM_BIN=""
if [ -x "./target/release/zellij-cct-tmux" ]; then
    SHIM_BIN="$(cd "$(dirname ./target/release/zellij-cct-tmux)" && pwd)/zellij-cct-tmux"
elif [ -x "./target/debug/zellij-cct-tmux" ]; then
    SHIM_BIN="$(cd "$(dirname ./target/debug/zellij-cct-tmux)" && pwd)/zellij-cct-tmux"
else
    echo "ERROR: zellij-cct-tmux binary not found. Run 'cargo build -p zellij-cct-tmux' first." >&2
    return 1 2>/dev/null || exit 1
fi

# Create symlink directory
SHIM_DIR="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/zellij-cct/${ZELLIJ_SESSION_NAME}/bin"
mkdir -p "$SHIM_DIR"

# Create tmux symlink pointing to the shim binary
ln -sf "$SHIM_BIN" "$SHIM_DIR/tmux"

# Save original PATH for deactivation
export ZELLIJ_CCT_ORIG_PATH="$PATH"

# Prepend shim dir to PATH so `tmux` resolves to our shim
export PATH="$SHIM_DIR:$PATH"

# Set env vars that Claude Code checks
export TMUX="zellij-cct:${ZELLIJ_SESSION_NAME},$$,0"
export TMUX_PANE="%0"

# Enable debug logging
export ZELLIJ_CCT_DEBUG=1

echo "zellij-cct-tmux activated."
echo "  TMUX=$TMUX"
echo "  TMUX_PANE=$TMUX_PANE"
echo "  tmux -> $(which tmux)"
echo "  Debug log: ${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/zellij-cct/${ZELLIJ_SESSION_NAME}/tmux-shim.log"
