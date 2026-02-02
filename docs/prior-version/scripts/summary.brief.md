# NPL Scripts Summary

## 8 CLI Scripts

| Script | Purpose | Key Parameters |
|--------|---------|-----------------|
| **npl-load** | Hierarchical resource loader | `c/m/s` (core/meta/style), items, `--skip`, `--verbose` |
| **npl-persona** | Persona lifecycle management | `init/get/list/remove/journal/task/kb/team`, `--scope`, `--role` |
| **npl-session** | Cross-agent worklog coordination | `init/log/read/status/close`, `--agent`, `--task`, `--peek` |
| **npl-fim-config** | Visualization tool selection | `--query`, `--table`, `--preferred-solution`, `--local` |
| **dump-files** | Extract file contents | `<target-folder>`, `--glob` patterns |
| **git-tree** | Directory structure viewer | `[target-folder]`, Git-aware filtering |
| **git-tree-depth** | Directory depth analysis | `<target-folder>`, depth relative to target |
| **git-dir-depth** | Legacy alias for git-tree-depth | Same parameters |

## Categories

**Resource Loading & Configuration**
- `npl-load`: Loads components, metadata, styles, prompts, agent definitions from hierarchical paths (env → project → user → system)
- `npl-fim-config`: Queries tool-task compatibility matrix and delegates to `npl-load`

**Persona & Team Management**
- `npl-persona`: Creates/manages persona files (definition, journal, tasks, knowledge-base), enables multi-persona teams
- Supports journal entries, task tracking, KB domains, team synthesis, health checks, backups

**Session & Worklog Coordination**
- `npl-session`: JSONL-based shared worklog with cursor-based per-agent reads
- Enables parent-child agent communication via append-only entries, dependency tracking

**Codebase Exploration**
- `dump-files`: Respects `.gitignore`, outputs formatted file contents with headers and `* * *` delimiters
- `git-tree`: Git-aware tree visualization using `tree` command or bash fallback
- `git-tree-depth`: Lists directories with nesting levels relative to target

## Common Workflows

**Resource Discovery & Loading**
```bash
# Load core components
npl-load c "syntax,agent" --skip ""
# Load with dependencies tracked
npl-load c "syntax,agent,pumps" --skip "syntax"
# Load agent definition
npl-load agent my-agent --definition
```

**Project Analysis for Agents**
```bash
# Dump source files for analysis
dump-files src/ -g "*.py"
# Show project structure
git-tree
# Analyze directory nesting
git-tree-depth src/
```

**Cross-Agent Coordination**
```bash
# Initialize session
npl-session init --task="Implement feature"
# Log discoveries
npl-session log --agent=explore-001 --action=found --summary="Found config.py"
# Read new entries
npl-session read --agent=parent
```

**Persona Collaboration**
```bash
# Create persona
npl-persona init sarah-architect --role "Architect"
# Track work
npl-persona journal sarah-architect add "Reviewed API design"
npl-persona task sarah-architect add "Refactor schema"
# Team synthesis
npl-persona team synthesize backend-team
```

**Visualization Tool Selection**
```bash
# Query for tool
npl-fim-config --query "organization chart for React"
# Show compatibility matrix
npl-fim-config --table
# Get preferred solution
npl-fim-config network-graphs --preferred-solution
```
