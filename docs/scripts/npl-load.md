# npl-load

A command-line tool for loading NPL (Noizu Prompt Lingua) components, metadata, style guides, agents, and schemas with hierarchical path resolution and dependency tracking.

## Synopsis

```bash
npl-load <command> [options]
```

## Commands

| Command | Description |
|---------|-------------|
| `c` | Load NPL components |
| `m` | Load metadata files |
| `s` | Load style guides |
| `spec` | Load specifications |
| `persona` | Load persona definitions |
| `prd` | Load PRD documents |
| `story` | Load user stories |
| `prompt` | Load prompts |
| `init-claude` | Append NPL prompts to CLAUDE.md |
| `schema` | Load raw SQL schema |
| `init` | Load the main `npl.md` file |
| `agent` | Load or list agent definitions |
| `syntax` | Analyze NPL syntax elements |

## Path Resolution

`npl-load` uses a hierarchical search strategy, checking paths in priority order until a match is found. This allows organizations to set defaults while projects and users can override specific components.

### Search Order

1. **Environment variable** (if set)
2. **Project** (`./.npl/`)
3. **User** (`~/.npl/`)
4. **System** (platform-specific)

### Platform-Specific System Paths

| Platform | System Path |
|----------|-------------|
| Linux | `/etc/npl/` |
| macOS | `/Library/Application Support/npl/` |
| Windows | `%PROGRAMDATA%\npl\` |

### Resource Type Paths

Each resource type has its own subdirectory structure:

#### Components (`c`)

Search paths for components:

| Priority | Path |
|----------|------|
| 1 | `$NPL_HOME/npl/` |
| 2 | `./.npl/npl/` |
| 3 | `~/.npl/npl/` |
| 4 | `<system>/npl/` |

**Example:** Loading `syntax.fences` searches for:
- `$NPL_HOME/npl/syntax/fences.md`
- `./.npl/npl/syntax/fences.md`
- `~/.npl/npl/syntax/fences.md`
- `/etc/npl/npl/syntax/fences.md`

#### Metadata (`m`)

Search paths for metadata:

| Priority | Path |
|----------|------|
| 1 | `$NPL_META` |
| 2 | `./.npl/meta/` |
| 3 | `~/.npl/meta/` |
| 4 | `<system>/meta/` |

#### Style Guides (`s`)

Search paths for style guides:

| Priority | Path |
|----------|------|
| 1 | `$NPL_STYLE_GUIDE` |
| 2 | `./.npl/conventions/` |
| 3 | `~/.npl/conventions/` |
| 4 | `<system>/conventions/` |

Style guides support **themes** via `$NPL_THEME`. The loader first checks `<path>/<theme>/` then falls back to `<path>/default/`.

#### Agents (`agent`)

Search paths for agents:

| Priority | Path |
|----------|------|
| 1 | `./.claude/agents/` |
| 2 | `~/.claude/agents/` |
| 3 | `$NPL_HOME/core/agents/` |
| 4 | `./.npl/core/agents/` |
| 5 | `~/.npl/core/agents/` |
| 6 | `<system>/core/agents/` |

#### Schemas (`schema`)

Search paths for SQL schemas:

| Priority | Path |
|----------|------|
| 1 | `./.npl/core/schema/` |
| 2 | `$NPL_HOME/core/schema/` |
| 3 | `~/.npl/core/schema/` |
| 4 | `/env/npl/core/schema/` |

#### Specifications (`spec`)

Search paths for specification documents:

| Priority | Path |
|----------|------|
| 1 | `./.npl/specifications/` |
| 2 | `~/.npl/specifications/` |
| 3 | `$NPL_HOME/core/specifications/` |
| 4 | `./.npl/core/specifications/` |
| 5 | `~/.npl/core/specifications/` |
| 6 | `<system>/core/specifications/` |

**Note:** Project-local specifications take priority, with fallback to core/specifications for shared specs.

#### Personas (`persona`)

Search paths for persona definitions:

| Priority | Path |
|----------|------|
| 1 | `./.npl/personas/` |
| 2 | `~/.npl/personas/` |
| 3 | `<system>/personas/` |

#### PRD Documents (`prd`)

Search paths for PRD documents:

| Priority | Path |
|----------|------|
| 1 | `./.npl/prds/` |
| 2 | `~/.npl/prds/` |
| 3 | `<system>/prds/` |

#### User Stories (`story`)

Search paths for user stories:

| Priority | Path |
|----------|------|
| 1 | `./.npl/user-stories/` |
| 2 | `~/.npl/user-stories/` |
| 3 | `<system>/user-stories/` |

#### Prompts (`prompt`)

Search paths for prompts:

| Priority | Path |
|----------|------|
| 1 | `./.npl/prompts/` |
| 2 | `~/.npl/prompts/` |
| 3 | `$NPL_HOME/core/prompts/` |
| 4 | `./.npl/core/prompts/` |
| 5 | `~/.npl/core/prompts/` |
| 6 | `<system>/core/prompts/` |

**Note:** Prompts are reusable content fragments for CLAUDE.md files. Project-local prompts take priority, with fallback to core/prompts for shared prompts.

## Environment Variables

| Variable | Description | Fallback |
|----------|-------------|----------|
| `NPL_HOME` | Base path for NPL definitions | `./.npl`, `~/.npl`, `<system>` |
| `NPL_META` | Path for metadata files | `<base>/meta/` |
| `NPL_STYLE_GUIDE` | Path for style conventions | `<base>/conventions/` |
| `NPL_THEME` | Theme name for style loading | `default` |

## Usage

### Loading Components

```bash
# Load a single component
npl-load c syntax

# Load multiple components
npl-load c syntax agent directive

# Load with dot notation (subdirectories)
npl-load c syntax.fences pumps.intent

# Load using glob patterns
npl-load c "syntax.*"

# Skip already-loaded components
npl-load c syntax agent --skip syntax
```

### Loading Metadata

```bash
# Load persona metadata
npl-load m persona.qa-engineer

# Load with skip patterns
npl-load m "persona.*" --skip "persona.deprecated-*"
```

### Loading Style Guides

```bash
# Load house style
npl-load s house-style

# Themed styles (uses $NPL_THEME or 'default')
NPL_THEME=corporate npl-load s formatting
```

### Loading Schemas

```bash
# Output raw SQL content
npl-load schema nimps
```

### Loading Specifications

```bash
# Load project architecture spec
npl-load spec project-arch-spec

# Load multiple specs
npl-load spec project-arch-spec project-layout-spec

# Load all specs matching pattern
npl-load spec "*-spec"

# Skip already-loaded specs
npl-load spec project-arch-spec --skip project-arch-spec
```

### Loading Personas

```bash
# Load a persona definition
npl-load persona qa-engineer

# Load multiple personas
npl-load persona qa-engineer dev-lead product-owner

# Load all personas
npl-load persona "*"
```

### Loading PRD Documents

```bash
# Load a PRD
npl-load prd user-authentication

# Load multiple PRDs
npl-load prd user-authentication payment-system

# Load all PRDs matching pattern
npl-load prd "phase-*"
```

### Loading User Stories

```bash
# Load a user story
npl-load story user-login

# Load multiple stories
npl-load story user-login user-registration

# Load all stories for a feature
npl-load story "auth-*"
```

### Loading Prompts

```bash
# Load a prompt
npl-load prompt npl_load

# Load multiple prompts
npl-load prompt npl_load scripts sql-lite

# Load all prompts
npl-load prompt "*"
```

### Initializing CLAUDE.md

```bash
# Append standard NPL prompts to CLAUDE.md (creates if doesn't exist)
npl-load init-claude

# Specify target file
npl-load init-claude --target ./project/CLAUDE.md

# Specify which prompts to append
npl-load init-claude --prompts npl_load scripts

# Default prompts: npl_load, scripts, sql-lite
```

**Note:** `init-claude` automatically detects if prompts are already present and skips duplicates.

### Loading Main NPL Definition

```bash
# Load the main npl.md file
npl-load init
```

### Working with Agents

```bash
# Load an agent
npl-load agent npl-author

# List all available agents
npl-load agent --list

# List with metadata details
npl-load agent --list --verbose

# Search agents by content
npl-load agent --list --search "database"

# Filter by metadata field
npl-load agent --list --filter-meta "model:opus"

# Filter by category
npl-load agent --list --category "writing"

# Export agent with NPL syntax documentation
npl-load agent npl-author --definition
```

### Analyzing NPL Syntax

```bash
# Analyze a file
npl-load syntax --file prompt.md

# Analyze with match details
npl-load syntax --file prompt.md --matches

# Analyze from stdin
cat prompt.md | npl-load syntax -

# Analyze inline content
npl-load syntax "🎯 Important: use `highlight` syntax"
```

## Dependency Tracking

When loading resources, `npl-load` outputs flag updates to track what has been loaded. These flags should be passed back via `--skip` on subsequent calls to prevent reloading.

### Output Format

```markdown
# Flag Update

```🏳️

@npl.def.loaded+="agent,syntax"
@npl.meta.loaded+="persona.qa-engineer"
@npl.style.loaded+="house-style"


```

---

# syntax:
[content...]␜
```

### Tracking Pattern

```bash
# First load - no skip
npl-load c syntax agent
# Returns: @npl.def.loaded+="agent,syntax"

# Subsequent load - skip already loaded
npl-load c syntax agent directive --skip "agent,syntax"
# Only loads directive, skips syntax and agent
```

## Patch Files

`npl-load` supports patch files for customizing loaded content without replacing the original. Patch files use the `.patch.md` extension and are prepended to the original content.

### Patch Resolution

For a component like `syntax/fences.md`:

1. Check `./.npl/npl/syntax/fences.patch.md`
2. Check `~/.npl/npl/syntax/fences.patch.md`
3. Check `/etc/npl/npl/syntax/fences.patch.md`

If a patch exists, output becomes:

```markdown
# syntax.fences:
『(patch)
[patch content]
』
[original content]␜
```

## Options

### Global Options

| Option | Description |
|--------|-------------|
| `--quiet` | Only output tracking flags, not content |

### Component/Meta/Style Options

| Option | Description |
|--------|-------------|
| `--skip` | Patterns to skip (supports wildcards) |
| `--verbose` | Enable verbose output |

### Agent Options

| Option | Description |
|--------|-------------|
| `--list` | List all available agents |
| `--verbose`, `-v` | Show metadata with `--list` |
| `--search` | Search in agent body (regex) |
| `--filter-meta` | Filter by metadata (`field:value`) |
| `--category` | Filter by category |
| `--definition` | Export with NPL documentation |

### Syntax Options

| Option | Description |
|--------|-------------|
| `--file` | File to analyze |
| `--matches` | Show actual pattern matches |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Invalid arguments |
| 2 | Resource not found |

## Examples

### Complete Workflow

```bash
# Initial load for a prompt session
npl-load c syntax agent directive

# Capture the loaded flags
# @npl.def.loaded+="agent,directive,syntax"

# Later, load additional components without reloading
npl-load c "pumps.*" formatting --skip "agent,directive,syntax"
```

### Agent Development

```bash
# Discover available agents
npl-load agent --list --verbose

# Find agents related to writing
npl-load agent --list --search "writing|documentation" --verbose

# Load agent with full NPL context
npl-load agent npl-technical-writer --definition > /tmp/writer-with-npl.md
```

### Project Override

```bash
# Project has custom syntax rules in ./.npl/npl/syntax.md
# This will be found first, overriding ~/.npl and system defaults
npl-load c syntax
```

## See Also

- [NPL Overview](../npl.md) - Core NPL framework documentation
- [Agent Definitions](../agents/) - Agent definition files
- [CLAUDE.md](../CLAUDE.md) - Project-level configuration
