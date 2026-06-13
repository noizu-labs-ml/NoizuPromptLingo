#!/bin/sh
# lib/todo.sh — Todo/task data operations with provider pattern
#
# Manages per-tab todo items stored in YAML files.
# Provider pattern: TAB_TODO_PROVIDER selects the backend (default: builtin).
# Future providers can implement the same _tabbing_todo_* interface.

# ---------------------------------------------------------------------------
# Get the todo file path for a tab
# ---------------------------------------------------------------------------
_tabbing_todo_file() {
  local tab_id="${1:-$TAB_ID}"
  local dir
  dir="$(_tabbing_state_dir)/todos"
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
  fi
  printf '%s/%s.yaml' "$dir" "$tab_id"
}

# ---------------------------------------------------------------------------
# Initialize the todo file if it doesn't exist
# ---------------------------------------------------------------------------
_tabbing_todo_init_file() {
  _tabbing_ensure_tab_id
  local tfile
  tfile="$(_tabbing_todo_file)"

  if [ ! -f "$tfile" ]; then
    printf 'tab_id: "%s"\n' "$TAB_ID" > "$tfile"
    printf 'task_title: "%s"\n' "$(_tabbing_yaml_escape "${TAB_TITLE:-}")" >> "$tfile"
    printf 'next_id: 1\n' >> "$tfile"
    printf 'todos:\n' >> "$tfile"
  fi
}

# ---------------------------------------------------------------------------
# Get the next available todo ID
# ---------------------------------------------------------------------------
_tabbing_todo_next_id() {
  local tfile
  tfile="$(_tabbing_todo_file)"
  if [ ! -f "$tfile" ]; then
    printf '1'
    return
  fi
  local next_id
  next_id="$(sed -n 's/^next_id: \(.*\)/\1/p' "$tfile" | head -1)"
  printf '%s' "${next_id:-1}"
}

# ---------------------------------------------------------------------------
# Increment the next_id in the todo file
# ---------------------------------------------------------------------------
_tabbing_todo_bump_id() {
  local tfile
  tfile="$(_tabbing_todo_file)"
  local current_id
  current_id="$(_tabbing_todo_next_id)"
  local new_id=$((current_id + 1))

  # Use a temp file for portability (BSD sed -i differs from GNU)
  local tmpfile="${tfile}.tmp"
  sed "s/^next_id: .*/next_id: ${new_id}/" "$tfile" > "$tmpfile"
  mv "$tmpfile" "$tfile"
}

# ---------------------------------------------------------------------------
# Add a new todo item
# Args: title [description] [emoji] [urgency]
# ---------------------------------------------------------------------------
_tabbing_todo_add() {
  local title="$1"
  local description="${2:-}"
  local emoji="${3:-}"
  local urgency="${4:-}"

  _tabbing_ensure_tab_id
  _tabbing_todo_init_file

  local tfile
  tfile="$(_tabbing_todo_file)"
  local todo_id
  todo_id="$(_tabbing_todo_next_id)"
  local ts
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date +%Y-%m-%dT%H:%M:%SZ)"

  # Append the todo entry
  printf '  - id: %s\n' "$todo_id" >> "$tfile"
  printf '    title: "%s"\n' "$(_tabbing_yaml_escape "$title")" >> "$tfile"
  if [ -n "$description" ]; then
    printf '    description: "%s"\n' "$(_tabbing_yaml_escape "$description")" >> "$tfile"
  fi
  if [ -n "$emoji" ]; then
    printf '    emoji: "%s"\n' "$emoji" >> "$tfile"
  fi
  if [ -n "$urgency" ]; then
    printf '    urgency: %s\n' "$urgency" >> "$tfile"
  fi
  printf '    status: "pending"\n' >> "$tfile"
  printf '    created: "%s"\n' "$ts" >> "$tfile"

  _tabbing_todo_bump_id

  printf 'tabbing: added todo #%s: %s\n' "$todo_id" "$title"

  # Record in history
  _tabbing_record_event "todo_add"
}

# ---------------------------------------------------------------------------
# List todos for the current tab
# Output format: [id] [status_icon] title
# ---------------------------------------------------------------------------
_tabbing_todo_list() {
  _tabbing_ensure_tab_id
  local tfile
  tfile="$(_tabbing_todo_file)"

  if [ ! -f "$tfile" ]; then
    printf 'No todos for this tab.\n'
    return
  fi

  local task_title
  task_title="$(sed -n 's/^task_title: "\(.*\)"/\1/p' "$tfile" | head -1)"
  printf 'Todos for: %s\n\n' "${task_title:-$TAB_TITLE}"

  # Parse and display todos using awk
  awk '
    /^  - id:/ { id = $3 }
    /^    title:/ {
      t = $0
      sub(/^    title: "/, "", t)
      sub(/"$/, "", t)
      titles[id] = t
    }
    /^    status:/ {
      s = $0
      sub(/^    status: "/, "", s)
      sub(/"$/, "", s)

      if (s == "done") icon = "\xe2\x9c\x85"       # ✅
      else if (s == "active") icon = "\xe2\x96\xb6"  # ▶
      else icon = "\xe2\x97\x8b"                      # ○

      printf "  %s #%-3s %s\n", icon, id, titles[id]
    }
  ' "$tfile"
  printf '\n'
}

# ---------------------------------------------------------------------------
# Get list of pending todo IDs and titles (for interactive selection)
# Output: one line per pending todo: "id title"
# ---------------------------------------------------------------------------
_tabbing_todo_pending() {
  local tfile
  tfile="$(_tabbing_todo_file)"

  if [ ! -f "$tfile" ]; then
    return
  fi

  awk '
    /^  - id:/ { id = $3 }
    /^    title:/ {
      t = $0
      sub(/^    title: "/, "", t)
      sub(/"$/, "", t)
      titles[id] = t
    }
    /^    status:/ {
      s = $0
      sub(/^    status: "/, "", s)
      sub(/"$/, "", s)
      if (s == "pending") {
        printf "%s %s\n", id, titles[id]
      }
    }
  ' "$tfile"
}

# ---------------------------------------------------------------------------
# Get todo details by ID
# Returns: title, description, emoji, urgency, status (as shell variables)
# ---------------------------------------------------------------------------
_tabbing_todo_get() {
  local target_id="$1"
  local tfile
  tfile="$(_tabbing_todo_file)"

  if [ ! -f "$tfile" ]; then
    return 1
  fi

  awk -v target="$target_id" '
    /^  - id:/ { id = $3; in_target = (id == target) }
    in_target && /^    title:/ {
      t = $0; sub(/^    title: "/, "", t); sub(/"$/, "", t)
      print "TODO_TITLE=\"" t "\""
    }
    in_target && /^    description:/ {
      d = $0; sub(/^    description: "/, "", d); sub(/"$/, "", d)
      print "TODO_DESC=\"" d "\""
    }
    in_target && /^    emoji:/ {
      e = $0; sub(/^    emoji: "/, "", e); sub(/"$/, "", e)
      print "TODO_EMOJI=\"" e "\""
    }
    in_target && /^    urgency:/ {
      print "TODO_URGENCY=" $3
    }
    in_target && /^    status:/ {
      s = $0; sub(/^    status: "/, "", s); sub(/"$/, "", s)
      print "TODO_STATUS=\"" s "\""
    }
  ' "$tfile"
}

# ---------------------------------------------------------------------------
# Switch to a todo item (make it active)
# Deactivates the currently active todo, activates the target
# Updates TAB_STATUS, TAB_EMOJI, TAB_URGENCY
# ---------------------------------------------------------------------------
_tabbing_todo_switch() {
  local target_id="$1"
  local tfile
  tfile="$(_tabbing_todo_file)"

  if [ ! -f "$tfile" ]; then
    printf 'tabbing: no todos found\n' >&2
    return 1
  fi

  # Deactivate any currently active todo, activate the target
  local tmpfile="${tfile}.tmp"
  awk -v target="$target_id" '
    /^  - id:/ { id = $3 }
    /^    status:/ {
      s = $0
      sub(/^    status: "/, "", s)
      sub(/"$/, "", s)
      if (s == "active") {
        print "    status: \"pending\""
        next
      }
      if (id == target && s == "pending") {
        print "    status: \"active\""
        next
      }
    }
    { print }
  ' "$tfile" > "$tmpfile"
  mv "$tmpfile" "$tfile"

  # Get the todo's details and apply to tab state
  local todo_info
  todo_info="$(_tabbing_todo_get "$target_id")"
  eval "$todo_info"

  if [ -n "${TODO_TITLE:-}" ]; then
    export TAB_STATUS="$TODO_TITLE"
  fi
  if [ -n "${TODO_EMOJI:-}" ]; then
    export TAB_EMOJI="$TODO_EMOJI"
  fi
  if [ -n "${TODO_URGENCY:-}" ]; then
    export TAB_URGENCY="$TODO_URGENCY"
  fi

  _tabbing_render
  _tabbing_record_event "todo_switch"

  printf 'tabbing: switched to todo #%s: %s\n' "$target_id" "${TODO_TITLE:-}"
}

# ---------------------------------------------------------------------------
# Mark a todo as done
# Args: [id] (defaults to currently active todo)
# ---------------------------------------------------------------------------
_tabbing_todo_done() {
  local target_id="$1"
  local tfile
  tfile="$(_tabbing_todo_file)"

  if [ ! -f "$tfile" ]; then
    printf 'tabbing: no todos found\n' >&2
    return 1
  fi

  # If no ID given, find the active todo
  if [ -z "$target_id" ]; then
    target_id="$(awk '
      /^  - id:/ { id = $3 }
      /^    status:/ {
        s = $0
        sub(/^    status: "/, "", s)
        sub(/"$/, "", s)
        if (s == "active") { print id; exit }
      }
    ' "$tfile")"

    if [ -z "$target_id" ]; then
      printf 'tabbing: no active todo to mark done (specify an id)\n' >&2
      return 1
    fi
  fi

  # Mark the todo as done
  local tmpfile="${tfile}.tmp"
  awk -v target="$target_id" '
    /^  - id:/ { id = $3 }
    /^    status:/ {
      if (id == target) {
        print "    status: \"done\""
        next
      }
    }
    { print }
  ' "$tfile" > "$tmpfile"
  mv "$tmpfile" "$tfile"

  _tabbing_record_event "todo_done"
  printf 'tabbing: marked todo #%s as done\n' "$target_id"
}
