# npl-load Detailed Reference

Command-line tool for loading NPL resources with hierarchical path resolution and dependency tracking.

## Synopsis

```bash
npl-load <command> [items...] [options]
```

## Commands

| Command | Description | Items Argument |
|:--------|:------------|:---------------|
| `c` | Load NPL components | `def_items` |
| `m` | Load metadata files | `meta_items` |
| `s` | Load style guides | `style_items` |
| `spec` | Load specifications | `spec_items` |
| `persona` | Load agent personas | `persona_items` |
| `user-persona` | Load user personas | `user_persona_items` |
| `prd` | Load PRD documents | `prd_items` |
| `story` | Load user stories | `story_items` |
| `prompt` | Load prompts | `prompt_items` |
| `workflow` | Load workflows | `workflow_items` |
| `schema` | Output raw SQL for a schema | `schema_name` |
| `init` | Load main `npl.md` file | (none) |
| `agent` | Load or list agent definitions | `agent_name` |
| `syntax` | Analyze NPL syntax elements | `content` |
| `init-claude` | Initialize/update CLAUDE.md | (none) |

---

## Path Resolution

The loader searches paths in priority order (first match wins). This enables organizations to set defaults while projects and users override specific components.

### Search Order

1. **Extra paths** (command-specific, e.g., `.claude/agents/`)
2. **Environment variable** (if set)
3. **Project** (`./.npl/`)
4. **User** (`~/.npl/`)
5. **System** (platform-specific)

### Platform-Specific System Paths

| Platform | System Path |
|:---------|:------------|
| Linux | `/etc/npl/` |
| macOS | `/Library/Application Support/npl/` |
| Windows | `%PROGRAMDATA%\npl\` |

### Dot Notation

Items use dot notation to specify subdirectories:

```bash
npl-load c syntax.fences    # Searches for syntax/fences.md
npl-load m persona.qa-engineer  # Searches for persona/qa-engineer.md
```

---

## Resource Configuration

Each resource type has a configuration defining search paths:

### Components (`c`)

**Environment:** `$NPL_HOME` with `/npl` suffix

| Priority | Path |
|:---------|:-----|
| 1 | `$NPL_HOME/npl/` |
| 2 | `./.npl/npl/` |
| 3 | `~/.npl/npl/` |
| 4 | `<system>/npl/` |

### Metadata (`m`)

**Environment:** `$NPL_META`

| Priority | Path |
|:---------|:-----|
| 1 | `$NPL_META/` |
| 2 | `./.npl/meta/` |
| 3 | `~/.npl/meta/` |
| 4 | `<system>/meta/` |

### Style Guides (`s`)

**Environment:** `$NPL_STYLE_GUIDE`
**Themed:** Yes (uses `$NPL_THEME`)

| Priority | Path |
|:---------|:-----|
| 1 | `$NPL_STYLE_GUIDE/` |
| 2 | `./.npl/conventions/` |
| 3 | `~/.npl/conventions/` |
| 4 | `<system>/conventions/` |

Style guides support themes. When `$NPL_THEME` is set (e.g., `corporate`), the loader checks `<path>/<theme>/` first, then falls back to `<path>/default/`.

### Specifications (`spec`)

**Environment:** `$NPL_HOME` with `/core/specifications` suffix

| Priority | Path |
|:---------|:-----|
| 1 | `$NPL_HOME/core/specifications/` |
| 2 | `./.npl/specifications/` |
| 3 | `~/.npl/specifications/` |
| 4 | `<system>/specifications/` |
| 5 | `./.npl/core/specifications/` |
| 6 | `~/.npl/core/specifications/` |
| 7 | `<system>/core/specifications/` |

### Agents (`agent`)

**Environment:** `$NPL_HOME` with `/core/agents` suffix
**Extra paths:** `./.claude/agents/`, `~/.claude/agents/`

| Priority | Path |
|:---------|:-----|
| 1 | `./.claude/agents/` |
| 2 | `~/.claude/agents/` |
| 3 | `$NPL_HOME/core/agents/` |
| 4 | `./.npl/core/agents/` |
| 5 | `~/.npl/core/agents/` |
| 6 | `<system>/core/agents/` |

### Schemas (`schema`)

**Environment:** `$NPL_HOME` with `/core/schema` suffix
**Extra paths:** `/env/npl/core/schema/`

| Priority | Path |
|:---------|:-----|
| 1 | `$NPL_HOME/core/schema/` |
| 2 | `./.npl/core/schema/` |
| 3 | `~/.npl/core/schema/` |
| 4 | `<system>/core/schema/` |
| 5 | `/env/npl/core/schema/` |

### Personas (`persona`)

**Environment:** `$NPL_PERSONA_DIR`

| Priority | Path |
|:---------|:-----|
| 1 | `$NPL_PERSONA_DIR/` |
| 2 | `./.npl/personas/` |
| 3 | `~/.npl/personas/` |
| 4 | `<system>/personas/` |

### User Personas (`user-persona`)

**Environment:** `$NPL_USER_PERSONA_DIR`

| Priority | Path |
|:---------|:-----|
| 1 | `$NPL_USER_PERSONA_DIR/` |
| 2 | `./.npl/user-personas/` |
| 3 | `~/.npl/user-personas/` |
| 4 | `<system>/user-personas/` |

### PRD Documents (`prd`)

| Priority | Path |
|:---------|:-----|
| 1 | `./.npl/prds/` |
| 2 | `~/.npl/prds/` |
| 3 | `<system>/prds/` |

### User Stories (`story`)

| Priority | Path |
|:---------|:-----|
| 1 | `./.npl/user-stories/` |
| 2 | `~/.npl/user-stories/` |
| 3 | `<system>/user-stories/` |

### Prompts (`prompt`)

**Environment:** `$NPL_HOME` with `/core/prompts` suffix

| Priority | Path |
|:---------|:-----|
| 1 | `$NPL_HOME/core/prompts/` |
| 2 | `./.npl/prompts/` |
| 3 | `~/.npl/prompts/` |
| 4 | `<system>/prompts/` |
| 5 | `./.npl/core/prompts/` |
| 6 | `~/.npl/core/prompts/` |
| 7 | `<system>/core/prompts/` |

### Workflows (`workflow`)

**Environment:** `$NPL_WORKFLOW_DIR`

| Priority | Path |
|:---------|:-----|
| 1 | `$NPL_WORKFLOW_DIR/` |
| 2 | `./.npl/workflows/` |
| 3 | `~/.npl/workflows/` |
| 4 | `<system>/workflows/` |

---

## Environment Variables

| Variable | Description | Default |
|:---------|:------------|:--------|
| `NPL_HOME` | Base path for NPL definitions | `./.npl`, `~/.npl`, `<system>` |
| `NPL_META` | Path for metadata files | `<base>/meta/` |
| `NPL_STYLE_GUIDE` | Path for style conventions | `<base>/conventions/` |
| `NPL_THEME` | Theme name for style loading | `default` |
| `NPL_PERSONA_DIR` | Persona definitions path | `<base>/personas/` |
| `NPL_USER_PERSONA_DIR` | User persona definitions path | `<base>/user-personas/` |
| `NPL_WORKFLOW_DIR` | Workflow definitions path | `<base>/workflows/` |

---

## Options

### Global Options

| Option | Description |
|:-------|:------------|
| `--quiet` | Output tracking flags only, suppress content |

### Resource Loading Options

Used with `c`, `m`, `s`, `spec`, `persona`, `user-persona`, `prd`, `story`, `prompt`, `workflow`:

| Option | Description |
|:-------|:------------|
| `--skip` | Patterns to skip (supports wildcards via fnmatch) |
| `--verbose` | Enable verbose output |

### Agent Options

| Option | Description |
|:-------|:------------|
| `--list` | List all available agents |
| `--verbose`, `-v` | Show metadata with `--list` |
| `--search` | Search agent body (regex pattern) |
| `--filter-meta` | Filter by metadata field (`field:value`) |
| `--category` | Filter by category |
| `--definition` | Export agent with NPL syntax documentation |

### Syntax Options

| Option | Description |
|:-------|:------------|
| `--file` | File to analyze |
| `--matches` | Show actual pattern matches |

### init-claude Options

| Option | Description |
|:-------|:------------|
| `--target` | Target CLAUDE.md path (default: `./CLAUDE.md`) |
| `--prompts` | Prompts to append (default: `npl npl_load scripts sql-lite`) |
| `--update` | Update specified sections (comma-separated names) |
| `--update-all` | Update all outdated/missing sections |
| `--dry-run` | Show changes without modifying files |
| `--json` | Output version info as JSON |

---

## Dependency Tracking

The loader outputs flag updates after loading resources. Pass these flags back via `--skip` to prevent reloading.

### Output Format

```markdown
# Flag Update

```🏳️

@npl.def.loaded+="agent,syntax"
@npl.meta.loaded+="persona.qa-engineer"

```

---

# syntax:
[content...]
```

### Flag Names

| Tracking Set | Flag Name |
|:-------------|:----------|
| Components | `@npl.def.loaded` |
| Metadata | `@npl.meta.loaded` |
| Style | `@npl.style.loaded` |
| Specifications | `@npl.spec.loaded` |
| Personas | `@npl.persona.loaded` |
| User Personas | `@npl.user-persona.loaded` |
| PRDs | `@npl.prd.loaded` |
| Stories | `@npl.story.loaded` |
| Prompts | `@npl.prompt.loaded` |
| Workflows | `@npl.workflow.loaded` |

### Usage Pattern

```bash
# First load
npl-load c syntax agent
# Output includes: @npl.def.loaded+="agent,syntax"

# Subsequent load - pass skip to avoid reloading
npl-load c syntax agent directive --skip "agent,syntax"
# Only loads directive
```

---

## Patch Files

Customize loaded content without replacing the original. Patches use `.patch.md` extension and prepend to the original.

### Patch Search Order

For `syntax/fences.md`:

1. `./.npl/npl/syntax/fences.patch.md`
2. `~/.npl/npl/syntax/fences.patch.md`
3. `/etc/npl/npl/syntax/fences.patch.md`

### Output with Patch

```markdown
# syntax.fences:
『(patch)
[patch content]
』
[original content]
```

### Style Patch Resolution

For themed styles, patches are checked in theme directories first:

1. `<conventions>/<theme>/path/to/file.patch.md`
2. `<conventions>/default/path/to/file.patch.md`
3. `<conventions>/path/to/file.patch.md`

---

## Glob Patterns

Resource items support glob patterns (wildcards):

```bash
npl-load c "syntax.*"        # All files in syntax/
npl-load c "*"               # All components
npl-load m "persona.*"       # All persona metadata
npl-load spec "*-spec"       # All specs ending in -spec
```

Skip patterns also support wildcards:

```bash
npl-load c "syntax.*" --skip "syntax.deprecated-*"
```

---

## init-claude Version Tracking

The `init-claude` command manages CLAUDE.md with version tracking for prompt sections.

### Section Format

Prompts use YAML frontmatter for version tracking:

```markdown
* * *
npl-instructions:
   name: section-name
   version: 1.0.0
---

[section content]
```

### Version Comparison

```bash
# Check version status
npl-load init-claude

# Output:
# NPL Prompt Version Status
# ============================================================
#
# Section                   Source     Installed  Status
# ------------------------------------------------------------
# npl-conventions           1.0.0      1.0.0      current
# npl-load-directive        1.0.0      0.9.0      OUTDATED
#
# Summary: 1 outdated, 1 current
```

### Update Commands

```bash
# Update specific sections
npl-load init-claude --update "npl-load-directive,scripts"

# Update all outdated sections
npl-load init-claude --update-all

# Preview changes
npl-load init-claude --update-all --dry-run

# JSON output
npl-load init-claude --json
```

### Exit Codes for init-claude

| Code | Meaning |
|:-----|:--------|
| 0 | All sections current / no changes needed |
| 1 | Updates applied |
| 2 | Updates available (outdated/missing sections) |
| 3 | Errors occurred during update |

---

## Agent Discovery and Loading

### List Agents

```bash
# Simple list
npl-load agent --list

# With metadata
npl-load agent --list --verbose
```

### Filter Agents

```bash
# Search body content (regex)
npl-load agent --list --search "database|sql"

# Filter by metadata field
npl-load agent --list --filter-meta "model:opus"

# Filter by category
npl-load agent --list --category "writing"

# Combine filters
npl-load agent --list --category "code" --search "test"
```

### Load Agent

```bash
# Load agent definition
npl-load agent npl-author

# Load with NPL syntax documentation
npl-load agent npl-author --definition
```

### Agent Metadata Format

Agents support YAML frontmatter:

```yaml
---
version: 1.0.0
description: Technical documentation writer
categories:
  - writing
  - documentation
model: opus
---
```

---

## NPL Syntax Analysis

Analyze content for NPL syntax elements:

```bash
# Analyze file
npl-load syntax --file prompt.md

# Show matches
npl-load syntax --file prompt.md --matches

# Analyze from stdin
cat prompt.md | npl-load syntax -

# Analyze inline
npl-load syntax "🎯 Use \`highlight\` syntax"
```

### Pattern Categories Detected

- **basic_syntax**: highlight, placeholder, in-fill, omission
- **special_syntax**: attention, note, qualifier
- **communication**: attention_alias, direct_message, value_placeholder
- **validation**: positive/negative markers, separators
- **content_generation**: inference dots/etc, literal_output
- **logic_operators**: summation, intersection, union, subset, element_of
- **fences**: fence types
- **handlebars**: vars, foreach, if, endif
- **npl_specific**: npl tags, section markers
- **directives**: directive patterns

---

## Exit Codes

| Code | Meaning |
|:-----|:--------|
| 0 | Success |
| 1 | Invalid arguments / updates applied (init-claude) |
| 2 | Resource not found / updates available (init-claude) |
| 3 | Errors during update (init-claude) |

---

## Usage Examples

### Load Multiple Resource Types

```bash
# Load components, then metadata, then styles
npl-load c syntax agent
npl-load m persona.qa-engineer --skip ""
npl-load s house-style --skip ""
```

### Project Override Pattern

```bash
# Project has ./.npl/npl/syntax.md
# This overrides ~/.npl and system defaults
npl-load c syntax
```

### Agent Development Workflow

```bash
# Discover agents
npl-load agent --list --verbose

# Find writing-related agents
npl-load agent --list --search "writing|documentation"

# Export with NPL context
npl-load agent npl-technical-writer --definition > /tmp/writer.md
```

### Initialize New Project

```bash
# Create CLAUDE.md with standard prompts
npl-load init-claude --target ./CLAUDE.md

# Check for updates later
npl-load init-claude

# Update all outdated sections
npl-load init-claude --update-all
```

### Schema Loading

```bash
# Output raw SQL
npl-load schema nimps

# Use in SQLite
npl-load schema nimps | sqlite3 db.sqlite
```

### Quiet Mode for Scripts

```bash
# Get only tracking flags (for scripts)
npl-load c syntax agent --quiet
```

---

## Implementation Details

### File: `core/scripts/npl-load`

The script is implemented in Python 3 and requires:

- `pyyaml` - YAML parsing
- `argparse` - CLI argument parsing
- `concurrent.futures` - Parallel loading

### Key Classes

- `NPLLoader` - Main loader class with path resolution and resource loading
- `SectionMetadata` - Dataclass for versioned prompt section metadata

### Resource Configuration

Resource types are configured in `RESOURCE_CONFIG` dict:

```python
RESOURCE_CONFIG = {
    'component': {
        'env_var': 'NPL_HOME',
        'env_suffix': 'npl',
        'subdirs': ['npl'],
    },
    'style': {
        'env_var': 'NPL_STYLE_GUIDE',
        'subdirs': ['conventions'],
        'themed': True,
    },
    # ...
}
```

### Skip Pattern Matching

Uses `fnmatch` for wildcard pattern matching:

```python
# Matches: syntax.deprecated-v1, syntax.deprecated-v2
--skip "syntax.deprecated-*"
```

---

## Limitations

- **No interactive mode**: All operations are non-interactive
- **Single theme**: Only one theme active at a time via `$NPL_THEME`
- **First match wins**: Cannot merge content from multiple path levels
- **Patches prepend only**: Patches cannot replace or append to specific sections

---

## See Also

- [npl-load.md](./npl-load.md) - Concise reference
- [NPL Framework](../../npl.md) - Core NPL documentation
- [CLAUDE.md](../../CLAUDE.md) - Project configuration
