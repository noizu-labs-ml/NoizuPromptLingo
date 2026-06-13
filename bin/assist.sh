#!/usr/bin/env bash
# =============================================================================
# assist.sh — AI-assisted help for k8 devops utilities
#
# Adds --assist "question" support to any utility. When invoked, calls
# Claude Code headlessly with tool context and the user's question.
#
# Integration: add these two lines after sourcing k8-lib modules:
#
#   source "$K8_LIB_DIR/bin/assist.sh"
#   _k8_check_assist "$0" "$@"
#
# For scripts that don't source k8-lib, use the full bootstrap:
#
#   _K8_ASSIST_LIB="${K8_LIB_DIR:-${HOME}/.local/share/k8-lib}/bin/assist.sh"
#   [[ -f "$_K8_ASSIST_LIB" ]] && { source "$_K8_ASSIST_LIB"; _k8_check_assist "$0" "$@"; }
# =============================================================================

_k8_parse_assist_args() {
  K8_ASSIST_QUERY=""
  local prev=""
  for arg in "$@"; do
    if [[ "$prev" == "--assist" ]]; then
      K8_ASSIST_QUERY="$arg"
      return 0
    fi
    if [[ "$arg" == --assist=* ]]; then
      K8_ASSIST_QUERY="${arg#--assist=}"
      return 0
    fi
    prev="$arg"
  done
  return 1
}

_k8_extract_header() {
  local script="$1"
  # Extract contiguous comment block starting at line 2 (skip shebang)
  tail -n +2 "$script" \
    | sed -n '/^#/p; /^[^#]/q' \
    | sed 's/^# \{0,1\}//' \
    | head -60
}

_k8_check_assist() {
  local script="$1"; shift

  _k8_parse_assist_args "$@" || return 0

  if ! command -v claude &>/dev/null; then
    echo "Error: claude CLI not found. Install Claude Code to use --assist." >&2
    echo "  https://docs.anthropic.com/en/docs/claude-code" >&2
    exit 1
  fi

  local tool_name
  tool_name="$(basename "$script")"

  local help_text
  help_text="$(_k8_extract_header "$script")"

  local infra_context=""
  if [[ -n "${INFRA_ROOT:-}" && -f "${INFRA_ROOT}/infra-config.yaml" ]]; then
    infra_context="The infrastructure root is ${INFRA_ROOT}. Configuration is in infra-config.yaml."
  fi

  local prompt
  prompt="$(cat <<PROMPT
You are a concise devops assistant helping a user with the \`${tool_name}\` CLI tool.
This tool is part of a Kubernetes/Helm/Docker devops toolchain installed at ~/.local/bin.
${infra_context}

## Tool Documentation
\`\`\`
${help_text}
\`\`\`

## User's Question
${K8_ASSIST_QUERY}

Answer concisely. If the question is about how to accomplish a specific task,
show the exact command. If vague, explain what the tool does and show common
usage patterns. Keep output under 40 lines unless detail is needed.
PROMPT
)"

  claude -p --bare --model sonnet "$prompt"
  exit 0
}
