# Claude Code Tmux Shim — Detailed Architecture

## Purpose

Claude Code Agent Teams spawns teammate processes by issuing `tmux` commands (`split-window`, `send-keys`, `kill-pane`, etc.) through its `TmuxBackend`. The backend detects tmux via the `$TMUX` environment variable and invokes the `tmux` binary directly. This shim satisfies that contract without requiring a real tmux installation, running on top of an unmodified Zellij 0.45+ server.

## High-Level Flow

```
Claude Code (TypeScript)
    |  spawns: tmux split-window -h -P -F '#{pane_id}'
    v
zellij-cct-tmux (this binary, symlinked as "tmux")
    1. Log raw invocation
    2. Strip global flags (-L/-S/-f)
    3. Route to command handler
    4. Translate to zellij action
    5. Return tmux-compatible stdout/exit code
    |  spawns: zellij action new-pane --direction right
    v
Zellij server (running)
    Creates pane, returns "terminal_3" on stdout
    |
    v
zellij-cct-tmux
    Maps "terminal_3" -> "%2" via idmap
    Prints "%2" to stdout for Claude Code
```

## Multicall Binary

The binary inspects `argv[0]` to decide its mode:

- **`tmux`** (via symlink) — tmux compatibility mode. Parses tmux-style arguments, translates, delegates.
- **anything else** — prints usage and exits 1.

The activation script creates the symlink at `$XDG_RUNTIME_DIR/zellij-cct/<session>/bin/tmux` and prepends that directory to `$PATH`.

## Command Dispatch Pipeline

```
main.rs
  |  argv[0] == "tmux"?
  v
logger::log_invocation()        <- always logs, ungated
  |
  v
dispatch::strip_global_flags()  <- removes -L, -S, -f before the subcommand
  |
  +-- -L <socket> present?
  |     YES -> handle_socket_scoped()   <- virtual state, no Zellij calls
  |     NO  |
  v
dispatch::run()                 <- match on subcommand name
  |
  +-- "-V"/"--version" -> commands::version::run()
  +-- "split-window"   -> commands::split_window::run()
  +-- "send-keys"      -> commands::send_keys::run()
  +-- "kill-pane"      -> commands::kill_pane::run()
  +-- ... (17 real handlers total)
  +-- "show-options"   -> commands::show_options::run()
  +-- "kill-server" etc -> commands::stub::run()  <- 9 stub categories
  +-- unknown          -> commands::stub::run()   <- logs, exits 0
```

## Core Modules

### `idmap.rs` — Pane ID Translation

tmux uses `%N` pane IDs; Zellij uses `terminal_N`. The idmap maintains a bidirectional mapping persisted to `$XDG_RUNTIME_DIR/zellij-cct/<session>/idmap.json`.

- IDs allocated monotonically (`%0`, `%1`, `%2`...), never reused.
- On `kill-pane`, entries are tombstoned (marked closed), not deleted.
- `created_at` timestamps (epoch seconds) drive the race-fix logic for recently-created panes.
- Corrupt or missing files are silently treated as empty (fresh start).

### `format.rs` — tmux Format String Expansion

Parses `#{...}` sequences and substitutes from a `FormatContext`. Covers the 7 variables Claude Code actually uses: `pane_id`, `session_name`, `window_index`, `window_name`, `pane_title`, `socket_path`, `pid`. Unknown variables expand to empty string. tmux style sequences like `#[fg=red,bold]` pass through unchanged.

### `keys.rs` — Key Name Translation

Maps tmux named keys to byte sequences: `Enter`/`Return`/`C-m` to `0x0D` (CR), `C-c` to `0x03` (SIGINT), arrow keys to ANSI escape sequences, `C-<letter>` to control characters. The `-l` flag disables named-key interpretation. Multiple arguments concatenate in order.

### `zellij_bridge.rs` — Zellij Subprocess Interface

All communication with Zellij goes through this module via `Command::new("zellij")`:

- `action(args)` — prepends `--session <name> action` targeting the current session.
- `command(args)` — bare `zellij <args>` for non-action subcommands like `list-sessions`.

Session name comes from `$ZELLIJ_SESSION_NAME` (set automatically by Zellij in every pane).

### `ready_wait.rs` — Race Condition Fix

**The problem:** Claude Code creates a pane (`split-window`) then immediately sends a command (`send-keys`). If the spawned shell hasn't finished loading, bytes are lost or interleaved.

**The fix:** When `send-keys` targets a pane created within the last 5 seconds (tracked via `idmap.created_at`), the shim polls the pane's screen content:

1. `zellij action dump-screen --pane-id terminal_N`
2. Find the last non-empty line
3. Check if it ends with a prompt character: `$ # > ❯ %`
4. If yes, proceed; if no, sleep 100ms and retry
5. After 3 seconds, send anyway (garbled > hung)

| Env var | Default | Purpose |
|---|---|---|
| `ZELLIJ_CCT_READY_TIMEOUT_MS` | `3000` | Max wait before sending anyway |
| `ZELLIJ_CCT_READY_PATTERN` | `[\$#>❯%]\s*$` | Custom prompt suffix to match |

### `logger.rs` — Observability

Every invocation logged to `$XDG_RUNTIME_DIR/zellij-cct/<session>/tmux-shim.log` (always on). Detailed internal messages gated on `ZELLIJ_CCT_DEBUG=1`.

## Socket-Scoped Commands (`-L <socket>`)

Claude Code creates an isolated tmux server via `-L <socket>` for its Bash tool PTYs. The shim detects `-L` as a global flag and routes those commands to `handle_socket_scoped()` — returning virtual responses without touching the real Zellij session:

| Command | Behavior |
|---|---|
| `new-session -d -s base` | Return success (virtual session) |
| `has-session -t base` | Always return 0 |
| `set-environment -g KEY VAL` | Log and return success |
| `display-message -p '#{socket_path},#{pid}'` | Fabricated socket path + PID |
| `kill-server` | Log and return success |

## Command Translation Reference

### Real Translations

| tmux command | Zellij equivalent | Notes |
|---|---|---|
| `split-window [-h\|-v] -P -F '#{pane_id}'` | `new-pane [--direction right]` | Captures pane ID, allocates `%N` |
| `send-keys -t %N <args> Enter` | `write-chars --pane-id terminal_N <text>` | Key translation + race fix |
| `kill-pane -t %N` | `close-pane --pane-id terminal_N` | Tombstones in idmap |
| `list-panes -F '<fmt>'` | `list-panes --json --all` | JSON parse + format template |
| `has-session -t <name>` | `list-sessions --short` | Grep for session name |
| `new-session -d -s <name>` | `new-tab [--name <name>]` | Sessions -> tabs |
| `new-window -t <sess> -n <name>` | `new-tab --name <name>` | Windows -> tabs |
| `list-windows -F '<fmt>'` | `list-tabs --json` | JSON parse + format template |
| `select-pane -T <title>` | `rename-pane --pane-id terminal_N <title>` | Direct mapping |
| `select-pane -P 'fg=<color>'` | `set-pane-color --pane-id terminal_N --fg <hex>` | Color name -> hex |
| `display-message -p '<fmt>'` | Local format expansion | No Zellij call |
| `list-sessions` | `list-sessions` | Pass-through |
| `capture-pane -p -t %N` | `dump-screen --pane-id terminal_N --full` | Screen capture |
| `show-options` | Local response | Returns tmux-compatible option values |
| `-V` / `--version` | Local response | Returns shim version string |

### Accepted No-Ops (Stubs)

| tmux command | Why no-op |
|---|---|
| `set-option -p pane-border-style` | Zellij renders borders natively |
| `set-option -w pane-border-status` | Zellij always shows pane borders |
| `set-option -p pane-border-format` | Zellij uses pane names for labels |
| `select-layout main-vertical\|tiled` | Zellij auto-layouts |
| `resize-pane -x 30%` | Zellij distributes space automatically |
| `break-pane` / `join-pane` | Pane stays in place |
| `kill-server` | Session managed by Zellij |
| `set-environment` / `setenv` | Env managed outside tmux |
| `rename-window` | Tabs named via Zellij |
| `display-menu` | No Zellij equivalent needed |
| `bind-key` / `unbind-key` | Keybindings managed by Zellij |
| `set-window-option` / `setw` | Window options handled by Zellij |
| `refresh-client` | Not applicable |
| `source-file` / `source` | No config to source |

## Environment Contract

| Variable | Value | Purpose |
|---|---|---|
| `TMUX` | `zellij-cct:<session>,<pid>,0` | Tells Claude Code it's inside tmux |
| `TMUX_PANE` | `%0` | Leader pane's tmux-style ID |
| `ZELLIJ_CCT_DEBUG` | `1` (optional) | Enable detailed internal logging |
| `PATH` | Shim dir prepended | Ensures `which tmux` finds the shim |
| `ZELLIJ_SESSION_NAME` | (set by Zellij) | Session identification |
| `ZELLIJ` | (set by Zellij) | Terminal environment confirmation |

## State Files

```
$XDG_RUNTIME_DIR/zellij-cct/
  +-- <session-name>/
      +-- idmap.json          # %N <-> terminal_N mapping
      +-- tmux-shim.log       # invocation log (always-on)
      +-- bin/
          +-- tmux            # symlink to zellij-cct-tmux binary
```

State is scoped per Zellij session name. Multiple concurrent sessions maintain independent ID spaces.

## Scope Boundaries

- **Not a tmux reimplementation.** Only the ~20 subcommands Claude Code uses are handled.
- **Not a Zellij server modification.** Pure translation layer calling `zellij action` as a subprocess. Works with unmodified upstream Zellij 0.45+.
- **Not for non-Claude-Code use.** Gated on being invoked as `tmux` inside a Zellij session.
