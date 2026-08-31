# skill-manage

Rust CLI to **list / enable / disable / audit** coding-agent **skills**, **agents**, and **commands** by managing symlinks from provider install roots into one or more configured source trees — plus a YAML **catalog** for tags, work types, and editor profiles.

## Skills ≠ agents ≠ commands

| Kind | Source shape | Provider install (Claude) |
|------|--------------|---------------------------|
| Skills | Dir with `SKILL.md` | `~/.claude/skills/<name>/` |
| Agents | `*.md` agent definitions | `~/.claude/agents/<name>.md` |
| Commands | Slash-command `*.md` | `~/.claude/commands/<name>.md` |

Do not confuse **agent definitions** (`$provider/agents`) with the **providers** themselves (Claude / Codex / Grok).

## Install

```bash
make -C utilities/agent/skill-manage install
# -> ~/.local/bin/skill-manage
```

## Quick start

```bash
# Generate config + catalog under ~/.config/skill-manage/
skill-manage init-config
skill-manage catalog init

# Or use env without a full config:
export SKILL_REPO=/path/to/monorepo/skills
export AGENT_REPO=~/.claude/agents   # optional extra sources
export COMMAND_REPO=~/.claude/commands

# Interactive TUI (requires a TTY)
skill-manage skills -i
skill-manage agents -i --provider claude
skill-manage commands -i
skill-manage profiles -i
skill-manage tui                 # hub starting on skills
skill-manage tui profiles

# Non-interactive
skill-manage skills              # list skills
skill-manage list skills --provider claude
skill-manage enable skills react-engineer --provider claude
skill-manage enable agents npl-tasker --provider claude
skill-manage audit --strict
skill-manage enable-set --work-type feature-dev --provider claude --dry-run
skill-manage context --provider codex --selection active --context-window 200000
```

### TUI keys

| Key | Action |
|-----|--------|
| `↑↓` / `j` `k` | Move |
| `Space` | Toggle enable/disable for current provider |
| `r` | Replace real path with managed symlink |
| `/` | Filter |
| `f` | Cycle status filter |
| `1` `2` `3` | Claude / Codex / Grok |
| `p` | Cycle provider |
| `e` | Edit catalog tags/work_types/notes (F2 save) |
| `Tab` | Next screen (skills → agents → commands → profiles) |
| `g` | Jump to profiles |
| `A` | Apply work-type enable-set (profiles) |
| `?` | Help |
| `q` | Quit |

## Config

Default: `~/.config/skill-manage/config.yaml` (override with `--config` or `SKILL_MANAGE_CONFIG`).

See `schema/config.example.yaml`. Multiple source roots per kind are allowed; lower `priority` wins on name clash.

| Env | Effect |
|-----|--------|
| `SKILL_REPO` | Append a skills source root |
| `AGENT_REPO` | Append an agents source root |
| `COMMAND_REPO` | Append a commands source root |
| `SKILL_MANAGE_CONFIG` | Config file path |

## Safety

- Enable creates **directory** (skills) or **file** (agents/commands) symlinks only.
- Refuses to overwrite real files/dirs unless `--replace` (renames to `*.bak.<timestamp>`).
- Disable removes destinations only when they are symlinks resolving under a configured source root.
- Never writes under Codex `skills/.system/` or Grok bundled trees.

## Context budget report

`context` measures the exact YAML frontmatter section for selected skills,
agents, and commands, including the `---` delimiters. It reports bytes,
characters, estimated tokens, and field-level character counts in JSON.

```bash
# What configured provider runners can currently see
skill-manage context --provider all

# Managed symlinks only
skill-manage context skills --provider codex --selection enabled

# Preview every discovered source item, including disabled items
skill-manage context all --provider codex --selection all

# Use Codex's 2% skill-metadata budget for a known model context window
skill-manage context skills --provider codex --context-window 200000

# Apply a known raw-frontmatter cap for another runner/provider
skill-manage context --provider claude --frontmatter-limit-bytes 65536

# Machine-readable per-item and aggregate metrics
skill-manage context --provider codex --json
```

Selections:

- `active` (default): discovered items whose matching provider destination is a
  managed symlink, real path, or foreign symlink.
- `enabled`: managed symlinks only.
- `all`: every discovered source item.

For Codex skills, the report also estimates the rendered `name + description +
source locator` line that enters model context. It mirrors Codex's 1,024-character
per-description cap and warns at 80% / 100% of the budget. Without
`--context-window`, it uses Codex's 8,000-character fallback budget; with a
window, it uses 2% of the supplied token count. Token estimates use four
characters per token and are intentionally approximate.

Reports cover items discovered under configured source roots. Provider built-ins,
plugin-provided skills, and untracked runtime entries are explicitly excluded.

## Catalog

`~/.config/skill-manage/catalog.yaml` (see `schema/catalog.example.yaml`):

- Per-item `tags`, `work_types`, optional `providers` allow-list
- `work_types` bundles recommended skills/agents/commands + editor profiles
- Editor profiles are **metadata + existence checks** only in v1 (no auto-apply)

```bash
skill-manage work-types list
skill-manage work-types show feature-dev
skill-manage catalog validate
```

## CLI summary

```text
skill-manage skills|agents|commands|profiles [-i|--interactive] [--provider]
skill-manage tui [skills|agents|commands|profiles] [--provider]
skill-manage list [skills|agents|commands|all] [--provider] [--tag] [--work-type] [--status]
skill-manage enable|disable <skills|agents|commands> <name>|--all [--provider] [--replace] [--dry-run]
skill-manage enable-set --work-type TYPE [--provider] [--dry-run]
skill-manage audit [skills|agents|commands|all] [--provider] [--strict] [--json]
skill-manage status
skill-manage context [skills|agents|commands|all] [--provider] [--selection active|enabled|all] [--context-window TOKENS] [--frontmatter-limit-bytes BYTES] [--json]
skill-manage catalog init|show|validate|edit-path
skill-manage work-types [list|show <type>]
skill-manage path <skills|agents|commands> <name>
skill-manage init-config [--force]
```

## Providers (v1)

| Provider | Skills | Agents | Commands |
|----------|--------|--------|----------|
| claude | yes | yes | yes |
| codex | yes | if configured | yes |
| grok | yes | optional | optional |
