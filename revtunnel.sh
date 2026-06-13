#!/usr/bin/env bash
# Persistent reverse tunnel via autossh.
# Default forwards:
#   remote:2222 -> local:22   (ssh)
#   remote:2023 -> local:2022 (eternal terminal)
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: revtunnel.sh [OPTIONS]

Options:
  --remote HOST        Remote SSH host (required)
  --user USER          Remote SSH user (default: $USER)
  --key PATH           SSH private key (default: ~/.ssh/id_ed25519)
  --forward SPEC       Reverse forward spec: REMOTE_PORT:LOCAL_HOST:LOCAL_PORT
                       May be repeated. Defaults: 2222:localhost:22 2023:localhost:2022
  -h, --help           Show this help
EOF
  exit "${1:-0}"
}

REMOTE=""
REMOTE_USER="$USER"
KEY="$HOME/.ssh/id_ed25519"
FORWARDS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --remote)  REMOTE="$2"; shift 2 ;;
    --user)    REMOTE_USER="$2"; shift 2 ;;
    --key)     KEY="$2"; shift 2 ;;
    --forward) FORWARDS+=("$2"); shift 2 ;;
    -h|--help) usage 0 ;;
    *) echo "Unknown option: $1" >&2; usage 1 ;;
  esac
done

[[ -z "$REMOTE" ]] && { echo "error: --remote is required" >&2; usage 1; }

if [[ ${#FORWARDS[@]} -eq 0 ]]; then
  FORWARDS=("2222:localhost:22" "2023:localhost:2022")
fi

export AUTOSSH_GATETIME=0
export AUTOSSH_PORT=0

FORWARD_ARGS=()
for spec in "${FORWARDS[@]}"; do
  FORWARD_ARGS+=(-R "$spec")
done

exec autossh -M 0 -N \
  -o "ServerAliveInterval=30" \
  -o "ServerAliveCountMax=3" \
  -o "ExitOnForwardFailure=yes" \
  -o "StrictHostKeyChecking=accept-new" \
  -o "BatchMode=yes" \
  -i "$KEY" \
  "${FORWARD_ARGS[@]}" \
  "${REMOTE_USER}@${REMOTE}"
