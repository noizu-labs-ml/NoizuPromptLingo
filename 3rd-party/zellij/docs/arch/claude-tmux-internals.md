# Claude Code Tmux Internals — What the Shim Must Satisfy

## Overview

This document describes how Claude Code's TypeScript codebase interacts with tmux. The `zellij-cct-tmux` shim must satisfy these contracts for Claude Code to function correctly inside Zellij.

## Detection (`src/utils/swarm/backends/detection.ts`)

Claude Code captures `$TMUX` and `$TMUX_PANE` at module load:

| Env Var | Used For | Shim Must Provide |
|---|---|---|
| `TMUX` | Detect "inside tmux" — gates TmuxBackend activation | Any non-empty value in format `path,pid,pane_index` |
| `TMUX_PANE` | Leader pane ID for split-window targeting | A `%N` format ID (e.g., `%0`) |

**Critical:** Claude only checks the env var — it never runs `tmux display-message` as a detection fallback. If `$TMUX` is unset, TmuxBackend is never used.

## Socket Isolation (`src/utils/tmuxSocket.ts`)

Claude creates an isolated socket via `-L claude-<PID>`. The shim sees these `-L` flags and should **strip them** — Zellij has no socket concept. Claude also passes `-S` flags in some paths.

Key behaviors the shim must handle:
- `tmux -L claude-12345 new-session -d -s base` — Create initial session (can be a no-op; the Zellij session already exists)
- `tmux -L claude-12345 set-environment -g KEY VALUE` — Set env var in session (can be a no-op or mapped to Zellij env)
- `tmux -L claude-12345 display-message -p '#{socket_path},#{pid}'` — Return socket info; shim should return a synthetic value
- `tmux -L claude-12345 kill-server` — Cleanup on exit (no-op for Zellij)

## TmuxBackend Commands (`src/utils/swarm/backends/TmuxBackend.ts`)

These are the actual pane management commands Claude issues:

### Pane Creation
```
tmux split-window -t %0 -h -l 70% -P -F '#{pane_id}'
tmux split-window -t %1 -v -P -F '#{pane_id}'
```
- `-P -F '#{pane_id}'` — Must print the new pane's ID to stdout in `%N` format
- `-h` / `-v` — Horizontal / vertical split
- `-l 70%` — Size hint (best-effort for Zellij)
- `-t %N` — Target pane to split from

### Command Execution
```
tmux send-keys -t %1 'claude --agent-type researcher' Enter
```
- Must wait for shell readiness before sending keys (the shim's key advantage over real tmux)

### Pane Properties
```
tmux select-pane -t %1 -P 'bg=default,fg=blue'
tmux select-pane -t %1 -T 'researcher'
tmux set-option -p -t %1 pane-border-style 'fg=blue'
tmux set-option -p -t %1 pane-active-border-style 'fg=blue'
tmux set-option -p -t %1 pane-border-format '#[fg=blue,bold] #{pane_title} #[default]'
tmux set-option -w -t session:0 pane-border-status top
```
- Pane styling is best-effort — Zellij handles borders differently

### Layout
```
tmux select-layout -t session:0 main-vertical
tmux resize-pane -t %0 -x 30%
```
- `main-vertical` with 30% leader is the standard layout
- `tiled` is used for external (non-leader) sessions

### Pane Lifecycle
```
tmux kill-pane -t %1
tmux new-session -d -s __claude_hidden__
tmux break-pane -d -s %1 -t __claude_hidden__:
tmux join-pane -h -s %1 -t session:0
```
- hide = `break-pane` to hidden session; show = `join-pane` back

### Session/Window Queries
```
tmux list-panes -t session:0 -F '#{pane_id}'
tmux list-windows -t claude-swarm -F '#{window_name}'
tmux has-session -t claude-swarm
tmux display-message -p '#{session_name}:#{window_index}'
tmux display-message -t %0 -p '#{session_name}:#{window_index}'
```

## External Swarm Session

When Claude runs **outside** tmux (shouldn't happen with the shim, but for completeness):
```
tmux -L claude-swarm-<PID> new-session -d -s claude-swarm -n swarm-view -P -F '#{pane_id}'
```
- Uses a separate socket (`claude-swarm-<PID>`)
- Creates a `claude-swarm` session with `swarm-view` window

## Format Variables

Claude uses these tmux format variables in `-F` strings:

| Variable | Expected Output |
|---|---|
| `#{pane_id}` | `%N` (e.g., `%0`, `%1`) |
| `#{socket_path}` | A path-like string |
| `#{pid}` | A numeric PID |
| `#{session_name}` | Session name string |
| `#{window_index}` | Numeric window index |
| `#{window_name}` | Window name string |
| `#{pane_title}` | Pane title string |

## Timing Assumptions

- Claude's `TmuxBackend` uses a 200ms delay (`PANE_SHELL_INIT_DELAY_MS`) after pane creation before sending commands
- Pane creation is serialized via a lock — no parallel `split-window` calls
- The shim's readiness detection (`ready_wait.rs`) can replace or supplement this delay

## Exit Codes

- `0` — Success
- Non-zero — Claude logs the error and may retry or fall back gracefully
- `has-session` returning non-zero means "session doesn't exist" (not an error)
