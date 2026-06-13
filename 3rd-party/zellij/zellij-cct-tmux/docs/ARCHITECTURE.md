# zellij-cct-tmux — Architecture & Design

## What this is

A Rust binary that impersonates `tmux` for Claude Code Agent Teams. When
symlinked as `tmux` on `$PATH` inside a Zellij session, it intercepts every
`tmux` CLI call Claude Code makes and translates them to equivalent `zellij
action` subprocess calls. Claude Code sees a tmux-shaped interface; Zellij does
the actual multiplexing.

## Why it exists

Claude Code Agent Teams spawns teammate processes by issuing `tmux` commands
(`split-window`, `send-keys`, `kill-pane`, etc.) through its `TmuxBackend`.
The backend detects tmux via the `$TMUX` environment variable and invokes
the `tmux` binary directly. This shim satisfies that contract without
requiring a real tmux installation.

The alternative — running real tmux — works but introduces a race condition
(`mmcd` bug, Claude Code issue #23615) where `send-keys` arrives before the
spawned shell has finished initializing. Real tmux has no mechanism to wait
for shell readiness. This shim does.

## High-level flow

```
Claude Code (TypeScript)
    │
    │  spawns subprocess: tmux split-window -h -P -F '#{pane_id}'
    ▼
┌─────────────────────────────────┐
│  zellij-cct-tmux (this binary)  │
│  invoked via PATH symlink       │
│                                 │
│  1. Log raw invocation          │
│  2. Strip global flags (-L/-S)  │
│  3. Route to command handler    │
│  4. Translate to zellij action  │
│  5. Return tmux-compatible      │
│     stdout/exit code            │
└────────────┬────────────────────┘
             │
             │  spawns subprocess: zellij action new-pane --direction right
             ▼
┌─────────────────────────────────┐
│  Zellij server (running)        │
│  Creates pane, returns          │
│  "terminal_3" on stdout         │
└─────────────────────────────────┘
             │
             │  stdout captured
             ▼
┌─────────────────────────────────┐
│  zellij-cct-tmux                │
│  Maps "terminal_3" → "%2"      │
│  Prints "%2" to stdout          │
│  Claude Code stores "%2"        │
└─────────────────────────────────┘
```

## Multicall binary

The binary inspects `argv[0]` to decide its mode:

- **`tmux`** (via symlink) → tmux compatibility mode. Parses tmux-style
  arguments, translates, delegates.
- **anything else** → prints usage and exits 1.

The activation script (`scripts/activate-tmux-compat.sh`) creates the symlink
at `$XDG_RUNTIME_DIR/zellij-cct/<session>/bin/tmux` and prepends that
directory to `$PATH`.

## Command dispatch pipeline

Every invocation follows this path through the code:

```
main.rs
  │  argv[0] == "tmux"?
  ▼
logger::log_invocation()        ← always logs, ungated
  │
  ▼
dispatch::strip_global_flags()  ← removes -L, -S, -f before the subcommand
  │
  ├── -L <socket> present?
  │     YES → handle_socket_scoped()   ← virtual state, no Zellij calls
  │     NO  ↓
  ▼
dispatch::run()                 ← match on subcommand name
  │
  ├── "split-window"  → commands::split_window::run()
  ├── "send-keys"     → commands::send_keys::run()
  ├── "kill-pane"     → commands::kill_pane::run()
  ├── ... (17 total handlers)
  └── unknown         → commands::stub::run()  ← logs, exits 0
```

## Core modules

### `idmap.rs` — Pane ID translation

tmux uses `%N` pane IDs (`%0`, `%1`, `%2`...). Zellij uses `terminal_N`
(`terminal_0`, `terminal_1`...). The idmap maintains a bidirectional mapping
between the two.

**Data model:**

```json
{
  "next_id": 3,
  "entries": [
    { "tmux_id": 0, "zellij_id": "terminal_0", "tombstoned": false, "created_at": 1779718257 },
    { "tmux_id": 1, "zellij_id": "terminal_3", "tombstoned": false, "created_at": 1779718258 },
    { "tmux_id": 2, "zellij_id": "terminal_5", "tombstoned": true,  "created_at": 1779718260 }
  ]
}
```

**Rules:**
- IDs are allocated monotonically — `%0`, `%1`, `%2`... never reused.
- On `kill-pane`, the entry is **tombstoned** (marked closed), not deleted.
  This prevents a new pane from inheriting a dead pane's ID.
- The `created_at` timestamp (epoch seconds) is used by the race-fix logic
  to identify recently-created panes.
- Persisted to `$XDG_RUNTIME_DIR/zellij-cct/<session>/idmap.json` after
  every mutation.
- On load, corrupt or missing files are silently treated as empty (fresh start).

**Pane ID parsing:** The function `parse_tmux_pane_id()` accepts both `%3`
and bare `3` as input, stripping the `%` prefix if present.

### `format.rs` — tmux format string expansion

tmux's `#{}` DSL is extensive; Claude Code uses exactly 7 variables. The
expander parses `#{...}` sequences and substitutes from a `FormatContext`:

| Variable | Source |
|---|---|
| `#{pane_id}` | `%N` from idmap or `$TMUX_PANE` |
| `#{session_name}` | `$ZELLIJ_SESSION_NAME` |
| `#{window_index}` | Tab position (default 0) |
| `#{window_name}` | Tab name from `list-tabs` |
| `#{pane_title}` | Pane title from `rename-pane` |
| `#{socket_path}` | Fabricated for `-L` commands |
| `#{pid}` | `std::process::id()` |

Unknown variables expand to empty string and log a debug message. tmux style
sequences like `#[fg=red,bold]` pass through unchanged — they appear in
`set-option pane-border-format` values and are not for the shim to interpret.

### `keys.rs` — Key name translation

tmux `send-keys` accepts a mix of literal strings and named keys as
space-separated arguments. The translator maps named keys to byte sequences:

| Key name | Bytes | Notes |
|---|---|---|
| `Enter`, `Return`, `C-m` | `0x0D` | CR, not LF — PTY line discipline expects CR |
| `Tab`, `C-i` | `0x09` | |
| `Space` | `0x20` | |
| `Escape`, `Esc` | `0x1B` | |
| `C-c` | `0x03` | SIGINT |
| `C-d` | `0x04` | EOF |
| `C-<letter>` | `letter - 0x40` | General control character formula |
| `Up`/`Down`/`Left`/`Right` | `ESC [ A/B/D/C` | ANSI cursor keys |
| Unrecognized | pass through as UTF-8 bytes | Literal text |

Multiple arguments concatenate in order: `send-keys 'echo hi' Enter` produces
`echo hi\r` (the literal string followed by CR).

The `-l` flag disables named-key interpretation — all arguments are treated as
literal text.

### `zellij_bridge.rs` — Zellij subprocess interface

All communication with Zellij goes through this module. It invokes `zellij`
as a subprocess and captures stdout/stderr/exit-code.

Two entry points:
- `action(args)` — prepends `--session <name> action` to target the current
  session's action dispatch.
- `command(args)` — invokes bare `zellij <args>` for non-action subcommands
  like `list-sessions`.

The session name comes from `$ZELLIJ_SESSION_NAME`, which Zellij sets
automatically in every pane.

### `ready_wait.rs` — Race condition fix

**The problem:** Claude Code creates a pane (`split-window`) then immediately
sends a command to it (`send-keys`). If the spawned shell hasn't finished
loading (oh-my-zsh, starship, asdf shims), the keystroke arrives before the
shell is reading stdin. Bytes are lost or interleaved, producing garbled
commands like `mmcd` instead of `cd`.

Real tmux has the same problem — Claude Code's `TmuxBackend.ts` mitigates it
with a 200ms blind sleep, which is insufficient for slow shells.

**The fix:** When `send-keys` targets a pane that was created within the last
5 seconds (tracked via `idmap.created_at`), the shim polls the pane's screen
content before writing:

```
1. Call `zellij action dump-screen --pane-id terminal_N`
2. Find the last non-empty line of output
3. Check if it ends with a prompt character: $ # > ❯ %
4. If yes → shell is ready, proceed with send-keys
5. If no  → sleep 100ms, try again
6. After 3 seconds → give up and send anyway (garbled > hung)
```

**Configuration:**

| Env var | Default | Purpose |
|---|---|---|
| `ZELLIJ_CCT_READY_TIMEOUT_MS` | `3000` | Max wait before sending anyway |
| `ZELLIJ_CCT_READY_PATTERN` | `[\$#>❯%]\s*$` | Custom prompt suffix to match |

The implementation avoids a regex dependency — the default pattern is checked
via character matching against the last char of the trimmed line. Custom
patterns fall back to simple suffix matching.

### `logger.rs` — Observability

Every invocation is logged to `$XDG_RUNTIME_DIR/zellij-cct/<session>/tmux-shim.log`
with a Unix timestamp and the full argument vector. Invocation logging is
**always on** (ungated) — this is the primary debugging tool.

Detailed internal messages (bridge calls, unimplemented commands, ready-wait
progress) are gated on `ZELLIJ_CCT_DEBUG=1`.

## Socket-scoped commands (`-L <socket>`)

Claude Code creates an isolated tmux server via `-L <socket>` for its Bash
tool PTYs. This is entirely separate from the user's tmux session — it's
Claude Code's private multiplexer for tool execution.

The shim detects `-L <socket>` as a global flag and routes those commands to
`handle_socket_scoped()` instead of touching the real Zellij session:

| Command | Behavior |
|---|---|
| `new-session -d -s base` | Return success (virtual session) |
| `has-session -t base` | Always return 0 (session "exists") |
| `set-environment -g KEY VAL` | Log and return success |
| `display-message -p '#{socket_path},#{pid}'` | Return fabricated socket path + PID |
| `kill-server` | Log and return success |

This is safe because Claude Code never reads from these "panes" via tmux — it
communicates with tool processes through stdin/stdout pipes, not `capture-pane`.

## Command translation reference

### Real translations (delegate to `zellij action`)

| tmux command | Zellij equivalent | Notes |
|---|---|---|
| `split-window [-h\|-v] -P -F '#{pane_id}'` | `new-pane [--direction right]` | Captures pane ID, allocates `%N` |
| `send-keys -t %N <args> Enter` | `write-chars --pane-id terminal_N <text>` | Key name translation + race fix |
| `kill-pane -t %N` | `close-pane --pane-id terminal_N` | Tombstones `%N` in idmap |
| `list-panes -F '<fmt>'` | `list-panes --json --all` | Parses JSON, applies format template |
| `has-session -t <name>` | `list-sessions --short` | Grep for session name |
| `new-session -d -s <name>` | `new-tab [--name <name>]` | Sessions → tabs mapping |
| `new-window -t <sess> -n <name>` | `new-tab --name <name>` | Windows → tabs mapping |
| `list-windows -F '<fmt>'` | `list-tabs --json` | Parses JSON, applies format template |
| `select-pane -T <title>` | `rename-pane --pane-id terminal_N <title>` | Direct mapping |
| `select-pane -P 'fg=<color>'` | `set-pane-color --pane-id terminal_N --fg <hex>` | tmux color names → hex |
| `display-message -p '<fmt>'` | Local format expansion | No Zellij call needed |
| `list-sessions` | `list-sessions` | Pass-through |
| `capture-pane -p -t %N` | `dump-screen --pane-id terminal_N --full` | Screen content capture |

### Accepted no-ops (exit 0, log only)

| tmux command | Why no-op |
|---|---|
| `set-option -p pane-border-style` | Zellij renders borders natively |
| `set-option -w pane-border-status` | Zellij always shows pane borders |
| `set-option -p pane-border-format` | Zellij uses pane names for labels |
| `select-layout main-vertical\|tiled` | Zellij auto-layouts panes |
| `resize-pane -x 30%` | Zellij distributes space automatically |
| `break-pane` | Pane stays in place (not actually hidden) |
| `join-pane` | Complement of break-pane, also no-op |

These succeed silently because Claude Code checks exit codes but doesn't
verify the visual effect. Zellij's native layout and border rendering
provides an acceptable experience without explicit layout/resize commands.

## Environment contract

The activation script sets these variables before Claude Code starts:

| Variable | Value | Purpose |
|---|---|---|
| `TMUX` | `zellij-cct:<session>,<pid>,0` | Tells Claude Code it's inside tmux |
| `TMUX_PANE` | `%0` | Leader pane's tmux-style ID |
| `ZELLIJ_CCT_DEBUG` | `1` (optional) | Enable detailed internal logging |
| `PATH` | Shim dir prepended | Ensures `which tmux` finds the shim |

Claude Code also relies on `$ZELLIJ_SESSION_NAME` (set by Zellij itself) for
session identification, and `$ZELLIJ` (also set by Zellij) to confirm the
terminal environment.

## State files

All persistent state lives under `$XDG_RUNTIME_DIR/zellij-cct/<session>/`:

```
$XDG_RUNTIME_DIR/zellij-cct/
  └── <session-name>/
      ├── idmap.json          # %N ↔ terminal_N mapping
      ├── tmux-shim.log       # invocation log (always-on)
      └── bin/
          └── tmux            # symlink to zellij-cct-tmux binary
```

State is scoped per Zellij session name. Multiple concurrent Zellij sessions
maintain independent ID spaces.

## What this is NOT

- **Not a tmux reimplementation.** Only the ~20 subcommands Claude Code uses
  are handled. General tmux workflows (`.tmux.conf`, plugins, mouse mode,
  copy mode, etc.) are not supported.
- **Not a Zellij server modification.** The shim is a pure translation layer
  that calls `zellij action` as a subprocess. No Zellij internals are
  patched. It works with unmodified upstream Zellij 0.45+.
- **Not for non-Claude-Code use.** The shim is gated on being invoked as
  `tmux` inside a Zellij session. Outside Zellij, it refuses to run.
