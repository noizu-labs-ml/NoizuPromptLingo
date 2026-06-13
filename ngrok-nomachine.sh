#!/usr/bin/env bash
# Start an ngrok TCP tunnel and push the public address to a remote host.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ngrok-nomachine.sh [OPTIONS]

Options:
  --remote HOST        Remote SSH host (required)
  --port PORT          Local port to tunnel (default: 4000)
  --remote-out PATH    File on remote host to write the tunnel address (required)
  -h, --help           Show this help
EOF
  exit "${1:-0}"
}

REMOTE=""
PORT=4000
REMOTE_OUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --remote)     REMOTE="$2"; shift 2 ;;
    --port)       PORT="$2"; shift 2 ;;
    --remote-out) REMOTE_OUT="$2"; shift 2 ;;
    -h|--help)    usage 0 ;;
    *) echo "Unknown option: $1" >&2; usage 1 ;;
  esac
done

[[ -z "$REMOTE" ]]     && { echo "error: --remote is required" >&2; usage 1; }
[[ -z "$REMOTE_OUT" ]] && { echo "error: --remote-out is required" >&2; usage 1; }

pkill -f "ngrok tcp $PORT" 2>/dev/null || true
sleep 1

nohup ngrok tcp "$PORT" --log=stdout >/tmp/ngrok.log 2>&1 &

URL=""
for _ in {1..20}; do
  sleep 1
  URL=$(curl -fs http://127.0.0.1:4040/api/tunnels \
    | python3 -c 'import json,sys; t=json.load(sys.stdin)["tunnels"]; print(t[0]["public_url"] if t else "")') || true
  [[ -n "$URL" ]] && break
done

[[ -z "$URL" ]] && { echo "ngrok failed to start" >&2; exit 1; }

ADDR="${URL#tcp://}"
printf '%s\n' "$ADDR" | ssh "$REMOTE" "cat > $REMOTE_OUT"
echo "$ADDR"
