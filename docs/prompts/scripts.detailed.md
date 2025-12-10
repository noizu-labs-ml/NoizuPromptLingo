# scripts.md Detailed Reference

Prompt file that provides a quick-reference catalog of NPL scripts for inclusion in CLAUDE.md and agent contexts.

## Synopsis

The `scripts.md` prompt file documents available NPL command-line tools in a compact tabular format. It is designed for injection into CLAUDE.md via `npl-load init-claude`.

**Source**: `core/prompts/scripts.md`
**Version**: 1.1.0
**Load command**: `npl-load prompt scripts`

---

## Purpose

This prompt provides LLMs with awareness of available NPL scripts during conversations. When loaded into context, it enables:

- Discovery of codebase exploration tools
- Understanding of persona management capabilities
- Knowledge of session and worklog infrastructure
- Access to visualization configuration tools

Without this prompt, agents lack knowledge of NPL tooling beyond standard shell commands.

---

## Structure

### Frontmatter

```yaml
npl-instructions:
   name: npl-scripts
   version: 1.1.0
```

The frontmatter enables version tracking for `npl-load init-claude` updates.

### Script Sections

The prompt documents five tool categories:

| Section | Scripts Covered |
|:--------|:----------------|
| npl-load | Resource loader with subcommands |
| npl-persona | Persona lifecycle, journals, tasks, knowledge, teams |
| npl-session | Session management and worklogs |
| npl-fim-config | Visualization tool configuration |
| Codebase Exploration | dump-files, git-tree, git-tree-depth |

---

## Script Documentation

### npl-load

Resource loader with hierarchical path resolution. Documented subcommands:

| Subcommand | Function |
|:-----------|:---------|
| `c <items>` | Load core components |
| `m <items>` | Load metadata |
| `s <items>` | Load style guides |
| `agent <name>` | Load agent definitions |
| `init-claude` | Initialize/update CLAUDE.md |
| `syntax --file <f>` | Analyze NPL syntax elements |

**Note**: Full `npl-load` documentation lives in [npl-load.detailed.md](../scripts/npl-load.detailed.md).

### npl-persona

Persona management for simulated agent identities. Command groups:

| Group | Commands | Purpose |
|:------|:---------|:--------|
| Lifecycle | init, get, list, remove | Create and manage personas |
| Journal | journal add/view/archive | Track experiences and learnings |
| Tasks | task add/update/complete/list | Manage persona goals |
| Knowledge | kb add/search/get | Build knowledge bases |
| Teams | team create/add/list/synthesize | Multi-persona collaboration |
| Maintenance | health, sync, backup | File integrity and backups |

### npl-session

Session and worklog management for cross-agent communication. Commands:

| Command | Purpose |
|:--------|:--------|
| `init [--task=X]` | Create new session |
| `current` | Get current session ID |
| `log --agent=X --action=Y --summary="..."` | Append worklog entry |
| `read --agent=X [--peek] [--since=N]` | Read entries since cursor |
| `status` | Show session statistics |
| `list [--all]` | List sessions |
| `close [--archive]` | Close current session |

**Cursor system**: Each agent maintains its own cursor at `.cursors/<agent-id>.cursor`, allowing independent read tracking.

### npl-fim-config

Configuration tool for NPL-FIM visualization agent. Commands:

| Command | Purpose |
|:--------|:--------|
| `query <desc>` | Find tools matching description |
| `list-tools` | List supported visualization tools |
| `matrix` | Show full compatibility matrix |

### Codebase Exploration

Simple file and directory inspection tools:

| Script | Purpose |
|:-------|:--------|
| `dump-files <path>` | Dump all file contents with headers |
| `git-tree [path]` | Display directory tree |
| `git-tree-depth <path>` | List directories with nesting depth |

---

## Integration with CLAUDE.md

### Loading via init-claude

The scripts prompt is part of the default prompt set for CLAUDE.md initialization:

```bash
npl-load init-claude --prompts "npl npl_load scripts sql-lite"
```

### Version Updates

Check if the installed version is current:

```bash
npl-load init-claude
```

Update to latest version:

```bash
npl-load init-claude --update scripts
```

### Manual Loading

Load directly into agent context:

```bash
npl-load prompt scripts
```

---

## Usage Patterns

### Agent Bootstrapping

Include in agent definitions to provide tool awareness:

```markdown
You must load before proceeding:

\`\`\`bash
npl-load c "syntax,agent" --skip {@npl.def.loaded}
\`\`\`
```

### Session-Based Workflows

Parent agents can initialize sessions for sub-agent coordination:

```bash
# Parent agent initializes
npl-session init --task="Code review"

# Sub-agents log their work
npl-session log --agent=scanner-001 --action=found --summary="security issue in auth.ts"

# Parent reads updates
npl-session read --agent=parent
```

### Visualization Tasks

Query appropriate tools for visualization tasks:

```bash
npl-fim-config query "network diagram"
npl-fim-config query "bar chart comparison"
```

---

## Relationship to Other Prompts

| Prompt | Relationship |
|:-------|:-------------|
| `npl.md` | Core NPL syntax referenced by scripts |
| `npl_load.md` | Detailed npl-load documentation |
| `sql-lite.md` | Database operations for session storage |

---

## Design Decisions

### Tabular Format

Scripts are documented in tables for:
- Scan-ability in context
- Compact token usage
- Consistent structure across tools

### Grouped Commands

Commands are grouped by function (lifecycle, journal, tasks) rather than alphabetically to:
- Show conceptual relationships
- Enable task-oriented lookup
- Reduce cognitive load

### Example Commands

Each subcommand includes an example to:
- Demonstrate syntax patterns
- Show typical argument values
- Enable copy-paste usage

---

## Limitations

- **Not exhaustive**: Does not document all command options
- **Reference only**: Does not teach workflows or best practices
- **Static**: Requires manual updates when scripts change

For complete documentation of individual scripts, see the `/docs/scripts/` directory.

---

## See Also

- [scripts.md](./scripts.md) - Concise reference
- [npl-load.detailed.md](../scripts/npl-load.detailed.md) - Full npl-load documentation
- [npl-persona.detailed.md](../scripts/npl-persona.detailed.md) - Persona management details
- [npl-session.detailed.md](../scripts/npl-session.detailed.md) - Session management details
