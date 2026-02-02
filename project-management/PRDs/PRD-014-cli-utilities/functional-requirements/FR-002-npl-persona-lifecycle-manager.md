# FR-002: npl-persona Lifecycle Manager

**Status**: Draft

## Description

Implement `npl-persona` CLI utility for creating, managing, and querying persistent persona state including journals, tasks, and knowledge bases.

## Interface

```bash
# Initialize new persona
npl-persona init sarah-architect --role "Architect" --scope project

# Get persona info
npl-persona get sarah-architect

# List personas
npl-persona list --scope project

# Remove persona
npl-persona remove sarah-architect

# Journal operations
npl-persona journal sarah-architect add "Reviewed API design"
npl-persona journal sarah-architect list --last 10

# Task operations
npl-persona task sarah-architect add "Refactor schema" --priority high
npl-persona task sarah-architect complete TASK-001
npl-persona task sarah-architect list --status pending

# Knowledge base operations
npl-persona kb sarah-architect add api "REST endpoint conventions"
npl-persona kb sarah-architect query "authentication"

# Team operations
npl-persona team create backend-team --members sarah,bob,alice
npl-persona team synthesize backend-team --topic "API redesign"
```

## Behavior

- **Given** persona ID and operation
- **When** npl-persona is invoked
- **Then** persona state is read from or written to `.npl/personas/{id}/`
- **And** journal entries are append-only with timestamps
- **And** tasks maintain status history
- **And** knowledge base supports full-text search

## Persona Storage Structure

```
.npl/personas/
├── sarah-architect/
│   ├── definition.yaml
│   ├── journal.jsonl
│   ├── tasks.yaml
│   └── knowledge/
│       ├── api.md
│       └── architecture.md
└── bob-developer/
    └── ...
```

## Subcommands

| Subcommand | Action | Description |
|------------|--------|-------------|
| `init` | create | Initialize new persona |
| `get` | read | Get persona details |
| `list` | read | List personas by scope |
| `remove` | delete | Remove persona |
| `journal` | manage | Journal entry operations |
| `task` | manage | Task tracking operations |
| `kb` | manage | Knowledge base operations |
| `team` | manage | Team coordination |

## Edge Cases

- **Duplicate persona ID**: Error if already exists
- **Missing persona**: Clear error for operations on non-existent persona
- **Corrupt journal**: Attempt recovery, report corruption
- **Concurrent writes**: Use file locking to prevent conflicts
- **Large knowledge bases**: Index for performance

## Related User Stories

- US-025

## Test Coverage

Expected test count: 20-25 tests
Target coverage: 100% for this FR
