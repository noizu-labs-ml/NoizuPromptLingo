# npl-persona - Persona

**Type**: Script
**Category**: Persona Management
**Version**: 1.0.0

## Overview

`npl-persona` is a comprehensive persona management tool that creates, tracks, and evolves simulated agent identities with persistent memory, task management, and knowledge bases. It enables multi-tier hierarchical loading (project → user → system) and supports team-based collaboration through shared knowledge synthesis and interaction tracking.

## Purpose & Use Cases

- Create and manage persistent AI personas with distinct roles, expertise, and characteristics
- Track persona experiences, decisions, and learnings through timestamped journals
- Manage persona-specific tasks, goals, and OKRs with status tracking
- Build domain-specific knowledge bases with confidence-weighted expertise graphs
- Facilitate multi-persona team collaboration with knowledge sharing and synthesis
- Maintain file integrity through health checks, validation, and automated backups

## Key Features

✅ Four-file persona architecture (definition, journal, tasks, knowledge-base)
✅ Hierarchical path resolution (environment → project → user → system)
✅ Dependency tracking with flag-based skip mechanisms (`@npl.personas.loaded`)
✅ Team management with expertise matrices and collaboration analytics
✅ Knowledge sharing between personas with optional attribution
✅ Health monitoring with file size warnings and integrity scoring
✅ Backup and archival operations for long-term persona evolution
✅ Analytics and reporting (journal sentiment, task completion, team dynamics)

## Usage

```bash
npl-persona <command> [options]
```

**Lifecycle Commands:**
```bash
npl-persona init <id> --role "Architect"      # Create persona
npl-persona get <id> --files definition,tasks  # Load files
npl-persona list --scope project -v            # List personas
npl-persona remove <id> --force                # Delete persona
```

**Daily Operations:**
```bash
npl-persona journal <id> add --message "..."   # Log experience
npl-persona task <id> add "Task" --due DATE    # Add task
npl-persona kb <id> add "Topic" --content "..."# Add knowledge
```

**Team Collaboration:**
```bash
npl-persona team create <team> --members "a,b" # Create team
npl-persona share <from> <to> --topic "Topic"  # Share knowledge
npl-persona team synthesize <team>             # Generate synthesis
```

## Integration Points

- **Triggered by**: Agent initialization via `npl-load`, manual invocation, CI/CD health checks
- **Feeds to**: Agent prompts (via `get` command), team reports, session worklogs
- **Complements**: `npl-load` (component loading), `npl-session` (worklog tracking), agent orchestration systems

## Parameters / Configuration

- `--scope` - Target tier: `project`, `user`, `system`
- `--files` - File subset: `definition`, `journal`, `tasks`, `knowledge`, `all`
- `--skip` - Comma-separated persona IDs to skip if already loaded
- `--verbose`, `-v` - Show detailed information (file status, member info)
- Environment variables: `$NPL_PERSONA_DIR`, `$NPL_PERSONA_TEAMS`, `$NPL_PERSONA_SHARED`

## Success Criteria

- All four mandatory files present and valid with proper NPL headers
- Flag updates correctly track loaded personas to prevent redundant loading
- Journal entries maintain chronological order with structured reflections
- Task status transitions follow valid state machine (pending → in-progress → completed)
- Knowledge base maintains confidence-weighted domain expertise
- Health score remains ≥ 90% (all files present, no critical warnings)

## Limitations & Constraints

- Task matching uses substring search; may match unintended tasks
- Sentiment analysis is keyword-based; not context-aware
- Knowledge search is line-based; won't match multi-line content
- Interactive mode (`-i`) requires terminal stdin; incompatible with pipes
- Report formats beyond `md` generate markdown despite format flag
- Backup creates flat archives without preserving scope hierarchy

## Related Utilities

- `npl-load` - Load NPL components and metadata with hierarchical resolution
- `npl-session` - Session and worklog management for cross-agent communication
- `npl-fim-config` - Configuration tool for visualization agents
- `dump-files` - Dump file contents for persona knowledge ingestion
