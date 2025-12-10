# npl-load

Load NPL resources with hierarchical path resolution and dependency tracking.

```bash
npl-load <command> [items...] [options]
```

## Commands

| Command | Description |
|:--------|:------------|
| `c` | Load components |
| `m` | Load metadata |
| `s` | Load style guides |
| `spec` | Load specifications |
| `persona` | Load agent personas |
| `user-persona` | Load user personas |
| `prd` | Load PRD documents |
| `story` | Load user stories |
| `prompt` | Load prompts |
| `workflow` | Load workflows |
| `schema` | Output raw SQL schema |
| `init` | Load main `npl.md` |
| `agent` | Load/list agents |
| `syntax` | Analyze NPL syntax |
| `init-claude` | Manage CLAUDE.md |

See [npl-load.detailed.md](./npl-load.detailed.md) for full command reference.

## Quick Start

```bash
# Load components
npl-load c syntax agent directive

# Load with dot notation
npl-load c syntax.fences pumps.intent

# Load using glob patterns
npl-load c "syntax.*"

# Skip already-loaded items
npl-load c syntax agent --skip "syntax"
```

## Path Resolution

Searches paths in priority order:

1. Environment variable (if set)
2. Project (`./.npl/`)
3. User (`~/.npl/`)
4. System (platform-specific)

See [Path Resolution](./npl-load.detailed.md#path-resolution) for details.

## Dependency Tracking

The loader outputs flags after loading. Pass back via `--skip`:

```bash
# First load
npl-load c syntax agent
# Returns: @npl.def.loaded+="agent,syntax"

# Subsequent load
npl-load c syntax agent directive --skip "agent,syntax"
```

See [Dependency Tracking](./npl-load.detailed.md#dependency-tracking) for output format.

## Common Options

| Option | Description |
|:-------|:------------|
| `--skip` | Patterns to skip (wildcards supported) |
| `--quiet` | Output flags only |
| `--verbose` | Verbose output |

## Agent Commands

```bash
npl-load agent --list              # List agents
npl-load agent --list --verbose    # List with metadata
npl-load agent my-agent            # Load agent
npl-load agent my-agent --definition  # Load with NPL docs
```

See [Agent Discovery](./npl-load.detailed.md#agent-discovery-and-loading) for filtering options.

## CLAUDE.md Management

```bash
npl-load init-claude               # Check/init CLAUDE.md
npl-load init-claude --update-all  # Update outdated sections
npl-load init-claude --dry-run     # Preview changes
```

See [init-claude Version Tracking](./npl-load.detailed.md#init-claude-version-tracking) for version management.

## Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `NPL_HOME` | Base NPL path |
| `NPL_META` | Metadata path |
| `NPL_STYLE_GUIDE` | Style conventions path |
| `NPL_THEME` | Theme for styles |

See [Environment Variables](./npl-load.detailed.md#environment-variables) for full list.

## Exit Codes

| Code | Meaning |
|:-----|:--------|
| 0 | Success |
| 1 | Invalid arguments |
| 2 | Resource not found |

## See Also

- [Detailed Reference](./npl-load.detailed.md) - Complete documentation
- [NPL Framework](../../npl.md) - Core NPL docs
