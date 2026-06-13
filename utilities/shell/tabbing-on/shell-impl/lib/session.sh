#!/bin/sh
# lib/session.sh — Per-session state persistence for CLI wrappers
#
# Saves/loads TAB_* env vars to a file keyed by TAB_SESSION.
# This allows state to persist across separate subshell invocations
# (e.g., when Claude Code or other tools spawn fresh shells).
#
# The session fingerprint (TAB_SESSION) is generated once at init
# and inherited by child processes via the environment.

# ---------------------------------------------------------------------------
# Generate a session fingerprint if TAB_SESSION is not already set
# Called by tabbing-init during shell startup
# ---------------------------------------------------------------------------
_tabbing_session_init() {
  if [ -n "${TAB_SESSION:-}" ]; then
    return
  fi
  if [ -r /dev/urandom ]; then
    TAB_SESSION="$(od -An -tx1 -N4 /dev/urandom 2>/dev/null | tr -d ' \n')"
  fi
  # Fallback if /dev/urandom failed or unavailable
  if [ -z "${TAB_SESSION:-}" ]; then
    TAB_SESSION="$(printf '%04x%04x' $$ "$(date +%s)" | cut -c1-8)"
  fi
  export TAB_SESSION
}

# ---------------------------------------------------------------------------
# Session state directory and file path
# ---------------------------------------------------------------------------
_tabbing_session_dir() {
  _dir="${XDG_STATE_HOME:-$HOME/.local/state}/tabbing/sessions"
  if [ ! -d "$_dir" ]; then
    mkdir -p "$_dir"
  fi
  printf '%s' "$_dir"
}

_tabbing_session_file() {
  if [ -z "${TAB_SESSION:-}" ]; then
    return 1
  fi
  printf '%s/%s.env' "$(_tabbing_session_dir)" "$TAB_SESSION"
}

# ---------------------------------------------------------------------------
# Save current TAB_* state to the session file
# Values are single-quoted with proper escaping for safe sourcing
# ---------------------------------------------------------------------------
_tabbing_session_save() {
  _file="$(_tabbing_session_file)" || return 0
  {
    printf "TAB_ID='%s'\n"        "$(printf '%s' "${TAB_ID:-}"        | sed "s/'/'\\\\''/g")"
    printf "TAB_TITLE='%s'\n"     "$(printf '%s' "${TAB_TITLE:-}"     | sed "s/'/'\\\\''/g")"
    printf "TAB_STATUS='%s'\n"    "$(printf '%s' "${TAB_STATUS:-}"    | sed "s/'/'\\\\''/g")"
    printf "TAB_HIGHLIGHT='%s'\n" "$(printf '%s' "${TAB_HIGHLIGHT:-}" | sed "s/'/'\\\\''/g")"
    printf "TAB_URGENCY='%s'\n"   "$(printf '%s' "${TAB_URGENCY:-}"   | sed "s/'/'\\\\''/g")"
    printf "TAB_EMOJI='%s'\n"     "$(printf '%s' "${TAB_EMOJI:-}"     | sed "s/'/'\\\\''/g")"
    printf "TAB_THEME='%s'\n"     "$(printf '%s' "${TAB_THEME:-}"     | sed "s/'/'\\\\''/g")"
    printf "TAB_TERMINAL='%s'\n"  "$(printf '%s' "${TAB_TERMINAL:-}"  | sed "s/'/'\\\\''/g")"
    printf "TABBING_DC_UUID='%s'\n" "$(printf '%s' "${TABBING_DC_UUID:-}" | sed "s/'/'\\\\''/g")"
    printf "TABBING_PIPE='%s'\n" "$(printf '%s' "${TABBING_PIPE:-}" | sed "s/'/'\\\\''/g")"
    printf "TABBING_CLAUDE_PID='%s'\n" "$(printf '%s' "${TABBING_CLAUDE_PID:-}" | sed "s/'/'\\\\''/g")"
    printf "TABBING_RUN_WITH_PIPE='%s'\n" "$(printf '%s' "${TABBING_RUN_WITH_PIPE:-}" | sed "s/'/'\\\\''/g")"
  } > "$_file"
}

# ---------------------------------------------------------------------------
# Load state from the session file into the environment
# Overwrites current values — the file is the source of truth
# ---------------------------------------------------------------------------
_tabbing_session_load() {
  _file="$(_tabbing_session_file)" || return 0
  if [ -f "$_file" ]; then
    . "$_file"
    export TAB_ID TAB_TITLE TAB_STATUS TAB_HIGHLIGHT TAB_URGENCY TAB_EMOJI TAB_THEME TAB_TERMINAL
    export TABBING_DC_UUID TABBING_PIPE TABBING_CLAUDE_PID TABBING_RUN_WITH_PIPE
  fi
}
