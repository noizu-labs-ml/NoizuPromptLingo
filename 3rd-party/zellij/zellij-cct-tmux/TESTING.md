# Zellij tmux Shim — Verification Checklist

Run these commands inside a Zellij session with `ZELLIJ_TMUX_COMPAT=1` set.
The `tmux` binary on PATH should resolve to `zellij-tmux-shim`.

## Prerequisites

```bash
# Confirm the shim is active (not real tmux)
which tmux          # should point to zellij-tmux-shim or a symlink to it
file "$(which tmux)" # should be a Mach-O / ELF binary, not /usr/bin/tmux
echo $ZELLIJ $ZELLIJ_TMUX_COMPAT $TMUX
# All three must be non-empty. TMUX should start with "zellij-cct:"
```

## 1. Version & Identity

```bash
tmux -V
# Expected: "tmux 3.6a" (spoofed version for Claude Code compat)
```

## 2. Session Operations

```bash
# List all Zellij sessions in tmux-compatible format
tmux list-sessions
# Expected: one line per session, names visible. Exit 0.

# Check current session exists (no -t flag = uses bridge's validated session)
tmux has-session
# Expected: exit 0.

# Check a named session
tmux has-session -t "$(echo $ZELLIJ_SESSION_NAME)"
# Expected: exit 0 if session exists, 1 if not.
# Note: if ZELLIJ_SESSION_NAME is stale, discovery resolves to first active session.
```

## 3. Display / Format Strings

```bash
tmux display-message -p '#{session_name}'
# Expected: prints the Zellij session name. Exit 0.

tmux display-message -p '#{pane_id}'
# Expected: prints "%0" or similar. Exit 0.

tmux display-message -p '#{window_name}'
# Expected: prints current tab name (may be empty if not mapped). Exit 0.

tmux display-message -p '#{socket_path},#{pid}'
# Expected: "/tmp/zellij-cct-socket,<pid>". Exit 0.
```

## 4. Tab (Window) Operations

```bash
# List tabs as tmux "windows"
tmux list-windows
# Expected: one line per tab, format "N: tab-name". Exit 0.
# Falls back to query-tab-names if list-tabs --json is unavailable.

# List with format string
tmux list-windows -F '#{window_index}:#{window_name}'
# Expected: "0:tab1\n1:tab2\n..." etc. Exit 0.

# Create a new tab
tmux new-window -n test-tab
# Expected: a new Zellij tab named "test-tab" appears. Exit 0.

# Select/switch to a tab by index
tmux select-window -t 0
# Expected: switches to the first tab. Exit 0.

# Rename a tab
tmux rename-window -t test-tab renamed-tab
# Expected: the tab is renamed. Exit 0.

# Close/kill a tab
tmux kill-window -t renamed-tab
# Expected: the tab is closed. Exit 0.
```

## 5. Pane Operations

```bash
# List panes in current tab
tmux list-panes
# Expected: at least one pane listed as "%N: (active)". Exit 0.

# Split horizontally (creates a pane below)
tmux split-window -v
# Expected: a new pane appears below. Exit 0.

# Split vertically (creates a pane to the right)
tmux split-window -h
# Expected: a new pane appears to the right. Exit 0.

# Select a pane
tmux select-pane -t %0
# Expected: focus moves to pane %0. Exit 0.

# Resize pane
tmux resize-pane -D 5
# Expected: pane grows 5 rows downward. Exit 0.

# Kill a pane
tmux kill-pane
# Expected: current pane closes. Exit 0.
# WARNING: don't kill the last pane — it closes the tab.
```

## 6. Send Keys

```bash
# Send keystrokes to current pane
tmux send-keys "echo hello" Enter
# Expected: "echo hello" is typed and Enter is sent in the target pane.

# Send to a specific pane
tmux send-keys -t %0 "pwd" Enter
# Expected: "pwd" is typed in pane %0.
```

## 7. Capture Pane

```bash
tmux capture-pane -p
# Expected: prints the visible content of the current pane. Exit 0.

tmux capture-pane -p -t %0
# Expected: prints content of pane %0. Exit 0.
```

## 8. Layout & Styling

```bash
tmux select-layout even-horizontal
# Expected: panes rearrange to equal horizontal splits. Exit 0. (May be a no-op stub.)

tmux set-option -g status off
# Expected: exit 0 (stub — Zellij manages its own status bar).

tmux show -gv focus-events
# Expected: "on". Exit 0.
```

## 9. Break / Join Pane

```bash
tmux break-pane
# Expected: current pane becomes its own tab. Exit 0.

tmux join-pane -s :1 -t :0
# Expected: moves a pane from tab 1 into tab 0. Exit 0.
```

## 10. Socket-Scoped Commands (Claude Code PTY isolation)

These use `-L <socket>` and target virtual state, not real Zellij tabs.

```bash
tmux -L claude-pty new-session -d -s main
# Expected: exit 0 (no-op, virtual session).

tmux -L claude-pty has-session -t main
# Expected: exit 0 (always claims session exists).

tmux -L claude-pty display-message -p '#{socket_path},#{pid}'
# Expected: "/tmp/zellij-cct-socket,<pid>". Exit 0.

tmux -L claude-pty kill-server
# Expected: exit 0 (no-op).
```

## 11. Stub Commands (should exit 0 silently)

```bash
tmux set-environment FOO bar     # exit 0, no-op
tmux bind-key x kill-pane        # exit 0, no-op
tmux unbind-key x                # exit 0, no-op
tmux setw -g mode-keys vi        # exit 0, no-op
tmux refresh-client              # exit 0, no-op
tmux source-file ~/.tmux.conf    # exit 0, no-op
```

## Logs

Check the shim log for diagnostics after running tests:

```bash
tail -50 "$TMPDIR/zellij-cct/$(echo $ZELLIJ_SESSION_NAME)/tmux-shim.log"
```

Enable verbose logging:

```bash
export ZELLIJ_CCT_DEBUG=1
```

## Fixed Issues (patched 2026-05-27)

1. **Stale session discovery** — `discover_session()` now checks stderr for "not found"
   and skips EXITED sessions when falling back to `list-sessions`. ANSI codes are
   stripped from the session list output.

2. **`has-session` without `-t`** — Now defaults to the bridge's validated current
   session via `zellij_bridge::current_session()`.

3. **`list-windows` JSON fallback** — `tab_resolve::query_tabs()` tries `list-tabs --json`
   first, then falls back to `query-tab-names` (one name per line). `list_windows.rs`
   now reuses `tab_resolve::query_tabs()` instead of duplicating the logic.

4. **`display-message #{window_name}`** — Now queries `tab_resolve::query_tabs()` to
   populate `FormatContext.window_name` before expanding format strings.
