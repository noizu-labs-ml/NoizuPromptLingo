# npl.md - NPL Conventions Reference

## Purpose

The `npl.md` prompt file establishes runtime conventions for NPL-powered agents. It configures agent delegation modes, work logging behavior, session tracking, and provides quick-reference documentation for visualization preferences, codebase tools, and core NPL syntax.

This file is typically loaded as the primary conventions reference for agent sessions, setting operational defaults that govern how agents collaborate, communicate, and document their work.

---

## File Structure

```
npl.md
├── YAML Frontmatter (name, version)
├── Runtime Flags Block
├── Agent Delegation
│   ├── Command-and-Control Modes
│   ├── Work-Log Flag
│   ├── Track-Work Flag
│   ├── Available Agents
│   ├── Session Directory Layout
│   ├── Interstitial Files
│   └── Worklog Communication
├── Visualization Preferences
├── Codebase Tools
└── NPL Framework Quick Reference
```

---

## Sections

### YAML Frontmatter

```yaml
npl-instructions:
   name: npl-conventions
   version: 1.3.0
```

Declares the instruction set name and version for tracking and compatibility.

### Runtime Flags

```
@command-and-control="task-master"
@work-log="standard"
@track-work=true
```

| Flag | Default | Description |
|:-----|:--------|:------------|
| `@command-and-control` | `task-master` | Agent delegation strategy |
| `@work-log` | `standard` | Interstitial file generation mode |
| `@track-work` | `true` | Enable session worklog tracking |

### Command-and-Control Modes

Controls how aggressively the primary agent delegates to sub-agents.

| Mode | Behavior |
|:-----|:---------|
| `lone-wolf` | Work independently; delegate only when explicitly requested |
| `team-member` | Suggest sub-agents during planning for complex tasks |
| `task-master` | Aggressively parallelize; push work to sub-agents |

Custom modes can be defined:
```
@command-and-control.{name}.definition="custom behavior description"
```

### Work-Log Flag

Controls which interstitial files agents generate in `.npl/sessions/<session>/tmp/<agent-id>/`:

| Value | Files Generated |
|:------|:----------------|
| `false` | None |
| `standard` | `.summary.md` + `.detailed.md` |
| `verbose` | All: `.summary.md`, `.detailed.md`, `.yaml` |
| `yaml|summary` | `.yaml` + `.summary.md` |
| `yaml|detailed` | `.yaml` + `.detailed.md` |

### Track-Work Flag

Enables session-based worklog tracking for cross-agent communication. Set `@track-work=false` to disable all session logging.

### Available Agents

| Agent | Purpose |
|:------|:--------|
| `Explore` | Codebase exploration, pattern discovery |
| `Plan` | Implementation design, architecture |
| `npl-technical-writer` | Documentation, specs, PRs |
| `npl-gopher-scout` | Reconnaissance, analysis |
| `npl-grader` | Validation, QA, edge testing |

### Session Directory Layout

Sessions organize shared worklogs and interstitial files under `.npl/sessions/YYYY-MM-DD/`:

```
.npl/sessions/YYYY-MM-DD/
├── meta.json           # Session metadata
├── worklog.jsonl       # Append-only shared log
├── .cursors/           # Per-agent read cursors
│   └── <agent-id>.cursor
└── tmp/                # Interstitial files
    └── <agent-id>/
        ├── <task>.summary.md
        ├── <task>.detailed.md
        └── <task>.yaml
```

**Agent ID Format**: `<agent-type>-<task-slug>-<NNN>`

Examples: `explore-auth-001`, `plan-api-design-002`

### Interstitial Files

| File | Purpose |
|:-----|:--------|
| `<task>.summary.md` | High-level findings; references headings in detailed file |
| `<task>.detailed.md` | Full content with `##` headings matching summary refs |
| `<task>.yaml` | Structured data (only in `verbose` or `yaml|*` modes) |

Reading pattern: Agents read `.summary.md` first, then fetch specific `##` sections from `.detailed.md` as needed.

### Worklog Communication

When `@track-work=true`, agents append entries to `worklog.jsonl`:

```bash
npl-session log --agent=explore-auth-001 --action=file_found --summary="Found auth.ts"
npl-session read --agent=primary  # Read new entries since cursor
```

Entry format:
```json
{"seq":1,"ts":"2025-12-10T08:01:30Z","agent_id":"explore-auth-001","agent_type":"Explore","action":"file_found","summary":"Found 3 auth files","data":{"files":["auth.ts"]},"tags":["discovery"]}
```

### Visualization Preferences

| Task | Preferred | Avoid |
|:-----|:----------|:------|
| Flowcharts | mermaid flowchart | ASCII boxes |
| Sequences | mermaid sequenceDiagram | ASCII arrows |
| Graphs | graphviz dot, YAML | ASCII trees |
| UI Mockups | SVG artifacts | ASCII frames |
| Data structures | YAML, JSON | ASCII tables |
| State machines | mermaid stateDiagram | ASCII diagrams |

### Codebase Tools

| Tool | Purpose | Example |
|:-----|:--------|:--------|
| Glob | Find files by pattern | `Glob("**/*.md")` |
| Grep | Search file contents | `Grep("def main", type="py")` |
| Read | View file contents | `Read("/path/to/file.py")` |
| Task | Delegate to agents | `Task("@reviewer analyze PR")` |

**Pattern**: Search first (`Glob`/`Grep`), then read relevant files.

### NPL Framework Quick Reference

**Agent invocation**: `@agent-name command args`

**Common fences**:
- `example` / `syntax` / `format` - Input/output specifications
- `diagram` - Mermaid, graphviz, plantuml
- `artifact` - Structured output with metadata

**Intuition pumps**:
- `<npl-intent>` - Clarify goals before acting
- `<npl-cot>` - Chain-of-thought reasoning
- `<npl-reflection>` - Evaluate output quality

**Key markers**:
- Highlight: `` `term` ``
- Attention: `target instruction`
- In-fill: `[...]` or `[...|qualifier]`
- Placeholder: `<term>`, `{term}`

---

## Usage Examples

### Loading in a Prompt

```bash
npl-load c "npl" --skip {@npl.def.loaded}
```

### Overriding Defaults

To work independently without sub-agents:
```
@command-and-control="lone-wolf"
```

To disable all logging:
```
@work-log="false"
@track-work=false
```

To enable verbose logging with YAML:
```
@work-log="verbose"
```

### Session Workflow

```bash
# Initialize session
npl-session init --task="Implement auth feature"

# Sub-agent logs findings
npl-session log --agent=explore-auth-001 --type=Explore \
    --action=file_found --summary="Found auth.ts, auth.test.ts"

# Parent reads new entries
npl-session read --agent=primary

# Monitor in real-time
tail -F .npl/sessions/$(npl-session current)/worklog.jsonl
```

---

## Integration

### Related Components

| Component | Relationship |
|:----------|:-------------|
| `npl/agent.md` | Full agent specification, worklog schema |
| `npl-session` script | CLI for session and worklog management |
| `CLAUDE.md` | Project-level NPL instructions |

### Loading Order

1. Core NPL syntax (`npl-load c "syntax"`)
2. NPL conventions (`npl-load c "npl"`)
3. Agent definitions (loaded per-task)
4. Style guides (`npl-load s "house-style"`)

---

## Best Practices

### Agent Delegation

- Use `task-master` for large codebases where parallelization saves time
- Use `lone-wolf` for focused, single-file changes
- Use `team-member` for balanced planning sessions

### Work Logging

- Use `standard` for most workflows (summary + detailed)
- Use `verbose` when machine-parseable YAML output is needed
- Use `false` for quick, one-off tasks

### Session Management

- Sessions auto-create on first sub-agent spawn
- Close sessions with `npl-session close` when work completes
- Use `--archive` to move old sessions out of active listing

### Interstitial File Patterns

- Write `.summary.md` first with clear heading references
- Use consistent `##` heading format in `.detailed.md`
- Keep YAML files flat and machine-readable
