#!/bin/bash
# shell/tabbing.bash — Bash-specific tabbing-on command definitions (thin adapter)
#
# Sources ONLY lib/render.sh for minimal namespace footprint.
# Heavy operations (history, recording, todo, session) are delegated
# to bin/ scripts running in subprocesses.
#
# Init: eval "$(tabbing-init bash)" in your .bashrc

# ---------------------------------------------------------------------------
# Locate root and source minimal render pipeline
# ---------------------------------------------------------------------------
if [ -n "${TABBING_ROOT:-}" ]; then
  _tabbing_root="$TABBING_ROOT"
else
  _tabbing_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  if [ ! -f "$_tabbing_root/lib/render.sh" ]; then
    _tabbing_root="${XDG_DATA_HOME:-$HOME/.local/share}/tabbing-on"
  fi
fi

source "${_tabbing_root}/lib/render.sh"
source "${_tabbing_root}/lib/dc.sh"

# Capture the interactive shell's TTY early so the dc daemon can use it
if [[ -z "${TABBING_TTY:-}" ]]; then
  TABBING_TTY="$(tty 2>/dev/null)" || TABBING_TTY="/dev/tty"
  export TABBING_TTY
fi

# dc state and daemon are deferred until tabbing-on is explicitly called

# ---------------------------------------------------------------------------
# Inline: detect terminal emulator (runs once at init)
# ---------------------------------------------------------------------------
if [ -n "${ITERM_SESSION_ID:-}" ]; then
  TAB_TERMINAL="iterm2"
elif [ -n "${GHOSTTY_RESOURCES_DIR:-}" ]; then
  TAB_TERMINAL="ghostty"
elif [ -n "${KITTY_WINDOW_ID:-}" ]; then
  TAB_TERMINAL="kitty"
elif [ "${TERM_PROGRAM:-}" = "WezTerm" ]; then
  TAB_TERMINAL="wezterm"
elif [ "${TERM_PROGRAM:-}" = "Apple_Terminal" ]; then
  TAB_TERMINAL="apple-terminal"
elif [ -n "${WT_SESSION:-}" ]; then
  TAB_TERMINAL="windows-terminal"
elif [ "${TERM_PROGRAM:-}" = "Alacritty" ] || [ "${TERM:-}" = "alacritty" ]; then
  TAB_TERMINAL="alacritty"
elif [ -n "${KONSOLE_VERSION:-}" ]; then
  TAB_TERMINAL="konsole"
elif [ -n "${GNOME_TERMINAL_SCREEN:-}" ]; then
  TAB_TERMINAL="gnome-terminal"
elif [ -n "${TMUX:-}" ]; then
  TAB_TERMINAL="tmux"
elif [ "${TERM:-}" = "xterm" ] || [ "${TERM:-}" = "xterm-256color" ]; then
  TAB_TERMINAL="xterm"
else
  TAB_TERMINAL="unknown"
fi
export TAB_TERMINAL

# ---------------------------------------------------------------------------
# Inline: generate session fingerprint (runs once at init)
# ---------------------------------------------------------------------------
if [ -z "${TAB_SESSION:-}" ]; then
  if [ -r /dev/urandom ]; then
    TAB_SESSION="$(od -An -tx1 -N4 /dev/urandom 2>/dev/null | tr -d ' \n')"
  fi
  if [ -z "${TAB_SESSION:-}" ]; then
    TAB_SESSION="$(printf '%04x%04x' $$ "$(date +%s)" | cut -c1-8)"
  fi
  export TAB_SESSION
fi

# ---------------------------------------------------------------------------
# Inline: generate dc UUID once per terminal session
# Scopes dc keys to this tab/pane so daemons don't cross-read state from
# other tabs. Regenerated in new Zellij panes (ZELLIJ_PANE_ID changes)
# to avoid cloned UUIDs from pane splits.
# ---------------------------------------------------------------------------
if _tabbing_dc_enabled; then
  _tabbing_need_uuid=0
  if [ -z "${TABBING_DC_UUID:-}" ]; then
    _tabbing_need_uuid=1
  elif [ -n "${ZELLIJ_PANE_ID:-}" ] && [ "${_TABBING_DC_ZELLIJ_PANE:-}" != "${ZELLIJ_PANE_ID}" ]; then
    _tabbing_need_uuid=1
  fi
  if [ "$_tabbing_need_uuid" -eq 1 ]; then
    _tabbing_dc_gen_uuid
    _TABBING_DC_ZELLIJ_PANE="${ZELLIJ_PANE_ID:-}"
  fi
  unset _tabbing_need_uuid
fi

# Known color names for -color shorthand matching (bash array)
_tabbing_known_colors=(
  black red green yellow blue magenta cyan white
  bright-black bright-red bright-green bright-yellow
  bright-blue bright-magenta bright-cyan bright-white
  bold dim italic underline blink inverse strikethrough
)

# ---------------------------------------------------------------------------
# Internal: commit side effects (history, display, session save)
# Uses full libs if available (bin/ context), else delegates to subprocess
# ---------------------------------------------------------------------------
_tabbing_commit() {
  if [ -n "${_TABBING_FULL_LIBS:-}" ]; then
    _tabbing_record_event "${1:-status}"
    _tabbing_display
    _tabbing_session_save
  else
    "_tabbing-commit" "${1:-status}"
  fi
}

# ---------------------------------------------------------------------------
# tabbing-on [flags in any position] [title] [status]
# ---------------------------------------------------------------------------
tabbing-on() {
  _tabbing_dc_ensure_daemon

  local opt_highlight="" opt_urgency="" opt_emoji="" opt_bg="" opt_theme=""
  local has_highlight=0 has_urgency=0 has_emoji=0 has_bg=0 has_theme=0
  local has_record=0 has_continue=0 has_stop_recording=0
  local no_emoji=0 no_bg=0 no_theme=0 has_marquee=0 no_marquee=0
  local has_claude=0 has_run_with=0
  local claude_args=() run_with_args=()
  local positional=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --highlight=*) opt_highlight="${1#--highlight=}"; has_highlight=1; shift ;;
      --highlight)   opt_highlight="$2"; has_highlight=1; shift 2 ;;
      --color=*)     opt_highlight="${1#--color=}"; has_highlight=1; shift ;;
      --color)       opt_highlight="$2"; has_highlight=1; shift 2 ;;
      -h)            opt_highlight="$2"; has_highlight=1; shift 2 ;;

      --urgency=*)   opt_urgency="${1#--urgency=}"; has_urgency=1; shift ;;
      --urgency)     opt_urgency="$2"; has_urgency=1; shift 2 ;;
      --pri=*)       opt_urgency="${1#--pri=}"; has_urgency=1; shift ;;
      --pri)         opt_urgency="$2"; has_urgency=1; shift 2 ;;
      -p)            opt_urgency="$2"; has_urgency=1; shift 2 ;;
      -pri[0-5])     opt_urgency="${1#-pri}"; has_urgency=1; shift ;;

      --emoji=*)     opt_emoji="${1#--emoji=}"; has_emoji=1; shift ;;
      --emoji)       opt_emoji="$2"; has_emoji=1; shift 2 ;;
      -e)            opt_emoji="$2"; has_emoji=1; shift 2 ;;
      --no-emoji)    no_emoji=1; shift ;;

      --bg=*)        opt_bg="${1#--bg=}"; has_bg=1; shift ;;
      --bg)          opt_bg="$2"; has_bg=1; shift 2 ;;
      --no-bg)       no_bg=1; shift ;;

      --theme=*)     opt_theme="${1#--theme=}"; has_theme=1; shift ;;
      --theme)       opt_theme="$2"; has_theme=1; shift 2 ;;
      --no-theme)    no_theme=1; shift ;;
      --theme-list|--themes)
        _tabbing_theme_list; return ;;
      --color-list|--colors)
        if [ -n "${_TABBING_FULL_LIBS:-}" ]; then _tabbing_color_list
        else command tabbing-on colors; fi
        return ;;

      -m|--marquee)    has_marquee=1; shift ;;
      --no-marquee)    no_marquee=1; shift ;;

      # Emoji search: -emoji:FILTER or --emoji-search=FILTER
      -emoji:*|--emoji-search=*)
        local _efilter="${1#*[=:]}"
        if [ -n "${_TABBING_FULL_LIBS:-}" ]; then _tabbing_emoji_search "$_efilter" | _tabbing_pager
        else command tabbing-on --emoji-search="$_efilter"; fi
        return ;;
      --emoji-search)
        if [ -n "${_TABBING_FULL_LIBS:-}" ]; then _tabbing_emoji_search "$2"
        else command tabbing-on --emoji-search="$2"; fi
        return ;;

      # Subcommands: use full libs if available, else delegate to bin/
      --emoji-list|--emojis|-emojis)
        if [ -n "${_TABBING_FULL_LIBS:-}" ]; then _tabbing_emoji_list | _tabbing_pager
        else command tabbing-on --emoji-list; fi
        return ;;
      --version) _tabbing_print_version; return ;;
      --help)
        if [ -n "${_TABBING_FULL_LIBS:-}" ]; then _tabbing_help
        else command tabbing-on --help; fi
        return ;;
      --terminal-info)
        if [ -n "${_TABBING_FULL_LIBS:-}" ]; then _tabbing_terminal_info
        else command tabbing-on --terminal-info; fi
        return ;;

      --claude)  has_claude=1; shift; claude_args=("$@"); break ;;
      --run-with) has_run_with=1; shift; run_with_args=("$@"); break ;;

      --record)         has_record=1; shift ;;
      --continue)       has_continue=1; shift ;;
      --stop-recording) has_stop_recording=1; shift ;;

      # -COLOR or -EMOJI shorthand (e.g. -blue, -rocket)
      -[a-z]*)
        local maybe="${1#-}"
        if [[ "$maybe" =~ ^pri[0-5]$ ]]; then
          opt_urgency="${maybe#pri}"; has_urgency=1; shift
        else
          local found=0
          for c in "${_tabbing_known_colors[@]}"; do
            if [[ "$maybe" == "$c" ]]; then
              opt_highlight="$maybe"; has_highlight=1; found=1
              break
            fi
          done
          if [[ $found -eq 0 ]]; then
            if _tabbing_is_known_emoji "$maybe"; then
              opt_emoji="$maybe"; has_emoji=1; found=1
            fi
          fi
          if [[ $found -eq 1 ]]; then
            shift
          else
            case "$maybe" in
              emoji|emjois|emojsi|emojs|emojies|emoj|eomjis|emjis|emois|emoij|emojii|emoijis|emojss|ejmois)
                printf 'tabbing: did you mean "-emojis"? [y/N] '
                local answer; read -r answer
                case "$answer" in
                  [yY]|[yY][eE][sS])
                    if [ -n "${_TABBING_FULL_LIBS:-}" ]; then _tabbing_emoji_list | _tabbing_pager
                    else command tabbing-on --emoji-list; fi
                    return ;;
                esac ;;
            esac
            _tabbing_out -v 0 -e 'tabbing: unknown option: %s\n' "$1"; return 1
          fi
        fi
        ;;

      -*)  _tabbing_out -v 0 -e 'tabbing: unknown option: %s\n' "$1"; return 1 ;;
      *) positional+=("$1"); shift ;;
    esac
  done

  # No args at all — display current state
  if [[ ${#positional[@]} -eq 0 && $has_highlight -eq 0 && $has_urgency -eq 0 && $has_emoji -eq 0 && $no_emoji -eq 0 && $has_bg -eq 0 && $no_bg -eq 0 && $has_theme -eq 0 && $no_theme -eq 0 && $has_marquee -eq 0 && $no_marquee -eq 0 && $has_record -eq 0 && $has_continue -eq 0 && $has_stop_recording -eq 0 ]]; then
    _tabbing_display
    return
  fi

  # Subcommands: "tabbing-on emojis", "tabbing-on help", "tabbing-on colors"
  if [[ ${#positional[@]} -eq 1 ]]; then
    case "${positional[0]}" in
      emojis|emoji-list)
        if [ -n "${_TABBING_FULL_LIBS:-}" ]; then _tabbing_emoji_list | _tabbing_pager
        else command tabbing-on --emoji-list; fi
        return ;;
      colors|color-list)
        if [ -n "${_TABBING_FULL_LIBS:-}" ]; then _tabbing_color_list
        else command tabbing-on colors; fi
        return ;;
      themes|theme-list)
        _tabbing_theme_list; return ;;
      help)
        if [ -n "${_TABBING_FULL_LIBS:-}" ]; then _tabbing_help
        else command tabbing-on --help; fi
        return ;;
      emoji|emjois|emojsi|emojs|emojies|emoj|eomjis|emjis|emois|emoij|emojii|emoijis|emojss|ejmois)
        printf 'tabbing: did you mean "emojis"? [y/N] '
        local answer
        read -r answer
        case "$answer" in
          [yY]|[yY][eE][sS])
            if [ -n "${_TABBING_FULL_LIBS:-}" ]; then _tabbing_emoji_list | _tabbing_pager
            else command tabbing-on --emoji-list; fi
            return ;;
        esac
        ;;
    esac
  fi

  # Validate and apply flags
  if [[ $has_highlight -eq 1 ]]; then
    if ! _tabbing_color_code "$opt_highlight" >/dev/null 2>&1; then
      _tabbing_color_code "$opt_highlight"
      return 1
    fi
    _tabbing_set highlight "$opt_highlight"
  fi

  if [[ $has_urgency -eq 1 ]]; then
    if [[ ! "$opt_urgency" =~ ^[0-5]$ ]]; then
      _tabbing_out -v 0 -e 'tabbing: urgency must be 0-5 (0=critical, 5=nominal)\n'
      return 1
    fi
    _tabbing_set urgency "$opt_urgency"
  fi

  if [[ $has_emoji -eq 1 ]]; then
    if ! _tabbing_emoji_lookup "$opt_emoji" >/dev/null 2>&1; then
      _tabbing_emoji_lookup "$opt_emoji"
      return 1
    fi
    _tabbing_set emoji "$opt_emoji"
  fi

  if [[ $no_emoji -eq 1 ]]; then
    _tabbing_set emoji ""
  fi

  if [[ $has_bg -eq 1 ]]; then
    if ! _tabbing_color_to_hex "$opt_bg" >/dev/null 2>&1; then
      _tabbing_color_to_hex "$opt_bg"
      return 1
    fi
    export TAB_BG="$opt_bg"
  fi
  if [[ $no_bg -eq 1 ]]; then
    _tabbing_clear_bg_color
    unset TAB_BG
  fi

  if [[ $has_theme -eq 1 ]]; then
    if ! _tabbing_apply_named_theme "$opt_theme" 2>/dev/null; then
      echo "tabbing: unknown theme '$opt_theme'" >&2
      _tabbing_theme_list >&2
      return 1
    fi
    _tabbing_set theme "$opt_theme"
  fi
  if [[ $no_theme -eq 1 ]]; then
    _tabbing_clear_theme
    _tabbing_set theme ""
  fi

  if [[ $has_marquee -eq 1 ]]; then
    export TAB_MARQUEE=1
  fi
  if [[ $no_marquee -eq 1 ]]; then
    unset TAB_MARQUEE
    _tabbing_marquee_kill
  fi

  # Positional args: bash arrays are 0-based
  if [[ ${#positional[@]} -ge 1 ]]; then
    _tabbing_set title "${positional[0]}"
    if [[ ${#positional[@]} -ge 2 ]]; then
      _tabbing_set status "${positional[1]}"
    else
      _tabbing_set status ""
    fi
  fi

  # Style-only invocation (no title given, no existing title) — nudge toward tabbing-style
  if [[ ${#positional[@]} -eq 0 && -z "${TAB_TITLE:-}" ]]; then
    if [[ $has_highlight -eq 1 || $has_urgency -eq 1 || $has_emoji -eq 1 || $has_bg -eq 1 || $has_theme -eq 1 || $has_marquee -eq 1 || $no_emoji -eq 1 || $no_bg -eq 1 || $no_theme -eq 1 || $no_marquee -eq 1 ]]; then
      echo "tabbing: hint: it is better to use tabbing-style to set these items." >&2
    fi
  fi

  # Inline: ensure TAB_ID exists
  if [[ -z "${TAB_ID:-}" ]]; then
    if [[ -r /dev/urandom ]]; then
      TAB_ID="$(od -An -tx1 -N4 /dev/urandom 2>/dev/null | tr -d ' \n')"
    fi
    [[ -z "${TAB_ID:-}" ]] && TAB_ID="$(printf '%04x%04x' $$ "$(date +%s)" | cut -c1-8)"
    export TAB_ID
  fi

  # Render immediately (from render.sh)
  if [[ -n "$TAB_TITLE" ]]; then
    _tabbing_render
    _tabbing_apply_urgency_color
    _tabbing_apply_bg_color
    _tabbing_marquee_render
  fi

  # Commit side effects (history + display + session save)
  _tabbing_commit "title"

  # Handle recording flags (on-demand source)
  if [[ $has_record -eq 1 || $has_continue -eq 1 || $has_stop_recording -eq 1 ]]; then
    if [ -z "${_TABBING_FULL_LIBS:-}" ]; then
      . "$_tabbing_root/lib/core.sh"
      . "$_tabbing_root/lib/history.sh"
      . "$_tabbing_root/lib/recording.sh"
      . "$_tabbing_root/lib/session.sh"
    fi
    _tabbing_handle_recording "$has_record" "$has_continue" "$has_stop_recording"
    _tabbing_session_save
  fi

  # Handle --claude: start pipe bridge to Claude Code status line
  if [[ $has_claude -eq 1 ]]; then
    . "$_tabbing_root/lib/claude.sh"
    _tabbing_claude_start_bridge "${claude_args[@]}"
  fi

  # Handle --run-with: start pipe bridge with a custom consumer command
  if [[ $has_run_with -eq 1 ]]; then
    . "$_tabbing_root/lib/claude.sh"
    _tabbing_run_with_start "${run_with_args[@]}"
  fi
}

# ---------------------------------------------------------------------------
# tabbing-status [flags] "text"
# ---------------------------------------------------------------------------
tabbing-status() {
  local opt_urgency="" opt_emoji="" opt_bg="" opt_theme=""
  local has_urgency=0 has_emoji=0 no_emoji=0 has_bg=0 no_bg=0 has_theme=0 no_theme=0
  local has_marquee=0 no_marquee=0
  local has_record=0 has_continue=0 has_stop_recording=0
  local positional=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --urgency=*) opt_urgency="${1#--urgency=}"; has_urgency=1; shift ;;
      --urgency)   opt_urgency="$2";              has_urgency=1; shift 2 ;;
      --pri=*)     opt_urgency="${1#--pri=}";      has_urgency=1; shift ;;
      --pri)       opt_urgency="$2";               has_urgency=1; shift 2 ;;
      -p)          opt_urgency="$2";               has_urgency=1; shift 2 ;;
      -pri[0-5])   opt_urgency="${1#-pri}";        has_urgency=1; shift ;;

      --emoji=*)   opt_emoji="${1#--emoji=}"; has_emoji=1; shift ;;
      --emoji)     opt_emoji="$2";            has_emoji=1; shift 2 ;;
      -e)          opt_emoji="$2";            has_emoji=1; shift 2 ;;
      --no-emoji)  no_emoji=1; shift ;;

      --bg=*)      opt_bg="${1#--bg=}"; has_bg=1; shift ;;
      --bg)        opt_bg="$2"; has_bg=1; shift 2 ;;
      --no-bg)     no_bg=1; shift ;;

      --theme=*)   opt_theme="${1#--theme=}"; has_theme=1; shift ;;
      --theme)     opt_theme="$2"; has_theme=1; shift 2 ;;
      --no-theme)  no_theme=1; shift ;;

      -m|--marquee)    has_marquee=1; shift ;;
      --no-marquee)    no_marquee=1; shift ;;

      --record)         has_record=1; shift ;;
      --continue)       has_continue=1; shift ;;
      --stop-recording) has_stop_recording=1; shift ;;

      # -EMOJI shorthand
      -[a-z]*)
        local maybe="${1#-}"
        if [[ "$maybe" =~ ^pri[0-5]$ ]]; then
          opt_urgency="${maybe#pri}"; has_urgency=1; shift
        elif _tabbing_is_known_emoji "$maybe"; then
          opt_emoji="$maybe"; has_emoji=1; shift
        else
          _tabbing_out -v 0 -e 'tabbing: unknown option: %s\n' "$1"; return 1
        fi
        ;;

      -*)  _tabbing_out -v 0 -e 'tabbing: unknown option: %s\n' "$1"; return 1 ;;
      *)           positional+=("$1"); shift ;;
    esac
  done

  if [[ -z "$TAB_TITLE" ]]; then
    _tabbing_out -v 0 -e 'tabbing-status: no TAB_TITLE set — call tabbing-on first\n'
    return 1
  fi

  if [[ $has_urgency -eq 1 ]]; then
    if [[ ! "$opt_urgency" =~ ^[0-5]$ ]]; then
      _tabbing_out -v 0 -e 'tabbing: urgency must be 0-5 (0=critical, 5=nominal)\n'
      return 1
    fi
    _tabbing_set urgency "$opt_urgency"
  fi

  if [[ $has_emoji -eq 1 ]]; then
    if ! _tabbing_emoji_lookup "$opt_emoji" >/dev/null 2>&1; then
      _tabbing_emoji_lookup "$opt_emoji"
      return 1
    fi
    _tabbing_set emoji "$opt_emoji"
  fi

  if [[ $no_emoji -eq 1 ]]; then
    _tabbing_set emoji ""
  fi

  if [[ $has_bg -eq 1 ]]; then
    if ! _tabbing_color_to_hex "$opt_bg" >/dev/null 2>&1; then
      _tabbing_color_to_hex "$opt_bg"
      return 1
    fi
    export TAB_BG="$opt_bg"
  fi
  if [[ $no_bg -eq 1 ]]; then
    _tabbing_clear_bg_color
    unset TAB_BG
  fi

  if [[ $has_theme -eq 1 ]]; then
    if ! _tabbing_apply_named_theme "$opt_theme" 2>/dev/null; then
      echo "tabbing: unknown theme '$opt_theme'" >&2
      _tabbing_theme_list >&2
      return 1
    fi
    _tabbing_set theme "$opt_theme"
  fi
  if [[ $no_theme -eq 1 ]]; then
    _tabbing_clear_theme
    _tabbing_set theme ""
  fi

  if [[ $has_marquee -eq 1 ]]; then
    export TAB_MARQUEE=1
  fi
  if [[ $no_marquee -eq 1 ]]; then
    unset TAB_MARQUEE
    _tabbing_marquee_kill
  fi

  # Bash: 0-based arrays
  if [[ ${#positional[@]} -ge 1 ]]; then
    _tabbing_set status "${positional[0]}"
  fi

  _tabbing_render
  _tabbing_apply_urgency_color
  _tabbing_apply_bg_color
  _tabbing_marquee_render

  # Commit side effects
  _tabbing_commit "status"

  # Handle recording (on-demand source)
  if [[ $has_record -eq 1 || $has_continue -eq 1 || $has_stop_recording -eq 1 ]]; then
    if [ -z "${_TABBING_FULL_LIBS:-}" ]; then
      . "$_tabbing_root/lib/core.sh"
      . "$_tabbing_root/lib/history.sh"
      . "$_tabbing_root/lib/recording.sh"
      . "$_tabbing_root/lib/session.sh"
    fi
    _tabbing_handle_recording "$has_record" "$has_continue" "$has_stop_recording"
    _tabbing_session_save
  fi
}

# ---------------------------------------------------------------------------
# tabbing-todo — delegates to bin/ script
# Interactive switch handled inline (needs TTY + env var setting)
# ---------------------------------------------------------------------------
tabbing-todo() {
  local _root="${TABBING_ROOT:-$_tabbing_root}"

  # Quick check: --switch/-n needs inline handling for env var setting
  local has_switch=0
  local has_record=0 has_continue=0 has_stop_recording=0
  local orig_args=("$@")

  for arg in "$@"; do
    case "$arg" in
      -n|--switch|--pick) has_switch=1 ;;
      --record)           has_record=1 ;;
      --continue)         has_continue=1 ;;
      --stop-recording)   has_stop_recording=1 ;;
    esac
  done

  if [[ $has_switch -eq 1 ]]; then
    if [[ -z "$TAB_TITLE" ]]; then
      _tabbing_out -v 0 -e 'tabbing-todo: no TAB_TITLE set — call tabbing-on first\n'
      return 1
    fi

    # Get pending list from bin/ script
    local pending
    pending="$("$_root/bin/tabbing-todo" --list-pending)"
    if [[ -z "$pending" ]]; then
      _tabbing_out -v 0 -e 'tabbing: no pending todos to switch to\n'
      return 1
    fi

    echo "Pending todos:"
    local ids=() titles=()
    while IFS=' ' read -r id title; do
      ids+=("$id")
      titles+=("$title")
      printf '  %s) %s\n' "$id" "$title"
    done <<< "$pending"

    printf '\nSwitch to todo #: '
    local choice
    read -r choice

    local valid=0
    for id in "${ids[@]}"; do
      if [[ "$choice" == "$id" ]]; then
        valid=1; break
      fi
    done

    if [[ $valid -eq 0 ]]; then
      _tabbing_out -v 0 -e 'tabbing: invalid choice\n'
      return 1
    fi

    # Get export statements from bin/ script and eval them
    local _exports
    _exports="$("$_root/bin/tabbing-todo" --export-switch "$choice")"
    if [[ -n "$_exports" ]]; then
      eval "$_exports"
      _tabbing_render
      _tabbing_apply_urgency_color
    fi

    # Handle recording if requested
    if [[ $has_record -eq 1 || $has_continue -eq 1 || $has_stop_recording -eq 1 ]]; then
      if [ -z "${_TABBING_FULL_LIBS:-}" ]; then
        . "$_tabbing_root/lib/core.sh"
        . "$_tabbing_root/lib/history.sh"
        . "$_tabbing_root/lib/recording.sh"
        . "$_tabbing_root/lib/session.sh"
      fi
      _tabbing_handle_recording "$has_record" "$has_continue" "$has_stop_recording"
      _tabbing_session_save
    fi
    return
  fi

  # All other todo operations delegate entirely to bin/ script
  "$_root/bin/tabbing-todo" "${orig_args[@]}"
}

# ---------------------------------------------------------------------------
# Read-only commands — pure delegation to bin/ scripts
# ---------------------------------------------------------------------------
tabbing-report() {
  command tabbing-report "$@"
}

tabbing-history() {
  command tabbing-history "$@"
}

tabbing-recordings() {
  command tabbing-recordings "$@"
}

tabbing-clear() {
  command tabbing-clear "$@"
}

tabbing-info() {
  command tabbing-info "$@"
}

tabbing-doctor() {
  command tabbing-doctor "$@"
}

tabbing-theme() {
  command tabbing-theme "$@"
}

# ---------------------------------------------------------------------------
# tabbing-style — Adjust tab appearance without changing title/status
# Dedicated command for setting theme, bg, color, emoji, urgency, marquee.
# Requires tabbing-on to have been called first.
# ---------------------------------------------------------------------------
tabbing-style() {
  local opt_highlight="" opt_urgency="" opt_emoji="" opt_bg="" opt_theme=""
  local has_highlight=0 has_urgency=0 has_emoji=0 has_bg=0 has_theme=0
  local no_emoji=0 no_bg=0 no_theme=0 has_marquee=0 no_marquee=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --highlight=*) opt_highlight="${1#--highlight=}"; has_highlight=1; shift ;;
      --highlight)   opt_highlight="$2"; has_highlight=1; shift 2 ;;
      --color=*)     opt_highlight="${1#--color=}"; has_highlight=1; shift ;;
      --color)       opt_highlight="$2"; has_highlight=1; shift 2 ;;
      -h)            opt_highlight="$2"; has_highlight=1; shift 2 ;;

      --urgency=*)   opt_urgency="${1#--urgency=}"; has_urgency=1; shift ;;
      --urgency)     opt_urgency="$2"; has_urgency=1; shift 2 ;;
      --pri=*)       opt_urgency="${1#--pri=}"; has_urgency=1; shift ;;
      --pri)         opt_urgency="$2"; has_urgency=1; shift 2 ;;
      -p)            opt_urgency="$2"; has_urgency=1; shift 2 ;;
      -pri[0-5])     opt_urgency="${1#-pri}"; has_urgency=1; shift ;;

      --emoji=*)     opt_emoji="${1#--emoji=}"; has_emoji=1; shift ;;
      --emoji)       opt_emoji="$2"; has_emoji=1; shift 2 ;;
      -e)            opt_emoji="$2"; has_emoji=1; shift 2 ;;
      --no-emoji)    no_emoji=1; shift ;;

      --bg=*)        opt_bg="${1#--bg=}"; has_bg=1; shift ;;
      --bg)          opt_bg="$2"; has_bg=1; shift 2 ;;
      --no-bg)       no_bg=1; shift ;;

      --theme=*)     opt_theme="${1#--theme=}"; has_theme=1; shift ;;
      --theme)       opt_theme="$2"; has_theme=1; shift 2 ;;
      --no-theme)    no_theme=1; shift ;;

      -m|--marquee)    has_marquee=1; shift ;;
      --no-marquee)    no_marquee=1; shift ;;

      --theme-list|--themes) _tabbing_theme_list; return ;;
      --color-list|--colors)
        if [ -n "${_TABBING_FULL_LIBS:-}" ]; then _tabbing_color_list
        else command tabbing-on colors; fi
        return ;;
      --emoji-list|--emojis|-emojis)
        if [ -n "${_TABBING_FULL_LIBS:-}" ]; then _tabbing_emoji_list | _tabbing_pager
        else command tabbing-on --emoji-list; fi
        return ;;

      # -COLOR or -EMOJI shorthand
      -[a-z]*)
        local maybe="${1#-}"
        if [[ "$maybe" =~ ^pri[0-5]$ ]]; then
          opt_urgency="${maybe#pri}"; has_urgency=1; shift
        else
          local found=0
          for c in "${_tabbing_known_colors[@]}"; do
            if [[ "$maybe" == "$c" ]]; then
              opt_highlight="$maybe"; has_highlight=1; found=1
              break
            fi
          done
          if [[ $found -eq 0 ]]; then
            if _tabbing_is_known_emoji "$maybe"; then
              opt_emoji="$maybe"; has_emoji=1; found=1
            fi
          fi
          if [[ $found -eq 1 ]]; then
            shift
          else
            echo "tabbing-style: unknown option: $1" >&2; return 1
          fi
        fi
        ;;

      -*)  echo "tabbing-style: unknown option: $1" >&2; return 1 ;;
      *)   echo "tabbing-style: unexpected argument: $1 (use tabbing-on to set title/status)" >&2; return 1 ;;
    esac
  done

  # No flags at all — show current settings
  if [[ $has_highlight -eq 0 && $has_urgency -eq 0 && $has_emoji -eq 0 && $no_emoji -eq 0 && $has_bg -eq 0 && $no_bg -eq 0 && $has_theme -eq 0 && $no_theme -eq 0 && $has_marquee -eq 0 && $no_marquee -eq 0 ]]; then
    printf 'highlight: %s\n' "${TAB_HIGHLIGHT:-(none)}"
    printf 'urgency:   %s\n' "${TAB_URGENCY:-(none)}"
    printf 'emoji:     %s\n' "${TAB_EMOJI:-(none)}"
    printf 'bg:        %s\n' "${TAB_BG:-(none)}"
    printf 'theme:     %s\n' "${TAB_THEME:-(none)}"
    printf 'marquee:   %s\n' "${TAB_MARQUEE:-off}"
    return
  fi

  # Apply settings
  if [[ $has_highlight -eq 1 ]]; then
    if ! _tabbing_color_code "$opt_highlight" >/dev/null 2>&1; then
      _tabbing_color_code "$opt_highlight"
      return 1
    fi
    _tabbing_set highlight "$opt_highlight"
  fi

  if [[ $has_urgency -eq 1 ]]; then
    if [[ ! "$opt_urgency" =~ ^[0-5]$ ]]; then
      echo "tabbing: urgency must be 0-5 (0=critical, 5=nominal)" >&2
      return 1
    fi
    _tabbing_set urgency "$opt_urgency"
  fi

  if [[ $has_emoji -eq 1 ]]; then
    if ! _tabbing_emoji_lookup "$opt_emoji" >/dev/null 2>&1; then
      _tabbing_emoji_lookup "$opt_emoji"
      return 1
    fi
    _tabbing_set emoji "$opt_emoji"
  fi
  if [[ $no_emoji -eq 1 ]]; then
    _tabbing_set emoji ""
  fi

  if [[ $has_bg -eq 1 ]]; then
    if ! _tabbing_color_to_hex "$opt_bg" >/dev/null 2>&1; then
      _tabbing_color_to_hex "$opt_bg"
      return 1
    fi
    export TAB_BG="$opt_bg"
  fi
  if [[ $no_bg -eq 1 ]]; then
    _tabbing_clear_bg_color
    unset TAB_BG
  fi

  if [[ $has_theme -eq 1 ]]; then
    if ! _tabbing_apply_named_theme "$opt_theme" 2>/dev/null; then
      echo "tabbing: unknown theme '$opt_theme'" >&2
      _tabbing_theme_list >&2
      return 1
    fi
    _tabbing_set theme "$opt_theme"
  fi
  if [[ $no_theme -eq 1 ]]; then
    _tabbing_clear_theme
    _tabbing_set theme ""
  fi

  if [[ $has_marquee -eq 1 ]]; then
    export TAB_MARQUEE=1
  fi
  if [[ $no_marquee -eq 1 ]]; then
    unset TAB_MARQUEE
    _tabbing_marquee_kill
  fi

  # Apply visual effects immediately
  _tabbing_apply_urgency_color
  _tabbing_apply_bg_color

  # Title rendering and session commit require an active tab
  if [[ -n "${TAB_TITLE:-}" ]]; then
    _tabbing_render
    _tabbing_marquee_render
    _tabbing_commit "settings"
  fi

  # Prevent external tools from overwriting our styling
  export CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1
}

# ---------------------------------------------------------------------------
# tabbing-off — Deactivate tabbing and restore terminal defaults
# Clears title, tab color, and badge, then unsets runtime variables.
# Preserves TAB_TERMINAL and TAB_SESSION for re-activation.
# ---------------------------------------------------------------------------
tabbing-off() {
  # Tear down bridges if active
  if [ -n "${TABBING_PIPE:-}" ] || [ -n "${TABBING_RUN_WITH_PIPE:-}" ]; then
    . "${_tabbing_root}/lib/claude.sh" 2>/dev/null
    [ -n "${TABBING_PIPE:-}" ] && _tabbing_claude_stop_bridge
    [ -n "${TABBING_RUN_WITH_PIPE:-}" ] && _tabbing_run_with_stop
  fi

  _tabbing_clear_title
  _tabbing_clear_bg_color
  _tabbing_clear_theme
  . "${_tabbing_root}/lib/terminal.sh"
  _tabbing_clear_tab_color
  _tabbing_clear_badge
  # Remove session file so precmd doesn't resurrect state
  if [[ -n "${TAB_SESSION:-}" ]]; then
    rm -f "${XDG_STATE_HOME:-$HOME/.local/state}/tabbing/sessions/${TAB_SESSION}.env"
  fi
  unset TAB_TITLE TAB_STATUS TAB_EMOJI TAB_URGENCY TAB_HIGHLIGHT TAB_BG TAB_THEME TAB_ID TAB_RECORDING
  unset TABBING_DC_UUID TABBING_DC_DAEMON_PID _TABBING_WAS_ACTIVE CLAUDE_CODE_DISABLE_TERMINAL_TITLE
  _tabbing_out 'tabbing: off\n'
}

# ---------------------------------------------------------------------------
# Prompt hook: tab title re-render + optional inline prompt prefix
# Auto-registered — lightweight no-op when tabbing is not active.
#
# Direnv guard: if tabbing-on was previously active (_TABBING_WAS_ACTIVE)
# but TAB_TITLE is now empty (direnv clobbered it on cd), restore from
# the session file. The session file is the source of truth for
# interactively-set state.
# ---------------------------------------------------------------------------
_tabbing_precmd() {
  if [[ -n "${_TABBING_WAS_ACTIVE:-}" && -z "${TAB_TITLE:-}" && -n "${TAB_SESSION:-}" ]]; then
    local _sf="${XDG_STATE_HOME:-$HOME/.local/state}/tabbing/sessions/${TAB_SESSION}.env"
    if [[ -f "$_sf" ]]; then
      . "$_sf"
      export TAB_ID TAB_TITLE TAB_STATUS TAB_HIGHLIGHT TAB_URGENCY TAB_EMOJI TAB_THEME TAB_TERMINAL TABBING_DC_UUID
      if [[ -n "${TAB_THEME:-}" ]]; then
        _tabbing_apply_named_theme "$TAB_THEME" 2>/dev/null
      fi
    fi
  fi

  if [[ -n "${TAB_TITLE:-}" ]]; then
    _tabbing_render
    _TABBING_WAS_ACTIVE=1
  elif [[ -n "${_TABBING_WAS_ACTIVE:-}" ]]; then
    _tabbing_clear_title
    unset _TABBING_WAS_ACTIVE
  fi
}

# Register hook — append so we run LAST,
# after Ghostty/Kitty shell integration hooks that reset the title.
case "${PROMPT_COMMAND:-}" in
  *_tabbing_precmd*) ;;
  *) PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}_tabbing_precmd" ;;
esac
