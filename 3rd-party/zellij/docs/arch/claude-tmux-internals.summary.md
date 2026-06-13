# Claude Code Tmux Internals — Summary

Claude Code's `TmuxBackend` drives multi-agent teams via `tmux` CLI calls. The `zellij-cct-tmux` shim must satisfy these contracts:

- **Detection**: `$TMUX` (non-empty, `path,pid,pane` format) and `$TMUX_PANE` (`%N` format) must be set. Claude never probes — env vars are the only signal.
- **Socket flags**: `-L`/`-S` flags are passed on most commands — strip them (Zellij has no sockets).
- **Pane creation**: `split-window` with `-P -F '#{pane_id}'` must print a `%N` ID to stdout.
- **Command dispatch**: `send-keys -t %N command Enter` sends commands to panes. Shell readiness before first `send-keys` is critical.
- **Pane styling**: `select-pane -P`, `set-option -p` for border colors/titles — best-effort in Zellij.
- **Layout**: `select-layout main-vertical` + `resize-pane -x 30%` for leader pane; `tiled` for equal splits.
- **Queries**: `list-panes`, `list-windows`, `has-session`, `display-message` with format variables (`#{pane_id}`, `#{session_name}`, etc.).
- **Lifecycle**: `kill-pane`, `break-pane` (hide), `join-pane` (show).

See [claude-tmux-internals.md](claude-tmux-internals.md) for the full command reference and [cct-tmux-shim.md](cct-tmux-shim.md) for the shim architecture.
