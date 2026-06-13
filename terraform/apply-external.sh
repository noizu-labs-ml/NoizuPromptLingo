#!/usr/bin/env bash
# =============================================================================
# Run terraform init/plan/apply across all external (non-Kubernetes) roots
#
# Usage:
#   ./apply-external.sh [plan|apply|init] [--only <root>]
#
# Examples:
#   ./apply-external.sh init               # init all roots
#   ./apply-external.sh plan               # plan all roots
#   ./apply-external.sh apply              # apply all roots
#   ./apply-external.sh plan --only cloudflare/zones/noizu
#   ./apply-external.sh plan --only sendgrid
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ACTION="${1:-plan}"
FILTER=""

shift || true
while [[ $# -gt 0 ]]; do
    case "$1" in
        --only) FILTER="$2"; shift 2 ;;
        *)      echo "Unknown option: $1"; exit 1 ;;
    esac
done

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

ROOTS=(
  cloudflare/dns-noizu
  cloudflare/dns-trl
  cloudflare/zero-trust
  sendgrid
  monitoring
  cloudflare/zones/noizu
  cloudflare/zones/trl
)

PASS=0
FAIL=0
SKIP=0

run() {
  local root="$1"
  local dir="$SCRIPT_DIR/$root"

  [[ -n "$FILTER" && "$root" != "$FILTER" ]] && return

  if grep -q 'PLACEHOLDER_TRL_ACCOUNT_ID' "$dir/locals.tf" 2>/dev/null; then
    echo -e "${YELLOW}SKIP${NC} $root (TRL account ID not configured)"
    ((SKIP++))
    return
  fi

  echo -e "${CYAN}━━━ $root ━━━${NC}"

  case "$ACTION" in
    init)  terraform -chdir="$dir" init  -input=false ;;
    plan)  terraform -chdir="$dir" plan  -input=false ;;
    apply) terraform -chdir="$dir" apply -input=false ;;
    *)     echo "Unknown action: $ACTION (use init, plan, apply)"; exit 1 ;;
  esac && { echo -e "${GREEN}OK${NC} $root"; ((PASS++)); } \
       || { echo -e "${RED}FAIL${NC} $root"; ((FAIL++)); }

  echo ""
}

for root in "${ROOTS[@]}"; do
  run "$root"
done

echo -e "━━━ Summary ━━━"
echo -e "${GREEN}Pass: $PASS${NC}  ${RED}Fail: $FAIL${NC}  ${YELLOW}Skip: $SKIP${NC}"
[[ $FAIL -gt 0 ]] && exit 1
exit 0
