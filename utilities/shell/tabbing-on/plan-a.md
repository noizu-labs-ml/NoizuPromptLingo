# Plan: Tabbing-On Feature Extensions (Items 1–10)

## Context

The user wants to extend the tabbing-on shell tab management system with 10 features spanning themes, context/links in prompts, multiplexer integration, Claude Code integration, and agent tracking. The codebase follows a strict three-layer architecture: POSIX libs (`lib/*.sh`), shell adapters (`shell/tabbing.{bash,zsh}`), and bin entry points. All new shared logic goes in `lib/` as POSIX sh; shell-specific wrappers go in both adapters.

---

## Implementation Order

Dependencies flow: **6 → 3 → 1 → 2 → 5 → 4 → 10 → 7 → 9 → 8**

---

## Item 1: Extend Themes with Optional Tab Color

**New env var:** `TAB_TAB_COLOR` (e.g. `"#7e3af2"` or named color like `"purple"`)

### Files to modify:
- **`lib/render.sh`** — Add `_tabbing_parse_hex_color()` (parses `#RRGGBB` → decimal R G B). Modify `_tabbing_apply_urgency_color()` to check `TAB_TAB_COLOR` first; if set, use it instead of urgency-derived color.
- **`shell/tabbing.bash`** (~line 92) — Add `--tab-color=*` / `--tab-color` flag → sets `TAB_TAB_COLOR`
- **`shell/tabbing.zsh`** — Mirror
- **`lib/session.sh`** — Add `TAB_TAB_COLOR` to save/load
- Both adapters `tabbing-off()` — Add to unset list

### Named color palette (small):
`red=#cc3333, orange=#cc6633, yellow=#ccaa33, green=#33aa33, blue=#3366cc, purple=#7e3af2, pink=#cc33aa, gray=#787878`

---

## Item 2: `--context=""` Flag

**New env var:** `TAB_CONTEXT`

### Files to modify:
- **`shell/tabbing.bash`** — Add `--context=*` / `--context` flag to `tabbing-on()` parser. Store in `TAB_CONTEXT`.
- **`shell/tabbing.zsh`** — Mirror
- **`shell/tabbing.bash` `_tabbing_precmd()`** — When `TAB_CONTEXT` is set, prepend rendered context to `PS1`. Save original PS1 in `_TABBING_ORIG_PS1`. Wrap non-printing chars in `\001...\002`.
- **`shell/tabbing.zsh` `_tabbing_precmd()`** — Same but use `%{...%}` for non-printing chars.
- **`lib/session.sh`** — Add `TAB_CONTEXT` to save/load
- Both `tabbing-off()` — Unset + restore original PS1

### Context rendering pipeline (in precmd):
```
TAB_CONTEXT → _tabbing_expand_proj_links → _tabbing_md_to_osc8 → wrap in prompt escapes → prepend to PS1
```

---

## Item 3: Markdown Links → OSC 8 Hyperlinks

### New functions in `lib/render.sh`:

**`_tabbing_md_to_osc8()`** — Converts `[text](url)` to OSC 8 hyperlinks.
- Input: string (argument or stdin via `input="${1:-$(cat)}"`)
- Output: string with `\033]8;;URL\033\\TEXT\033]8;;\033\\`
- Uses `sed`: `s/\[([^]]*)\](\([^)]*\))/ESC]8;;\2ESC\\\\1ESC]8;;ESC\\\\/g`
- POSIX sed with proper escaping

**Important:** Do NOT apply to tab titles (OSC 0 can't nest escape sequences). Only for console output and PS1.

---

## Item 4: Link Substitution in Task Display

### Files to modify:
- **`lib/render.sh` `_tabbing_display()`** (~line 837) — Pipe title/status through `_tabbing_md_to_osc8` when outputting to console
- **`lib/todo.sh` `_tabbing_todo_list()`** (~line 115) — Pipe awk output through `_tabbing_md_to_osc8` for display
- Tab title OSC 0 rendering is NOT affected (plain text only)

---

## Item 5: Predefined Tasks Include Context

### Files to modify:
- **`lib/todo.sh` `_tabbing_todo_add()`** — Accept 5th param `context`. Write `context: "..."` to YAML.
- **`lib/todo.sh` `_tabbing_todo_get()`** — Parse `context:` field, output `TODO_CONTEXT="..."`
- **`lib/todo.sh` `_tabbing_todo_switch()`** — After eval of get, `export TAB_CONTEXT="$TODO_CONTEXT"` if non-empty
- **`bin/tabbing-todo`** — Add `--context` / `-c` flag, pass to `_tabbing_todo_add`
- **`bin/tabbing-todo` export-switch handler** — Emit `export TAB_CONTEXT="..."`

---

## Item 6: `--proj-root` / `TAB_PROJ_ROOT`

**New env var:** `TAB_PROJ_ROOT` (defaults to `$PWD` when unset)

### New function in `lib/render.sh`:

**`_tabbing_expand_proj_links()`** — Replaces `](//path)` with `](file://$TAB_PROJ_ROOT/path)`.
- Uses `sed` to match `](//` and expand
- Runs BEFORE `_tabbing_md_to_osc8` in the pipeline

### Files to modify:
- **`shell/tabbing.bash`** — Add `--proj-root=*` / `--proj-root` flag
- **`shell/tabbing.zsh`** — Mirror
- **`lib/session.sh`** — Add `TAB_PROJ_ROOT` to save/load
- Both `tabbing-off()` — Unset

---

## Item 7: `tabbing-on-aside`

Opens a side pane in the current multiplexer or terminal.

### New file: `lib/multiplexer.sh` (POSIX sh)

Functions:
- **`_tabbing_detect_multiplexer()`** — Sets `TAB_MULTIPLEXER` to `tmux`, `zellij`, or empty. Checks `$TMUX`, `$ZELLIJ_SESSION_NAME`.
- **`_tabbing_aside_tmux()`** — `tmux split-window -h -p 30` with TAB_* env forwarding via `-e`. Names pane via `tmux select-pane -T`.
- **`_tabbing_aside_zellij()`** — `zellij action new-pane --direction right` + `zellij action rename-pane`.
- **`_tabbing_aside_iterm2()`** — `osascript` to split vertically (macOS only, guarded).
- **`_tabbing_aside()`** — Dispatch by `TAB_MULTIPLEXER`, fallback to terminal-native. Default pane name: current emoji + "(aside)".

### New file: `bin/tabbing-on-aside`
- Sources `_tabbing-wrapper` + `lib/multiplexer.sh`
- Parses: positional pane name, `--color COLOR`, `--size N` (percentage)
- Calls `_tabbing_aside`

### Adapter changes:
- Both adapters: add `tabbing-on-aside()` function delegating to bin script

### Source in wrapper:
- `bin/_tabbing-wrapper` — Add `source "$TABBING_ROOT/lib/multiplexer.sh"`

---

## Item 8: tmux/zellij Integration Roadmap (Design Only)

### 8a. Status Bar Integration
- New `bin/tabbing-tmux-status` script callable from `tmux set -g status-right '#(tabbing-tmux-status)'`
- Reads session env file, outputs formatted emoji + title + status
- Zellij equivalent via plugin system or `zellij action rename-tab`

### 8b. Window/Tab Naming Sync
- In `_tabbing_render()`, after OSC 0, optionally call `tmux rename-window` / `zellij action rename-tab`
- Gated behind `TAB_MUX_SYNC=1` flag

### 8c. Session Save/Restore
- `_tabbing_tmux_session_save()` — Iterate tmux windows, capture TAB_* from each, write YAML
- `_tabbing_tmux_session_restore()` — Recreate windows with saved state
- New `bin/tabbing-session save|restore|list`

### 8d. Keybindings
- New `conf/tmux-bindings.conf` — Sample bind-keys for aside, task switching, status update
- New `conf/zellij-keybindings.kdl`

### 8e. Layout Presets
- `_tabbing_tmux_layout_coding()` — Main (60%) + aside (20%) + logs (20%)
- `_tabbing_tmux_layout_review()` — Two equal panes
- New `bin/tabbing-layout coding|review|custom`

### 8f. Pane-Specific Task Assignment
- Store pane→task mappings in YAML
- `TAB_PANE_ID` from `tmux display-message -p '#{pane_id}'`
- Functions: `_tabbing_pane_assign`, `_tabbing_pane_info`

---

## Item 9: `tabbing-on-claude`

### New file: `lib/claude.sh` (POSIX sh)

Functions:
- **`_tabbing_claude_build_context()`** — Assembles context string from TAB_TITLE, TAB_STATUS, TAB_CONTEXT, and optionally a task's details (title, description, context)
- **`_tabbing_claude_record()`** — Sets `TAB_AGENT="claude:SESSION_NAME"`, records `claude_start` event

### New file: `bin/tabbing-on-claude`

Flags:
| Flag | Purpose |
|------|---------|
| `--session NAME` | Claude session name (default: `TAB_TITLE-TAB_ID`) |
| `--worktree PATH` | Working directory (default: `$TAB_PROJ_ROOT` or `$PWD`) |
| `--system-prompt "..."` | Additional system prompt text |
| `--task ID` | Load task details as context |
| `--resume` | Resume existing Claude session |
| `--print` | Use Claude `--print` mode |
| `--aside` | Open Claude in a side pane (reuses `lib/multiplexer.sh`) |
| `--model MODEL` | Model override |

Behavior:
1. Build context from current tab state + task details + user system prompt
2. Set `TAB_AGENT="claude:$session_name"`, record `claude_start`
3. If `--aside`: open in multiplexer pane with the claude command
4. Else: exec claude in current shell
5. On exit: record `claude_stop`

### Adapter changes:
- Both adapters: add `tabbing-on-claude()` delegating to bin script

---

## Item 10: `--agent` Flag

**New env var:** `TAB_AGENT`

### Files to modify:
- **`shell/tabbing.bash`** — Add `--agent=*` / `--agent` flag to `tabbing-on()` parser
- **`shell/tabbing.zsh`** — Mirror
- **`lib/session.sh`** — Add `TAB_AGENT` to save/load
- **`lib/history.sh` `_tabbing_record_event()`** — Append `agent: "..."` to event YAML when `TAB_AGENT` is set
- **`lib/todo.sh` `_tabbing_todo_add()`** — Accept agent param, write to YAML. Default to `$TAB_AGENT`.
- **`lib/todo.sh` `_tabbing_todo_get()`** — Parse `agent:` field
- **`lib/history.sh` report functions** — Add agent time breakdown section
- Both `tabbing-off()` — Add to unset list

---

## New Files Summary

| File | Type | Purpose |
|------|------|---------|
| `lib/multiplexer.sh` | POSIX lib | Multiplexer detection + pane operations |
| `lib/claude.sh` | POSIX lib | Claude Code context building |
| `bin/tabbing-on-aside` | Entry point | Aside pane command |
| `bin/tabbing-on-claude` | Entry point | Claude Code launcher |
| `conf/tmux-bindings.conf` | Config | Sample tmux keybindings (item 8) |
| `conf/zellij-keybindings.kdl` | Config | Sample zellij keybindings (item 8) |

## Modified Files Summary

| File | Changes |
|------|---------|
| `lib/render.sh` | `_tabbing_parse_hex_color`, `_tabbing_md_to_osc8`, `_tabbing_expand_proj_links`, tab-color override in apply_urgency_color, link rendering in display |
| `lib/session.sh` | Add TAB_TAB_COLOR, TAB_CONTEXT, TAB_PROJ_ROOT, TAB_AGENT to save/load |
| `lib/todo.sh` | Add context + agent fields to add/get/switch |
| `lib/history.sh` | Add agent to events, agent time in reports |
| `shell/tabbing.bash` | Flags: --tab-color, --context, --proj-root, --agent. PS1 context rendering. New function wrappers. |
| `shell/tabbing.zsh` | Mirror all bash adapter changes |
| `bin/_tabbing-wrapper` | Source multiplexer.sh |
| `bin/tabbing-todo` | Add --context flag |

## Verification Plan

1. **Tab color**: `tabbing-on --tab-color "#7e3af2" "Test"` — verify iTerm2/Kitty tab color changes
2. **Context**: `tabbing-on --context="Working on [docs](//README.md)" "Proj"` — verify PS1 shows context with clickable link
3. **Links**: Confirm `[text](url)` in context/display renders as OSC 8 hyperlink (hover shows URL in terminal)
4. **Proj root**: `tabbing-on --proj-root /path "Proj"` then verify `//file` links expand correctly
5. **Todo context**: `tabbing-todo "task" -c "See [spec](//docs/spec.md)"` then `tabbing-todo --pick` — verify context carries over
6. **Agent**: `tabbing-on --agent "claude:main" "Proj"` then `tabbing-report` — verify agent appears in history
7. **Aside**: Inside tmux, `tabbing-on-aside "helper"` — verify pane opens with name
8. **Claude**: `tabbing-on-claude --task 1 --aside` — verify Claude opens in side pane with task context
9. **Demo runner**: Run `bin/demo-runner` to verify no regressions

