# NPL Persona CLI Reference

`npl_persona` (v2.0) is a modular persona management package for NPL. It provides multi-tier hierarchical loading of persona files, journals, tasks, knowledge bases, and team management.

**Package**: `src/npl_persona/`
**Entry point**: `npl-persona` CLI or `from npl_persona import ...`

---

## Architecture

### Multi-Tier Path Resolution

Resources are searched in priority order (first-found wins):

1. **Environment override** — `NPL_PERSONA_DIR`, `NPL_PERSONA_TEAMS`, `NPL_PERSONA_SHARED`
2. **Project scope** — `./.npl/personas`, `./.npl/teams`, `./.npl/shared`
3. **User scope** — `~/.npl/personas`, `~/.npl/teams`, `~/.npl/shared`
4. **System scope** — `/Library/Application Support/npl/` (macOS), `/etc/npl/` (Linux)

### Mandatory Files Per Persona

Every persona consists of four markdown files:

| File | Purpose |
|------|---------|
| `{id}.persona.md` | Identity definition, expertise graph, relationships |
| `{id}.journal.md` | Continuous interactions and reflections |
| `{id}.tasks.md` | Active tasks, goals, OKRs, responsibilities |
| `{id}.knowledge-base.md` | Core domains, learning paths, references |

---

## CLI Commands

### Persona Management

```bash
npl-persona init <id> --role=architect --scope=project
npl-persona init <id> --from-template=user
npl-persona list --scope=all [--verbose]
npl-persona which <id>
npl-persona get <id> --files=definition,journal
npl-persona remove <id> --force
npl-persona health <id> [--verbose]
npl-persona health --all
npl-persona sync <id> --validate
npl-persona backup <id> --output=./backups
```

### Journal Operations

```bash
npl-persona journal <id> add --message="Learned about API patterns"
npl-persona journal <id> add --interactive
npl-persona journal <id> view --entries=5
npl-persona journal <id> view --since=2025-01-15
npl-persona journal <id> archive --before=2024-12-31
```

### Task Management

```bash
npl-persona task <id> add "Review API design" --due=2025-10-15 --priority=high
npl-persona task <id> list [--filter=blocked]
npl-persona task <id> update "Review API" --status=in-progress
npl-persona task <id> complete "Review API"
npl-persona task <id> remove "Old task"
```

### Knowledge Base

```bash
npl-persona kb <id> add "GraphQL" --content="Query language" --source="Apollo docs"
npl-persona kb <id> search "API" [--domain="Security"]
npl-persona kb <id> get "GraphQL"
npl-persona kb <id> update-domain "Architecture" --confidence=85
npl-persona share <from> <to> --topic="API patterns" --translate
```

### Teams

```bash
npl-persona team create <team_id> --members=alice,bob --scope=project
npl-persona team add <team_id> <persona_id>
npl-persona team list <team_id> [--verbose]
npl-persona team matrix <team_id>
npl-persona team synthesize <team_id> --output=./synthesis.md
npl-persona team analyze <team_id> --period=30
```

### Analytics

```bash
npl-persona analyze <id> --type=journal --period=30
npl-persona analyze <id> --type=tasks --period=90
npl-persona report <id> --format=md --period=quarter
```

---

## Data Model

### Task Statuses

| Status | Icon | Description |
|--------|------|-------------|
| `completed` | ✅ | Done |
| `in_progress` | 🔄 | Active work |
| `blocked` | 🚫 | Waiting on dependency |
| `pending` | ⏸️ | Not started |

### Knowledge Domains

Each domain tracks:
- **Confidence**: 0–100% self-assessed expertise
- **Depth**: surface → working → proficient → expert
- **Last updated**: When domain was last revised

### File Size Limits

| File | Max Size |
|------|----------|
| Journal | 100 KB |
| Knowledge base | 500 KB |
| Tasks | 50 KB |
| Definition | 20 KB |

---

## File Formats

### Persona Definition (`*.persona.md`)

```markdown
⌜persona:{id}|{role}|NPL@1.0⌝
# {Name}

## Identity
- **Role**: Title
- **Experience**: Years and domains

## Voice Signature
## Expertise Graph
## Relationships
⟪🤝: (l,l,c) | Persona,Relationship,Dynamics⟫

## Memory Hooks
- journal: ./{id}.journal.md
- tasks: ./{id}.tasks.md
- knowledge: ./{id}.knowledge-base.md
⌞persona:{id}⌟
```

### Journal (`*.journal.md`)

```markdown
# {id} Journal

## Recent Interactions

### YYYY-MM-DD - session-id
**Context**: Description
**Participants**: @persona-list

<npl-reflection>
Reflective content
</npl-reflection>

**Outcomes**: What was accomplished
**Growth**: What was learned
```

### Tasks (`*.tasks.md`)

```markdown
# {id} Tasks

## 🎯 Active Tasks
⟪📅: (l,c,c,r) | Task,Status,Owner,Due⟫
| Task description | ✅ Status | @owner | YYYY-MM-DD |

## 🎭 Role Responsibilities
## 📈 Goals & OKRs
## 🚫 Blocked Items
```

### Knowledge Base (`*.knowledge-base.md`)

```markdown
# {id} Knowledge Base

## 📚 Core Knowledge Domains
### Domain Name
confidence: NN%
depth: level

## 🔄 Recently Acquired Knowledge
## 🎓 Learning Paths
## 📖 Reference Library
## ❓ Knowledge Gaps
```

### Team (`*.team.md`)

```markdown
⌜team:{team_id}|NPL@1.0⌝
# {Team Name}

## Team Composition
⟪👥: (l,l,c,r) | Persona,Role,Joined,Status⟫

## Team Purpose
## Collaboration Patterns
## Knowledge Areas
⌞team:{team_id}⌟
```

---

## Modules

| Module | Purpose |
|--------|---------|
| `cli.py` | CLI entry point and command dispatch |
| `persona.py` | PersonaManager — init, get, list, remove, health, sync, backup |
| `journal.py` | JournalManager — add, view, archive entries |
| `tasks.py` | TaskManager — add, update, list, remove, complete tasks |
| `knowledge.py` | KnowledgeManager — add, search, get, update_domain, share |
| `teams.py` | TeamManager — create, add_member, list, matrix, synthesize, analyze |
| `analysis.py` | JournalAnalyzer, TaskAnalyzer, TeamAnalyzer |
| `models.py` | Persona, JournalEntry, Task, KnowledgeDomain, Team, etc. |
| `config.py` | Constants, markers, status icons, section headers, file limits |
| `paths.py` | PathResolver — multi-tier resolution for personas, teams, shared |
| `parsers.py` | Markdown parsing: journals, tasks, teams, knowledge, mentions |
| `templates.py` | Template generators for all file types |
| `io.py` | FileManager with Result types (Ok/Err) and atomic writes |
| `compat.py` | NPLPersona wrapper for backwards compatibility |

---

## Analysis Capabilities

### JournalAnalyzer

- **Collaborations**: Top collaborators from @mentions
- **Sentiment**: Score and trend (↗↘→)
- **Topics**: Extracted topic frequencies
- **Learning velocity**: Concepts learned per week

### TaskAnalyzer

- **Status breakdown**: Count by status
- **Completion rate**: Percentage completed

### TeamAnalyzer

- **Interaction frequency**: Cross-member collaboration
- **Sentiment**: Team-wide sentiment analysis
- **Topics**: Shared topic focus areas

---

## Key Design Principles

1. **Markdown-native** — All data stored as readable markdown with NPL markers
2. **Multi-tier resolution** — Project → user → system scope hierarchy
3. **Result types** — Explicit error handling with Ok/Err containers
4. **Template-driven** — Consistent file initialization
5. **Modular managers** — Each responsibility has a dedicated manager
6. **Backwards compatible** — `NPLPersona` wrapper for legacy interface
