#!/bin/sh
# lib/history.sh — TAB_ID generation and YAML history tracking
#
# Tracks title/status/emoji changes per tab with timestamps.
# History stored in ~/.local/state/tabbing/history/{TAB_ID}.yaml

# ---------------------------------------------------------------------------
# Generate unique TAB_ID if not already set
# Called automatically on first tabbing-on invocation
# ---------------------------------------------------------------------------
_tabbing_ensure_tab_id() {
  if [ -n "${TAB_ID:-}" ]; then
    return
  fi
  if [ -r /dev/urandom ]; then
    TAB_ID="$(od -An -tx1 -N4 /dev/urandom 2>/dev/null | tr -d ' \n')"
  fi
  # Fallback if /dev/urandom failed or unavailable
  if [ -z "${TAB_ID:-}" ]; then
    TAB_ID="$(printf '%04x%04x' $$ "$(date +%s)" | cut -c1-8)"
  fi
  export TAB_ID
}

# ---------------------------------------------------------------------------
# Get/create the history directory
# Respects XDG_STATE_HOME, defaults to ~/.local/state
# ---------------------------------------------------------------------------
_tabbing_state_dir() {
  printf '%s/tabbing' "${XDG_STATE_HOME:-$HOME/.local/state}"
}

_tabbing_history_dir() {
  local dir
  dir="$(_tabbing_state_dir)/history"
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
  fi
  printf '%s' "$dir"
}

# ---------------------------------------------------------------------------
# Get the history file path for the current tab
# ---------------------------------------------------------------------------
_tabbing_history_file() {
  printf '%s/%s.yaml' "$(_tabbing_history_dir)" "${TAB_ID}"
}

# ---------------------------------------------------------------------------
# Record a history event
# Args: event_type (init|title|status|emoji|urgency|todo_add|todo_switch|
#                    todo_done|record_start|record_stop)
# Appends a timestamped YAML entry to the tab's history file.
# ---------------------------------------------------------------------------
_tabbing_record_event() {
  local event_type="${1:-status}"
  _tabbing_ensure_tab_id

  local hfile
  hfile="$(_tabbing_history_file)"

  # Write header on first event
  if [ ! -f "$hfile" ]; then
    printf 'tab_id: "%s"\n' "$TAB_ID" >> "$hfile"
    printf 'terminal: "%s"\n' "${TAB_TERMINAL:-unknown}" >> "$hfile"
    printf 'started: "%s"\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date +%Y-%m-%dT%H:%M:%SZ)" >> "$hfile"
    printf 'entries:\n' >> "$hfile"
  fi

  # Append entry (all string values YAML-escaped)
  local ts
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date +%Y-%m-%dT%H:%M:%SZ)"

  printf '  - timestamp: "%s"\n' "$ts" >> "$hfile"
  printf '    event: "%s"\n' "$event_type" >> "$hfile"

  if [ -n "${TAB_TITLE:-}" ]; then
    printf '    title: "%s"\n' "$(_tabbing_yaml_escape "$TAB_TITLE")" >> "$hfile"
  fi
  if [ -n "${TAB_STATUS:-}" ]; then
    printf '    status: "%s"\n' "$(_tabbing_yaml_escape "$TAB_STATUS")" >> "$hfile"
  fi
  if [ -n "${TAB_URGENCY:-}" ]; then
    printf '    urgency: %s\n' "$TAB_URGENCY" >> "$hfile"
  fi
  if [ -n "${TAB_EMOJI:-}" ]; then
    printf '    emoji: "%s"\n' "$TAB_EMOJI" >> "$hfile"
  fi
  if [ -n "${TAB_RECORDING:-}" ]; then
    printf '    recording: "%s"\n' "$(_tabbing_yaml_escape "$TAB_RECORDING")" >> "$hfile"
  fi
}

# ---------------------------------------------------------------------------
# List all known tab IDs from history
# ---------------------------------------------------------------------------
_tabbing_history_list_tabs() {
  local dir
  dir="$(_tabbing_history_dir)"
  if [ ! -d "$dir" ]; then
    echo "No history found." >&2
    return 1
  fi
  local rec_base
  rec_base="$(_tabbing_state_dir)/recordings"

  for f in "$dir"/*.yaml; do
    [ -f "$f" ] || continue
    local tab_id started title rec_count
    tab_id="$(sed -n 's/^tab_id: "\(.*\)"/\1/p' "$f" | head -1)"
    started="$(sed -n 's/^started: "\(.*\)"/\1/p' "$f" | head -1)"
    title="$(grep '    title: ' "$f" | tail -1 | sed 's/.*title: "\(.*\)"/\1/')"

    # Count recordings for this tab
    rec_count=0
    if [ -d "$rec_base/$tab_id" ]; then
      rec_count="$(find "$rec_base/$tab_id" -name '*.cast' 2>/dev/null | wc -l | tr -d ' ')"
    fi

    if [ "$rec_count" -gt 0 ]; then
      printf '  %s  %s  %-20s  [%s recordings]\n' "$tab_id" "$started" "$title" "$rec_count"
    else
      printf '  %s  %s  %s\n' "$tab_id" "$started" "$title"
    fi
  done
}

# ---------------------------------------------------------------------------
# Search history files for a query string
# Args: query_string
# ---------------------------------------------------------------------------
_tabbing_history_search() {
  local query="$1"
  local dir
  dir="$(_tabbing_history_dir)"
  if [ ! -d "$dir" ]; then
    echo "No history found." >&2
    return 1
  fi

  printf 'Searching for: %s\n\n' "$query"
  local found=0
  for f in "$dir"/*.yaml; do
    [ -f "$f" ] || continue
    if grep -qi "$query" "$f" 2>/dev/null; then
      local tab_id
      tab_id="$(sed -n 's/^tab_id: "\(.*\)"/\1/p' "$f" | head -1)"
      printf '--- Tab %s ---\n' "$tab_id"
      grep -i -B2 -A2 "$query" "$f" 2>/dev/null | grep -v '^--$'
      printf '\n'
      found=1
    fi
  done
  if [ "$found" -eq 0 ]; then
    printf 'No results found.\n'
  fi
}

# ---------------------------------------------------------------------------
# Report: compute time-in-state for a tab's history
# Args: [tab_id] (defaults to current TAB_ID)
# Output: ASCII bar chart of time spent in each status
# ---------------------------------------------------------------------------
_tabbing_report() {
  local tab_id="${1:-$TAB_ID}"
  local hfile
  hfile="$(_tabbing_history_dir)/${tab_id}.yaml"

  if [ ! -f "$hfile" ]; then
    echo "No history for tab $tab_id" >&2
    return 1
  fi

  printf 'Status Distribution (tab %s):\n' "$tab_id"

  # Use awk to compute time-in-state
  awk '
    BEGIN { n = 0; total = 0 }
    /^  - timestamp:/ {
      gsub(/"/, "", $2)
      # Parse ISO timestamp to epoch using a simple approach
      ts = $2
      n++
      timestamps[n] = ts
    }
    /^    status:/ {
      st = $0
      sub(/^    status: "/, "", st)
      sub(/"$/, "", st)
      statuses[n] = st
    }
    END {
      if (n < 1) { print "  (no entries)"; exit }

      # Convert timestamps to seconds (approximate: use shell date)
      # For pure awk, we compute relative differences from ISO strings
      for (i = 1; i < n; i++) {
        s = statuses[i]
        if (s == "") s = "(no status)"

        # Full date-aware diff: days*86400 + hours*3600 + min*60 + sec
        split(timestamps[i], da, /[-T:]/)
        split(timestamps[i+1], db, /[-T:]/)
        gsub(/Z/, "", da[6]); gsub(/Z/, "", db[6])

        sec_a = da[4]*3600 + da[5]*60 + da[6]
        sec_b = db[4]*3600 + db[5]*60 + db[6]

        # Day difference (approximate: assume same month for simplicity)
        day_diff = (db[3] - da[3])
        diff = day_diff * 86400 + (sec_b - sec_a)
        if (diff < 0) diff = 0

        if (s in durations) durations[s] += diff
        else durations[s] = diff
        total += diff
      }
      # Last entry counts as "still active" — add 0 or skip
      s = statuses[n]
      if (s != "" && !(s in durations)) durations[s] = 0

      if (total == 0) total = 1  # avoid div by zero

      # Sort by duration (simple bubble sort on keys)
      nk = 0
      for (k in durations) { nk++; keys[nk] = k }
      for (i = 1; i <= nk; i++) {
        for (j = i+1; j <= nk; j++) {
          if (durations[keys[j]] > durations[keys[i]]) {
            tmp = keys[i]; keys[i] = keys[j]; keys[j] = tmp
          }
        }
      }

      bar_width = 30
      for (i = 1; i <= nk; i++) {
        k = keys[i]
        pct = int(durations[k] * 100 / total)
        filled = int(pct * bar_width / 100)
        if (filled < 0) filled = 0

        hrs = int(durations[k] / 3600)
        mins = int((durations[k] % 3600) / 60)

        bar = ""
        for (bi = 0; bi < filled; bi++) bar = bar "\xe2\x96\x88"
        for (bi = filled; bi < bar_width; bi++) bar = bar " "

        printf "  %-14s [%s] %3d%%  %dh %02dm\n", k, bar, pct, hrs, mins
      }
    }
  ' "$hfile"

  # Show associated recordings if any exist
  local rec_dir
  rec_dir="$(_tabbing_state_dir)/recordings/${tab_id}"
  if [ -d "$rec_dir" ]; then
    local cast_count=0
    for cf in "$rec_dir"/*.cast; do
      [ -f "$cf" ] || continue
      cast_count=$((cast_count + 1))
    done
    if [ "$cast_count" -gt 0 ]; then
      printf '\n  Recordings (%s):\n' "$cast_count"
      for cf in "$rec_dir"/*.cast; do
        [ -f "$cf" ] || continue
        local fname size
        fname="$(basename "$cf")"
        size="$(wc -c < "$cf" | tr -d ' ')"
        # Extract status from filename: {timestamp}_{status}.cast
        local status_part="${fname%.cast}"
        status_part="${status_part#*_}"
        printf '    %s  (%s bytes)  [%s]\n' "$fname" "$size" "$status_part"
      done
      printf '  Path: %s/\n' "$rec_dir"
    fi
  fi
}

# ---------------------------------------------------------------------------
# Report: output Mermaid pie chart syntax
# Args: [tab_id] (defaults to current TAB_ID)
# ---------------------------------------------------------------------------
_tabbing_report_mermaid() {
  local tab_id="${1:-$TAB_ID}"
  local hfile
  hfile="$(_tabbing_history_dir)/${tab_id}.yaml"

  if [ ! -f "$hfile" ]; then
    echo "No history for tab $tab_id" >&2
    return 1
  fi

  awk '
    BEGIN { n = 0; total = 0 }
    /^  - timestamp:/ {
      gsub(/"/, "", $2)
      n++
      timestamps[n] = $2
    }
    /^    status:/ {
      st = $0
      sub(/^    status: "/, "", st)
      sub(/"$/, "", st)
      statuses[n] = st
    }
    END {
      if (n < 1) exit

      for (i = 1; i < n; i++) {
        s = statuses[i]
        if (s == "") s = "(no status)"

        split(timestamps[i], da, /[-T:]/)
        split(timestamps[i+1], db, /[-T:]/)
        gsub(/Z/, "", da[6]); gsub(/Z/, "", db[6])

        sec_a = da[4]*3600 + da[5]*60 + da[6]
        sec_b = db[4]*3600 + db[5]*60 + db[6]
        day_diff = (db[3] - da[3])
        diff = day_diff * 86400 + (sec_b - sec_a)
        if (diff < 0) diff = 0

        if (s in durations) durations[s] += diff
        else durations[s] = diff
        total += diff
      }

      if (total == 0) total = 1

      printf "pie title Time by Status (tab %s)\n", tab_id
      for (k in durations) {
        pct = int(durations[k] * 100 / total)
        if (pct < 1) pct = 1
        printf "  \"%s\" : %d\n", k, pct
      }
    }
  ' tab_id="$tab_id" "$hfile"
}

# ---------------------------------------------------------------------------
# Report: combine all tabs
# ---------------------------------------------------------------------------
_tabbing_report_all() {
  local dir
  dir="$(_tabbing_history_dir)"
  if [ ! -d "$dir" ]; then
    echo "No history found." >&2
    return 1
  fi
  for f in "$dir"/*.yaml; do
    [ -f "$f" ] || continue
    local tab_id
    tab_id="$(sed -n 's/^tab_id: "\(.*\)"/\1/p' "$f" | head -1)"
    printf '\n'
    _tabbing_report "$tab_id"
  done
}

# ---------------------------------------------------------------------------
# Full info dump for current tab: state, paths, recordings, todos
# ---------------------------------------------------------------------------
_tabbing_info() {
  local tab_id="${1:-$TAB_ID}"

  printf 'Tab Info\n'
  printf '========\n\n'

  # Current state
  printf '  Tab ID:     %s\n' "${tab_id:-(none)}"
  printf '  Terminal:   %s\n' "${TAB_TERMINAL:-unknown}"
  printf '  Title:      %s\n' "${TAB_TITLE:-(not set)}"
  printf '  Status:     %s\n' "${TAB_STATUS:-(not set)}"
  printf '  Urgency:    %s\n' "${TAB_URGENCY:-(not set)}"
  printf '  Emoji:      %s\n' "${TAB_EMOJI:-(not set)}"
  printf '  Highlight:  %s\n' "${TAB_HIGHLIGHT:-(not set)}"
  if _tabbing_is_recording 2>/dev/null; then
    printf '  Recording:  %s\n' "${TAB_RECORDING}"
  else
    printf '  Recording:  no\n'
  fi

  printf '\n'
  printf 'Storage\n'
  printf '-------\n'
  local state_dir
  state_dir="$(_tabbing_state_dir)"

  # History
  local hfile="${state_dir}/history/${tab_id}.yaml"
  if [ -f "$hfile" ]; then
    local entry_count
    entry_count="$(grep -c '  - timestamp:' "$hfile" 2>/dev/null || echo 0)"
    printf '  History:     %s  (%s entries)\n' "$hfile" "$entry_count"
  else
    printf '  History:     (none)\n'
  fi

  # Todos
  local tfile="${state_dir}/todos/${tab_id}.yaml"
  if [ -f "$tfile" ]; then
    local todo_count pending_count
    todo_count="$(grep -c '  - id:' "$tfile" 2>/dev/null || echo 0)"
    pending_count="$(grep -c 'status: "pending"' "$tfile" 2>/dev/null || echo 0)"
    printf '  Todos:       %s  (%s total, %s pending)\n' "$tfile" "$todo_count" "$pending_count"
  else
    printf '  Todos:       (none)\n'
  fi

  # Recordings
  local rec_dir="${state_dir}/recordings/${tab_id}"
  if [ -d "$rec_dir" ]; then
    local cast_count=0
    for cf in "$rec_dir"/*.cast; do
      [ -f "$cf" ] || continue
      cast_count=$((cast_count + 1))
    done
    if [ "$cast_count" -gt 0 ]; then
      printf '  Recordings:  %s/  (%s files)\n' "$rec_dir" "$cast_count"
      for cf in "$rec_dir"/*.cast; do
        [ -f "$cf" ] || continue
        local fname size
        fname="$(basename "$cf")"
        size="$(wc -c < "$cf" | tr -d ' ')"
        printf '               - %s  (%s bytes)\n' "$fname" "$size"
      done
    else
      printf '  Recordings:  %s/  (empty)\n' "$rec_dir"
    fi
  else
    printf '  Recordings:  (none)\n'
  fi
  printf '\n'
}

# ---------------------------------------------------------------------------
# Clear history for a tab
# Args: [tab_id] [--before DATE] [--after DATE]
#   No date args: delete the entire history file
#   With date args: filter entries, keeping only those outside the range
# ---------------------------------------------------------------------------
_tabbing_clear_history() {
  local tab_id="${1:-$TAB_ID}"
  local before="$2"
  local after="$3"

  local hfile
  hfile="$(_tabbing_history_dir)/${tab_id}.yaml"

  if [ ! -f "$hfile" ]; then
    printf 'tabbing: no history for tab %s\n' "$tab_id"
    return 0
  fi

  if [ -z "$before" ] && [ -z "$after" ]; then
    # Delete entire file
    rm -f "$hfile"
    printf 'tabbing: cleared history for tab %s\n' "$tab_id"
    return 0
  fi

  # Filter by time range — keep entries outside the range
  local tmpfile="${hfile}.tmp"
  awk -v before="$before" -v after="$after" '
    BEGIN { in_entry = 0; skip = 0; header = 1 }
    /^  - timestamp:/ {
      if (in_entry && !skip) {
        printf "%s", buf
      }
      in_entry = 1; skip = 0; buf = ""
      ts = $2; gsub(/"/, "", ts)
      if (after != "" && ts < after) skip = 0
      else if (before != "" && ts > before) skip = 0
      else if (after != "" && before != "" && ts >= after && ts <= before) skip = 1
      else if (after != "" && ts >= after) skip = 1
      else if (before != "" && ts <= before) skip = 1
    }
    in_entry { buf = buf $0 "\n"; next }
    { print }
    END { if (in_entry && !skip) printf "%s", buf }
  ' "$hfile" > "$tmpfile"
  mv "$tmpfile" "$hfile"

  printf 'tabbing: cleared history entries'
  [ -n "$after" ] && printf ' after %s' "$after"
  [ -n "$before" ] && printf ' before %s' "$before"
  printf ' for tab %s\n' "$tab_id"
}

# ---------------------------------------------------------------------------
# Clear todos for a tab
# Args: [tab_id]
# ---------------------------------------------------------------------------
_tabbing_clear_todos() {
  local tab_id="${1:-$TAB_ID}"
  local tfile
  tfile="$(_tabbing_state_dir)/todos/${tab_id}.yaml"

  if [ ! -f "$tfile" ]; then
    printf 'tabbing: no todos for tab %s\n' "$tab_id"
    return 0
  fi

  rm -f "$tfile"
  printf 'tabbing: cleared todos for tab %s\n' "$tab_id"
}

# ---------------------------------------------------------------------------
# Clear recordings for a tab
# Args: [tab_id]
# ---------------------------------------------------------------------------
_tabbing_clear_recordings() {
  local tab_id="${1:-$TAB_ID}"
  local rec_dir
  rec_dir="$(_tabbing_state_dir)/recordings/${tab_id}"

  if [ ! -d "$rec_dir" ]; then
    printf 'tabbing: no recordings for tab %s\n' "$tab_id"
    return 0
  fi

  local count=0
  for cf in "$rec_dir"/*.cast; do
    [ -f "$cf" ] || continue
    count=$((count + 1))
  done

  rm -rf "$rec_dir"
  printf 'tabbing: cleared %s recordings for tab %s\n' "$count" "$tab_id"
}

# ---------------------------------------------------------------------------
# Clear all data for a tab (history + todos + recordings)
# Args: [tab_id]
# ---------------------------------------------------------------------------
_tabbing_clear_all() {
  local tab_id="${1:-$TAB_ID}"
  _tabbing_clear_history "$tab_id"
  _tabbing_clear_todos "$tab_id"
  _tabbing_clear_recordings "$tab_id"
}

# ---------------------------------------------------------------------------
# Clear everything across ALL tabs
# ---------------------------------------------------------------------------
_tabbing_clear_everything() {
  local state_dir
  state_dir="$(_tabbing_state_dir)"
  rm -rf "${state_dir}/history" "${state_dir}/todos" "${state_dir}/recordings"
  printf 'tabbing: cleared all data for all tabs\n'
}
