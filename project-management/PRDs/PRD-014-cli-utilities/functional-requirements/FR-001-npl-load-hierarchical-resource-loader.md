# FR-001: npl-load Hierarchical Resource Loader

**Status**: Draft

## Description

Implement `npl-load` CLI utility for loading NPL resources (syntax, agents, prompts, metadata) from hierarchical paths with dependency tracking and skip flags.

## Interface

```bash
# Load core components
npl-load c "syntax,agent,pumps"

# Load with skip flag
npl-load c "syntax,agent" --skip {@npl.def.loaded}

# Load metadata
npl-load m "project,version"

# Load style definitions
npl-load s "format,output"

# Load specific agent
npl-load agent gopher-scout --definition

# Verbose output
npl-load c "syntax" --verbose
```

## Behavior

- **Given** resource type and comma-separated items
- **When** npl-load is invoked
- **Then** resources are resolved in hierarchical order (env → project → user → system)
- **And** items matching `--skip` expression are skipped
- **And** output includes NPL boundary markers
- **And** flags are set for loaded items

## Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | positional | Resource type: `c` (core), `m` (meta), `s` (style), `agent` |
| `items` | positional | Comma-separated list of items to load |
| `--skip` | optional | Flag expression for items to skip |
| `--verbose` | optional | Show detailed loading information |
| `--definition` | optional | For agents: load full definition |
| `--path` | optional | Override default search paths |

## Path Resolution Order

1. `$NPL_HOME` environment variable
2. `./.npl/` (project-local)
3. `~/.npl/` (user-global)
4. `/etc/npl/` (system-wide)

## Output Format

```
⌜📦 NPL Resources⌝
  syntax: loaded (2.1kb)
  agent: loaded (4.5kb)
  pumps: skipped (already loaded)
⌞📦 NPL Resources⌟

{@npl.def.loaded = "syntax,agent,pumps"}
```

## Edge Cases

- **Missing resource**: Log warning, continue with next
- **Invalid skip expression**: Error with clear message
- **No matching paths**: Report "no resources found" error
- **Circular dependencies**: Detect and report error
- **Large resource files**: Stream instead of loading entirely

## Related User Stories

- US-001
- US-002
- US-003

## Test Coverage

Expected test count: 12-15 tests
Target coverage: 100% for this FR
