# npl-persona

**Type**: Script
**Category**: Persona Management
**Status**: Core

## Purpose

`npl-persona` is a comprehensive persona management tool for NPL that enables creation, tracking, and team collaboration through simulated agent identities. Each persona maintains persistent state across four mandatory files (definition, journal, tasks, knowledge-base), supporting multi-tiered hierarchical loading from project, user, and system scopes. The tool facilitates collaborative problem-solving through multi-persona teams with shared knowledge synthesis, activity tracking, and automated reporting.

## Key Capabilities

- **Lifecycle management**: Create, retrieve, locate, and remove personas with template initialization or cloning
- **Experience tracking**: Chronological journal entries with reflection blocks, participant tracking, and archival
- **Task management**: Active task tracking with status transitions, priorities, and due dates
- - **Knowledge base**: Domain expertise with confidence levels, learning paths, and cross-persona sharing
- **Team collaboration**: Multi-persona teams with knowledge synthesis, expertise matrices, and interaction analysis
- **Health monitoring**: File integrity checks, size warnings, and automated backup with compression

## Usage & Integration

- **Triggered by**: Command-line invocation or agent scripts via `npl-load` workflows
- **Outputs to**: Markdown files in `.npl/personas/`, `.npl/teams/`, `.npl/shared/` with NPL-formatted content
- **Complements**: `npl-load` (resource loading), `npl-session` (worklog communication), agent definitions

## Core Operations

### Create and load persona
```bash
npl-persona init sarah-architect --role "Software Architect"
npl-persona get sarah-architect --files definition,tasks
```

### Daily workflow
```bash
npl-persona journal sarah-architect add --message "Completed API review"
npl-persona task sarah-architect complete "Review API design"
npl-persona kb sarah-architect add "REST Patterns" --content "Use HATEOAS..." --source "API Guidelines v2"
```

### Team operations
```bash
npl-persona team create backend-team --members "sarah,bob,carol"
npl-persona team synthesize backend-team
npl-persona share sarah-architect bob-developer --topic "API Design" --translate
```

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| `--scope` | Search/creation scope | project | Choices: `project`, `user`, `system` |
| `--files` | File subset to load | all | Comma-separated: `definition,journal,tasks,knowledge` |
| `--skip` | Skip already-loaded personas | `[]` | Prevents reloading; use tracking flags |
| `--verbose`, `-v` | Detailed output | false | Shows file status, integrity, member info |

## Integration Points

- **Upstream dependencies**: Hierarchical path resolution (NPL_PERSONA_DIR → ./.npl/personas → ~/.npl/personas → system)
- **Downstream consumers**: Agents reading persona context, CI/CD health checks, automated backup cron jobs
- **Related utilities**: `npl-load` for component loading, `npl-session` for cross-agent worklogs, `dump-files` for content extraction

## Limitations & Constraints

- Interactive mode (`-i`) requires terminal stdin; incompatible with piped input
- Task matching uses substring; may match unintended tasks without unique descriptions
- Sentiment analysis is keyword-based; lacks context-awareness
- Backup creates flat tar.gz archive; does not preserve scope hierarchy
- Report formats (`json`, `html`) currently generate markdown regardless of flag

## Success Indicators

- All four mandatory files present per persona (verified via `health` command)
- Dependency tracking flags output after `get` command (e.g., `@npl.personas.loaded+="sarah-architect"`)
- Health score ≥95% (no missing files, no integrity issues, size under thresholds)
- Team collaboration index >60% (calculated from unique pairs / possible pairs)

---
**Generated from**: worktrees/main/docs/scripts/npl-persona.md, worktrees/main/docs/scripts/npl-persona.detailed.md
