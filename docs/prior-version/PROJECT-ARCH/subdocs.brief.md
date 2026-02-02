# PROJECT-ARCH Subdocuments Summary

## Purpose

These four documents provide comprehensive architectural documentation for NoizuPromptLingo (NPL), covering:
- **Domain Model** (domain.md): Entity definitions and bounded contexts
- **Architectural Layers** (layers.md): System layer separation and responsibilities
- **Infrastructure** (infrastructure.md): Deployment, databases, and tooling
- **Code Patterns** (patterns.md): Reusable design patterns and implementation guidance

## Key Sections

### Domain Model (domain.md)
- **NPL Framework Context**: 80+ syntax elements (agents, directives, prefixes, pumps, fences)
- **MCP Tooling Context**: Artifacts, revisions, reviews, chat rooms, notifications
- **Personas Context**: AI identities with persistent state (journals, tasks, knowledge bases)
- **Cross-Context Relationships**: How syntax, personas, and MCP tooling interact

### Architectural Layers (layers.md)
- **Consumer Layer**: Claude Code, LLM clients, MCP-compatible tools
- **Interface Layer**: MCP Server (23 tools), CLI scripts (npl-load, npl-persona), CLAUDE.md config
- **Definition Layer**: NPL syntax definitions, 45+ agent definitions, file-backed personas
- **Storage Layer**: SQLite databases (MCP, NIMPS, KB), file system for artifacts

### Infrastructure (infrastructure.md)
- **SQLite Databases**: MCP server (artifacts, reviews, chat), NIMPS (project management), KB (knowledge articles)
- **Python Packages**: npl-mcp (FastMCP server), npl-installer (stub)
- **CLI Tools**: npl-load (hierarchical loading), npl-persona (persona lifecycle), dump-files, git-tree
- **Deployment**: Local-first, pip install, no cloud/containers

### Code Patterns (patterns.md)
- **Markdown-as-Code**: Agent definitions as structured markdown
- **Hierarchical Loading**: Project → User → System path resolution
- **Event-Sourced Chat**: Immutable event log for collaboration
- **Manager/Service**: Domain managers (ArtifactManager, ReviewManager, ChatManager)
- **Base64 Content Transfer**: Binary encoding at MCP boundary
- **Unicode Boundary Markers**: Agent/section delimiters
- **Directive Pattern**: Emoji-prefixed structured commands
- **YAML Frontmatter**: Agent metadata extraction

## Domain Model

### Key Entities and Relationships

**NPL Framework**
- Agent → defines Persona behavior
- Directive (9 types: table, temporal, template, interactive, identifier, explanatory, reference, explicit)
- Prefix (15+ response modes: speech, visual, code, etc.)
- Pump (8 reasoning patterns: npl-intent, npl-cot, npl-reflection, npl-panel)
- Fence (10 types: example, syntax, format, template, alg, artifact)
- Special Section (5 precedence levels: secure prompt > runtime flags > agent declaration > extension > template)

**MCP Tooling**
- Artifact (1) ←─has─→ (N) Revision
- Review (1) ←─targets─→ (1) Artifact + (1) Revision
- Review (1) ←─has─→ (N) InlineComment
- ChatRoom (1) ←─has─→ (N) RoomMember
- ChatRoom (1) ←─has─→ (N) ChatEvent (messages, reactions, shares, todos)
- Notification ←─triggers from─→ ChatEvent (@mentions, artifact shares)

**Personas**
- Persona ←─has─→ 4 mandatory files (.persona.md, .journal.md, .tasks.md, .knowledge-base.md)
- Team (1) ←─has─→ (N) Persona
- Persona (1) ←─has─→ (N) Relationship ←─to─→ (1) Persona
- Persona: VoiceSignature (lexicon, patterns, quirks)
- Persona: ExpertiseGraph (primary, secondary, boundaries, learning)
- Persona: OceanScores (Big Five personality traits)

### Cross-Context Flow
```
NPL Agent Definition → Persona Behavior → ChatRoom Collaboration → Artifact Creation → Review Workflow
```

## Architectural Patterns

### Layered Architecture
- **Consumer Layer** (Claude Code, LLM clients) → calls → **Interface Layer** (MCP Server, CLI)
- **Interface Layer** → reads → **Definition Layer** (NPL syntax, agents, personas)
- **Interface Layer** → persists → **Storage Layer** (SQLite + file system)
- **Definition Layer** is pure markdown (no code execution)
- **Storage Layer** is data-only (no business logic)

### Hierarchical Loading Pattern
All resources (components, agents, personas, styles) resolve via fallback chain:
```
Project (./.npl/) → User (~/.npl/) → System (/etc/npl/)
```
Supports `.patch.md` overlays and `--skip` tracking to prevent duplicate loads.

### Event Sourcing
Chat system uses append-only event log with typed payloads:
- Events: message, emoji_reaction, artifact_share, todo_create, persona_join, persona_leave
- Notifications auto-generated from @mentions and shares
- Complete audit trail enables replay and history reconstruction

### Manager Pattern
Domain logic encapsulated in managers:
- `ArtifactManager`: CRUD + revision management
- `ReviewManager`: Review sessions + inline comments
- `ChatManager`: Rooms, events, notifications

MCP Server delegates to managers; managers delegate to Storage Layer.

## Infrastructure Components

### Tech Stack
- **Language**: Python 3.10+
- **MCP Framework**: FastMCP (ASGI-based)
- **Database**: SQLite (embedded, 3 databases: MCP, NIMPS, KB)
- **File Storage**: Local filesystem for binary artifacts
- **Build System**: hatchling (pyproject.toml)
- **CLI**: Bash + Python scripts

### Databases
1. **MCP Server DB** (`npl-mcp.db`): artifacts, revisions, reviews, inline_comments, chat_rooms, chat_events, notifications
2. **NIMPS DB** (`nimps.sql`): projects, epics, user_stories, personas, components, dependencies, diagrams
3. **KB DB** (`nb.sql`): articles, sections, cross_references, FTS5 search

### MCP Server Tools (23)
- **Script Tools (4)**: dump_files, git_tree, git_tree_depth, npl_load
- **Artifact Tools (5)**: create_artifact, add_revision, get_artifact, list_artifacts, get_artifact_history
- **Review Tools (6)**: create_review, add_inline_comment, add_overlay_annotation, get_review, generate_annotated_artifact, complete_review
- **Chat Tools (8)**: create_chat_room, send_message, react_to_message, share_artifact, create_todo, get_chat_feed, get_notifications, mark_notification_read

### CLI Tools
- `npl-load`: Hierarchical component loading (12 resource types: c, m, s, agent, spec, persona, prd, story, prompt, schema, init, init-claude)
- `npl-persona`: Persona lifecycle (init, get, list, remove, journal, task, kb, team, health, sync, backup)
- `dump-files`, `git-tree`, `git-tree-depth`: Codebase exploration

## Questions/Gaps

### Clarifications Needed
1. **Version management**: No migration system for SQLite schemas; how are schema changes handled across versions?
2. **Persona scope hierarchy**: How are conflicts resolved when personas exist at multiple scopes (project vs. user)?
3. **Team dynamics**: `TeamDynamics` value object mentioned but usage patterns unclear
4. **NIMPS integration**: How does NIMPS database integrate with MCP server workflows?
5. **npl-installer**: Marked as "stub implementation" - what's the roadmap?

### Missing Components
1. **Error handling patterns**: No documentation on error propagation across layers
2. **Testing strategy**: pytest mentioned but no test patterns documented
3. **Concurrency model**: Async patterns used but no concurrency guarantees specified
4. **Security model**: No authentication/authorization for MCP server tools
5. **Data migration**: No documented strategy for persona/artifact migration across scopes
6. **Performance considerations**: No discussion of SQLite performance limits or optimization strategies

### Ambiguities
1. **Artifact type enforcement**: How is `artifact_type` validated? What types are valid?
2. **Revision file paths**: Are they relative to data directory? Configurable?
3. **Notification delivery**: How are notifications consumed? Polling vs. push?
4. **Session management**: Reference to "session grouping" in Storage Layer description but no session tables in schema
5. **Browser utilities**: `browser/` package mentioned in launcher.py description but no implementation details in infrastructure docs

---

## 2-3 Paragraph Brief

**NoizuPromptLingo** is a markdown-based framework for defining LLM agent behaviors through structured prompt engineering. At its core, NPL separates concerns into four architectural layers: the **Consumer Layer** (Claude Code, LLM clients) consumes agent definitions; the **Interface Layer** exposes 23 MCP tools and CLI scripts (npl-load, npl-persona) for artifact management and persona lifecycle; the **Definition Layer** contains 80+ syntax elements (agents, directives, pumps, fences) and 45+ agent definitions as pure markdown; and the **Storage Layer** provides SQLite-backed persistence for artifacts, revisions, reviews, chat rooms, and persona state files. The architecture enables agents defined as markdown documents to be dynamically loaded via hierarchical path resolution (project → user → system), interpreted by LLMs, and used to orchestrate multi-agent collaboration through event-sourced chat rooms and versioned artifact workflows.

The domain model spans three bounded contexts that interact through defined relationships: **NPL Framework** defines the syntax language (directives for formatting, prefixes for response modes, pumps for reasoning patterns); **MCP Tooling** manages collaborative artifacts with version control and inline review comments; and **Personas** provide persistent AI identities with journals, task lists, and knowledge bases stored as markdown files. Key architectural decisions include markdown-as-code (agent behavior defined through structured markdown rather than executable code), event-sourced chat (all collaboration captured as immutable event log), hierarchical loading with patch overlays (enabling project-specific customization of system defaults), and the manager/service pattern (clean separation between MCP tool layer, domain logic managers, and storage).

Critical patterns that enable the system include Unicode boundary markers (`⌜agent|type|NPL@ver⌝`) for unambiguous agent definition boundaries, directive syntax (`⟪emoji: instruction | elaboration⟫`) for fine-grained output control, YAML frontmatter metadata for agent discovery and filtering, and base64 content transfer at MCP boundaries for binary artifact handling. The entire system is local-first with no cloud dependencies: SQLite provides embedded storage for three separate databases (MCP collaboration, NIMPS project management, KB knowledge articles), FastMCP serves 23 tools over the Model Context Protocol, and Python/Bash CLI scripts provide direct filesystem access to NPL definitions and persona state. Open questions remain around version migration strategies, concurrency guarantees, and the roadmap for completing stub components like npl-installer.
