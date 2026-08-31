# How To

Task-oriented guides for `skill-manage`. See [PROJ-ARCH.md](PROJ-ARCH.md) for
*what it is*, [PROJ-LAYOUT.md](PROJ-LAYOUT.md) for *where things live*.

## How to: install skill-manage

**Goal:** get the `skill-manage` binary on your `PATH`.
**Prereqs:** Rust/Cargo toolchain; run from inside the Noizu Infra monorepo.

1. Build, test, and install in one step:
   ```bash
   make -C utilities/agent/skill-manage install
   ```
2. Or drive the Makefile targets directly:
   ```bash
   cd utilities/agent/skill-manage
   make compile   # cargo build --release
   make test      # cargo test
   make install   # copies binary + schema examples
   ```

**Verify:**
```bash
skill-manage --help
```
**Gotchas:**
- `install` also copies `schema/*.example.yaml` to `~/.local/share/skill-manage/schema` — use those as templates, don't hand-write config from scratch.
- `~/.local/bin` must be on `PATH` or the binary won't resolve after install.

## How to: point skill-manage at your source trees

**Goal:** tell the tool where your skills/agents/commands actually live so it can discover them.
**Prereqs:** installed binary.

1. Generate a starter config:
   ```bash
   skill-manage init-config
   ```
   Writes `~/.config/skill-manage/config.yaml` (refuses to overwrite without `--force`).
2. Edit it to add source roots, or skip the file entirely and use env vars for one-off runs:
   ```bash
   export SKILL_REPO=/path/to/monorepo/skills
   export AGENT_REPO=~/.claude/agents
   export COMMAND_REPO=~/.claude/commands
   ```

**Verify:**
```bash
skill-manage status
```
Shows an `enabled/disabled/real/foreign/broken` matrix per kind × provider — a non-zero row means discovery is working.
**Gotchas:**
- Env vars are appended as **priority-10** source roots — a `config.yaml` entry with a *lower* priority number for the same kind wins on name clash, not the env var.
- `--config <path>` or `SKILL_MANAGE_CONFIG` overrides the default `~/.config/skill-manage/config.yaml` path — useful for testing a config without touching your real one.

## How to: enable or disable a skill/agent/command for a provider

**Goal:** symlink an item into (or remove it from) a provider's install root.
**Prereqs:** config/env pointed at a source tree ([above](#how-to-point-skill-manage-at-your-source-trees)); know the item's exact name (`skill-manage list skills --provider claude`).

1. Preview before mutating anything:
   ```bash
   skill-manage enable skills trl-react-engineer --provider claude --dry-run
   ```
2. Enable for real (drop `--dry-run`):
   ```bash
   skill-manage enable skills trl-react-engineer --provider claude
   ```
3. Disable the same way:
   ```bash
   skill-manage disable skills trl-react-engineer --provider claude
   ```
4. Enable everything discovered for a kind:
   ```bash
   skill-manage enable skills --all --provider claude
   ```

**Verify:**
```bash
skill-manage list skills --provider claude --status enabled
```
**Gotchas:**
- `enable` on an item that's already enabled is a no-op that reports `already enabled ...` — safe to re-run.
- `disable` only removes the destination when it's a **managed symlink resolving under a configured source root**; a `real` file/dir or a `foreign` symlink (pointing somewhere else) is left untouched — see the real-file case below.
- Omit `--provider` to act across all configured providers at once.

## How to: bulk-enable a curated toolset by work type

Enable a whole recommended bundle of skills/agents/commands/editor-profile hints in one command, driven by a YAML catalog.
→ *See [howto/work-type-bundles.md](howto/work-type-bundles.md)*

## How to: convert a real file into a managed symlink

**Goal:** bring an existing (non-symlink) skill/agent/command under skill-manage's management without losing it.
**Prereqs:** the item shows `status=real` in `skill-manage list` or `audit`.

1. Confirm it's real, not foreign:
   ```bash
   skill-manage audit skills --provider claude
   ```
2. Enable with `--replace`:
   ```bash
   skill-manage enable skills my-old-skill --provider claude --replace
   ```

**Verify:** the original is renamed to `*.bak.<timestamp>` alongside the destination, and `skill-manage list` now shows `enabled`.
**Gotchas:**
- Without `--replace`, `enable` refuses to touch a real file/dir — this is the safety rail, not a bug.
- The TUI equivalent is the `r` key on the highlighted row.

## How to: fork a skill/agent/command to test local edits without touching the shared source

**Goal:** edit a provider's copy of an item in isolation, without changing the canonical source every other provider symlinks to.
**Prereqs:** the item currently shows `status=enabled` (a managed symlink) in `skill-manage list`.

1. Disable it — this only removes the symlink, never the source:
   ```bash
   skill-manage disable skills trl-react-engineer --provider claude
   ```
2. Drop a real copy at the now-empty destination (edit freely from here):
   ```bash
   cp -r skills/trl-react-engineer ~/.claude/skills/trl-react-engineer
   ```
3. Work on the copy however long you need — `skill-manage` ignores it as long as it stays a real file/dir.
4. Done experimenting and want back on the shared, live-updating copy? Re-enable with `--replace`:
   ```bash
   skill-manage enable skills trl-react-engineer --provider claude --replace
   ```

**Verify:**
```bash
skill-manage list skills --provider claude --status real   # step 3, while forked
skill-manage list skills --provider claude --status enabled # after step 4
```
**Gotchas:**
- Step 4 renames your forked copy to `*.bak.<timestamp>` next to the destination rather than deleting it — recover any edits you want to keep from there before cleanup.
- There's no built-in diff/merge between the fork and the source; if you want to keep your edits, copy them back into the source tree yourself before disabling the fork.
- `audit` (no `--strict`) will list the forked copy as `orphan` while it's real and un-symlinked — expected, not an error.

## How to: find broken or orphaned links

**Goal:** catch stale symlinks and provider-side files skill-manage doesn't know about, before they cause confusion.
**Prereqs:** none.

1. Run a strict audit:
   ```bash
   skill-manage audit --strict
   ```
2. For scripting/CI, get machine-readable output:
   ```bash
   skill-manage audit --strict --json
   ```

**Verify:** exit code and `broken`/`foreign`/orphan lines in the output; a clean repo prints nothing under `--strict`.
**Gotchas:**
- `broken` = managed symlink whose source vanished (e.g. you deleted the skill dir upstream). `foreign` = a symlink skill-manage didn't create. `orphan` (plain `audit`, no `--strict`) = a real file present in a provider dir with no matching source item — common right after adopting skill-manage on a directory that had hand-copied files.
- Never writes under Codex `skills/.system/` or Grok's bundled trees — those won't show as manageable even if present.

## How to: browse and toggle interactively

**Goal:** eyeball everything enabled/disabled across kinds and flip items without memorizing names.
**Prereqs:** a real TTY (not piped output).

1. Launch the hub, optionally starting on a screen:
   ```bash
   skill-manage tui
   skill-manage tui profiles
   ```
2. Or jump straight into one kind:
   ```bash
   skill-manage skills -i --provider claude
   ```

**Verify:** `Space` toggles the highlighted row; the status column updates live.
**Gotchas:** `1`/`2`/`3` switch provider (Claude/Codex/Grok) without leaving the row; `f` cycles the status filter and `/` filters by name — useful once a source tree has 50+ items.
