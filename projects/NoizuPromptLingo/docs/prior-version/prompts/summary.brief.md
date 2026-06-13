# NPL Prompts Summary

## NPL Syntax Overview

**Core Markers & Directives**
- Highlight: Backticks `` `term` ``
- Attention: `🎯 instruction` emoji prefix
- In-fill: `[...]` or `[...|qualifier]` placeholders
- Placeholders: `<term>` or `{term}` template syntax

**Intuition Pumps (Reasoning Aids)**
- `<npl-intent>`: Clarify goals before acting
- `<npl-cot>`: Chain-of-thought reasoning steps
- `<npl-reflection>`: Evaluate output quality and iterate

**Fence Blocks**
- `example`, `syntax`, `format`: Specify input/output specs
- `diagram`: Mermaid, graphviz, plantuml visualizations
- `artifact`: Structured output with metadata, designed for agent processing

**Visualization Preferences**
- Use Mermaid flowcharts over ASCII boxes
- Use mermaid sequenceDiagram over ASCII arrows
- Prefer YAML/JSON for data structures over ASCII tables
- Use SVG artifacts for UI mockups, not ASCII frames
- Prefer graphviz/mermaid state diagrams over ASCII state representations

## Load Protocol (Multi-Tier Resolution)

**Path Resolution Order**
1. Environment variable override (e.g., `$NPL_HOME`)
2. Project directory (`./.npl/`)
3. User directory (`~/.npl/`)
4. System directory (platform-specific)

**Environment Variables**
- `$NPL_HOME`: Base NPL path
- `$NPL_META`: Metadata files
- `$NPL_STYLE_GUIDE`: Style conventions
- `$NPL_THEME`: Theme name for styles
- `$NPL_PERSONA_DIR`: Persona definitions
- `$NPL_PERSONA_TEAMS`: Team definitions
- `$NPL_PERSONA_SHARED`: Shared persona resources

**Dependency Tracking (Skip Flags)**
```bash
# First load
npl-load c "syntax,agent" --skip ""
# Returns: @npl.def.loaded+="syntax,agent"

# Subsequent load (pass loaded items via --skip)
npl-load c "syntax,agent,pumps" --skip "syntax,agent"
# Only loads: pumps
```

Flags prevent duplicate loading across invocations. The tool outputs global flags that must be passed back via `--skip` on subsequent calls.

## SQLite Guide

**Heredoc Pattern (Multi-Line Operations)**
```bash
sqlite3 mydb.sqlite <<'EOF'
<SQL statements>
EOF
```

**CRUD Operations**

| Operation | Example |
|-----------|---------|
| Create | `CREATE TABLE t (id INTEGER PRIMARY KEY, name TEXT);` |
| Insert | `INSERT INTO t (name) VALUES ('val1'), ('val2');` |
| Query | `SELECT * FROM t WHERE condition;` |
| Alter | `ALTER TABLE t ADD COLUMN col TEXT;` |
| Update | `UPDATE t SET col = 'val' WHERE condition;` |
| Delete | `DELETE FROM t WHERE condition;` |

**One-Liner Query**
```bash
sqlite3 -header -column mydb.sqlite 'SELECT * FROM users;'
```

**Output Formats**
- CSV: `sqlite3 -csv mydb.sqlite 'SELECT ...;'`
- JSON: `sqlite3 -json mydb.sqlite 'SELECT ...;'`
- Formatted table: `sqlite3 -header -column mydb.sqlite 'SELECT ...;'`

**Tips**
- Use `<<'EOF'` (quoted) to prevent variable expansion
- Escape single quotes by doubling: `'O''Brien'`
- Enable WAL mode for concurrent access

## Script Reference (Invocation Patterns)

**Resource Loading**
```bash
npl-load c "syntax,agent" --skip {@npl.def.loaded}
npl-load m "persona.qa-engineer" --skip ""
npl-load s "house-style" --skip ""
npl-load agent my-agent --definition
npl-load init-claude --update-all
```

**Persona Management**
```bash
npl-persona init sarah-architect --role "Architect"
npl-persona get sarah-architect --files definition,tasks --skip sarah-architect
npl-persona journal sarah-architect add "Completed review"
npl-persona task sarah-architect add "Refactor API"
npl-persona team create backend --members "a,b,c"
npl-persona team synthesize backend
```

**Session Coordination**
```bash
npl-session init --task="Implement auth"
npl-session log --agent=explore-001 --action=found --summary="Found auth.ts"
npl-session read --agent=primary --peek
npl-session status --json
npl-session close --archive
```

**Codebase Exploration**
```bash
dump-files src/ -g "*.md"
git-tree core/
git-tree-depth src/
```

**Visualization Selection**
```bash
npl-fim-config --query "organization chart"
npl-fim-config --table
npl-fim-config network-graphs --preferred-solution
```

## Integration Patterns

**Session-Based Agent Coordination**
- Parent agent initializes session: `npl-session init --task=X`
- Sub-agents log discoveries: `npl-session log --agent=id --action=Y`
- Parent reads new entries: `npl-session read --agent=parent`
- Each agent maintains independent cursor for incremental reads

**Dependency Tracking Across Invocations**
- Tool outputs flags after loading: `@npl.def.loaded+="syntax,agent"`
- Pass flags back via `--skip` to prevent reloading
- Supports glob patterns in skip list: `--skip "syntax*"`

**Interstitial File Generation**
- Work-log flag controls output: `@work-log="standard|verbose|yaml|summary"`
- Files generated in `.npl/tmp/<agent-id>/`
  - `.summary.md`: High-level findings with section references
  - `.detailed.md`: Full content with `##` headings matching summary
  - `.yaml`: Structured data (verbose mode only)
- Agents read summary first, then fetch specific sections from detailed file as needed
