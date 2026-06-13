#!/usr/bin/env bash
#
# Non-interactive deploy for CI or scripted runs. Authenticates via
# MODAL_TOKEN_ID / MODAL_TOKEN_SECRET (no `modal setup` / browser), (re)creates
# the required Modal secrets, and deploys every app + the gateway.
#
# Usage:
#   ./deploy-ci.sh                # secrets + all apps + gateway
#   SKIP_SECRETS=1 ./deploy-ci.sh # assume secrets already exist
#   SKIP_GATEWAY=1 ./deploy-ci.sh # deploy model apps only
#   ONLY="llm image" ./deploy-ci.sh   # deploy just these apps (+gateway unless skipped)
#
# Config comes from the environment, or a .env file in this directory.
# Required:  MODAL_TOKEN_ID, MODAL_TOKEN_SECRET, HF_TOKEN
# Optional:  MODAL_GENAI_VLLM_KEY, MODAL_GENAI_API_KEY  (auto-generated if unset)
#            MODAL_ENVIRONMENT  (Modal environment/workspace to deploy into)
set -euo pipefail

cd "$(dirname "$0")"

# ---- load .env (without clobbering vars already set in the environment) ----
if [[ -f .env ]]; then
  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" =~ ^[[:space:]]*$ ]] && continue
    key="${line%%=*}"; key="${key// /}"
    [[ -z "$key" ]] && continue
    if [[ -z "${!key:-}" ]]; then export "$line"; fi
  done < .env
fi

MODAL_BIN="${MODAL_BIN:-modal}"
command -v "$MODAL_BIN" >/dev/null 2>&1 || { echo "ERROR: modal CLI not found. Run 'uv sync --extra modal' and use 'uv run'." >&2; exit 1; }

ENV_FLAG=()
[[ -n "${MODAL_ENVIRONMENT:-}" ]] && ENV_FLAG=(-e "$MODAL_ENVIRONMENT")

require() { [[ -n "${!1:-}" ]] || { echo "ERROR: $1 is required (set it in the environment or .env)." >&2; exit 1; }; }

# ---- auth (Modal reads these directly; no interactive setup needed) --------
require MODAL_TOKEN_ID
require MODAL_TOKEN_SECRET
export MODAL_TOKEN_ID MODAL_TOKEN_SECRET
echo "==> Authenticated via MODAL_TOKEN_ID (${MODAL_TOKEN_ID:0:8}...)"

gen() { openssl rand -hex 24; }

# ---- secrets --------------------------------------------------------------
if [[ "${SKIP_SECRETS:-0}" != "1" ]]; then
  require HF_TOKEN
  : "${MODAL_GENAI_VLLM_KEY:=$(gen)}"
  : "${MODAL_GENAI_API_KEY:=$(gen)}"
  export MODAL_GENAI_VLLM_KEY MODAL_GENAI_API_KEY

  echo "==> Creating/updating Modal secrets"
  "$MODAL_BIN" secret create "${ENV_FLAG[@]}" --force huggingface "HF_TOKEN=$HF_TOKEN"
  "$MODAL_BIN" secret create "${ENV_FLAG[@]}" --force modal-genai-vllm "MODAL_GENAI_VLLM_KEY=$MODAL_GENAI_VLLM_KEY"
  "$MODAL_BIN" secret create "${ENV_FLAG[@]}" --force modal-genai-gateway \
      "MODAL_GENAI_API_KEY=$MODAL_GENAI_API_KEY" "MODAL_GENAI_VLLM_KEY=$MODAL_GENAI_VLLM_KEY"
else
  echo "==> SKIP_SECRETS=1, leaving existing secrets in place"
fi

# ---- deploy ---------------------------------------------------------------
declare -A APP_FILE=(
  [llm]=modal_apps/llm.py
  [image]=modal_apps/image.py
  [tts]=modal_apps/tts.py
  [stt]=modal_apps/stt.py
  [music]=modal_apps/music.py
  [sfx]=modal_apps/sfx.py
  [video]=modal_apps/video.py
  [threed]=modal_apps/threed.py
)
DEFAULT_ORDER=(llm image tts stt music sfx video threed)
APPS=(${ONLY:-${DEFAULT_ORDER[@]}})

for app in "${APPS[@]}"; do
  file="${APP_FILE[$app]:-}"
  [[ -n "$file" ]] || { echo "WARN: unknown app '$app', skipping" >&2; continue; }
  echo "==> Deploying $app ($file)"
  "$MODAL_BIN" deploy "${ENV_FLAG[@]}" "$file"
done

if [[ "${SKIP_GATEWAY:-0}" != "1" ]]; then
  echo "==> Deploying gateway (modal_apps/gateway.py)"
  "$MODAL_BIN" deploy "${ENV_FLAG[@]}" modal_apps/gateway.py
fi

echo
echo "==> Deploy complete."
if [[ "${SKIP_SECRETS:-0}" != "1" ]]; then
  echo "    Gateway API key : $MODAL_GENAI_API_KEY"
  echo "    vLLM shared key : $MODAL_GENAI_VLLM_KEY"
  echo "    (save these; re-running regenerates them unless set in .env)"
fi
echo "    NOTE: paste the printed vLLM *.modal.run URLs into config/models.yaml"
echo "    (providers.vllm-*.base_url), then re-run: SKIP_SECRETS=1 ONLY= SKIP_GATEWAY=0 ./deploy-ci.sh"
