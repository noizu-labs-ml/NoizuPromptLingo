# Claude Switch Prompt Hook for Zsh
# Source this file in your .zshrc after direnv hook
#
# Add to ~/.zshrc:
#   eval "$(direnv hook zsh)"
#   source /path/to/run-claude/hooks/zsh_hook.zsh

typeset -g _AGENT_SHIM_LAST_TOKEN=""

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

# Register with zsh precmd hooks
if (( ! ${+_AGENT_SHIM_HOOK_INSTALLED} )); then
    typeset -g _AGENT_SHIM_HOOK_INSTALLED=1
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd _agent_shim_hook
fi
