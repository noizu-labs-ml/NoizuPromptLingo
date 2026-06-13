# Claude Code Agent Teams — Zellij tmux Shim Setup

## Prerequisites

- Zellij built from this fork (includes `ZELLIJ_TMUX_COMPAT` support)
- Rust toolchain (`rustup`)

## How it works

When `ZELLIJ_TMUX_COMPAT=1` is set, Zellij automatically exports `TMUX` and
`TMUX_PANE` environment variables into each pane, matching what tmux would set.
The `zellij-tmux-shim` binary intercepts `tmux` CLI calls and translates them
to `zellij action` commands.

The shim only activates when **both** `ZELLIJ_TMUX_COMPAT=1` and `ZELLIJ` are
set. Otherwise it passes through to the real `tmux` binary, so it's safe to
leave installed permanently.

## One-time setup

### 1. Build and install

```bash
cd ~/Github/scaffolding/claude/zellij
cargo build -p zellij-cct-tmux --release

# Install the shim alongside zellij — symlink as tmux so it's found first
ln -sf "$(pwd)/target/release/zellij-tmux-shim" /usr/local/bin/zellij-tmux-shim
ln -sf /usr/local/bin/zellij-tmux-shim /usr/local/bin/tmux
```

Or if you prefer not to override the system tmux globally, use a project
`.envrc`:

```bash
# .envrc
export ZELLIJ_TMUX_COMPAT=1
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
if [ -n "$ZELLIJ" ]; then
  PATH_add "/path/to/zellij/bin"  # directory containing tmux -> zellij-tmux-shim symlink
  log_status "zellij-cct-tmux activated"
fi
```

### 2. Set the environment variable

Add to your shell profile, Zellij config, or `.envrc`:

```bash
export ZELLIJ_TMUX_COMPAT=1
```

That's it. Zellij will set `TMUX` and `TMUX_PANE` automatically in every pane.

## Usage

```bash
zellij -s work
claude  # Agent Teams will use the tmux shim transparently
```

## Logs

Shim activity is logged per-session:

```bash
tail -f $TMPDIR/zellij-cct/$(echo $ZELLIJ_SESSION_NAME)/tmux-shim.log
```

Unknown/unhandled tmux subcommands are also logged to:

```
/var/log/zellij/tmux-compat.log
```

Enable verbose debug logging:

```bash
export ZELLIJ_CCT_DEBUG=1
```

## Troubleshooting

**`echo $TMUX` is empty inside Zellij:**
Ensure you're running the fork build with `ZELLIJ_TMUX_COMPAT=1` set before
launching Zellij.

**Shim passes through to real tmux:**
Both `ZELLIJ_TMUX_COMPAT=1` and `ZELLIJ` must be set. Check with
`echo $ZELLIJ_TMUX_COMPAT $ZELLIJ`.

**Panes spawn but commands are garbled:**
The shim polls for a shell prompt before sending keys. If your prompt doesn't
end with `$`, `#`, `>`, `❯`, or `%`, set a custom pattern:

```bash
export ZELLIJ_CCT_READY_PATTERN='your-prompt-suffix'
```
