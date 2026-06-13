#!/bin/sh
# lib/toggl.sh — Toggl Track API integration for tabbing-on
#
# Creates/manages time entries in Toggl Track that mirror tabbing-on
# task/subtask lifecycle. Uses running timers with periodic activity
# checks and idle warnings.
#
# Env vars (user-provided or auto-detected):
#   TAB_TOGGL_TOKEN        — Toggl API token (required)
#   TAB_TOGGL_WORKSPACE    — Workspace ID (prompted if missing)
#   TAB_TOGGL_PROJECT      — Project ID (prompted if missing)
#   TAB_TOGGL_CLIENT       — Client ID (optional)
#   TAB_TOGGL_BILLABLE     — "true"/"false" (default: false)
#   TAB_TOGGL_DURATION     — Heartbeat interval in seconds (default: 1800 = 30m)
#   TAB_TOGGL_INACTIVE_WARN — Idle check interval in seconds (default: 300 = 5m)
#   TAB_TOGGL_PREFIX       — Description prefix (default: TABO-{repo})
#   TAB_TOGGL_CREATED_WITH — created_with field (default: TABO)
#
# Runtime state (managed internally):
#   TAB_TOGGL_ENTRY_ID     — Current time entry ID
#   TAB_TOGGL_ENTRY_START  — ISO timestamp of entry start
#   TAB_TOGGL_LAST_ACTIVE  — Epoch of last detected activity
#   TAB_TOGGL_MONITOR_PID  — PID of background activity monitor

_TOGGL_API="https://api.track.toggl.com/api/v9"

# ---------------------------------------------------------------------------
# Prerequisite check
# ---------------------------------------------------------------------------
_tabbing_toggl_check_deps() {
  if ! command -v curl >/dev/null 2>&1; then
    _tabbing_out -v 0 -e 'tabbing-toggl: curl is required\n'
    return 1
  fi
  if ! command -v jq >/dev/null 2>&1; then
    _tabbing_out -v 0 -e 'tabbing-toggl: jq is required (brew install jq)\n'
    return 1
  fi
  return 0
}

# ---------------------------------------------------------------------------
# API helpers
# ---------------------------------------------------------------------------
_tabbing_toggl_auth() {
  printf '%s:api_token' "${TAB_TOGGL_TOKEN}"
}

_tabbing_toggl_api() {
  # Usage: _tabbing_toggl_api METHOD endpoint [data]
  _method="$1"
  _endpoint="$2"
  _data="${3:-}"

  _auth="$(_tabbing_toggl_auth)"

  if [ -n "$_data" ]; then
    curl -s -w '\n%{http_code}' \
      -u "$_auth" \
      -H "Content-Type: application/json" \
      -X "$_method" \
      "${_TOGGL_API}${_endpoint}" \
      -d "$_data"
  else
    curl -s -w '\n%{http_code}' \
      -u "$_auth" \
      -H "Content-Type: application/json" \
      -X "$_method" \
      "${_TOGGL_API}${_endpoint}"
  fi
}

# Extract body and HTTP status from curl response
# Sets _TOGGL_BODY and _TOGGL_STATUS
_tabbing_toggl_parse_response() {
  _resp="$1"
  _TOGGL_STATUS="$(printf '%s' "$_resp" | tail -1)"
  _TOGGL_BODY="$(printf '%s' "$_resp" | sed '$d')"
}

# ---------------------------------------------------------------------------
# Token validation & user info
# ---------------------------------------------------------------------------
_tabbing_toggl_validate_token() {
  if [ -z "${TAB_TOGGL_TOKEN:-}" ]; then
    _tabbing_out -v 0 -e 'tabbing-toggl: TAB_TOGGL_TOKEN not set\n'
    return 1
  fi

  _resp="$(_tabbing_toggl_api GET /me)"
  _tabbing_toggl_parse_response "$_resp"

  if [ "$_TOGGL_STATUS" != "200" ]; then
    _tabbing_out -v 0 -e 'tabbing-toggl: authentication failed (HTTP %s)\n' "$_TOGGL_STATUS"
    return 1
  fi

  # Cache default workspace if not set
  if [ -z "${TAB_TOGGL_WORKSPACE:-}" ]; then
    TAB_TOGGL_WORKSPACE="$(printf '%s' "$_TOGGL_BODY" | jq -r '.default_workspace_id')"
    export TAB_TOGGL_WORKSPACE
  fi

  return 0
}

# ---------------------------------------------------------------------------
# Interactive setup — prompted when --toggl is used without config
# ---------------------------------------------------------------------------
_tabbing_toggl_interactive_setup() {
  _task_name="${1:-}"

  _tabbing_out '\n── Toggl Track Setup ──\n\n'

  # Validate token first
  if ! _tabbing_toggl_validate_token; then
    return 1
  fi

  _tabbing_out '  Authenticated. Default workspace: %s\n' "$TAB_TOGGL_WORKSPACE"

  # List workspaces
  _resp="$(_tabbing_toggl_api GET /me/workspaces)"
  _tabbing_toggl_parse_response "$_resp"
  if [ "$_TOGGL_STATUS" = "200" ]; then
    _ws_count="$(printf '%s' "$_TOGGL_BODY" | jq 'length')"
    if [ "$_ws_count" -gt 1 ]; then
      _tabbing_out '\n  Workspaces:\n'
      printf '%s' "$_TOGGL_BODY" | jq -r '.[] | "    \(.id)  \(.name)"'
      printf '\n  Workspace ID [%s]: ' "$TAB_TOGGL_WORKSPACE"
      read -r _ws_choice
      if [ -n "$_ws_choice" ]; then
        TAB_TOGGL_WORKSPACE="$_ws_choice"
        export TAB_TOGGL_WORKSPACE
      fi
    fi
  fi

  # List projects for chosen workspace
  _resp="$(_tabbing_toggl_api GET "/workspaces/${TAB_TOGGL_WORKSPACE}/projects?active=true")"
  _tabbing_toggl_parse_response "$_resp"
  if [ "$_TOGGL_STATUS" = "200" ] && [ "$_TOGGL_BODY" != "null" ] && [ "$_TOGGL_BODY" != "[]" ]; then
    _tabbing_out '\n  Projects:\n'
    printf '%s' "$_TOGGL_BODY" | jq -r '.[] | "    \(.id)  \(.name)"'
    printf '\n  Project ID [%s]: ' "${TAB_TOGGL_PROJECT:-none}"
    read -r _proj_choice
    if [ -n "$_proj_choice" ]; then
      TAB_TOGGL_PROJECT="$_proj_choice"
      export TAB_TOGGL_PROJECT
    fi
  else
    _tabbing_out '\n  No active projects found in workspace.\n'
  fi

  # Description / task
  _repo="$(_tabbing_toggl_detect_repo)"
  _prefix="${TAB_TOGGL_PREFIX:-TABO-${_repo}}"
  _desc="${_prefix}: ${_task_name:-${TAB_TITLE:-untitled}}"

  printf '\n  Description [%s]: ' "$_desc"
  read -r _desc_choice
  if [ -n "$_desc_choice" ]; then
    _desc="$_desc_choice"
  fi
  TAB_TOGGL_DESCRIPTION="$_desc"
  export TAB_TOGGL_DESCRIPTION

  # Billable
  printf '  Billable? [y/N]: '
  read -r _bill
  case "$_bill" in
    [yY]|[yY][eE][sS]) TAB_TOGGL_BILLABLE="true" ;;
    *) TAB_TOGGL_BILLABLE="false" ;;
  esac
  export TAB_TOGGL_BILLABLE

  # Confirm
  _tabbing_out '\n  ── Confirm ──\n'
  _tabbing_out '  Workspace:   %s\n' "$TAB_TOGGL_WORKSPACE"
  _tabbing_out '  Project:     %s\n' "${TAB_TOGGL_PROJECT:-none}"
  _tabbing_out '  Description: %s\n' "$TAB_TOGGL_DESCRIPTION"
  _tabbing_out '  Billable:    %s\n' "$TAB_TOGGL_BILLABLE"
  _tabbing_out '  Tags:        autodur, aconfirm\n'
  printf '\n  [Y]es / [e]dit / [d]isable: '
  read -r _confirm
  case "$_confirm" in
    [eE])
      # Recurse for re-edit
      _tabbing_toggl_interactive_setup "$_task_name"
      return $?
      ;;
    [dD]|[nN])
      _tabbing_out 'tabbing-toggl: disabled for this session\n'
      TAB_TOGGL_DISABLED=1
      export TAB_TOGGL_DISABLED
      return 1
      ;;
    *)
      # Approved — proceed
      return 0
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Repo/branch detection
# ---------------------------------------------------------------------------
_tabbing_toggl_detect_repo() {
  if [ -n "${TAB_TOGGL_GIT_REPO:-}" ]; then
    printf '%s' "$TAB_TOGGL_GIT_REPO"
    return
  fi
  if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    _remote="$(git remote get-url origin 2>/dev/null || true)"
    if [ -n "$_remote" ]; then
      # Extract repo name from URL
      printf '%s' "$_remote" | sed 's|.*/||; s|\.git$||'
      return
    fi
    # Fallback: directory name
    basename "$(git rev-parse --show-toplevel 2>/dev/null)"
    return
  fi
  printf 'unknown'
}

_tabbing_toggl_detect_branch() {
  if [ -n "${TAB_TOGGL_GIT_BRANCH:-}" ]; then
    printf '%s' "$TAB_TOGGL_GIT_BRANCH"
    return
  fi
  if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git branch --show-current 2>/dev/null || printf 'detached'
    return
  fi
  printf 'unknown'
}

# ---------------------------------------------------------------------------
# Time entry CRUD
# ---------------------------------------------------------------------------
_tabbing_toggl_start_entry() {
  # Build description from current tab state
  if [ -z "${TAB_TOGGL_DESCRIPTION:-}" ]; then
    _repo="$(_tabbing_toggl_detect_repo)"
    _prefix="${TAB_TOGGL_PREFIX:-TABO-${_repo}}"
    _emoji_part=""
    if [ -n "${TAB_EMOJI:-}" ]; then
      _emoji_part=" ${TAB_EMOJI}"
    fi
    _status_part=""
    if [ -n "${TAB_STATUS:-}" ]; then
      _status_part=" - ${TAB_STATUS}"
    fi
    TAB_TOGGL_DESCRIPTION="${_prefix}:${_emoji_part} ${TAB_TITLE:-untitled}${_status_part}"
    export TAB_TOGGL_DESCRIPTION
  fi

  _now="$(date -u +%Y-%m-%dT%H:%M:%S.000Z 2>/dev/null || date -u +%Y-%m-%dT%H:%M:%SZ)"
  _ws="${TAB_TOGGL_WORKSPACE}"
  _created="${TAB_TOGGL_CREATED_WITH:-TABO}"

  # Build JSON payload
  _json="$(jq -n \
    --arg desc "$TAB_TOGGL_DESCRIPTION" \
    --argjson ws "$_ws" \
    --arg start "$_now" \
    --arg created "$_created" \
    --argjson billable "${TAB_TOGGL_BILLABLE:-false}" \
    '{
      description: $desc,
      workspace_id: $ws,
      start: $start,
      duration: -1,
      created_with: $created,
      billable: $billable,
      tags: ["autodur", "aconfirm"]
    }')"

  # Add project_id if set
  if [ -n "${TAB_TOGGL_PROJECT:-}" ]; then
    _json="$(printf '%s' "$_json" | jq --argjson pid "$TAB_TOGGL_PROJECT" '. + {project_id: $pid}')"
  fi

  _resp="$(_tabbing_toggl_api POST "/workspaces/${_ws}/time_entries" "$_json")"
  _tabbing_toggl_parse_response "$_resp"

  if [ "$_TOGGL_STATUS" != "200" ]; then
    _tabbing_out -v 0 -e 'tabbing-toggl: failed to create entry (HTTP %s)\n' "$_TOGGL_STATUS"
    _tabbing_out -v 0 -e '  %s\n' "$_TOGGL_BODY"
    return 1
  fi

  TAB_TOGGL_ENTRY_ID="$(printf '%s' "$_TOGGL_BODY" | jq -r '.id')"
  TAB_TOGGL_ENTRY_START="$_now"
  TAB_TOGGL_LAST_ACTIVE="$(date +%s)"
  export TAB_TOGGL_ENTRY_ID TAB_TOGGL_ENTRY_START TAB_TOGGL_LAST_ACTIVE

  _tabbing_out 'tabbing-toggl: timer started (entry %s)\n' "$TAB_TOGGL_ENTRY_ID"
  return 0
}

_tabbing_toggl_stop_entry() {
  if [ -z "${TAB_TOGGL_ENTRY_ID:-}" ]; then
    return 0
  fi

  _ws="${TAB_TOGGL_WORKSPACE}"
  _eid="${TAB_TOGGL_ENTRY_ID}"

  # Stop the running timer
  _resp="$(_tabbing_toggl_api PATCH "/workspaces/${_ws}/time_entries/${_eid}/stop")"
  _tabbing_toggl_parse_response "$_resp"

  if [ "$_TOGGL_STATUS" != "200" ] && [ "$_TOGGL_STATUS" != "409" ]; then
    _tabbing_out -v 0 -e 'tabbing-toggl: failed to stop entry (HTTP %s)\n' "$_TOGGL_STATUS"
    return 1
  fi

  # Remove autodur and aconfirm tags, keep others
  _current_tags="$(printf '%s' "$_TOGGL_BODY" | jq -r '[.tags[] | select(. != "autodur" and . != "aconfirm")] | @json' 2>/dev/null)"
  if [ -z "$_current_tags" ] || [ "$_current_tags" = "null" ]; then
    _current_tags="[]"
  fi

  _update_json="$(jq -n --argjson tags "$_current_tags" '{tags: $tags}')"
  _tabbing_toggl_api PUT "/workspaces/${_ws}/time_entries/${_eid}" "$_update_json" >/dev/null 2>&1

  _tabbing_out 'tabbing-toggl: timer stopped (entry %s)\n' "$_eid"

  # Stop the activity monitor
  _tabbing_toggl_stop_monitor

  unset TAB_TOGGL_ENTRY_ID TAB_TOGGL_ENTRY_START TAB_TOGGL_LAST_ACTIVE
  return 0
}

_tabbing_toggl_update_description() {
  # Update the running entry's description to match current tab state
  if [ -z "${TAB_TOGGL_ENTRY_ID:-}" ]; then
    return 0
  fi

  _repo="$(_tabbing_toggl_detect_repo)"
  _prefix="${TAB_TOGGL_PREFIX:-TABO-${_repo}}"
  _emoji_part=""
  if [ -n "${TAB_EMOJI:-}" ]; then
    _emoji_part=" ${TAB_EMOJI}"
  fi
  _status_part=""
  if [ -n "${TAB_STATUS:-}" ]; then
    _status_part=" - ${TAB_STATUS}"
  fi
  _new_desc="${_prefix}:${_emoji_part} ${TAB_TITLE:-untitled}${_status_part}"

  # Only update if changed
  if [ "$_new_desc" = "${TAB_TOGGL_DESCRIPTION:-}" ]; then
    return 0
  fi

  TAB_TOGGL_DESCRIPTION="$_new_desc"
  export TAB_TOGGL_DESCRIPTION

  _ws="${TAB_TOGGL_WORKSPACE}"
  _eid="${TAB_TOGGL_ENTRY_ID}"
  _json="$(jq -n --arg desc "$_new_desc" '{description: $desc}')"
  _tabbing_toggl_api PUT "/workspaces/${_ws}/time_entries/${_eid}" "$_json" >/dev/null 2>&1
}

# ---------------------------------------------------------------------------
# Activity monitoring
# ---------------------------------------------------------------------------
_tabbing_toggl_monitor_pid_path() {
  printf '%s/tabbing/toggl-monitor-%s.pid' \
    "${XDG_STATE_HOME:-$HOME/.local/state}" "${TAB_SESSION:-default}"
}

_tabbing_toggl_activity_file() {
  printf '%s/tabbing/toggl-activity-%s' \
    "${XDG_STATE_HOME:-$HOME/.local/state}" "${TAB_SESSION:-default}"
}

# Touch the activity file — called from precmd hook
_tabbing_toggl_touch_activity() {
  _afile="$(_tabbing_toggl_activity_file)"
  if [ -n "${TAB_TOGGL_ENTRY_ID:-}" ]; then
    date +%s > "$_afile"
    TAB_TOGGL_LAST_ACTIVE="$(date +%s)"
    export TAB_TOGGL_LAST_ACTIVE
  fi
}

# Background monitor loop
_tabbing_toggl_monitor_loop() {
  _inactive_warn="${TAB_TOGGL_INACTIVE_WARN:-300}"
  _duration="${TAB_TOGGL_DURATION:-1800}"
  _afile="$(_tabbing_toggl_activity_file)"
  _ws="${TAB_TOGGL_WORKSPACE}"
  _eid="${TAB_TOGGL_ENTRY_ID}"
  _session="${TAB_SESSION:-default}"
  _no_color="${TAB_NO_COLOR:-}"

  trap 'rm -f "$_afile"; exit 0' INT TERM

  # Initialize activity file
  date +%s > "$_afile"

  while true; do
    sleep "$_inactive_warn"

    # Check if the entry still exists (could have been stopped externally)
    if [ ! -f "$_afile" ]; then
      exit 0
    fi

    _last="$(cat "$_afile" 2>/dev/null || echo 0)"
    _now="$(date +%s)"
    _idle=$((_now - _last))

    if [ "$_idle" -ge "$_inactive_warn" ]; then
      # Idle detected — warn user
      if [ -n "${TMUX:-}" ]; then
        # In tmux: show message in status line
        tmux display-message \
          "tabbing-toggl: idle ${_idle}s — run 'tabbing-on --extend' to continue tracking" \
          2>/dev/null
      else
        # Not in tmux: print colored banner to stderr
        if [ -z "$_no_color" ]; then
          printf '\033[1;33m⏸ tabbing-toggl: idle %ss — run "tabbing-on --extend" to continue\033[0m\n' \
            "$_idle" >&2
        else
          printf '⏸ tabbing-toggl: idle %ss — run "tabbing-on --extend" to continue\n' \
            "$_idle" >&2
        fi
      fi
    fi

    # If idle exceeds the full duration window, stop the entry automatically
    if [ "$_idle" -ge "$_duration" ]; then
      if [ -n "${TMUX:-}" ]; then
        tmux display-message \
          "tabbing-toggl: auto-stopped after ${_duration}s idle" \
          2>/dev/null
      else
        if [ -z "$_no_color" ]; then
          printf '\033[1;31m⏹ tabbing-toggl: auto-stopped after %ss idle\033[0m\n' \
            "$_duration" >&2
        else
          printf '⏹ tabbing-toggl: auto-stopped after %ss idle\n' "$_duration" >&2
        fi
      fi
      # The actual stop will need to be done by the shell session
      # We signal by removing the activity file
      rm -f "$_afile"
      exit 0
    fi
  done
}

_tabbing_toggl_start_monitor() {
  if [ -z "${TAB_TOGGL_ENTRY_ID:-}" ]; then
    return 0
  fi

  _pidfile="$(_tabbing_toggl_monitor_pid_path)"
  _state_dir="$(dirname "$_pidfile")"
  mkdir -p "$_state_dir"

  # Kill any existing monitor
  _tabbing_toggl_stop_monitor

  # Launch background monitor
  _tabbing_toggl_monitor_loop &
  _mon_pid=$!
  printf '%s' "$_mon_pid" > "$_pidfile"
  TAB_TOGGL_MONITOR_PID="$_mon_pid"
  export TAB_TOGGL_MONITOR_PID

  _tabbing_out 'tabbing-toggl: activity monitor started (pid %s)\n' "$_mon_pid"
}

_tabbing_toggl_stop_monitor() {
  _pidfile="$(_tabbing_toggl_monitor_pid_path)"
  _afile="$(_tabbing_toggl_activity_file)"

  if [ -f "$_pidfile" ]; then
    _old_pid="$(cat "$_pidfile")"
    kill "$_old_pid" 2>/dev/null || true
    rm -f "$_pidfile"
  fi
  rm -f "$_afile"
  unset TAB_TOGGL_MONITOR_PID
}

# ---------------------------------------------------------------------------
# Extend — reset idle timer
# ---------------------------------------------------------------------------
_tabbing_toggl_extend() {
  if [ -z "${TAB_TOGGL_ENTRY_ID:-}" ]; then
    _tabbing_out -v 0 -e 'tabbing-toggl: no active entry to extend\n'
    return 1
  fi

  _tabbing_toggl_touch_activity
  _tabbing_out 'tabbing-toggl: idle timer reset\n'
}

# ---------------------------------------------------------------------------
# Full lifecycle: init (called from tabbing-on --toggl)
# ---------------------------------------------------------------------------
_tabbing_toggl_init() {
  _interactive="${1:-0}"
  _task_name="${2:-}"

  # Skip if disabled
  if [ "${TAB_TOGGL_DISABLED:-}" = "1" ]; then
    return 0
  fi

  # Check deps
  _tabbing_toggl_check_deps || return 1

  # Check token
  if [ -z "${TAB_TOGGL_TOKEN:-}" ]; then
    _tabbing_out -v 0 -e 'tabbing-toggl: TAB_TOGGL_TOKEN not set — skipping Toggl tracking\n'
    return 1
  fi

  # Interactive setup if requested and workspace/project not pre-configured
  if [ "$_interactive" = "1" ]; then
    _tabbing_toggl_interactive_setup "$_task_name" || return 1
  else
    # Non-interactive: validate token and auto-detect workspace
    _tabbing_toggl_validate_token || return 1
  fi

  # Start the time entry
  _tabbing_toggl_start_entry || return 1

  # Start activity monitor
  _tabbing_toggl_start_monitor

  return 0
}

# ---------------------------------------------------------------------------
# Finalize — called from tabbing-off or task completion
# ---------------------------------------------------------------------------
_tabbing_toggl_finalize() {
  _interactive="${1:-0}"

  if [ -z "${TAB_TOGGL_ENTRY_ID:-}" ]; then
    return 0
  fi

  if [ "$_interactive" = "1" ]; then
    _tabbing_out '\n── Toggl: Finalize Entry ──\n'
    _tabbing_out '  Entry ID:    %s\n' "$TAB_TOGGL_ENTRY_ID"
    _tabbing_out '  Description: %s\n' "${TAB_TOGGL_DESCRIPTION:-}"
    _tabbing_out '  Started:     %s\n' "${TAB_TOGGL_ENTRY_START:-}"
    printf '\n  Stop and finalize? [Y/n]: '
    read -r _confirm
    case "$_confirm" in
      [nN]) _tabbing_out 'tabbing-toggl: entry left running\n'; return 0 ;;
    esac
  fi

  _tabbing_toggl_stop_entry
}

# ---------------------------------------------------------------------------
# Status display
# ---------------------------------------------------------------------------
_tabbing_toggl_status() {
  if [ -z "${TAB_TOGGL_ENTRY_ID:-}" ]; then
    _tabbing_out 'tabbing-toggl: no active entry\n'
    return 0
  fi

  _now="$(date +%s)"
  _started="${TAB_TOGGL_LAST_ACTIVE:-$_now}"
  _elapsed=$((_now - _started))

  _tabbing_out '  Entry ID:    %s\n' "$TAB_TOGGL_ENTRY_ID"
  _tabbing_out '  Description: %s\n' "${TAB_TOGGL_DESCRIPTION:-}"
  _tabbing_out '  Started:     %s\n' "${TAB_TOGGL_ENTRY_START:-}"
  _tabbing_out '  Workspace:   %s\n' "${TAB_TOGGL_WORKSPACE:-}"
  _tabbing_out '  Project:     %s\n' "${TAB_TOGGL_PROJECT:-none}"
  _tabbing_out '  Billable:    %s\n' "${TAB_TOGGL_BILLABLE:-false}"

  if [ -n "${TAB_TOGGL_MONITOR_PID:-}" ] && kill -0 "$TAB_TOGGL_MONITOR_PID" 2>/dev/null; then
    _tabbing_out '  Monitor:     active (pid %s)\n' "$TAB_TOGGL_MONITOR_PID"
  else
    _tabbing_out '  Monitor:     inactive\n'
  fi
}
