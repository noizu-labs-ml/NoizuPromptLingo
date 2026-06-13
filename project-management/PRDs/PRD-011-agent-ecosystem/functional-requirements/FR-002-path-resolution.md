# FR-002: Path Resolution Hierarchy

**Status**: Draft

## Description

The system must resolve agent definition paths in a specific hierarchical order to support project-local, user-global, and system-wide agent installations.

## Interface

```python
def resolve_agent_paths() -> list[Path]:
    """Resolve agent definition paths in priority order.

    Returns:
        List of paths to scan for agent definitions, ordered by priority
    """
```

## Behavior

- **Given** the system is initializing
- **When** agent paths are resolved
- **Then** paths are returned in this order:
  1. `$NPL_AGENTS` environment variable (if set)
  2. `.npl/agents/` (project-local, relative to current directory)
  3. `~/.npl/agents/` (user-global)
  4. `/etc/npl/agents/` (system-wide)

## Edge Cases

- **Invalid paths**: Skip non-existent paths
- **Environment variable with multiple paths**: Split by `:` (Unix) or `;` (Windows)
- **Relative paths in $NPL_AGENTS**: Resolve relative to current working directory
- **Symlinks**: Follow symlinks to target directories

## Related User Stories

- US-001: Agent Discovery System

## Test Coverage

Expected test count: 8 tests
Target coverage: 100% for this FR
