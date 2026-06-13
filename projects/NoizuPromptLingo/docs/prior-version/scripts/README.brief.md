# Scripts Documentation

**Type**: Documentation / Reference
**Category**: Scripts
**Status**: Core

## Purpose

Comprehensive reference for NPL project scripts and utilities. Documents two categories: project scripts (`.claude/scripts/`) for active development and scaffolding scripts (`agentic/scaffolding/scripts/`) for distribution. Provides Git-aware file analysis, directory visualization, and session management tools designed for seamless integration with NPL agents.

## Key Capabilities

- **Git-Aware File Operations**: Dump file contents and visualize directory structures respecting `.gitignore` patterns
- **Directory Analysis**: Calculate nesting depth and generate tree visualizations
- **Glob Filtering**: Pattern-based file selection for targeted content extraction
- **Session Management**: Shared JSONL worklogs with cursor-based reads for cross-agent communication
- **Scaffolding Distribution**: Identical functionality scripts packaged for NPL deployment across projects
- **Agent Integration**: Formatted outputs optimized for NPL agent consumption

## Usage & Integration

**Triggered by**: NPL agents requiring project structure analysis, file content extraction, or cross-agent coordination.

**Outputs to**: NPL agents (formatted text), session worklogs (JSONL), standard output (tree/depth visualizations).

**Complements**: NPL agent personas (`npl-gopher-scout`, `npl-technical-writer`), exploration workflows, documentation generation pipelines.

## Core Operations

### File Content Extraction
```bash
# Dump all files in directory (respects .gitignore)
./.claude/scripts/dump-files src/

# Filter with glob patterns
./.claude/scripts/dump-files docs/ -g "*.md" -g "*.ts"
```

### Directory Visualization
```bash
# Show tree structure
./.claude/scripts/git-tree deployments/

# Calculate nesting depth
./.claude/scripts/git-dir-depth src/
```

### Session Management
```bash
# Initialize session
npl-session init --task="Feature implementation"

# Log discovery
npl-session log --agent=explore-001 --action=file_found --summary="Found auth.ts"

# Read new entries
npl-session read --agent=primary
```

## Configuration & Parameters

### dump-files
| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| `target-folder` | Directory to process | (required) | Respects Git tracking rules |
| `--glob PATTERN` | Shell pattern filter | none | Multiple `-g` flags allowed |

### git-tree
| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| `target-folder` | Directory to visualize | current dir | Requires `tree` command |

### npl-session
| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| `--agent=ID` | Agent identifier | (required) | Format: `<type>-<slug>-<NNN>` |
| `--action=ACTION` | Entry action type | (required) | e.g., `file_found`, `analysis_complete` |
| `--summary=TEXT` | Entry description | (required) | Human-readable summary |
| `--peek` | Read without cursor advance | false | For non-consuming reads |

## Integration Points

- **Upstream dependencies**: Git repository context, `.gitignore` configuration
- **Downstream consumers**: NPL agents (Explore, Plan, gopher-scout, technical-writer), documentation generators
- **Related utilities**: `npl-load` (resource loading), `npl-persona` (agent identity management), `npl-fim-config` (visualization configuration)

## Limitations & Constraints

- `dump-files`/`git-tree` require Git repository context; fail outside repos
- `git-tree` depends on external `tree` command installation
- Session worklogs use append-only JSONL format (no in-place edits)
- Scaffolding scripts must be manually copied to target projects (no auto-sync)

## Success Indicators

- Formatted file dumps include clear delimiters and path headers
- Directory visualizations exclude ignored files per `.gitignore`
- Session reads advance cursors correctly, preventing duplicate entry processing
- Scaffolding deployments maintain behavioral parity with project scripts

---
**Generated from**: worktrees/main/docs/scripts/README.md
