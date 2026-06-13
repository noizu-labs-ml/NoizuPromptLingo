# Legacy Architecture Perspectives (from Previous Iteration)

## Introduction

The previous iteration of NPL documented architectural patterns and domain models that inform current development. This document consolidates architectural insights from the legacy PROJECT-ARCH documentation, including the four-layer architecture, domain model bounded contexts, and design patterns. These perspectives serve as reference material for understanding system design decisions.

> **Note**: Current implementation may diverge from these patterns. Use as reference, not specification.

---

## Section 1: Four-Layer Architecture

The NPL system architecture separates concerns into four distinct layers, enabling multiple interface patterns while maintaining a single source of truth for language definitions and agent behaviors.

### Layer Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     CONSUMER LAYER                              │
│  Claude Code Sessions | External LLM Clients | Web Portal       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     INTERFACE LAYER                             │
│  MCP Server Tools | CLI Scripts | CLAUDE.md Configuration      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     DEFINITION LAYER                            │
│  NPL Syntax | Agent Specifications | Templates | Directives    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     STORAGE LAYER                               │
│  SQLite Database | File System | Event Store                   │
└─────────────────────────────────────────────────────────────────┘
```

### Consumer Layer

The topmost layer provides runtime environments that interpret NPL:

| Consumer Type | Description | NPL Access Method |
|--------------|-------------|-------------------|
| Claude Code Sessions | Interactive AI coding sessions | CLAUDE.md injection |
| External LLM Clients | Third-party LLM integrations | npl-load CLI |
| Web Portal | Browser-based interface | MCP Server API |
| MCP Clients | Protocol-compatible tools | MCP tool calls |

### Interface Layer

Exposes NPL definitions through multiple access patterns:

- **MCP Server Tools**: 23+ tools for artifact management, reviews, chat, notifications
- **CLI Scripts**: `npl-load`, `npl-persona`, `npl-session` for command-line access
- **CLAUDE.md Configuration**: Automatic context injection for Claude Code sessions
- **REST APIs**: HTTP endpoints for web portal functionality

### Definition Layer

Contains pure NPL syntax and agent specifications with no runtime code:

- **NPL Syntax**: Core language definitions, directives, pumps, fences
- **Agent Specifications**: Behavioral definitions in markdown format
- **Templates**: Reusable patterns for scaffolding and generation
- **Directives**: Fine-grained behavior control instructions

### Storage Layer

Provides persistence for collaboration features and state:

- **SQLite Database**: Artifacts, revisions, reviews, chat events, notifications
- **File System**: Persona state (journals, tasks, knowledge bases)
- **Event Store**: Immutable audit trails for chat and review activities

### Layer Interaction Rules

1. **Consumer → Interface**: Requests via protocol, CLI, or config injection
2. **Interface → Definition**: File reads for loading NPL content
3. **Interface → Storage**: Database and file operations for persistence
4. **Definition → None**: Pure definitions with no dependencies
5. **Storage → None**: Persistence only, no upstream calls
6. **No Circular Dependencies**: Storage cannot reference Definition; Definition has no dependencies

### When Each Layer Is Involved

| Workflow | Layers Involved |
|----------|-----------------|
| Load agent definition | Consumer → Interface → Definition |
| Create artifact | Consumer → Interface → Storage |
| Conduct review | Consumer → Interface → Storage |
| Chat collaboration | Consumer → Interface → Storage |
| Persona state sync | Consumer → Interface → Storage (files) |

---

## Section 2: Domain Model (Bounded Contexts)

The NPL domain model defines three primary bounded contexts with clear responsibilities and ubiquitous language.

### Context Map

```
┌─────────────────┐
│  NPL Framework  │
│    Context      │
└────────┬────────┘
         │
         │ defines behavior
         ▼
┌─────────────────┐         collaborates via         ┌─────────────────┐
│    Personas     │ ──────────────────────────────▶  │   MCP Tooling   │
│    Context      │                                  │    Context      │
└─────────────────┘                                  └─────────────────┘
         ▲                                                    ▲
         │                                                    │
         │                  structures output                 │
         └────────────────────────────────────────────────────┘
                           (NPL Framework)
```

### NPL Framework Context

**Purpose**: Prompt syntax and patterns for LLM behavior specification

| Entity Type | Core Entities | Key Attributes |
|-------------|--------------|----------------|
| **Aggregate Root** | Agent | name, type, version, capabilities, constraints |
| **Entities** | Directive, Prefix, Pump, Fence, SpecialSection | emoji_prefix, type, purpose, processing |
| **Value Objects** | SyntaxElement, Template | formatting conventions, reusable patterns |

**Key Invariants**:
- Agent names unique within scope
- Directive types must match defined categories
- Pumps follow XHTML tag structure
- Special sections enforce precedence hierarchy

**Domain Events**:
- `AgentDefined`: New agent specification created
- `DirectiveApplied`: Directive modifies agent behavior
- `SyntaxValidated`: Syntax parsing completed

### MCP Tooling Context

**Purpose**: Artifact management, reviews, and collaboration features

| Entity Type | Core Entities | Key Attributes |
|-------------|--------------|----------------|
| **Aggregate Roots** | Artifact, Review, ChatRoom | id, name, created_at, current_revision_id |
| **Entities** | Revision, InlineComment, ChatEvent, Notification | sequential numbering, timestamps, relationships |
| **Value Objects** | ReviewOverlay, RoomMember | file paths, composite keys |

**Key Invariants**:
- Artifact names globally unique
- Revisions sequential starting from 0
- Review status transitions: `in_progress` → `completed` only (no reopen)
- ChatEvents must reference existing parent events

**Domain Events**:
- `ArtifactCreated`: New artifact registered
- `RevisionAdded`: New version of artifact created
- `ReviewCompleted`: Review workflow finished
- `MessagePosted`: Chat message added to room
- `NotificationGenerated`: @mention created notification

### Personas Context

**Purpose**: AI identity management with persistent state

| Entity Type | Core Entities | Key Attributes |
|-------------|--------------|----------------|
| **Aggregate Roots** | Persona, Team | id (slug), scope, file_paths, mandatory files |
| **Entities** | Journal, TaskList, KnowledgeBase, Relationship | chronological entries, active items, connections |
| **Value Objects** | VoiceSignature, ExpertiseGraph, OceanScores | communication patterns, domain competencies, personality |

**Key Invariants**:
- All 4 mandatory persona files required (definition, journal, tasks, knowledge base)
- Voice signature consistent across interactions
- Hierarchical loading: project > user > system
- Auto-archiving at thresholds (journal: 100KB, tasks: 90 days)

**Domain Events**:
- `PersonaActivated`: Persona loaded for interaction
- `JournalEntryAdded`: Experience recorded
- `TaskCompleted`: Task marked as done
- `RelationshipEstablished`: Connection between personas created

### Cross-Context Integration

| From | To | Integration |
|------|-----|-------------|
| NPL Framework | Personas | Agent declarations establish Persona behaviors |
| NPL Framework | MCP Tooling | Fences structure Artifact content; Templates format Review output |
| Personas | MCP Tooling | Personas create Artifacts, conduct Reviews, collaborate via ChatRooms |

---

## Section 3: Design Patterns

### Markdown-as-Code

**Purpose**: Agent definitions as executable markdown documents with metadata

```markdown
---
name: agent-name
description: Agent capabilities
model: inherit
---

npl-load c "syntax,agent,directive" --skip {@npl.def.loaded}

⎜agent-name|type|NPL@1.0⎟
# Agent Title
Behavioral specifications and core functions.
⎞agent-name⎠
```

**Key Elements**:
- YAML frontmatter for metadata discovery
- Unicode boundary markers for agent blocks
- Embedded load commands for dependency management

### Event-Sourced Chat

**Purpose**: Immutable message logs with audit trails

```python
async def _create_event(room_id, event_type, persona, data, reply_to_id=None):
    data_json = json.dumps(data)
    cursor = await db.execute(
        "INSERT INTO chat_events (room_id, event_type, persona, data, reply_to_id) VALUES (?, ?, ?, ?, ?)",
        (room_id, event_type, persona, data_json, reply_to_id)
    )
    return cursor.lastrowid
```

**Benefits**:
- Complete audit trail of all interactions
- Replay capability for debugging
- Notification generation from events
- No destructive updates

### Manager/Service Pattern

**Purpose**: Clean separation between orchestration and execution

```python
class ArtifactManager:
    def __init__(self, db: Database):
        self.db = db

    async def create_artifact(name, artifact_type, file_content, filename, ...):
        # Encapsulated business logic

    async def add_revision(artifact_id, ...):
        # Domain-specific operations
```

**Structure**:
- Managers orchestrate complex workflows
- Services execute atomic operations
- Dependency injection for database access
- Clear domain boundaries

### Unicode Boundary Markers

**Purpose**: Agent definition delineation using Unicode characters

| Marker | Unicode | Purpose |
|--------|---------|---------|
| `⎜` | U+231C | Opening corner bracket |
| `⎟` | U+231D | Closing corner bracket |
| `⎞` | U+231E | End marker opening |
| `⎠` | U+231F | End marker closing |

**Usage**: `⎜agent-name|type|NPL@1.0⎟ ... ⎞agent-name⎠`

### Hierarchical Resource Loading

**Purpose**: Multi-tier path resolution for resources

```python
def get_search_paths(resource_type='component'):
    paths = [
        Path('./.npl/npl'),          # Project local
        Path.home() / '.npl/npl',    # User home
        global_npl / 'npl'           # System global
    ]
    return paths
```

**Resolution Order**:
1. Project-local (`./.npl/`)
2. User home (`~/.npl/`)
3. System global (`/etc/npl/`)

---

## Section 4: Limitations & Constraints from Previous Design

The legacy architecture documented several known limitations:

### Deployment Constraints

| Constraint | Description |
|------------|-------------|
| **Local-only deployment** | No cloud infrastructure or containerization support |
| **Single-user model** | SQLite not designed for concurrent multi-user access |
| **No CI/CD pipeline** | Manual test execution and deployment |

### Technical Constraints

| Constraint | Description |
|------------|-------------|
| **No migration system** | Schemas applied directly; manual updates required |
| **Incomplete installer** | Manual pip installation; no one-click setup |
| **Python >= 3.10 requirement** | Minimum version for MCP server |
| **File system dependency** | Personas require file-backed state |

### Architectural Constraints

| Constraint | Description |
|------------|-------------|
| **Sequential revisions** | Artifact revision numbers must increment; cannot skip |
| **Single status transition** | Reviews cannot be reopened once completed |
| **MCP Server singleton** | Only one instance per data directory |
| **No mixed-version support** | CLAUDE.md locks to single NPL version |

---

## Environment Configuration

| Variable | Purpose | Default |
|----------|---------|---------|
| `NPL_HOME` | Base path for NPL definitions | `./.npl` → `~/.npl` → `/etc/npl/` |
| `NPL_MCP_DATA_DIR` | MCP Server database and artifacts | `./data/` |
| `NPL_PERSONA_DIR` | Persona definition files | `./.npl/personas` |
| `NPL_META` | Path for metadata files | `$NPL_HOME/meta` |
| `NPL_STYLE_GUIDE` | Path for style conventions | `$NPL_HOME/conventions` |
| `NPL_THEME` | Theme name for style loading | `default` |

---

## Legacy References

| Document | Source |
|----------|--------|
| Domain Model | `.tmp/docs/PROJECT-ARCH/domain.brief.md` |
| Architectural Layers | `.tmp/docs/PROJECT-ARCH/layers.brief.md` |
| Code Patterns | `.tmp/docs/PROJECT-ARCH/patterns.brief.md` |
| Infrastructure | `.tmp/docs/PROJECT-ARCH/infrastructure.brief.md` |

---

## Implementation Status

**Status**: Reference documentation

These architectural perspectives were extracted from the previous NPL iteration. Current implementation may implement, extend, or deviate from these patterns. Consult current source code and active PRDs for authoritative design decisions.

See also:
- [docs/arch/](../arch/) - Current architecture documentation
- [docs/prds/](../prds/) - Active product requirements

---

*Extracted from legacy PROJECT-ARCH documentation for reference. Current implementation may vary.*
