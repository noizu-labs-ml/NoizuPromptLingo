# Scripts - Persona

**Type**: Prompt
**Category**: Tools Documentation
**Version**: 1.0.0

## Overview

The Scripts prompt provides LLMs with comprehensive awareness of NPL command-line tools during conversations. It serves as a quick-reference catalog enabling discovery of codebase exploration utilities, persona management systems, session coordination infrastructure, and visualization configuration tools.

## Purpose & Use Cases

- **Tool Discovery**: Enable LLMs to discover available NPL scripts without searching documentation
- **Agent Bootstrapping**: Provide tool awareness to agents during initialization
- **Session Workflows**: Document commands for cross-agent communication via worklogs
- **Codebase Navigation**: Expose file exploration and directory inspection utilities
- **Visualization Tasks**: Query appropriate tools for chart, diagram, and visualization generation

## Key Features

✅ **Tabular Script Catalog** - Compact, scannable reference format for all NPL tools
✅ **Grouped by Function** - Commands organized by lifecycle, journal, tasks, teams, not alphabetically
✅ **Example Commands** - Each subcommand includes practical usage examples
✅ **Version Tracking** - Frontmatter enables `npl-load init-claude` to detect outdated prompts
✅ **Hierarchical Tool Coverage** - Documents npl-load, npl-persona, npl-session, npl-fim-config, and exploration scripts
✅ **Integration Patterns** - Shows agent bootstrapping, session-based workflows, and visualization queries

## Usage

```bash
# Load via CLAUDE.md initialization (default prompt set)
npl-load init-claude

# Direct load into agent context
npl-load prompt scripts

# Check if prompt version is current
npl-load init-claude --json

# Update to latest version
npl-load init-claude --update scripts
```

Scripts prompt is loaded into CLAUDE.md during `npl-load init-claude` as part of the default prompt set alongside `npl`, `npl_load`, and `sql-lite` prompts. Once loaded, agents gain awareness of all documented NPL tooling.

## Integration Points

- **Triggered by**: `npl-load init-claude` or `npl-load prompt scripts` commands
- **Feeds to**: CLAUDE.md, agent context windows, sub-agent definitions
- **Complements**: `npl.md` (core NPL syntax), `npl_load.md` (loader details), `sql-lite.md` (database operations)

## Parameters / Configuration

- **Source Path**: `worktrees/main/docs/prompts/scripts.md` (concise) and `scripts.detailed.md` (comprehensive)
- **Version**: Tracked via frontmatter `npl-instructions.version` field (current: 1.1.0)
- **Load Target**: CLAUDE.md injection via `npl-load init-claude`
- **Update Strategy**: Version-based detection; manual update with `--update scripts` or bulk with `--update-all`
- **Output Format**: Markdown tables with command groups and examples

## Success Criteria

- Agents can discover NPL tools without external documentation lookup
- Command examples are copy-pasteable with minimal modification
- Version tracking prevents stale prompt usage
- Token usage remains compact (<2KB) for frequent context inclusion
- Grouped structure enables task-oriented lookup (not alphabetical scanning)

## Limitations & Constraints

- **Not Exhaustive**: Does not document all command options or flags
- **Reference Only**: Does not teach workflows, best practices, or design patterns
- **Static**: Requires manual updates when scripts change or new tools are added
- **No Error Handling**: Does not document failure modes, exit codes, or error messages

For complete documentation of individual scripts, see `docs/scripts/` directory with full `.detailed.md` files.

## Related Utilities

- **npl.md** - Core NPL syntax and conventions referenced by scripts
- **npl_load.md** - Detailed npl-load documentation and hierarchical resolution
- **sql-lite.md** - SQLite patterns for session storage and worklog persistence
- **npl-load** - Resource loader that injects this prompt into CLAUDE.md
- **npl-session** - Worklog infrastructure that scripts prompt documents
