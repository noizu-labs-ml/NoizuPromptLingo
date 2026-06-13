# Plan: Convert remaining echo/printf to _tabbing_out

## Context

We just added `_tabbing_tty_printf` and `_tabbing_out` to `lib/render.sh` and converted all `/dev/tty` escape writes + shell adapter error messages. The remaining lib files and bin scripts still use raw `echo`/`printf` for user-facing output. This batch converts them all so every user-visible message goes through `_tabbing_out`, enabling verbosity control via `$TAB_VERBOSITY` and consistent output routing.

## Key Constraints

- **`_tabbing_out` is available** in all files that source `_tabbing-wrapper` (which sources `shell/tabbing.bash` → `lib/render.sh`)
- **Standalone scripts** (`bin/tabbing-doctor`, `bin/demo-runner`) need a local copy of `_tabbing_out` OR must source render.sh — use inline copy (same as we did for `_tabbing_tty_printf` in `bin/tabbing-marquee`)
- **DO NOT convert**: return values (`echo "30"` in case statements), YAML file writes, `printf '%s'` used for variable building, export statements, pipe sources
- **DO convert**: error messages (`>&2`), status/progress messages, help text, list display output
- Error messages → `_tabbing_out -v 0 -e 'msg\n'`
- Normal info → `_tabbing_out 'msg\n'`
- The `echo` calls need `\n` added since `_tabbing_out` uses `printf` semantics

## Work Units

### Unit 1: lib/history.sh
- ~13 calls: 5 error (`echo ... >&2`), 8 info (`printf 'tabbing: ...'`)
- All functions here are loaded via `_tabbing-wrapper` → `_tabbing_out` is available

### Unit 2: lib/recording.sh
- ~13 calls: 5 error, 8 info
- Loaded via `_tabbing-wrapper` → `_tabbing_out` is available

### Unit 3: lib/todo.sh
- ~8 calls: 3 error, 5 info
- Loaded via `_tabbing-wrapper` → `_tabbing_out` is available

### Unit 4: lib/core.sh
- ~40+ calls: 2 error (emoji search usage), many info (emoji list, color list, help text)
- Loaded via `_tabbing-wrapper` → `_tabbing_out` is available
- Largest file — most calls are in emoji_list/color_list display functions

### Unit 5: bin/ wrapper scripts (tabbing-todo, tabbing-report, tabbing-recordings, tabbing-clear)
- ~15 calls across 4 files: mostly error messages
- All source `_tabbing-wrapper` → `_tabbing_out` is available

### Unit 6: bin/tabbing-doctor (standalone)
- ~20+ calls: info/status messages via `_check`, `_warn`, `_info`, `printf`
- Standalone script — needs local `_tabbing_out` copy added at top
- Has its own helper functions (`_check`, `_warn`, `_info`) — convert those to use `_tabbing_out` internally

### Unit 7: bin/demo-runner (standalone)
- ~15 calls: info messages for demo playback
- Standalone script — needs local `_tabbing_out` copy added at top

## E2e Verification

No test framework exists. Verification is:
1. `sh -n <file>` / `bash -n <file>` / `zsh -n <file>` syntax check on every modified file
2. `eval "$(bin/tabbing-init bash)"` then exercise basic commands to confirm no runtime breakage
3. `TAB_VERBOSITY=0 tabbing-on "test"` should suppress normal output
4. `TAB_VERBOSITY=2 tabbing-on "test"` should show everything

## Worker Instructions Template

```
Convert all user-facing echo/printf statements in the assigned file(s) to use `_tabbing_out`.

Rules:
- `echo "msg" >&2` → `_tabbing_out -v 0 -e 'msg\n'`
- `printf 'msg\n' >&2` → `_tabbing_out -v 0 -e 'msg\n'`
- `printf 'msg\n' args` (info) → `_tabbing_out 'msg\n' args`
- `echo "msg"` (info) → `_tabbing_out 'msg\n'`
- DO NOT convert: echo/printf used as return values, YAML writes, variable building, pipe input, export statements
- For standalone scripts (no _tabbing-wrapper): add a local _tabbing_out function at the top
- Preserve all format strings and arguments exactly
- Run `sh -n <file>` (or bash -n / zsh -n as appropriate) after changes to verify syntax
```

