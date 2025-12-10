# scripts.md

Prompt file documenting available NPL command-line tools for CLAUDE.md and agent contexts.

**Source**: `core/prompts/scripts.md`
**Version**: 1.1.0

## Purpose

Provides LLMs with awareness of NPL scripts during conversations. Enables discovery of codebase exploration, persona management, session management, and visualization tools.

See [Purpose](./scripts.detailed.md#purpose) for details.

## Scripts Documented

| Script | Description |
|:-------|:------------|
| npl-load | Resource loader with hierarchical path resolution |
| npl-persona | Persona lifecycle, journals, tasks, knowledge, teams |
| npl-session | Session management and worklogs |
| npl-fim-config | Visualization tool configuration |
| dump-files | Dump file contents recursively |
| git-tree | Display directory tree |
| git-tree-depth | List directories with nesting depth |

See [Script Documentation](./scripts.detailed.md#script-documentation) for command details.

## Loading

```bash
# Via init-claude (default prompt set)
npl-load init-claude

# Direct load
npl-load prompt scripts

# Check version status
npl-load init-claude --json
```

See [Integration with CLAUDE.md](./scripts.detailed.md#integration-with-claudemd) for version management.

## Quick Reference

### npl-load

```bash
npl-load c "syntax,agent" --skip ""
npl-load agent my-agent --definition
npl-load init-claude --update-all
```

### npl-persona

```bash
npl-persona init <id>
npl-persona journal <id> add "Entry text"
npl-persona task <id> add "Task description"
npl-persona team synthesize <team-id>
```

### npl-session

```bash
npl-session init --task="Task description"
npl-session log --agent=agent-001 --action=found --summary="description"
npl-session read --agent=parent
npl-session close --archive
```

### Codebase Exploration

```bash
dump-files src/ -g "*.md"
git-tree core/
git-tree-depth src/
```

## See Also

- [Detailed Reference](./scripts.detailed.md) - Complete documentation
- [npl-load.detailed.md](../scripts/npl-load.detailed.md) - Full npl-load docs
- [npl-session.detailed.md](../scripts/npl-session.detailed.md) - Session management
