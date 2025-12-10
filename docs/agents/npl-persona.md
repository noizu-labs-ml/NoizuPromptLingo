# npl-persona

Persona-based collaboration agent with persistent file-backed state for reviews, discussions, and multi-persona orchestration.

## Purpose

Simulates authentic character-driven interactions by loading persona definitions, maintaining state through journal/tasks/knowledge files, and enabling team collaboration patterns.

## Quick Start

```bash
# Create persona
npl-persona init sarah-architect --role=architect

# Invoke in conversation
@persona sarah-architect "How would you design the auth layer?"

# Team discussion
@persona --team=architects "Discuss: microservices vs monolith"
```

## Capabilities

- Single and multi-persona invocation with maintained voice
- Persistent state via journal, tasks, and knowledge base files
- Hierarchical persona resolution (project -> user -> system)
- Team creation, knowledge synthesis, and collaboration analytics
- CLI tool for lifecycle management

See [npl-persona.detailed.md](./npl-persona.detailed.md) for complete reference.

## CLI Commands

| Command | Purpose | Details |
|---------|---------|---------|
| `init <id>` | Create persona with 4 files | [Lifecycle](#cli-lifecycle) |
| `get <id>` | Load persona files | [Lifecycle](#cli-lifecycle) |
| `list` | List available personas | [Lifecycle](#cli-lifecycle) |
| `journal <id> add\|view\|archive` | Manage experience log | [Journal Ops](./npl-persona.detailed.md#journal-operations) |
| `task <id> add\|update\|list` | Manage tasks | [Task Mgmt](./npl-persona.detailed.md#task-management) |
| `kb <id> add\|search\|get` | Manage knowledge base | [Knowledge Base](./npl-persona.detailed.md#knowledge-base-operations) |
| `health [--all]` | Check file integrity | [Maintenance](./npl-persona.detailed.md#health-and-maintenance) |
| `sync <id>` | Validate and sync files | [Maintenance](./npl-persona.detailed.md#health-and-maintenance) |
| `backup [--all]` | Archive persona data | [Maintenance](./npl-persona.detailed.md#health-and-maintenance) |
| `share <from> <to> --topic` | Transfer knowledge | [Knowledge Sharing](./npl-persona.detailed.md#knowledge-sharing) |
| `team create\|add\|list\|synthesize` | Team operations | [Teams](./npl-persona.detailed.md#team-management) |
| `analyze <id>` | Journal/task analytics | [Analytics](./npl-persona.detailed.md#analytics-and-reporting) |
| `report <id>` | Generate full report | [Analytics](./npl-persona.detailed.md#analytics-and-reporting) |

## File Structure

```
$NPL_PERSONA_DIR/
├── {id}.persona.md       # Role, voice, expertise
├── {id}.journal.md       # Experience log
├── {id}.tasks.md         # Active tasks
└── {id}.knowledge-base.md
```

See [File System Structure](./npl-persona.detailed.md#file-system-structure) for complete layout including teams and shared resources.

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `$NPL_PERSONA_DIR` | Base path for personas |
| `$NPL_PERSONA_TEAMS` | Team definitions path |
| `$NPL_PERSONA_SHARED` | Shared resources path |

Resolution order: project -> user -> system. See [Environment Variables](./npl-persona.detailed.md#environment-variables).

## Agent Invocation Patterns

```bash
# Single persona
@persona sarah-architect "Review this API design"

# Multiple personas
@persona alice,bob,charlie "Review auth PR #482"

# Team session
@persona --team=architects "Architecture decision"

# Sequential workflow
@persona designer "Create mockup" | @persona dev "Implement"
```

See [Agent Usage](./npl-persona.detailed.md#agent-usage) for all patterns.

## Integration

```bash
# With technical writer
@persona tech-leads "Review spec" | @npl-technical-writer "Format as RFC"

# With grader
@persona --panel=architects "Review" | @npl-grader "Grade"
```

See [Integration Patterns](./npl-persona.detailed.md#integration-patterns).

## Best Practices

1. Complete all persona file sections for consistent behavior
2. Run `health --all` regularly to catch file issues
3. Archive journals before exceeding 100KB
4. Use `team synthesize` monthly to identify knowledge gaps
5. Commit persona files to version control

See [Best Practices](./npl-persona.detailed.md#best-practices) and [Limitations](./npl-persona.detailed.md#limitations).

## See Also

- **Detailed Reference**: [npl-persona.detailed.md](./npl-persona.detailed.md)
- **Agent Definition**: `core/agents/npl-persona.md`
- **CLI Script**: `core/scripts/npl-persona`
