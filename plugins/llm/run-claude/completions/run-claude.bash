# bash completion for run-claude.
#
# Install (either works):
#   1. Copy to ${XDG_DATA_HOME:-~/.local/share}/bash-completion/completions/run-claude
#      (done by `make install-completions`; auto-loaded by bash-completion v2).
#   2. Source this file from .bashrc.

__rc_profiles() { run-claude profiles list 2>/dev/null | awk '/^  /{print $1}'; }
__rc_model_defs() { run-claude models list 2>/dev/null | awk '/^  /{print $1}'; }
# NF==1 guard: with the proxy down the command prints a status sentence, not names.
__rc_enabled_models() { run-claude models enabled --names-only 2>/dev/null | awk 'NF==1'; }

_run_claude() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    COMPREPLY=()

    local commands="enter leave janitor set-folder status env proxy watchdog db profiles models keys chat with install secrets"
    local global_flags="-V --version -d --debug -x --enhanced -xx --kitchen-sink -h --help"

    # Flags whose value is the next word.
    case "$prev" in
        --dir)
            COMPREPLY=($(compgen -d -- "$cur"))
            return ;;
        --system|--prompt|--timeout|--interval)
            return ;;
    esac

    # Locate the subcommand (first non-flag word after run-claude).
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

    # Count positional args between the subcommand and the cursor.
    local pos=0
    for ((i = cmd_i + 1; i < COMP_CWORD; i++)); do
        w="${COMP_WORDS[i]}"
        case "$w" in
            --dir|--system|--prompt|--timeout|--interval)
                ((i++)) ;;
            -*) ;;
            *) ((pos++)) ;;
        esac
    done

    local opts=""
    case "$cmd" in
        enter)
            opts="--dir --refresh"
            if [[ "$cur" != -* ]]; then
                # pos 0 = token (no completion), pos 1 = profile
                if ((pos == 1)); then
                    COMPREPLY=($(compgen -W "$(__rc_profiles)" -- "$cur"))
                fi
                return
            fi ;;
        leave)
            return ;;
        janitor)
            opts="-q --quiet -f --force" ;;
        set-folder)
            opts="--dir"
            if [[ "$cur" != -* ]]; then
                ((pos == 0)) && COMPREPLY=($(compgen -W "$(__rc_profiles)" -- "$cur"))
                return
            fi ;;
        status)
            opts="--health" ;;
        env)
            opts="-e --export"
            if [[ "$cur" != -* ]]; then
                ((pos == 0)) && COMPREPLY=($(compgen -W "$(__rc_profiles)" -- "$cur"))
                return
            fi ;;
        proxy)
            if ((pos == 0)) && [[ "$cur" != -* ]]; then
                COMPREPLY=($(compgen -W "start stop restart supervise status health db-test" -- "$cur"))
                return
            fi
            case "${COMP_WORDS[cmd_i+1]}" in
                start|restart) opts="--no-db" ;;
                supervise)     opts="--no-db --interval" ;;
                stop)          opts="--with-db --all" ;;
            esac ;;
        watchdog)
            if ((pos == 0)) && [[ "$cur" != -* ]]; then
                COMPREPLY=($(compgen -W "start stop restart status" -- "$cur"))
                return
            fi
            case "${COMP_WORDS[cmd_i+1]}" in
                start) opts="--interval" ;;
                stop)  opts="--with-proxy" ;;
            esac ;;
        db)
            if ((pos == 0)) && [[ "$cur" != -* ]]; then
                COMPREPLY=($(compgen -W "start stop status migrate" -- "$cur"))
                return
            fi
            case "${COMP_WORDS[cmd_i+1]}" in
                stop) opts="-r --remove" ;;
            esac ;;
        profiles)
            if [[ "$cur" != -* ]]; then
                if ((pos == 0)); then
                    COMPREPLY=($(compgen -W "list show install" -- "$cur"))
                elif ((pos == 1)) && [[ "${COMP_WORDS[cmd_i+1]}" == "show" ]]; then
                    COMPREPLY=($(compgen -W "$(__rc_profiles)" -- "$cur"))
                fi
                return
            fi ;;
        models)
            if [[ "$cur" != -* ]]; then
                if ((pos == 0)); then
                    COMPREPLY=($(compgen -W "list enabled show avail wipe" -- "$cur"))
                elif ((pos == 1)) && [[ "${COMP_WORDS[cmd_i+1]}" == "show" ]]; then
                    COMPREPLY=($(compgen -W "$(__rc_model_defs)" -- "$cur"))
                fi
                return
            fi
            case "${COMP_WORDS[cmd_i+1]}" in
                enabled) opts="--names-only" ;;
                avail)   opts="--json --short" ;;
                wipe)    opts="-f --force" ;;
            esac ;;
        keys)
            if [[ "$cur" != -* ]]; then
                if ((pos == 0)); then
                    COMPREPLY=($(compgen -W "list add delete switch" -- "$cur"))
                fi
                return
            fi
            case "${COMP_WORDS[cmd_i+1]}" in
                add)    opts="--env --from-env --value" ;;
                switch) opts="--using" ;;
            esac ;;
        chat)
            opts="--system --prompt --timeout"
            if [[ "$cur" != -* ]]; then
                ((pos == 0)) && COMPREPLY=($(compgen -W "$(__rc_enabled_models)" -- "$cur"))
                return
            fi ;;
        with)
            opts="--refresh"
            if [[ "$cur" != -* ]]; then
                if ((pos == 0)); then
                    COMPREPLY=($(compgen -W "$(__rc_profiles)" -- "$cur"))
                elif ((pos == 1)); then
                    COMPREPLY=($(compgen -c -- "$cur"))
                else
                    COMPREPLY=($(compgen -f -- "$cur"))
                fi
                return
            fi ;;
        install)
            opts="-f --force" ;;
        secrets)
            if [[ "$cur" != -* ]]; then
                ((pos == 0)) && COMPREPLY=($(compgen -W "init path export" -- "$cur"))
                return
            fi
            case "${COMP_WORDS[cmd_i+1]}" in
                init) opts="-g --generate -f --force" ;;
            esac ;;
    esac

    if [[ "$cur" == -* && -n "$opts" ]]; then
        COMPREPLY=($(compgen -W "$opts" -- "$cur"))
    fi
}

complete -F _run_claude run-claude
