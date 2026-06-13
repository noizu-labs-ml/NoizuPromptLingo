#!/usr/bin/env bash
# Cron guard: start ngrok only if a flag file exists on the remote and ngrok isn't already running.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
  cat <<'EOF'
Usage: ngrok-cron.sh [OPTIONS]

Options:
  --remote HOST        Remote SSH host (required)
  --flag PATH          Flag file on remote that triggers startup (required)
  --port PORT          Local port to tunnel (default: 4000)
  --remote-out PATH    File on remote to write tunnel address (required)
  -h, --help           Show this help
EOF
  exit "${1:-0}"
}

REMOTE=""
FLAG=""
PORT=4000
REMOTE_OUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --remote)     REMOTE="$2"; shift 2 ;;
    --flag)       FLAG="$2"; shift 2 ;;
    --port)       PORT="$2"; shift 2 ;;
    --remote-out) REMOTE_OUT="$2"; shift 2 ;;
    -h|--help)    usage 0 ;;
    *) echo "Unknown option: $1" >&2; usage 1 ;;
  esac
done

[[ -z "$REMOTE" ]]     && { echo "error: --remote is required" >&2; usage 1; }
[[ -z "$FLAG" ]]       && { echo "error: --flag is required" >&2; usage 1; }
[[ -z "$REMOTE_OUT" ]] && { echo "error: --remote-out is required" >&2; usage 1; }

ssh -o BatchMode=yes -o ConnectTimeout=5 "$REMOTE" "test -f $FLAG" || exit 0
pgrep -f "ngrok tcp $PORT" >/dev/null && exit 0
"$SCRIPT_DIR/ngrok-nomachine.sh" --remote "$REMOTE" --port "$PORT" --remote-out "$REMOTE_OUT"
