# Claude Switch Prompt Hook for Bash
# Source this file in your .bashrc after direnv hook
#
# Add to ~/.bashrc:
#   eval "$(direnv hook bash)"
#   source /path/to/run-claude/hooks/bash_hook.sh

_AGENT_SHIM_LAST_TOKEN=""

_agent_shim_hook() {
    local current_token="${AGENT_SHIM_TOKEN:-}"

    if [[ "$current_token" != "$_AGENT_SHIM_LAST_TOKEN" ]]; then
        # Token changed
        if [[ -n "$_AGENT_SHIM_LAST_TOKEN" ]]; then
            # Left a shimmed directory
            run-claude leave "$_AGENT_SHIM_LAST_TOKEN" 2>/dev/null || true
        fi

        if [[ -n "$current_token" && -n "${AGENT_SHIM_PROFILE:-}" ]]; then
            # Entered a shimmed directory
            run-claude enter "$current_token" "$AGENT_SHIM_PROFILE" 2>/dev/null || true
        fi

        _AGENT_SHIM_LAST_TOKEN="$current_token"
    fi

    # Opportunistic janitor (rate-limited internally)
    run-claude janitor --quiet 2>/dev/null || true
}

# Append to PROMPT_COMMAND
if [[ -z "$_AGENT_SHIM_HOOK_INSTALLED" ]]; then
    export _AGENT_SHIM_HOOK_INSTALLED=1
    PROMPT_COMMAND="_agent_shim_hook${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
fi
