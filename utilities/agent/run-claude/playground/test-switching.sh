#!/usr/bin/env bash
#
# Test script for run-claude directory switching
#
# This script simulates what the shell hook does when you cd between directories.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_SWITCH_DIR="$(dirname "$SCRIPT_DIR")"

# Add run-claude to path
export PATH="$CLAUDE_SWITCH_DIR:$PATH"

echo "=== Claude Switch Directory Switching Test ==="
echo ""

# Helper to run run-claude via Python directly (for environments without uv)
run_run_claude() {
    python3 -c "
import sys
sys.path.insert(0, '$CLAUDE_SWITCH_DIR')
sys.argv = ['run-claude'] + sys.argv[1:]
from run_claude.cli import main
sys.exit(main())
" "$@"
}

# Stub for direnv function (not available outside direnv)
source_env_if_exists() {
    local file="$1"
    if [[ -f "$file" ]]; then
        source "$file"
    fi
}

echo "1. Initial status:"
run_run_claude status
echo ""

echo "2. Simulating entry into cerebras-project..."
cd "$SCRIPT_DIR/cerebras-project"
source .envrc
echo "   Token: $AGENT_SHIM_TOKEN"
echo "   Profile: $AGENT_SHIM_PROFILE"
run_run_claude enter "$AGENT_SHIM_TOKEN" "$AGENT_SHIM_PROFILE"
cd "$SCRIPT_DIR"
echo ""

echo "3. Status after entering cerebras-project:"
run_run_claude status
echo ""

echo "4. Environment that would be set:"
run_run_claude env "$AGENT_SHIM_PROFILE" --export
echo ""

echo "5. Simulating entry into groq-project (without leaving cerebras)..."
cd "$SCRIPT_DIR/groq-project"
source .envrc
echo "   Token: $AGENT_SHIM_TOKEN"
echo "   Profile: $AGENT_SHIM_PROFILE"
run_run_claude enter "$AGENT_SHIM_TOKEN" "$AGENT_SHIM_PROFILE"
cd "$SCRIPT_DIR"
echo ""

echo "6. Status with both projects active:"
run_run_claude status
echo ""

echo "7. Simulating leave from cerebras-project..."
run_run_claude leave "4d9787ff8a546896"
echo ""

echo "8. Status after leaving cerebras:"
run_run_claude status
echo ""

echo "9. Simulating leave from groq-project..."
run_run_claude leave "5794b0f80bc369ef"
echo ""

echo "10. Final status (should show pending leases):"
run_run_claude status
echo ""

echo "11. Running janitor with --force..."
run_run_claude janitor --force
echo ""

echo "=== Test Complete ==="
