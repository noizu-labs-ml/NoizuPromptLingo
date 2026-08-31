# bash completion for llm-toolkit.
#
# Install (either works):
#   1. Copy to ${XDG_DATA_HOME:-~/.local/share}/bash-completion/completions/llm-toolkit
#      (done by `make install-completions`; auto-loaded by bash-completion v2).
#   2. Source this file from .bashrc.

_lt_skill_kinds() { echo "skills agents commands"; }
_lt_skill_kind_filter() { echo "skills agents commands all"; }
_lt_skill_providers() { echo "claude codex grok all"; }
_lt_skill_status() { echo "enabled disabled foreign real broken missing-source"; }
_lt_skill_selection() { echo "active enabled all"; }

_llm_toolkit() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    COMPREPLY=()

    local commands="api web skill --no-zellij recent search list show index serve interactive help"
    local global_flags="-h --help"

    # Flags whose value is the next word (top-level, before/without a subcommand).
    case "$prev" in
        --limit|--period|--since)
            return ;;
    esac

    # Locate the subcommand (first non-flag word after llm-toolkit).
    local cmd="" cmd_i=0 i w
    for ((i = 1; i < COMP_CWORD; i++)); do
        w="${COMP_WORDS[i]}"
        case "$w" in
            -*) continue ;;
            *) cmd="$w"; cmd_i=$i; break ;;
        esac
    done

    if [[ -z "$cmd" ]]; then
        COMPREPLY=($(compgen -W "$commands $global_flags" -- "$cur"))
        return
    fi

    case "$cmd" in
        skill)
            _lt_skill "$cmd_i"
            return ;;
        recent)
            if [[ "$cur" == -* ]]; then
                COMPREPLY=($(compgen -W "--period --since --limit --full --json -h --help" -- "$cur"))
            fi
            return ;;
        search)
            return ;;
        list)
            case "$prev" in
                --project) return ;;
            esac
            if [[ "$cur" == -* ]]; then
                COMPREPLY=($(compgen -W "--project --limit" -- "$cur"))
            fi
            return ;;
        show)
            return ;;
        index|serve|interactive|help|api|web|--no-zellij)
            return ;;
    esac
}

# Nested completion for `llm-toolkit skill ...` (the embedded skill-manage Rust binary).
_lt_skill() {
    local cmd_i="$1"
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    case "$prev" in
        --config|--catalog)
            COMPREPLY=($(compgen -f -- "$cur"))
            return ;;
        --work-type|--tag|--context-window|--frontmatter-limit-bytes)
            return ;;
        --status)
            COMPREPLY=($(compgen -W "$(_lt_skill_status)" -- "$cur"))
            return ;;
        --selection)
            COMPREPLY=($(compgen -W "$(_lt_skill_selection)" -- "$cur"))
            return ;;
        --provider)
            COMPREPLY=($(compgen -W "$(_lt_skill_providers)" -- "$cur"))
            return ;;
    esac

    local sub_commands="list skills agents commands profiles tui enable disable enable-set audit status context catalog work-types path init-config"
    local global_flags="--config --catalog -v --verbose -q --quiet -h --help"

    # Locate the skill-manage subcommand (first non-flag word after `skill`).
    local sub="" sub_i=0 i w
    for ((i = cmd_i + 1; i < COMP_CWORD; i++)); do
        w="${COMP_WORDS[i]}"
        case "$w" in
            -*) continue ;;
            *) sub="$w"; sub_i=$i; break ;;
        esac
    done

    if [[ -z "$sub" ]]; then
        COMPREPLY=($(compgen -W "$sub_commands $global_flags" -- "$cur"))
        return
    fi

    local opts=""
    case "$sub" in
        list)
            opts="--provider --tag --work-type --status"
            if [[ "$cur" != -* && $((COMP_CWORD - sub_i)) -eq 1 ]]; then
                COMPREPLY=($(compgen -W "$(_lt_skill_kind_filter)" -- "$cur"))
                return
            fi ;;
        skills|agents|commands|profiles)
            opts="-i --interactive --provider" ;;
        tui)
            opts="--provider"
            if [[ "$cur" != -* && $((COMP_CWORD - sub_i)) -eq 1 ]]; then
                COMPREPLY=($(compgen -W "skills agents commands profiles" -- "$cur"))
                return
            fi ;;
        enable)
            opts="--all --provider --replace --dry-run"
            if [[ "$cur" != -* && $((COMP_CWORD - sub_i)) -eq 1 ]]; then
                COMPREPLY=($(compgen -W "$(_lt_skill_kinds)" -- "$cur"))
                return
            fi ;;
        disable)
            opts="--all --provider --dry-run"
            if [[ "$cur" != -* && $((COMP_CWORD - sub_i)) -eq 1 ]]; then
                COMPREPLY=($(compgen -W "$(_lt_skill_kinds)" -- "$cur"))
                return
            fi ;;
        enable-set)
            opts="--work-type --provider --replace --dry-run" ;;
        audit)
            opts="--provider --strict --json"
            if [[ "$cur" != -* && $((COMP_CWORD - sub_i)) -eq 1 ]]; then
                COMPREPLY=($(compgen -W "$(_lt_skill_kind_filter)" -- "$cur"))
                return
            fi ;;
        status)
            return ;;
        context)
            opts="--provider --selection --context-window --frontmatter-limit-bytes --json"
            if [[ "$cur" != -* && $((COMP_CWORD - sub_i)) -eq 1 ]]; then
                COMPREPLY=($(compgen -W "$(_lt_skill_kind_filter)" -- "$cur"))
                return
            fi ;;
        catalog)
            if [[ "$cur" != -* && $((COMP_CWORD - sub_i)) -eq 1 ]]; then
                COMPREPLY=($(compgen -W "init show validate edit-path" -- "$cur"))
                return
            fi
            case "${COMP_WORDS[sub_i+1]}" in
                init) opts="--force" ;;
            esac ;;
        work-types)
            if [[ "$cur" != -* && $((COMP_CWORD - sub_i)) -eq 1 ]]; then
                COMPREPLY=($(compgen -W "list show" -- "$cur"))
                return
            fi ;;
        path)
            if [[ "$cur" != -* && $((COMP_CWORD - sub_i)) -eq 1 ]]; then
                COMPREPLY=($(compgen -W "$(_lt_skill_kinds)" -- "$cur"))
                return
            fi ;;
        init-config)
            opts="--force" ;;
    esac

    if [[ "$cur" == -* && -n "$opts" ]]; then
        COMPREPLY=($(compgen -W "$opts $global_flags" -- "$cur"))
    fi
}

complete -F _llm_toolkit llm-toolkit
