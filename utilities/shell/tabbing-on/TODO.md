# TODO

## CLI Wrappers for Subshell Compatibility

### Status: Basic Implementation Complete

Session-scoped state file approach is implemented. Wrapper scripts in `bin/`
source the bash adapter, load/save state via `TAB_SESSION`-keyed files.

### What's Done

- `lib/session.sh` — POSIX functions for session state persistence
- `bin/tabbing-init` — generates `TAB_SESSION` fingerprint at init
- `shell/tabbing.{bash,zsh}` — source session.sh, auto-save after state changes
- `bin/tabbing-on`, `bin/tabbing-status`, `bin/tabbing-todo`, `bin/tabbing-report`,
  `bin/tabbing-history`, `bin/tabbing-recordings`, `bin/tabbing-info`,
  `bin/tabbing-clear` — standalone executable wrappers
- `bin/_tabbing-wrapper` — shared setup (source adapter, load state, EXIT trap)

### How It Works

1. `eval "$(tabbing-init bash)"` generates and exports `TAB_SESSION` (random 8-char hex)
2. `TAB_SESSION` is inherited by all subshells (env vars pass through)
3. State saved to `~/.local/state/tabbing/sessions/{TAB_SESSION}.env`
4. Each wrapper: loads state from file -> runs command -> saves state on exit
5. Terminal escapes (OSC title, tab color) work directly from subshells

### Remaining Work

#### Parent Shell Sync (Prompt-Hook)

The parent shell's env vars go stale when wrappers update state. Adding a
prompt-hook sync would fix this:

```bash
_tabbing_precmd() {
  if [[ -n "${TAB_SESSION:-}" ]]; then
    _tabbing_session_load   # pick up wrapper changes
  fi
  if [[ -n "${TAB_TITLE:-}" ]]; then
    _tabbing_render
  fi
}
```

This is optional — wrappers already talk to each other via the file. The parent
just won't reflect wrapper changes in its own env until the hook runs.

#### PATH Setup

For the bin/ wrappers to be callable by name (not full path), users need
`bin/` on their PATH. Options:

- Document: `export PATH="$TABBING_ROOT/bin:$PATH"` in shell rc
- Have `tabbing-init` output the PATH export automatically
- Symlink into `~/.local/bin`

#### Known Limitations

- **Interactive features**: `tabbing-todo --switch` uses `read` from tty —
  won't work in non-interactive subshells (Claude). Workaround: pass todo ID
  directly with `tabbing-todo --done <id>` or `--switch <id>`
- **Recording**: `--record` spawns an asciinema sub-shell — incompatible with
  non-interactive wrappers
- **Race conditions**: Concurrent wrapper calls could clobber the session file.
  Not a practical concern for sequential CLI usage
- **Session cleanup**: Old session files accumulate in `sessions/` dir. Could
  add a cleanup sweep based on file age
