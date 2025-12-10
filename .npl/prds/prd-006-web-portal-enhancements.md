# PRD: NPL MCP Web Portal Enhancements
Product Requirements Document for comprehensive web portal improvements transforming the NPL MCP portal from a basic session viewer into a full-featured collaboration hub.

**version**
: 1.0

**status**
: draft

**owner**
: NPL Development Team

**last-updated**
: 2025-12-10

**stakeholders**
: MCP Server Development, NPL Framework, AI Agent Integration

**source-document**
: `mcp-server/docs/ENHANCEMENTS.md`

---

## Executive Summary

The NPL MCP Web Portal currently provides basic session and chat viewing capabilities. This PRD specifies enhancements to transform it into a comprehensive collaboration hub with:

1. **Enhanced Navigation** - Expanded header with access to artifacts, agents, personas, and global search
2. **Rich Artifact System** - Gallery views, rich content rendering (Mermaid, LaTeX, syntax highlighting), and web uploads
3. **Agent/Persona Integration** - Directory views for NPL agents and personas with MCP tool access
4. **Session Improvements** - Creation tracking and web-based room creation
5. **Chat Enhancements** - Reply threading, reaction grouping, todo display, and rich message content
6. **Global Search** - Full-text search across all entities using SQLite FTS5

These enhancements will improve human operator experience and enable richer AI agent collaboration within the NPL ecosystem.

---

## Problem Statement

### Current State

The NPL MCP web portal provides:
- Session listing and detail views
- Basic chat room viewing with message posting
- Minimal artifact display (detail pages only, no gallery)
- No visibility into agents or personas
- No search capability
- No rich content rendering (Mermaid diagrams, LaTeX, etc.)

### Desired State

A comprehensive collaboration hub where:
- Human operators can browse and manage all entities (sessions, artifacts, agents, personas)
- Rich content renders natively (diagrams, math, syntax-highlighted code)
- Global search enables quick discovery across all data
- Agent and persona directories provide transparency into available resources
- Real-time updates keep views synchronized (future phase)

### Gap Analysis

| Aspect | Current | Desired | Gap |
|:-------|:--------|:--------|:----|
| Navigation | Sessions + API only | 6 primary routes | +4 navigation items |
| Artifact views | Detail page only | Gallery + rich rendering | Gallery, filters, thumbnails |
| Content rendering | Plain text | Mermaid, LaTeX, syntax | 3 rendering engines |
| Agent visibility | None | Directory + prompts | Full agent integration |
| Persona visibility | None | Directory + activity | Full persona integration |
| Search | None | Global FTS5 | Full-text search |
| Session tracking | Basic | Creator + client info | Enhanced metadata |

---

## Goals and Objectives

### Business Objectives

1. **Improve developer experience** - Enable human operators to efficiently interact with the NPL MCP system through a polished web interface
2. **Enhance transparency** - Provide visibility into agents, personas, and their activities for debugging and monitoring
3. **Enable self-service** - Allow web-based artifact upload and room creation without MCP client

### User Objectives

1. **Browse artifacts efficiently** - Gallery views with filtering and search
2. **Understand agent capabilities** - View agent definitions and prompts
3. **Track persona activity** - See what personas are doing across sessions
4. **Find information quickly** - Global search across all entities

### Non-Goals

- Real-time collaborative editing (beyond basic chat)
- Mobile-native applications (web-responsive is sufficient)
- User authentication/authorization (single-user/trusted environment)
- Video/audio conferencing
- External integrations (Slack, Discord, etc.)

---

## Success Metrics

| Metric | Baseline | Target | Timeframe | Measurement |
|:-------|:---------|:-------|:----------|:------------|
| Navigation routes | 2 | 6 | Phase 1-2 | Route count |
| Artifact types supported | 4 | 8 | Phase 1 | Type enumeration |
| Rendering engines | 0 | 3 | Phase 1 | Feature count |
| Search response time | N/A | <500ms | Phase 4 | Performance test |
| Page load time | ~1s | <2s | All phases | Lighthouse |

---

## User Personas

### Developer/Operator

**demographics**
: Technical user, advanced proficiency, desktop-focused

**goals**
: Monitor session activity, browse artifacts, understand agent behavior

**frustrations**
: Limited visibility, no search, cannot upload artifacts from web

**quote**
: "I need to see what the agents are doing without diving into logs."

### AI Agent (MCP Client)

**demographics**
: Automated MCP client, programmatic access

**goals**
: Query agents, personas, search across entities via MCP tools

**frustrations**
: Limited discovery of available agents and personas

**quote**
: "I need to discover and invoke other agents programmatically."

---

## Functional Requirements

### FR-100: Navigation and Global UI

#### FR-101: Enhanced Header Navigation

**description**
: Header navigation must include links to: Sessions, Artifacts, Agents, Personas, API, and Search

**priority**
: P0

**acceptance-criteria**
: - [ ] Header displays 6 navigation items
: - [ ] Active route is visually highlighted
: - [ ] Navigation is responsive on smaller screens
: - [ ] Search includes keyboard shortcut (Cmd/Ctrl+K)

**dependencies**
: None

---

#### FR-102: New Routes

**description**
: Add new routes for artifact gallery, agent directory, persona directory, and search

**priority**
: P0

**acceptance-criteria**
: - [ ] `/artifacts` - Artifact gallery with search/filter
: - [ ] `/artifact/{id}` - Artifact detail (exists, enhance)
: - [ ] `/artifact/{id}/edit` - Edit/upload new revision
: - [ ] `/agents` - Agent directory
: - [ ] `/agent/{slug}` - Agent detail with prompt
: - [ ] `/personas` - Persona directory
: - [ ] `/persona/{slug}` - Persona detail with journal/tasks
: - [ ] `/search` - Global search results
: - [ ] All routes return proper 404 for invalid IDs

---

### FR-200: Artifact System Enhancements

#### FR-201: Artifact Gallery

**description**
: Provide a gallery view of all artifacts with grid/list toggle, search, and filtering

**priority**
: P0

**acceptance-criteria**
: - [ ] Grid view displays thumbnail/icon, name, type, creator
: - [ ] List view displays tabular data with sortable columns
: - [ ] Toggle persists in localStorage
: - [ ] Search filters by name (partial match)
: - [ ] Filter by type dropdown (document, image, code, diagram, etc.)
: - [ ] Filter by creator (persona)
: - [ ] Sort by: created, updated, name (asc/desc)
: - [ ] Pagination with 20 items per page

**dependencies**
: FR-102 (/artifacts route)

---

#### FR-202: Extended Artifact Types

**description**
: Support additional artifact types beyond the current set

**priority**
: P1

**acceptance-criteria**
: - [ ] `document` - .md, .txt, .rst - Markdown rendering
: - [ ] `code` - .py, .js, .ts, .go, .rs - Syntax highlighting
: - [ ] `image` - .png, .jpg, .gif, .webp - Native display
: - [ ] `svg` - .svg - Inline SVG rendering
: - [ ] `diagram` - .mmd, .mermaid - Mermaid.js rendering
: - [ ] `latex` - .tex, .tikz - KaTeX rendering
: - [ ] `data` - .json, .yaml, .csv - Formatted viewer
: - [ ] `html` - .html - Sandboxed iframe preview

**dependencies**
: FR-203 (Rich Content Rendering)

**database-changes**
: Type enum extension (no schema change, validation only)

---

#### FR-203: Rich Content Rendering

**description**
: Render rich content types natively in the browser

**priority**
: P0

**acceptance-criteria**
: - [ ] Mermaid diagrams render using Mermaid.js CDN
: - [ ] LaTeX/math renders using KaTeX CDN
: - [ ] Code blocks render with Prism.js syntax highlighting
: - [ ] Markdown renders with GFM support (tables, task lists, footnotes)
: - [ ] Fenced code blocks with `mermaid` language auto-render as diagrams
: - [ ] `$$...$$` blocks auto-render as LaTeX
: - [ ] Rendering errors display gracefully with fallback to raw text

**dependencies**
: None

**frontend-libraries**
: - Mermaid.js (CDN)
: - KaTeX (CDN)
: - Prism.js (CDN)
: - marked.js (CDN)

---

#### FR-204: Web Artifact Upload

**description**
: Allow uploading artifacts via web form

**priority**
: P0

**acceptance-criteria**
: - [ ] Upload form accessible from `/artifacts` and `/artifact/upload`
: - [ ] Form fields: name (required), type (select), purpose (textarea), file (required), persona (default: human-operator), session_id (optional)
: - [ ] File size limit: 10MB (configurable via NPL_MAX_UPLOAD_SIZE)
: - [ ] Auto-detect type from file extension
: - [ ] Redirect to artifact detail on success
: - [ ] Display validation errors on form

**api-endpoint**
: `POST /artifact/upload` (multipart/form-data)

**dependencies**
: FR-201 (Gallery)

---

#### FR-205: Artifact Revision Upload

**description**
: Allow uploading new revisions of existing artifacts

**priority**
: P1

**acceptance-criteria**
: - [ ] Upload form at `/artifact/{id}/edit`
: - [ ] Form fields: file (required), purpose (textarea), notes (textarea)
: - [ ] Increment revision number automatically
: - [ ] Redirect to artifact detail showing new revision
: - [ ] Display diff view option against previous revision (if text-based)

**api-endpoint**
: `POST /artifact/{id}/revision`

**dependencies**
: FR-204 (Web Upload)

---

### FR-300: Agent Integration

#### FR-301: Agent Directory

**description**
: Display directory of available NPL agents scanned from filesystem

**priority**
: P1

**acceptance-criteria**
: - [ ] Scan `$NPL_HOME/core/agents/*.md` for agent definitions
: - [ ] Parse YAML frontmatter for name, description, color
: - [ ] Display cards with: name, description, color indicator
: - [ ] Link to agent detail page
: - [ ] "Copy Prompt" button copies full prompt to clipboard
: - [ ] Cache agent data in database, refresh on page load if file modified

**dependencies**
: FR-302 (Agent Schema), FR-102 (/agents route)

**environment-variables**
: `NPL_HOME` - Base path for NPL definitions

---

#### FR-302: Agent Database Schema

**description**
: Add database table for caching agent information

**priority**
: P1

**acceptance-criteria**
: - [ ] Table `agents` with columns: id, slug, name, description, color, prompt_path, cached_prompt, updated_at
: - [ ] Unique constraint on slug
: - [ ] Migration increments schema_version

**schema**
```sql
CREATE TABLE IF NOT EXISTS agents (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    slug TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    color TEXT,
    prompt_path TEXT,
    cached_prompt TEXT,
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
```

---

#### FR-303: Agent MCP Tools

**description**
: Expose agent information via MCP tools

**priority**
: P1

**acceptance-criteria**
: - [ ] `list_agents()` returns list of {slug, name, description, color}
: - [ ] `get_agent_prompt(slug)` returns {slug, name, description, prompt}
: - [ ] Tools documented in MCP schema

**mcp-tools**
: `list_agents`, `get_agent_prompt`

---

### FR-400: Persona Integration

#### FR-401: Persona Directory

**description**
: Display directory of available personas scanned from filesystem

**priority**
: P1

**acceptance-criteria**
: - [ ] Scan `$NPL_PERSONA_DIR/*.persona.md` for persona definitions
: - [ ] Parse YAML frontmatter for name, role, expertise
: - [ ] Display cards with: name, role, expertise tags
: - [ ] Link to persona detail page
: - [ ] Tabs: Profile, Journal, Tasks, Knowledge, Activity

**dependencies**
: FR-402 (Persona Schema), FR-102 (/personas route)

**environment-variables**
: `NPL_PERSONA_DIR` - Path to persona definitions

---

#### FR-402: Persona Database Schema

**description**
: Add database tables for persona caching and activity tracking

**priority**
: P1

**acceptance-criteria**
: - [ ] Table `personas` with columns: id, slug, name, role, profile_path, cached_profile, updated_at
: - [ ] Table `persona_activity` with columns: id, persona_slug, activity_type, reference_id, reference_type, timestamp
: - [ ] Unique constraint on personas.slug
: - [ ] Index on persona_activity(persona_slug)
: - [ ] Migration increments schema_version

**schema**
```sql
CREATE TABLE IF NOT EXISTS personas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    slug TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    role TEXT,
    profile_path TEXT,
    cached_profile TEXT,
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS persona_activity (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    persona_slug TEXT NOT NULL,
    activity_type TEXT NOT NULL,
    reference_id INTEGER,
    reference_type TEXT,
    timestamp TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_persona_activity_slug ON persona_activity(persona_slug);
```

---

#### FR-403: Persona MCP Tools

**description**
: Expose persona information via MCP tools

**priority**
: P1

**acceptance-criteria**
: - [ ] `list_personas()` returns list of {slug, name, role}
: - [ ] `get_persona(slug)` returns profile and recent activity
: - [ ] `get_persona_journal(slug, limit=10)` returns journal entries
: - [ ] Tools documented in MCP schema

**mcp-tools**
: `list_personas`, `get_persona`, `get_persona_journal`

---

### FR-500: Session Enhancements

#### FR-501: Session Creation Tracking

**description**
: Track who/what created sessions and from where

**priority**
: P2

**acceptance-criteria**
: - [ ] Sessions table has: created_by (persona/agent slug), client_info (JSON), parent_session_id
: - [ ] Display created_by on session detail page
: - [ ] Display client_info (terminal, working directory) if available
: - [ ] Link to parent session if sub-session

**schema**
```sql
ALTER TABLE sessions ADD COLUMN created_by TEXT;
ALTER TABLE sessions ADD COLUMN client_info TEXT;
ALTER TABLE sessions ADD COLUMN parent_session_id TEXT;
```

---

#### FR-502: Web Room Creation

**description**
: Allow creating chat rooms from web interface

**priority**
: P2

**acceptance-criteria**
: - [ ] Form on session detail page to create room
: - [ ] Form fields: name (required), description, members (comma-separated)
: - [ ] Room created and linked to session
: - [ ] Redirect to new room on success

**api-endpoint**
: `POST /session/{id}/create-room`

---

### FR-600: Chat Enhancements

#### FR-601: Reply Threading Visualization

**description**
: Display reply threads visually in chat feed

**priority**
: P2

**acceptance-criteria**
: - [ ] Replies indented under parent message
: - [ ] Reply indicator shows "replying to [persona]"
: - [ ] Click reply indicator scrolls to/highlights parent
: - [ ] Reply button on each message to initiate reply

---

#### FR-602: Reaction Grouping

**description**
: Group and display reactions under messages

**priority**
: P2

**acceptance-criteria**
: - [ ] Reactions grouped by emoji type
: - [ ] Display format: emoji + count + tooltip with persona names
: - [ ] Click reaction count shows full list
: - [ ] Add reaction button for each message

---

#### FR-603: Todo Display Enhancement

**description**
: Display todos as interactive cards in chat

**priority**
: P2

**acceptance-criteria**
: - [ ] Todo cards show: description, assigned_to, status
: - [ ] Mark Complete button (updates todo status)
: - [ ] Reassign button opens member selector
: - [ ] Completed todos show strikethrough

---

#### FR-604: Rich Message Content

**description**
: Render rich content (markdown, code, diagrams) in chat messages

**priority**
: P1

**acceptance-criteria**
: - [ ] Markdown formatting in messages
: - [ ] Code blocks with syntax highlighting
: - [ ] Inline mermaid diagrams (fenced with ```mermaid)
: - [ ] Inline LaTeX ($$...$$ blocks)
: - [ ] Links are clickable

**dependencies**
: FR-203 (Rich Content Rendering)

---

#### FR-605: Chat Artifact Upload

**description**
: Upload and share artifacts directly from chat room

**priority**
: P2

**acceptance-criteria**
: - [ ] Upload form in chat room interface
: - [ ] Form fields: file, name, message (optional comment)
: - [ ] Creates artifact and artifact_share event
: - [ ] Displays shared artifact card in chat feed

**api-endpoint**
: `POST /session/{session_id}/room/{room_id}/upload`

---

### FR-700: Search System

#### FR-701: Global Search Page

**description**
: Provide global search across all entities

**priority**
: P1

**acceptance-criteria**
: - [ ] Search box in header triggers search
: - [ ] `/search?q=query` shows results page
: - [ ] Results grouped by type: Sessions, Artifacts, Messages, Personas, Agents
: - [ ] Result count per type
: - [ ] Click result navigates to detail page
: - [ ] Keyboard shortcut (Cmd/Ctrl+K) opens search

---

#### FR-702: Full-Text Search Index

**description**
: Implement SQLite FTS5 for efficient text search

**priority**
: P1

**acceptance-criteria**
: - [ ] FTS5 virtual table: search_index(entity_type, entity_id, title, content, metadata)
: - [ ] Triggers maintain index on INSERT for: artifacts, chat_events, sessions
: - [ ] Search returns results ranked by relevance
: - [ ] Search response time < 500ms for 10k records

**schema**
```sql
CREATE VIRTUAL TABLE IF NOT EXISTS search_index USING fts5(
    entity_type,
    entity_id,
    title,
    content,
    metadata
);

CREATE TRIGGER IF NOT EXISTS idx_artifact_insert AFTER INSERT ON artifacts
BEGIN
    INSERT INTO search_index (entity_type, entity_id, title, content)
    VALUES ('artifact', NEW.id, NEW.name, '');
END;
```

---

#### FR-703: Search MCP Tool

**description**
: Expose search via MCP tool

**priority**
: P1

**acceptance-criteria**
: - [ ] `search(query, types=None, limit=20)` returns matching entities
: - [ ] Filter by types: ['session', 'artifact', 'message', 'persona', 'agent']
: - [ ] Results include entity_type, entity_id, title, snippet

**mcp-tools**
: `search`

---

### FR-800: API Enhancements

#### FR-801: New REST API Endpoints

**description**
: Add REST API endpoints for programmatic access

**priority**
: P1

**acceptance-criteria**
: - [ ] `GET /api/artifacts` - List with filters
: - [ ] `GET /api/artifacts/search` - Search artifacts
: - [ ] `GET /api/agents` - List agents
: - [ ] `GET /api/agent/{slug}` - Get agent details
: - [ ] `GET /api/personas` - List personas
: - [ ] `GET /api/persona/{slug}` - Get persona details
: - [ ] `GET /api/search` - Global search
: - [ ] All endpoints return JSON

---

### FR-900: Real-Time Updates (Future)

#### FR-901: Server-Sent Events

**description**
: Provide real-time updates via SSE

**priority**
: P3

**acceptance-criteria**
: - [ ] `GET /api/room/{room_id}/events` - SSE endpoint
: - [ ] Events: message, reaction, artifact_share, typing, presence
: - [ ] Client auto-reconnects on disconnect
: - [ ] Configurable via NPL_ENABLE_REALTIME

**dependencies**
: All Phase 1-3 features

---

## Non-Functional Requirements

### NFR-PERF-001: Page Load Performance

**requirement**
: All pages must load within 2 seconds on standard broadband

**priority**
: P0

| Metric | Target | Measurement |
|:-------|:-------|:------------|
| Initial page load | <2s | Lighthouse |
| API response time | <200ms p95 | APM |
| Search response | <500ms | End-to-end |

### NFR-PERF-002: Database Performance

**requirement**
: Database queries must remain performant as data grows

**priority**
: P0

| Metric | Target | Measurement |
|:-------|:-------|:------------|
| Gallery load (1000 artifacts) | <500ms | Query timing |
| Search (10k records) | <500ms | Query timing |
| Chat feed (1000 messages) | <300ms | Query timing |

### NFR-SEC-001: File Upload Security

**requirement**
: File uploads must be validated and size-limited

**priority**
: P0

**controls**
: - File size limit: 10MB default (configurable)
: - Content-type validation
: - Filename sanitization
: - No executable content

### NFR-A11Y-001: Accessibility

**requirement**
: Web interface must meet WCAG 2.1 AA standards

**priority**
: P1

**requirements**
: - Keyboard navigation support
: - Screen reader compatibility
: - Color contrast compliance
: - Focus indicators

### NFR-MAINT-001: Code Organization

**requirement**
: New code follows existing patterns and structure

**priority**
: P0

**requirements**
: - Routes in `web/app.py` or modular route files
: - Templates in `web/templates/`
: - Managers in appropriate module directories
: - Migrations in `storage/migrations.py`

---

## Constraints and Assumptions

### Constraints

**technical**
: - SQLite database (no PostgreSQL/MySQL)
: - Python FastAPI backend
: - CDN-hosted frontend libraries (no npm build)
: - Single-server deployment

**business**
: - No external service dependencies
: - Open-source compatible

**timeline**
: - 4-week phased implementation

### Assumptions

| Assumption | Impact if False | Validation Plan |
|:-----------|:----------------|:----------------|
| SQLite FTS5 available | Search feature blocked | Test on target environment |
| CDN access available | Frontend libraries unavailable | Bundle fallback |
| `$NPL_HOME` configured | Agent scanning fails | Validate on startup |
| `$NPL_PERSONA_DIR` configured | Persona scanning fails | Graceful fallback |

---

## Dependencies

### Internal Dependencies

| Dependency | Owner | Status | Impact |
|:-----------|:------|:-------|:-------|
| NPL Persona System | NPL Core | Implemented | Persona data source |
| NPL Agent Definitions | NPL Core | Implemented | Agent data source |
| MCP Server Infrastructure | MCP Team | Implemented | Foundation |

### External Dependencies

| Dependency | Provider | SLA | Fallback |
|:-----------|:---------|:----|:---------|
| Mermaid.js CDN | jsDelivr | Best-effort | Bundle locally |
| KaTeX CDN | jsDelivr | Best-effort | Bundle locally |
| Prism.js CDN | jsDelivr | Best-effort | Bundle locally |

---

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation | Owner |
|:-----|:-----------|:-------|:-----------|:------|
| FTS5 performance at scale | M | H | Test with 100k records, add pagination | Backend |
| CDN unavailability | L | M | Bundle fallback versions of libraries | Frontend |
| Breaking existing MCP tools | M | H | Backward-compatible API additions only | API |
| Large file upload timeouts | M | M | Chunked upload, progress indicator | Backend |
| Agent/persona file parsing errors | M | L | Graceful degradation, log errors | Backend |

---

## Timeline and Milestones

### Phases

**Phase 1: Core Improvements (Week 1)**
: Scope: FR-101, FR-102, FR-201, FR-203, FR-204
: Dependencies: None
: Deliverables: Enhanced nav, artifact gallery, rich rendering, web upload

**Phase 2: Agent & Persona Integration (Week 2)**
: Scope: FR-301, FR-302, FR-303, FR-401, FR-402, FR-403, FR-501, FR-502
: Dependencies: Phase 1
: Deliverables: Agent directory, persona directory, session tracking

**Phase 3: Chat Enhancements (Week 3)**
: Scope: FR-601, FR-602, FR-603, FR-604, FR-605
: Dependencies: FR-203
: Deliverables: Threading, reactions, todos, rich messages

**Phase 4: Search & Advanced (Week 4)**
: Scope: FR-701, FR-702, FR-703, FR-801, FR-901 (optional)
: Dependencies: Phase 1-2
: Deliverables: Global search, FTS5, API endpoints

### Milestones

| Milestone | Target | Success Criteria |
|:----------|:-------|:-----------------|
| Phase 1 Complete | Week 1 | Artifact gallery functional, rich rendering works |
| Phase 2 Complete | Week 2 | Agent/persona directories populated, MCP tools work |
| Phase 3 Complete | Week 3 | Chat enhancements deployed |
| Phase 4 Complete | Week 4 | Search functional, all tests passing |

---

## Open Questions

| Question | Impact | Owner | Due |
|:---------|:-------|:------|:----|
| Bundle libraries or use CDN only? | Offline capability | Frontend | Phase 1 |
| Real-time priority for v1? | Scope | Product | Phase 4 |
| Index chat message content in FTS? | Search scope, performance | Backend | Phase 4 |

---

## Database Migration Summary

**Migration 4: Agent caching**
```sql
CREATE TABLE IF NOT EXISTS agents (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    slug TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    color TEXT,
    prompt_path TEXT,
    cached_prompt TEXT,
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
```

**Migration 5: Persona caching**
```sql
CREATE TABLE IF NOT EXISTS personas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    slug TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    role TEXT,
    profile_path TEXT,
    cached_profile TEXT,
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS persona_activity (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    persona_slug TEXT NOT NULL,
    activity_type TEXT NOT NULL,
    reference_id INTEGER,
    reference_type TEXT,
    timestamp TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_persona_activity_slug ON persona_activity(persona_slug);
```

**Migration 6: Session tracking**
```sql
ALTER TABLE sessions ADD COLUMN created_by TEXT;
ALTER TABLE sessions ADD COLUMN client_info TEXT;
ALTER TABLE sessions ADD COLUMN parent_session_id TEXT;
```

**Migration 7: Artifact session link** (already exists, verify)
```sql
ALTER TABLE artifacts ADD COLUMN session_id TEXT REFERENCES sessions(id);
```

**Migration 8: Full-text search**
```sql
CREATE VIRTUAL TABLE IF NOT EXISTS search_index USING fts5(
    entity_type, entity_id, title, content, metadata
);
```

---

## MCP Tool Summary

| Tool | Parameters | Returns | Phase |
|:-----|:-----------|:--------|:------|
| `list_agents` | None | List of agent summaries | 2 |
| `get_agent_prompt` | slug: str | Agent with full prompt | 2 |
| `list_personas` | None | List of persona summaries | 2 |
| `get_persona` | slug: str | Persona profile + activity | 2 |
| `get_persona_journal` | slug: str, limit: int | Journal entries | 2 |
| `search` | query: str, types: list, limit: int | Search results | 4 |

---

## Configuration Summary

| Variable | Purpose | Default |
|:---------|:--------|:--------|
| `NPL_MCP_HOST` | Web server host | 127.0.0.1 |
| `NPL_MCP_PORT` | Web server port | 8765 |
| `NPL_MCP_DATA_DIR` | Data directory | ./data |
| `NPL_HOME` | NPL installation | (required) |
| `NPL_PERSONA_DIR` | Persona definitions | (optional) |
| `NPL_AGENTS_DIR` | Agent definitions override | $NPL_HOME/core/agents |
| `NPL_MAX_UPLOAD_SIZE` | Max file upload bytes | 10485760 (10MB) |
| `NPL_ENABLE_REALTIME` | Enable SSE updates | false |

---

## Appendix

### Glossary

**artifact**
: A versioned file or document managed by the MCP system

**persona**
: A simulated agent identity with persistent state (journal, tasks, knowledge)

**agent**
: An NPL agent definition that can be invoked for specific tasks

**session**
: A grouping container for related chat rooms and artifacts

**FTS5**
: SQLite Full-Text Search extension version 5

### References

- Source specification: `mcp-server/docs/ENHANCEMENTS.md`
- NPL Persona system: `core/scripts/npl-persona`
- NPL Agent definitions: `core/agents/*.md`
- PRD Specification: `core/specifications/prd-spec.md`

### Revision History

| Version | Date | Author | Changes |
|:--------|:-----|:-------|:--------|
| 1.0 | 2025-12-10 | Claude | Initial PRD from ENHANCEMENTS.md |
