#!/bin/sh
# lib/recording.sh — asciinema recording lifecycle management
#
# Manages terminal recording tied to tab tasks/status.
# Uses asciinema for recording .cast files.
# Detection of active recording via ASCIINEMA_REC env var.

# ---------------------------------------------------------------------------
# Check if currently recording (inside an asciinema sub-shell)
# ---------------------------------------------------------------------------
_tabbing_is_recording() {
  [ -n "${ASCIINEMA_REC:-}" ] && return 0
  [ -n "${TAB_RECORDING:-}" ] && return 0
  return 1
}

# ---------------------------------------------------------------------------
# Get the recordings directory for a tab
# ---------------------------------------------------------------------------
_tabbing_recordings_dir() {
  local tab_id="${1:-$TAB_ID}"
  local dir
  dir="$(_tabbing_state_dir)/recordings/${tab_id}"
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
  fi
  printf '%s' "$dir"
}

# ---------------------------------------------------------------------------
# Generate a recording filename based on current status
# Returns: full path to .cast file
# ---------------------------------------------------------------------------
_tabbing_recording_path() {
  _tabbing_ensure_tab_id
  local rec_dir
  rec_dir="$(_tabbing_recordings_dir)"

  local timestamp
  timestamp="$(date +%Y%m%dT%H%M%S)"

  local status_slug
  status_slug="$(printf '%s' "${TAB_STATUS:-unknown}" | tr ' /' '-_' | tr -cd 'a-zA-Z0-9_-')"

  printf '%s/%s_%s.cast' "$rec_dir" "$timestamp" "$status_slug"
}

# ---------------------------------------------------------------------------
# Start a new asciinema recording
# This launches asciinema rec which spawns a sub-shell.
# The user continues working inside that sub-shell.
# ---------------------------------------------------------------------------
_tabbing_record_start() {
  if ! command -v asciinema >/dev/null 2>&1; then
    printf 'tabbing: asciinema not found\n' >&2
    printf 'tabbing: install it: https://docs.asciinema.org/manual/cli/installation/\n' >&2
    return 1
  fi

  _tabbing_ensure_tab_id
  local cast_file
  cast_file="$(_tabbing_recording_path)"
  export TAB_RECORDING="$cast_file"

  # Record the event before starting (so it's in history)
  _tabbing_record_event "record_start"

  printf 'tabbing: recording to %s\n' "$cast_file"
  printf 'tabbing: type "exit" or Ctrl-D to stop recording\n'

  # asciinema rec spawns a sub-shell; execution continues there
  # When the sub-shell exits, recording stops automatically
  asciinema rec --overwrite "$cast_file"

  # This runs after the sub-shell exits (recording stopped)
  _tabbing_record_event "record_stop"
  printf 'tabbing: recording saved to %s\n' "$cast_file"
  unset TAB_RECORDING
}

# ---------------------------------------------------------------------------
# Stop the current recording
# If inside an asciinema sub-shell, exit it
# ---------------------------------------------------------------------------
_tabbing_record_stop() {
  if ! _tabbing_is_recording; then
    printf 'tabbing: not currently recording\n' >&2
    return 1
  fi

  _tabbing_record_event "record_stop"
  printf 'tabbing: stopping recording\n'

  if [ -n "${ASCIINEMA_REC:-}" ]; then
    printf 'tabbing: exiting asciinema session...\n'
    # Signal the user that they need to exit, or send exit
    # In practice, the user types 'exit' or we can kill the parent
    exit 0
  fi

  unset TAB_RECORDING
}

# ---------------------------------------------------------------------------
# Handle recording flags for tabbing-on / tabbing-status / tabbing-todo
#
# Args: has_record (0/1), has_continue (0/1), has_stop_recording (0/1)
#
# Logic:
#   Not recording + --record       → start new recording
#   Not recording + --continue     → warn (no-op)
#   Recording + --continue         → keep going (no-op)
#   Recording + --record           → stop current, start new
#   Recording + neither            → stop current, start new
#   Any + --stop-recording         → stop recording
# ---------------------------------------------------------------------------
_tabbing_handle_recording() {
  local has_record="${1:-0}"
  local has_continue="${2:-0}"
  local has_stop="${3:-0}"

  # Explicit stop
  if [ "$has_stop" -eq 1 ]; then
    if _tabbing_is_recording; then
      _tabbing_record_stop
    fi
    return
  fi

  local currently_recording=0
  if _tabbing_is_recording; then
    currently_recording=1
  fi

  if [ "$currently_recording" -eq 0 ]; then
    # Not recording
    if [ "$has_record" -eq 1 ]; then
      _tabbing_record_start
    elif [ "$has_continue" -eq 1 ]; then
      printf 'tabbing: --continue ignored (not currently recording)\n' >&2
    fi
  else
    # Currently recording
    if [ "$has_continue" -eq 1 ]; then
      # Keep recording — no action needed
      :
    elif [ "$has_record" -eq 1 ]; then
      # Stop current and start new
      _tabbing_record_stop
      _tabbing_record_start
    else
      # Neither flag while recording — stop current, start new
      # (This happens on status change without --continue)
      _tabbing_record_stop
      _tabbing_record_start
    fi
  fi
}

# ---------------------------------------------------------------------------
# List recordings for a tab
# Args: [tab_id] (defaults to current TAB_ID)
# ---------------------------------------------------------------------------
_tabbing_recordings_list() {
  local tab_id="${1:-$TAB_ID}"
  local rec_dir
  rec_dir="$(_tabbing_state_dir)/recordings/${tab_id}"

  if [ ! -d "$rec_dir" ]; then
    printf 'No recordings for tab %s\n' "$tab_id"
    return 1
  fi

  printf 'Recordings for tab %s:\n' "$tab_id"
  for f in "$rec_dir"/*.cast; do
    [ -f "$f" ] || continue
    local fname size
    fname="$(basename "$f")"
    size="$(wc -c < "$f" | tr -d ' ')"
    printf '  %s  (%s bytes)\n' "$fname" "$size"
  done
}

# ---------------------------------------------------------------------------
# Convert a .cast recording to GIF using agg
# Args: cast_file [output.gif]
# ---------------------------------------------------------------------------
_tabbing_recording_to_gif() {
  local cast_file="$1"
  local gif_file="${2:-${cast_file%.cast}.gif}"

  if ! command -v agg >/dev/null 2>&1; then
    printf 'tabbing: agg not found\n' >&2
    printf 'tabbing: install it: cargo install --git https://github.com/asciinema/agg\n' >&2
    return 1
  fi

  if [ ! -f "$cast_file" ]; then
    printf 'tabbing: recording not found: %s\n' "$cast_file" >&2
    return 1
  fi

  printf 'tabbing: converting %s → %s\n' "$cast_file" "$gif_file"
  agg "$cast_file" "$gif_file"
  printf 'tabbing: GIF saved to %s\n' "$gif_file"
}
