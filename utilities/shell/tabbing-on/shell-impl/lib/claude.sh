#!/bin/sh
# lib/claude.sh — Claude Code status line bridge via named pipe
#
# Creates a FIFO and background reader process that persists tabbing-on
# state to a flat file.  Claude Code's statusline script reads this file
# to display tab state in its status bar.
#
# Data flow:
#   tabbing-on render → FIFO → bridge reader → .state file ← statusline script

# ---------------------------------------------------------------------------
# Path helpers
# ---------------------------------------------------------------------------

_tabbing_claude_state_dir() {
  printf '%s/tabbing' "${XDG_STATE_HOME:-$HOME/.local/state}"
}

_tabbing_claude_pipe_path() {
  printf '%s/claude-%s.pipe' "$(_tabbing_claude_state_dir)" "${TAB_SESSION:-default}"
}

_tabbing_claude_state_path() {
  printf '%s/claude-%s.state' "$(_tabbing_claude_state_dir)" "${TAB_SESSION:-default}"
}

_tabbing_claude_pid_path() {
  printf '%s/claude-bridge-%s.pid' "$(_tabbing_claude_state_dir)" "${TAB_SESSION:-default}"
}

# ---------------------------------------------------------------------------
# Bridge reader loop — runs as a background process
#
# Reads delimited state blocks from the FIFO and writes them to a flat
# file atomically.  Self-terminates when the tracked PID dies (if given).
# ---------------------------------------------------------------------------
_tabbing_claude_bridge_loop() {
  _tracked_pid="$1"
  _pipe="$2"
  _state="$3"

  trap 'rm -f "$_pipe" "$_state" "${_state}.tmp"; exit 0' INT TERM

  while true; do
    # Check if tracked process is still alive
    if [ -n "$_tracked_pid" ] && ! kill -0 "$_tracked_pid" 2>/dev/null; then
      rm -f "$_pipe" "$_state" "${_state}.tmp"
      exit 0
    fi

    # Read a state snapshot from the FIFO (blocks until data available)
    _block=""
    while IFS= read -r _line; do
      [ "$_line" = "---" ] && break
      _block="${_block}${_line}
"
    done < "$_pipe"

    # Only write if we got data
    if [ -n "$_block" ]; then
      printf '%s' "$_block" > "${_state}.tmp"
      mv "${_state}.tmp" "$_state"
    fi
  done
}

# ---------------------------------------------------------------------------
# Start the bridge: create FIFO, launch reader, set env var
# ---------------------------------------------------------------------------
_tabbing_claude_start_bridge() {
  _tracked_pid="${1:-}"
  _state_dir="$(_tabbing_claude_state_dir)"
  _pipe="$(_tabbing_claude_pipe_path)"
  _state="$(_tabbing_claude_state_path)"
  _pidfile="$(_tabbing_claude_pid_path)"

  mkdir -p "$_state_dir"

  # Clean up any stale bridge
  if [ -f "$_pidfile" ]; then
    _old_pid="$(cat "$_pidfile")"
    kill "$_old_pid" 2>/dev/null || true
    rm -f "$_pidfile"
  fi
  rm -f "$_pipe" "$_state"

  # Create the FIFO
  mkfifo "$_pipe" 2>/dev/null || {
    _tabbing_out -v 0 -e 'tabbing: failed to create pipe at %s\n' "$_pipe"
    return 1
  }

  # Launch the bridge reader in the background
  _tabbing_claude_bridge_loop "$_tracked_pid" "$_pipe" "$_state" &
  _bridge_pid=$!
  printf '%s' "$_bridge_pid" > "$_pidfile"

  # Export so the render pipeline writes to the pipe
  export TABBING_PIPE="$_pipe"
  if [ -n "$_tracked_pid" ]; then
    export TABBING_CLAUDE_PID="$_tracked_pid"
  fi

  # Auto-configure Claude Code statusline
  _tabbing_claude_install_statusline

  _tabbing_out 'tabbing: claude bridge started (pipe=%s, bridge pid=%s)\n' "$_pipe" "$_bridge_pid"
}

# ---------------------------------------------------------------------------
# Stop the bridge: kill reader, remove FIFO and state file
# ---------------------------------------------------------------------------
_tabbing_claude_stop_bridge() {
  _pidfile="$(_tabbing_claude_pid_path)"
  _pipe="$(_tabbing_claude_pipe_path)"
  _state="$(_tabbing_claude_state_path)"

  if [ -f "$_pidfile" ]; then
    _old_pid="$(cat "$_pidfile")"
    kill "$_old_pid" 2>/dev/null || true
    rm -f "$_pidfile"
  fi

  rm -f "$_pipe" "$_state" "${_state}.tmp"
  unset TABBING_PIPE TABBING_CLAUDE_PID

  _tabbing_out 'tabbing: claude bridge stopped\n'
}

# ---------------------------------------------------------------------------
# Auto-configure Claude Code settings.json
# ---------------------------------------------------------------------------
_tabbing_claude_install_statusline() {
  _settings="${HOME}/.claude/settings.json"
  _script="${TABBING_ROOT:-${_tabbing_root:-}}/bin/tabbing-claude-statusline"

  # Bail if no script path
  if [ -z "$_script" ] || [ ! -f "$_script" ]; then
    return 0
  fi

  if [ ! -f "$_settings" ]; then
    mkdir -p "$(dirname "$_settings")"
    printf '{"statusLine":{"type":"command","command":"%s"}}\n' "$_script" > "$_settings"
    _tabbing_out 'tabbing: created %s with statusline config\n' "$_settings"
    return
  fi

  # Check if already configured
  if command -v jq >/dev/null 2>&1; then
    _current="$(jq -r '.statusLine.command // ""' "$_settings" 2>/dev/null)"
    if [ "$_current" = "$_script" ]; then
      return 0
    fi
    jq --arg cmd "$_script" '.statusLine = {"type":"command","command":$cmd}' \
      "$_settings" > "${_settings}.tmp" && mv "${_settings}.tmp" "$_settings"
    _tabbing_out 'tabbing: updated statusline in %s\n' "$_settings"
  else
    _tabbing_out -v 1 'tabbing: install jq to auto-configure, or add to %s:\n' "$_settings"
    _tabbing_out -v 1 '  "statusLine": {"type":"command","command":"%s"}\n' "$_script"
  fi
}

# ---------------------------------------------------------------------------
# --run-with: pipe bridge with a custom consumer command
#
# Creates the same FIFO + bridge reader, but instead of persisting to a
# state file the reader pipes each state block to the given command.
#
# Usage: tabbing-on "title" --run-with my-tool --format json
# ---------------------------------------------------------------------------

_tabbing_run_with_pipe_path() {
  printf '%s/run-with-%s.pipe' "$(_tabbing_claude_state_dir)" "${TAB_SESSION:-default}"
}

_tabbing_run_with_pid_path() {
  printf '%s/run-with-%s.pid' "$(_tabbing_claude_state_dir)" "${TAB_SESSION:-default}"
}

_tabbing_run_with_loop() {
  _cmd_args="$1"
  _pipe="$2"

  trap 'rm -f "$_pipe"; exit 0' INT TERM

  while true; do
    _block=""
    while IFS= read -r _line; do
      [ "$_line" = "---" ] && break
      _block="${_block}${_line}
"
    done < "$_pipe"

    if [ -n "$_block" ]; then
      printf '%s' "$_block" | eval "$_cmd_args"
    fi
  done
}

_tabbing_run_with_start() {
  if [ $# -eq 0 ]; then
    _tabbing_out -v 0 -e 'tabbing: --run-with requires a command\n'
    return 1
  fi

  _state_dir="$(_tabbing_claude_state_dir)"
  _pipe="$(_tabbing_run_with_pipe_path)"
  _pidfile="$(_tabbing_run_with_pid_path)"

  mkdir -p "$_state_dir"

  # Clean up any stale run-with bridge
  if [ -f "$_pidfile" ]; then
    _old_pid="$(cat "$_pidfile")"
    kill "$_old_pid" 2>/dev/null || true
    rm -f "$_pidfile"
  fi
  rm -f "$_pipe"

  mkfifo "$_pipe" 2>/dev/null || {
    _tabbing_out -v 0 -e 'tabbing: failed to create pipe at %s\n' "$_pipe"
    return 1
  }

  # Build the command string for eval
  _cmd=""
  for _arg in "$@"; do
    _cmd="${_cmd} '$(printf '%s' "$_arg" | sed "s/'/'\\\\''/g")'"
  done

  _tabbing_run_with_loop "$_cmd" "$_pipe" &
  _rw_pid=$!
  printf '%s' "$_rw_pid" > "$_pidfile"

  # Set TABBING_PIPE so the render pipeline writes here too
  # If a claude bridge is already active, use a second pipe var
  if [ -n "${TABBING_PIPE:-}" ]; then
    export TABBING_RUN_WITH_PIPE="$_pipe"
  else
    export TABBING_PIPE="$_pipe"
  fi

  _tabbing_out 'tabbing: run-with bridge started (pipe=%s, cmd=%s)\n' "$_pipe" "$*"
}

_tabbing_run_with_stop() {
  _pidfile="$(_tabbing_run_with_pid_path)"
  _pipe="$(_tabbing_run_with_pipe_path)"

  if [ -f "$_pidfile" ]; then
    _old_pid="$(cat "$_pidfile")"
    kill "$_old_pid" 2>/dev/null || true
    rm -f "$_pidfile"
  fi

  rm -f "$_pipe"
  unset TABBING_RUN_WITH_PIPE

  _tabbing_out 'tabbing: run-with bridge stopped\n'
}
