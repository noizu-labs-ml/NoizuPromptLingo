# NPL MCP Web Portal Enhancement Specification

Version: 1.0.0
Date: 2025-12-10

---

## Overview

This document specifies enhancements to transform the NPL MCP web portal from a basic session/chat viewer into a comprehensive collaboration hub with rich content rendering, persona/agent integration, artifact management, and human operator capabilities.

---

## 1. Navigation & Global UI

### 1.1 Enhanced Header Navigation

**Current:** Sessions | API links only

**Proposed:**
```
┌─────────────────────────────────────────────────────────────────────┐
│ NPL MCP                                                             │
│ ─────────────────────────────────────────────────────────────────── │
│ [Sessions] [Artifacts] [Agents] [Personas] [API]      🔍 Search     │
└─────────────────────────────────────────────────────────────────────┘
```

### 1.2 New Routes

| Route | Purpose |
|-------|---------|
| `/artifacts` | Artifact gallery with search/filter |
| `/artifact/{id}` | Artifact detail (exists) |
| `/artifact/{id}/edit` | Edit artifact (upload new revision) |
| `/agents` | Agent directory |
| `/agent/{slug}` | Agent detail with prompt |
| `/personas` | Persona directory |
| `/persona/{slug}` | Persona detail with journal/tasks |
| `/search` | Global search |

---

## 2. Artifact System Enhancements

### 2.1 Artifact Gallery (`/artifacts`)

**Features:**
- Grid/list view toggle
- Search by name, type, creator
- Filter by type (document, image, code, data, diagram)
- Sort by: created, updated, name
- Thumbnail previews for images/diagrams

**UI Mockup:**
```
┌─────────────────────────────────────────────────────────────────────┐
│ Artifacts                                              [Grid] [List]│
│ ─────────────────────────────────────────────────────────────────── │
│ 🔍 [Search artifacts...]        [Type ▼] [Creator ▼] [Sort ▼]       │
│ ─────────────────────────────────────────────────────────────────── │
│ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐                 │
│ │  📄      │ │  🖼️      │ │  📊      │ │  💻      │                 │
│ │          │ │          │ │          │ │          │                 │
│ │ spec.md  │ │ arch.svg │ │ flow.mmd │ │ auth.py  │                 │
│ │ document │ │ image    │ │ diagram  │ │ code     │                 │
│ │ @alice   │ │ @bob     │ │ @claude  │ │ @alice   │                 │
│ └──────────┘ └──────────┘ └──────────┘ └──────────┘                 │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.2 Enhanced Artifact Types

| Type | Extensions | Rendering |
|------|------------|-----------|
| `document` | .md, .txt, .rst | Markdown with syntax highlighting |
| `code` | .py, .js, .ts, .go, .rs | Syntax-highlighted code |
| `image` | .png, .jpg, .gif, .webp | Native image display |
| `svg` | .svg | Inline SVG rendering |
| `diagram` | .mmd, .mermaid | Mermaid.js live render |
| `latex` | .tex, .tikz | KaTeX/MathJax rendering |
| `data` | .json, .yaml, .csv | Formatted data viewer |
| `html` | .html | Sandboxed iframe preview |

### 2.3 Rich Content Rendering

**Mermaid Diagrams:**
```html
<!-- Include mermaid.js -->
<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>

<!-- Auto-detect and render -->
<div class="mermaid">
graph TD
    A[Start] --> B{Decision}
    B -->|Yes| C[Action]
    B -->|No| D[End]
</div>
```

**LaTeX/TikZ:**
```html
<!-- KaTeX for inline math -->
<script src="https://cdn.jsdelivr.net/npm/katex/dist/katex.min.js"></script>

<!-- Render LaTeX blocks -->
$$\int_{0}^{\infty} e^{-x^2} dx = \frac{\sqrt{\pi}}{2}$$
```

**Markdown Enhancements:**
- Detect fenced code blocks with `mermaid` language
- Detect `$$...$$` for LaTeX blocks
- Support GFM tables, task lists, footnotes

### 2.4 Artifact Upload (Web UI)

**New endpoint:** `POST /artifact/upload`

**Form:**
```html
<form method="POST" action="/artifact/upload" enctype="multipart/form-data">
  <input type="text" name="name" placeholder="Artifact name" required>
  <select name="artifact_type">
    <option value="document">Document</option>
    <option value="image">Image</option>
    <option value="code">Code</option>
    <option value="diagram">Diagram</option>
    <option value="data">Data</option>
  </select>
  <textarea name="purpose" placeholder="Purpose/description"></textarea>
  <input type="file" name="file" required>
  <input type="text" name="persona" value="human-operator">
  <input type="hidden" name="session_id" value="{current_session}">
  <button type="submit">Upload</button>
</form>
```

**Backend handler:**
```python
@app.post("/artifact/upload")
async def upload_artifact(request: Request):
    form = await request.form()
    file = form["file"]
    content = await file.read()

    # Create artifact via manager
    result = await artifact_manager.create_artifact(
        name=form["name"],
        artifact_type=form["artifact_type"],
        file_content=content,
        filename=file.filename,
        created_by=form.get("persona", "human-operator"),
        purpose=form.get("purpose"),
        session_id=form.get("session_id")
    )

    return RedirectResponse(f"/artifact/{result['artifact_id']}")
```

### 2.5 Artifact Revision Upload

**Route:** `POST /artifact/{id}/revision`

Allow uploading new revisions with diff view against previous.

---

## 3. Agent Integration

### 3.1 Agent Directory (`/agents`)

**Source:** Read from `$NPL_HOME/core/agents/*.md`

**Display:**
```
┌─────────────────────────────────────────────────────────────────────┐
│ Agents                                                              │
│ ─────────────────────────────────────────────────────────────────── │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │ 📝 npl-technical-writer                                    blue │ │
│ │ Technical writer/editor for specs, PRs, issues, documentation  │ │
│ │ [View Details] [Copy Prompt]                                    │ │
│ └─────────────────────────────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │ 🔍 npl-gopher-scout                                       green │ │
│ │ Elite reconnaissance agent for codebase exploration            │ │
│ │ [View Details] [Copy Prompt]                                    │ │
│ └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.2 Agent Detail (`/agent/{slug}`)

**Display:**
- Agent name, description, color
- Full prompt/definition (syntax highlighted)
- Usage examples
- Link to invoke via MCP

**Schema addition:**
```sql
CREATE TABLE IF NOT EXISTS agents (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    slug TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    color TEXT,
    prompt_path TEXT,  -- path to .md file
    cached_prompt TEXT,  -- cached content
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
```

### 3.3 Agent MCP Tools

```python
@mcp.tool()
async def list_agents() -> list:
    """List available NPL agents."""
    # Scan core/agents/*.md

@mcp.tool()
async def get_agent_prompt(slug: str) -> dict:
    """Get agent definition and prompt."""
    # Return parsed agent definition
```

---

## 4. Persona Integration

### 4.1 Persona Directory (`/personas`)

**Source:** Read from `$NPL_PERSONA_DIR/*.persona.md`

**Display:**
```
┌─────────────────────────────────────────────────────────────────────┐
│ Personas                                                            │
│ ─────────────────────────────────────────────────────────────────── │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │ 👤 alice-dev                                                    │ │
│ │ Role: Senior Developer | Experience: 8 years                    │ │
│ │ Expertise: Python, Architecture, Testing                        │ │
│ │ [View Profile] [Journal] [Tasks]                                │ │
│ └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

### 4.2 Persona Detail (`/persona/{slug}`)

**Tabs:**
- **Profile:** Identity, expertise, voice signature
- **Journal:** Recent journal entries
- **Tasks:** Active and completed tasks
- **Knowledge:** Knowledge base entries
- **Activity:** Recent chat/artifact activity

### 4.3 Persona Schema Addition

```sql
CREATE TABLE IF NOT EXISTS personas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    slug TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    role TEXT,
    profile_path TEXT,  -- path to .persona.md
    cached_profile TEXT,  -- cached parsed content
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS persona_activity (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    persona_slug TEXT NOT NULL,
    activity_type TEXT NOT NULL,  -- 'message', 'artifact', 'review', 'task'
    reference_id INTEGER,  -- ID of related entity
    reference_type TEXT,  -- 'chat_event', 'artifact', 'review', 'task'
    timestamp TEXT NOT NULL DEFAULT (datetime('now'))
);
```

### 4.4 Persona MCP Tools

```python
@mcp.tool()
async def list_personas() -> list:
    """List available personas."""

@mcp.tool()
async def get_persona(slug: str) -> dict:
    """Get persona profile and recent activity."""

@mcp.tool()
async def get_persona_journal(slug: str, limit: int = 10) -> list:
    """Get recent journal entries for persona."""
```

---

## 5. Session Enhancements

### 5.1 Session Initialization Handshake

**Purpose:** Track who/what created a session and from where.

**New fields:**
```sql
ALTER TABLE sessions ADD COLUMN created_by TEXT;  -- persona/agent slug
ALTER TABLE sessions ADD COLUMN client_info TEXT;  -- JSON: terminal, host, etc.
ALTER TABLE sessions ADD COLUMN parent_session_id TEXT;  -- for sub-sessions
```

**MCP tool update:**
```python
@mcp.tool()
async def create_session(
    title: Optional[str] = None,
    session_id: Optional[str] = None,
    created_by: Optional[str] = None,
    client_info: Optional[dict] = None,
    parent_session_id: Optional[str] = None
) -> dict:
    """Create session with tracking info."""
```

### 5.2 Session Detail Enhancements

**Display:**
- Created by (with link to persona/agent)
- Client info (terminal, working directory)
- Parent session (if sub-session)
- Activity timeline
- Room creation form

### 5.3 Create Room from Web

**Route:** `POST /session/{id}/create-room`

```html
<form method="POST" action="/session/{session_id}/create-room">
  <input type="text" name="name" placeholder="Room name" required>
  <textarea name="description" placeholder="Description"></textarea>
  <input type="text" name="members" placeholder="Members (comma-separated)">
  <button type="submit">Create Room</button>
</form>
```

---

## 6. Chat Enhancements

### 6.1 Reply Threading

**Visual:**
```
┌─────────────────────────────────────────────────────────────────────┐
│ claude • 10:30 AM                                                   │
│ I've shared the architecture document for review.                   │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │ ↩️ alice • 10:32 AM                                         │   │
│   │ Looks good! I have a few comments on the auth flow.         │   │
│   └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │ ↩️ bob • 10:35 AM                                           │   │
│   │ +1, also curious about the caching strategy.                │   │
│   └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

### 6.2 Reaction Grouping

**Visual:**
```
┌─────────────────────────────────────────────────────────────────────┐
│ claude • 10:30 AM                                                   │
│ The feature is now deployed to staging!                             │
│                                                                     │
│ 👍 3 (alice, bob, carol)  🎉 2 (alice, dave)  ❤️ 1 (bob)            │
└─────────────────────────────────────────────────────────────────────┘
```

### 6.3 Todo Display Enhancement

```
┌─────────────────────────────────────────────────────────────────────┐
│ 📋 alice • 10:40 AM                                                 │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │ ☐ Review authentication module                                  │ │
│ │   Assigned to: @bob                                             │ │
│ │   [Mark Complete] [Reassign]                                    │ │
│ └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

### 6.4 Artifact Share Enhancement

```
┌─────────────────────────────────────────────────────────────────────┐
│ claude • 10:45 AM                                                   │
│ 📎 Shared artifact:                                                 │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │ 📄 auth-spec.md                           document • revision 2 │ │
│ │ Authentication module specification                             │ │
│ │ [View] [Download] [Start Review]                                │ │
│ └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

### 6.5 Rich Message Content

**Render in messages:**
- Markdown formatting
- Code blocks with syntax highlighting
- Inline mermaid diagrams
- Inline LaTeX math

```python
def _render_message_content(content: str) -> str:
    """Render message with rich content support."""
    # 1. Escape HTML
    # 2. Parse markdown
    # 3. Detect and render mermaid blocks
    # 4. Detect and render LaTeX
    # 5. Syntax highlight code blocks
    return rendered_html
```

### 6.6 Artifact Upload in Chat

**Form addition to chat room:**
```html
<div class="card">
  <h3>Share Artifact</h3>
  <form method="POST" action="/session/{session_id}/room/{room_id}/upload"
        enctype="multipart/form-data">
    <input type="file" name="file" required>
    <input type="text" name="name" placeholder="Artifact name">
    <textarea name="message" placeholder="Comment (optional)"></textarea>
    <button type="submit">Upload & Share</button>
  </form>
</div>
```

---

## 7. Search System

### 7.1 Global Search (`/search`)

**Search across:**
- Sessions (by title, ID)
- Artifacts (by name, content, type)
- Chat messages (by content, persona)
- Personas (by name, role)
- Agents (by name, description)

### 7.2 Search API

```python
@mcp.tool()
async def search(
    query: str,
    types: Optional[List[str]] = None,  # ['session', 'artifact', 'message', 'persona']
    limit: int = 20
) -> dict:
    """Global search across all entities."""
```

### 7.3 Full-Text Search Schema

```sql
-- SQLite FTS5 for full-text search
CREATE VIRTUAL TABLE IF NOT EXISTS search_index USING fts5(
    entity_type,
    entity_id,
    title,
    content,
    metadata
);

-- Triggers to keep index updated
CREATE TRIGGER IF NOT EXISTS idx_artifact_insert AFTER INSERT ON artifacts
BEGIN
    INSERT INTO search_index (entity_type, entity_id, title, content)
    VALUES ('artifact', NEW.id, NEW.name, '');
END;
```

---

## 8. Real-time Updates (Future)

### 8.1 WebSocket Support

**Endpoint:** `ws://localhost:8765/ws/room/{room_id}`

**Events:**
- `message`: New message
- `reaction`: New reaction
- `artifact_share`: Artifact shared
- `typing`: User typing indicator
- `presence`: User join/leave

### 8.2 Server-Sent Events (Simpler)

**Endpoint:** `GET /api/room/{room_id}/events`

```python
@app.get("/api/room/{room_id}/events")
async def room_events(request: Request, room_id: int):
    async def event_generator():
        last_id = 0
        while True:
            events = await chat_manager.get_events_since(room_id, last_id)
            for event in events:
                yield f"data: {json.dumps(event)}\n\n"
                last_id = event['id']
            await asyncio.sleep(1)

    return StreamingResponse(event_generator(), media_type="text/event-stream")
```

---

## 9. API Enhancements

### 9.1 New API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/artifacts` | GET | List artifacts with filters |
| `/api/artifacts/search` | GET | Search artifacts |
| `/api/agents` | GET | List agents |
| `/api/agent/{slug}` | GET | Get agent details |
| `/api/personas` | GET | List personas |
| `/api/persona/{slug}` | GET | Get persona details |
| `/api/search` | GET | Global search |

### 9.2 MCP Tool Additions

| Tool | Purpose |
|------|---------|
| `list_agents` | List available agents |
| `get_agent_prompt` | Get agent definition |
| `list_personas` | List personas |
| `get_persona` | Get persona profile |
| `search` | Global search |
| `upload_artifact` | Create artifact (alternative to create_artifact) |

---

## 10. Implementation Priority

### Phase 1: Core Improvements (Week 1)
1. Enhanced navigation header
2. Artifact gallery with search
3. Rich content rendering (mermaid, code highlighting)
4. Artifact upload from web

### Phase 2: Persona & Agent Integration (Week 2)
1. Agent directory and detail pages
2. Persona directory and profiles
3. Session creation tracking
4. Persona activity feed

### Phase 3: Chat Enhancements (Week 3)
1. Reply threading visualization
2. Reaction grouping
3. Todo management from web
4. Rich message rendering

### Phase 4: Advanced Features (Week 4)
1. Global search with FTS
2. Real-time updates (SSE)
3. Artifact diff view
4. Review workflow improvements

---

## 11. Technical Notes

### 11.1 Frontend Libraries

```html
<!-- Syntax highlighting -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/prismjs/themes/prism-tomorrow.min.css">
<script src="https://cdn.jsdelivr.net/npm/prismjs/prism.min.js"></script>

<!-- Mermaid diagrams -->
<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>

<!-- KaTeX math -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex/dist/katex.min.css">
<script src="https://cdn.jsdelivr.net/npm/katex/dist/katex.min.js"></script>

<!-- Markdown parsing -->
<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
```

### 11.2 File Upload Handling

```python
from fastapi import UploadFile, File

MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB

@app.post("/artifact/upload")
async def upload_artifact(
    name: str = Form(...),
    artifact_type: str = Form(...),
    file: UploadFile = File(...),
    ...
):
    if file.size > MAX_FILE_SIZE:
        raise HTTPException(413, "File too large")

    content = await file.read()
    # Process and store
```

### 11.3 Agent/Persona File Scanning

```python
async def scan_agents(agents_dir: Path) -> List[dict]:
    """Scan agent definition files."""
    agents = []
    for path in agents_dir.glob("*.md"):
        content = path.read_text()
        # Parse YAML frontmatter
        if content.startswith("---"):
            _, frontmatter, body = content.split("---", 2)
            meta = yaml.safe_load(frontmatter)
            agents.append({
                "slug": path.stem,
                "name": meta.get("name", path.stem),
                "description": meta.get("description", ""),
                "color": meta.get("color", "gray"),
                "path": str(path),
                "prompt": body.strip()
            })
    return agents
```

---

## 12. Configuration

### 12.1 Environment Variables

```bash
# Existing
NPL_MCP_HOST=127.0.0.1
NPL_MCP_PORT=8765
NPL_MCP_DATA_DIR=./data

# New
NPL_HOME=/path/to/npl
NPL_PERSONA_DIR=/path/to/.npl/personas
NPL_AGENTS_DIR=/path/to/core/agents
NPL_MAX_UPLOAD_SIZE=10485760  # 10MB
NPL_ENABLE_REALTIME=false
```

---

## Appendix: Database Migration

```sql
-- Migration 4: Agent caching
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

-- Migration 5: Persona caching
CREATE TABLE IF NOT EXISTS personas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    slug TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    role TEXT,
    profile_path TEXT,
    cached_profile TEXT,
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Migration 6: Session tracking
ALTER TABLE sessions ADD COLUMN created_by TEXT;
ALTER TABLE sessions ADD COLUMN client_info TEXT;
ALTER TABLE sessions ADD COLUMN parent_session_id TEXT;

-- Migration 7: Artifact session link
ALTER TABLE artifacts ADD COLUMN session_id TEXT REFERENCES sessions(id);

-- Migration 8: Full-text search
CREATE VIRTUAL TABLE IF NOT EXISTS search_index USING fts5(
    entity_type, entity_id, title, content, metadata
);
```
