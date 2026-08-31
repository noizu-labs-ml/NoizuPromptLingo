#!/usr/bin/env bash
#
# Install run-claude shell hooks
#
# Usage:
#   ./install.sh [--bash] [--zsh] [--both]
#
# By default, detects current shell and installs appropriate hook.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_SWITCH_DIR="$(dirname "$SCRIPT_DIR")"

install_bash() {
    local rc_file="${HOME}/.bashrc"
    local hook_line="source \"${SCRIPT_DIR}/bash_hook.sh\""
    local marker="# >>> run-claude hook"

    if grep -q "$marker" "$rc_file" 2>/dev/null; then
        echo "Bash hook already installed in $rc_file"
        return 0
    fi

    echo "" >> "$rc_file"
    echo "$marker" >> "$rc_file"
    echo "$hook_line" >> "$rc_file"
    echo "# <<< run-claude hook" >> "$rc_file"

    echo "Installed bash hook to $rc_file"
    echo "Restart your shell or run: source $rc_file"
}

install_zsh() {
    local rc_file="${HOME}/.zshrc"
    local hook_line="source \"${SCRIPT_DIR}/zsh_hook.zsh\""
    local marker="# >>> run-claude hook"

    if grep -q "$marker" "$rc_file" 2>/dev/null; then
        echo "Zsh hook already installed in $rc_file"
        return 0
    fi

    echo "" >> "$rc_file"
    echo "$marker" >> "$rc_file"
    echo "$hook_line" >> "$rc_file"
    echo "# <<< run-claude hook" >> "$rc_file"

    echo "Installed zsh hook to $rc_file"
    echo "Restart your shell or run: source $rc_file"
}

add_to_path() {
    local shell="$1"
    local rc_file
    local path_line="export PATH=\"${CLAUDE_SWITCH_DIR}:\$PATH\""
    local marker="# >>> run-claude path"

    if [[ "$shell" == "bash" ]]; then
        rc_file="${HOME}/.bashrc"
    else
        rc_file="${HOME}/.zshrc"
    fi

    if grep -q "$marker" "$rc_file" 2>/dev/null; then
        return 0
    fi

    echo "" >> "$rc_file"
    echo "$marker" >> "$rc_file"
    echo "$path_line" >> "$rc_file"
    echo "# <<< run-claude path" >> "$rc_file"

    echo "Added run-claude to PATH in $rc_file"
}

main() {
    local install_bash_flag=false
    local install_zsh_flag=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --bash)
                install_bash_flag=true
                shift
                ;;
            --zsh)
                install_zsh_flag=true
                shift
                ;;
            --both)
                install_bash_flag=true
                install_zsh_flag=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                echo "Usage: $0 [--bash] [--zsh] [--both]"
                exit 1
                ;;
        esac
    done

    # Auto-detect if no flags specified
    if ! $install_bash_flag && ! $install_zsh_flag; then
        case "$SHELL" in
            */bash)
                install_bash_flag=true
                ;;
            */zsh)
                install_zsh_flag=true
                ;;
            *)
                echo "Could not detect shell. Use --bash or --zsh"
                exit 1
                ;;
        esac
    fi

    # Install hooks
    if $install_bash_flag; then
        add_to_path bash
        install_bash
    fi

    if $install_zsh_flag; then
        add_to_path zsh
        install_zsh
    fi

    echo ""
    echo "Installation complete!"
    echo ""
    echo "Make sure you have direnv installed and its hook loaded BEFORE the run-claude hook."
    echo "Example for bash:"
    echo "  eval \"\$(direnv hook bash)\""
    echo "  source \"${SCRIPT_DIR}/bash_hook.sh\""
}

main "$@"
