#!/bin/sh
# lib/dc.sh — direnv-config (dc) integration layer for tabbing-on
#
# When TABBING_ON_DC_MODE=1 (or --direnv-config-mode), tab state is
# read from and written to the dc "tab" named config. Changes bump
# the dc store version, which notifies other watchers (precmd hook,
# tabbing-daemon) to pick up the new state.

# ---------------------------------------------------------------------------
# Guard: dc mode active?
# ---------------------------------------------------------------------------
_tabbing_dc_enabled() {
  [ "${TABBING_ON_DC_MODE:-0}" = "1" ] && command -v dc >/dev/null 2>&1
}

# ---------------------------------------------------------------------------
# Session-scoped dc namespace.
# Returns "tab-{TABBING_DC_UUID}" so each terminal tab/pane gets its
# own dc keyspace. The UUID is generated once at shell init time,
# preventing stale dc values from previous sessions or other tabs
# from leaking in. Regenerated for new Zellij panes to avoid cloned
# UUIDs from pane splits. Child processes inherit TABBING_DC_UUID.
# ---------------------------------------------------------------------------
_tabbing_dc_ns() {
  if [ -n "${TABBING_DC_UUID:-}" ]; then
    printf 'tab-%s' "$TABBING_DC_UUID"
  else
    printf 'tab'
  fi
}

# ---------------------------------------------------------------------------
# Generate a dc UUID for this terminal session. Called once at shell init
# (by tabbing.zsh/tabbing.bash) to establish the session's dc scope.
# ---------------------------------------------------------------------------
_tabbing_dc_gen_uuid() {
  if [ -r /dev/urandom ]; then
    TABBING_DC_UUID="$(od -An -tx1 -N8 /dev/urandom 2>/dev/null | tr -d ' \n')"
  fi
  if [ -z "${TABBING_DC_UUID:-}" ]; then
    TABBING_DC_UUID="$(printf '%04x%04x%04x%04x' $$ "$(date +%s)" $RANDOM $RANDOM | cut -c1-16)"
  fi
  export TABBING_DC_UUID
}

# ---------------------------------------------------------------------------
# Read all tab state from dc into TAB_* env vars
# ---------------------------------------------------------------------------
_tabbing_dc_load() {
  _tabbing_dc_enabled || return 0
  _ns="$(_tabbing_dc_ns)"

  _val="$(dc get "$_ns" title --raw 2>/dev/null)" && [ -n "$_val" ] && TAB_TITLE="$_val"
  _val="$(dc get "$_ns" status --raw 2>/dev/null)" && [ -n "$_val" ] && TAB_STATUS="$_val"
  _val="$(dc get "$_ns" highlight --raw 2>/dev/null)" && [ -n "$_val" ] && TAB_HIGHLIGHT="$_val"
  _val="$(dc get "$_ns" urgency --raw 2>/dev/null)" && [ -n "$_val" ] && TAB_URGENCY="$_val"
  _val="$(dc get "$_ns" emoji --raw 2>/dev/null)" && [ -n "$_val" ] && TAB_EMOJI="$_val"
  _val="$(dc get "$_ns" theme --raw 2>/dev/null)" && [ -n "$_val" ] && TAB_THEME="$_val"

  export TAB_TITLE TAB_STATUS TAB_HIGHLIGHT TAB_URGENCY TAB_EMOJI TAB_THEME
  unset _val _ns
}

# ---------------------------------------------------------------------------
# Write a single tab key to dc (bumps version, triggering watchers)
# ---------------------------------------------------------------------------
_tabbing_dc_set() {
  _tabbing_dc_enabled || return 0
  _key="$1"
  _value="$2"
  dc set "$(_tabbing_dc_ns)" "$_key" "$_value" 2>/dev/null
  _tabbing_dc_bump_timestamp
  _tabbing_dc_notify_daemon
}

# ---------------------------------------------------------------------------
# Send SIGUSR1 to the daemon to trigger an immediate refresh.
# Falls back silently if no daemon is running.
# ---------------------------------------------------------------------------
_tabbing_dc_notify_daemon() {
  if [ -n "${TABBING_DC_DAEMON_PID:-}" ] && kill -0 "$TABBING_DC_DAEMON_PID" 2>/dev/null; then
    kill -USR1 "$TABBING_DC_DAEMON_PID" 2>/dev/null || true
  fi
}

# ---------------------------------------------------------------------------
# Bump the last_update timestamp (millisecond epoch) so the daemon can
# detect changes by checking a single value.
# ---------------------------------------------------------------------------
_tabbing_dc_bump_timestamp() {
  _tabbing_dc_enabled || return 0
  if command -v gdate >/dev/null 2>&1; then
    _ts="$(gdate +%s%3N)"
  elif date +%s%3N >/dev/null 2>&1; then
    _ts="$(date +%s%3N)"
  else
    _ts="$(date +%s)000"
  fi
  dc set "$(_tabbing_dc_ns)" last_update "$_ts" 2>/dev/null
}

# ---------------------------------------------------------------------------
# Set a TAB_* variable and write-through to dc if dc mode is active.
# Usage: _tabbing_set <key> <value>
#   key: lowercase dc key name (title, status, highlight, urgency, emoji, theme)
# Sets the corresponding TAB_* env var AND calls dc set immediately.
# ---------------------------------------------------------------------------
_tabbing_set() {
  _key="$1"
  _value="$2"
  case "$_key" in
    title)     export TAB_TITLE="$_value" ;;
    status)    export TAB_STATUS="$_value" ;;
    highlight) export TAB_HIGHLIGHT="$_value" ;;
    urgency)   export TAB_URGENCY="$_value" ;;
    emoji)     export TAB_EMOJI="$_value" ;;
    theme)     export TAB_THEME="$_value" ;;
  esac
  _tabbing_dc_set "$_key" "$_value"
}

# ---------------------------------------------------------------------------
# Write all current TAB_* state to dc in one shot
# Uses dc yaml to merge a YAML blob into the tab config
# ---------------------------------------------------------------------------
_tabbing_dc_save() {
  _tabbing_dc_enabled || return 0
  _ns="$(_tabbing_dc_ns)"
  _tabbing_dc_bump_timestamp
  _ts="$(dc get "$_ns" last_update --raw 2>/dev/null)"
  printf 'title: %s\nstatus: %s\nhighlight: %s\nurgency: %s\nemoji: %s\ntheme: %s\nlast_update: %s\n' \
    "${TAB_TITLE:-}" "${TAB_STATUS:-}" "${TAB_HIGHLIGHT:-}" \
    "${TAB_URGENCY:-}" "${TAB_EMOJI:-}" "${TAB_THEME:-}" "${_ts:-0}" \
    | dc yaml "$_ns" --replace 2>/dev/null
  _tabbing_dc_notify_daemon
}

# ---------------------------------------------------------------------------
# Get the current dc store version (for daemon polling)
# ---------------------------------------------------------------------------
_tabbing_dc_version() {
  if [ -n "${DC_ROOT:-}" ] && [ -f "${DC_ROOT}/.version" ]; then
    cat "${DC_ROOT}/.version" 2>/dev/null
  else
    printf '0'
  fi
}

# ---------------------------------------------------------------------------
# Initialize dc tab config if it doesn't exist
# Seeds with current TAB_* state so dc has something to serve
# ---------------------------------------------------------------------------
_tabbing_dc_init() {
  _tabbing_dc_enabled || return 1
  # With UUID-scoped namespaces, a fresh UUID always means fresh state.
  # Seed dc with current TAB_* env vars.
  _tabbing_dc_save
}

# ---------------------------------------------------------------------------
# Ensure daemon is running for this session. Uses TABBING_DC_DAEMON_PID
# env var as a fast check — only hits the pidfile/start path if unset or stale.
# ---------------------------------------------------------------------------
_tabbing_dc_ensure_daemon() {
  _tabbing_dc_enabled || return 0
  if [ -n "${TABBING_DC_DAEMON_PID:-}" ] && kill -0 "$TABBING_DC_DAEMON_PID" 2>/dev/null; then
    return 0
  fi
  # Find tabbing-daemon: on PATH first, then relative to TABBING_ROOT
  if command -v tabbing-daemon >/dev/null 2>&1; then
    tabbing-daemon start 2>/dev/null || true
  else
    _dr="${TABBING_ROOT:-$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)}"
    [ -z "$_dr" ] && return 0
    "$_dr/bin/tabbing-daemon" start 2>/dev/null || true
  fi
  _pf="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/tabbing-daemon.${TAB_SESSION:-$$}.pid"
  if [ -f "$_pf" ]; then
    TABBING_DC_DAEMON_PID="$(cat "$_pf")"
    export TABBING_DC_DAEMON_PID
  fi
}
