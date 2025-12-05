# Infrastructure

Service configuration and deployment documentation for NoizuPromptLingo.

## Service Inventory

| Service | Version | Type | Config Location |
|:--------|:--------|:-----|:----------------|
| SQLite (MCP) | embedded | database | `mcp-server/src/npl_mcp/storage/schema.sql` |
| SQLite (NIMPS) | embedded | database | `core/schema/nimps.sql` |
| SQLite (KB) | embedded | database | `core/schema/nb.sql` |
| npl-mcp | 0.1.0 | Python package | `mcp-server/pyproject.toml` |
| npl-installer | 0.1.0 | Python package | `installer/pyproject.toml` |
| npl-load | - | CLI script | `core/scripts/npl-load` |
| npl-persona | - | CLI script | `core/scripts/npl-persona` |
| dump-files | - | CLI script | `core/scripts/dump-files` |
| git-tree | - | CLI script | `core/scripts/git-tree` |
| git-tree-depth | - | CLI script | `core/scripts/git-tree-depth` |

---

## SQLite Databases

**purpose**
: Local embedded storage for artifacts, chat, knowledge, and project management

**deployment**
: Created on-demand at runtime; no migration system

### MCP Server Database

**schema**: `mcp-server/src/npl_mcp/storage/schema.sql`

**data directory**
: Configurable via `NPL_MCP_DATA_DIR` environment variable
: Default: `./data/npl-mcp.db`

| Table | Purpose |
|:------|:--------|
| artifacts | Main artifact registry with name, type, timestamps |
| revisions | Version history with file paths and metadata |
| reviews | Artifact review sessions by persona |
| inline_comments | Line-by-line or position-based comments |
| review_overlays | Image annotation overlays |
| chat_rooms | Collaboration spaces |
| room_members | Persona membership in rooms |
| chat_events | All events in chat rooms (messages, reactions, shares) |
| notifications | User notifications from @mentions and events |

**indexes**
: `idx_revisions_artifact`, `idx_reviews_artifact`, `idx_reviews_revision`
: `idx_inline_comments_review`, `idx_chat_events_room`, `idx_chat_events_timestamp`
: `idx_notifications_persona`, `idx_notifications_read`

```sql
-- Core artifact tables
CREATE TABLE IF NOT EXISTS artifacts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    type TEXT NOT NULL,  -- 'document', 'image', 'code', 'data', etc.
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    current_revision_id INTEGER,
    FOREIGN KEY (current_revision_id) REFERENCES revisions(id)
);

CREATE TABLE IF NOT EXISTS revisions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    artifact_id INTEGER NOT NULL,
    revision_num INTEGER NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    created_by TEXT,  -- persona slug
    file_path TEXT NOT NULL,  -- relative path in data/artifacts/
    meta_path TEXT NOT NULL,  -- path to .meta.md file
    purpose TEXT,
    notes TEXT,
    FOREIGN KEY (artifact_id) REFERENCES artifacts(id),
    UNIQUE(artifact_id, revision_num)
);

-- Chat system
CREATE TABLE IF NOT EXISTS chat_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    room_id INTEGER NOT NULL,
    event_type TEXT NOT NULL,  -- 'message', 'emoji_reaction', 'artifact_share', etc.
    persona TEXT NOT NULL,
    timestamp TEXT NOT NULL DEFAULT (datetime('now')),
    data TEXT NOT NULL,  -- JSON-encoded event data
    reply_to_id INTEGER,
    FOREIGN KEY (room_id) REFERENCES chat_rooms(id),
    FOREIGN KEY (reply_to_id) REFERENCES chat_events(id)
);
```

---

### NIMPS Database

**schema**: `core/schema/nimps.sql`

**version**
: 2.1 (NPL-compatible SQLite schema with JSON details)

| Table | Purpose |
|:------|:--------|
| projects | Project registry with status workflow |
| business_analysis | SWOT, competition, risks with JSON details |
| go_to_market | Revenue models, pricing, projections, marketing |
| designs | Wireframes, mockups, prototypes, components |
| style_guide | Brand, color, typography, spacing tokens |
| personas | User personas with journey stages |
| persona_relationships | Relationship mapping between personas |
| competitors | Competitive analysis |
| epics | High-level feature groupings (EP-XXX format) |
| user_stories | Individual stories (US-XXX format) with narrative JSON |
| acceptance_criteria | Gherkin-style criteria per story |
| components | System architecture components |
| component_dependencies | Upstream/downstream dependencies |
| assets | All project deliverables |
| dependencies | External dependencies (team, vendor, compliance) |
| yield_points | Review cycle tracking |
| diagrams | Generated diagrams (mermaid, plantuml, svg) |

**status workflow**
: `discovery` -> `analysis` -> `persona` -> `planning` -> `architecture` -> `creation` -> `mockup` -> `documentation` -> `completed`

**triggers**
: Auto-update timestamps on `projects`, `personas`, `epics`, `user_stories`, `components`, `assets`, `diagrams`

```sql
-- Core project table
CREATE TABLE IF NOT EXISTS projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    slug TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    status TEXT DEFAULT 'discovery' CHECK(status IN (
        'discovery', 'analysis', 'persona', 'planning',
        'architecture', 'creation', 'mockup', 'documentation', 'completed'
    )),
    details JSON, -- {elevator_pitch, executive_summary, pitch_30s, pitch_2min, ...}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User stories with narrative structure
CREATE TABLE IF NOT EXISTS user_stories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    epic_id INTEGER,
    ticket TEXT UNIQUE NOT NULL, -- US-001 format
    title TEXT NOT NULL,
    priority TEXT CHECK(priority IN ('P0', 'P1', 'P2', 'P3')),
    points INTEGER,
    status TEXT DEFAULT 'backlog' CHECK(status IN (
        'backlog', 'planned', 'in_progress', 'testing', 'done', 'blocked'
    )),
    narrative JSON, -- {user_type, context, want, outcome, emotion, goal}
    details JSON,   -- {personas, background, user_goals, business_goals, ...}
    dod JSON,       -- {code_complete, tested, accessible, performant, ...}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (epic_id) REFERENCES epics(id) ON DELETE SET NULL
);
```

---

### Knowledge Base Database

**schema**: `core/schema/nb.sql`

**storage location**
: `.npl/nb/articles.sqlite`

| Table | Purpose |
|:------|:--------|
| articles | Main article registry with topic, level, status |
| sections | Chapter/section content with metadata |
| cross_references | Article linking with reference types |
| search_cache | Cached search results with AI suggestions |
| articles_fts | FTS5 virtual table for full-text search |

**features**
: FTS5 full-text search on title, keywords, abstract
: Automatic FTS maintenance via triggers
: Access tracking with `accessed_at` and `access_count`

```sql
-- Articles with full-text search
CREATE TABLE IF NOT EXISTS articles (
  id VARCHAR(10) PRIMARY KEY,          -- Format: XX-NNN (e.g., ST-001)
  topic VARCHAR(100) NOT NULL,
  title VARCHAR(200) NOT NULL,
  keywords TEXT,
  abstract TEXT,
  level ENUM('beginner','intermediate','advanced','postgrad') DEFAULT 'postgrad',
  status ENUM('draft','published','archived') DEFAULT 'published',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  access_count INTEGER DEFAULT 0
);

-- FTS5 virtual table
CREATE VIRTUAL TABLE IF NOT EXISTS articles_fts USING fts5(
  id, title, keywords, abstract, content='articles'
);

-- Cross-references between articles
CREATE TABLE IF NOT EXISTS cross_references (
  source_article VARCHAR(10) NOT NULL,
  source_section VARCHAR(20),
  target_article VARCHAR(10) NOT NULL,
  target_section VARCHAR(20),
  reference_type ENUM('see_also','prerequisite','extends','related') DEFAULT 'related',
  PRIMARY KEY (source_article, source_section, target_article, target_section)
);
```

---

## Python Packages

### npl-mcp

**purpose**
: FastMCP server exposing 23 NPL tools for artifact management, reviews, and chat

**configuration**
: Primary: `mcp-server/pyproject.toml`
: Entry point: `npl-mcp` command
: Build system: hatchling

**python requirement**
: >=3.10

**dependencies**
: fastmcp>=0.1.0 - MCP server framework
: pyyaml>=6.0 - YAML parsing
: pillow>=10.0 - Image processing
: aiosqlite>=0.19.0 - Async SQLite

**dev dependencies**
: pytest>=7.4.0
: pytest-asyncio>=0.21.0

**package structure**
: `src/npl_mcp/server.py` - Main server with 23 tool definitions
: `src/npl_mcp/storage/` - Database layer
: `src/npl_mcp/artifacts/` - Artifact and review managers
: `src/npl_mcp/chat/` - Chat system manager

**exposed tools**
: Script tools: `dump_files`, `git_tree`, `git_tree_depth`, `npl_load`
: Artifact tools: `create_artifact`, `add_revision`, `get_artifact`, `list_artifacts`, `get_artifact_history`
: Review tools: `create_review`, `add_inline_comment`, `add_overlay_annotation`, `get_review`, `generate_annotated_artifact`, `complete_review`
: Chat tools: `create_chat_room`, `send_message`, `react_to_message`, `share_artifact`, `create_todo`, `get_chat_feed`, `get_notifications`, `mark_notification_read`

```toml
[project]
name = "npl-mcp"
version = "0.1.0"
description = "NPL MCP Server with artifact management and persona chat system"
requires-python = ">=3.10"
dependencies = [
    "fastmcp>=0.1.0",
    "pyyaml>=6.0",
    "pillow>=10.0",
    "aiosqlite>=0.19.0",
]

[project.scripts]
npl-mcp = "npl_mcp.server:main"

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

---

### npl-installer

**purpose**
: Installer for NPL repository and agent setup

**status**
: Stub implementation

**configuration**
: Primary: `installer/pyproject.toml`
: Entry point: `install-npl` command

**python requirement**
: >=3.9

**dependencies**
: None (stub)

```toml
[project]
name = "npl-installer"
version = "0.1.0"
description = "Installer for NPL repository and agent setup"
requires-python = ">=3.9"
dependencies = []

[project.scripts]
install-npl = "installer:main"
```

---

## CLI Tools

### npl-load

**purpose**
: Hierarchical component loading with fallback chains and dependency tracking

**location**
: `core/scripts/npl-load`

**language**
: Python 3

**dependencies**
: PyYAML for agent metadata extraction

**environment variables**
: `NPL_HOME` - Base path for NPL definitions
: `NPL_META` - Path for metadata files
: `NPL_STYLE_GUIDE` - Path for style conventions
: `NPL_THEME` - Theme name for style loading

**search order**
: Project (`./.npl/`) -> User (`~/.npl/`) -> System (`/etc/npl/`)

**subcommands**

| Command | Description |
|:--------|:------------|
| `c <items>` | Load components (npl definitions) |
| `m <items>` | Load metadata files |
| `s <items>` | Load style guides |
| `schema <name>` | Output raw SQL schema |
| `init` | Load main npl.md file |
| `agent <name>` | Load agent definitions |
| `spec <items>` | Load specifications |
| `persona <items>` | Load personas |
| `prd <items>` | Load PRD documents |
| `story <items>` | Load user stories |
| `prompt <items>` | Load prompts |
| `init-claude` | Initialize CLAUDE.md with NPL prompts |
| `syntax` | Analyze NPL syntax elements |

**usage examples**

```bash
# Load NPL components
npl-load c "syntax,agent,directive" --skip "syntax"

# Load agent with filtering
npl-load agent --list --verbose
npl-load agent npl-gopher-scout

# Load schema
npl-load schema nimps

# Initialize CLAUDE.md
npl-load init-claude --target ./CLAUDE.md
```

---

### npl-persona

**purpose**
: Comprehensive persona management with multi-tiered hierarchical loading

**location**
: `core/scripts/npl-persona`

**language**
: Python 3

**environment variables**
: `NPL_PERSONA_DIR` - Base path for persona definitions
: `NPL_PERSONA_TEAMS` - Path for team definitions
: `NPL_PERSONA_SHARED` - Path for shared persona resources

**mandatory files per persona**
: `{persona_id}.persona.md` - Definition
: `{persona_id}.journal.md` - Experience journal
: `{persona_id}.tasks.md` - Task tracking
: `{persona_id}.knowledge-base.md` - Knowledge base

**command groups**

| Group | Commands | Description |
|:------|:---------|:------------|
| Lifecycle | `init`, `get`, `list`, `remove` | Create and manage personas |
| Journal | `journal add\|view\|archive` | Track persona experiences |
| Tasks | `task add\|update\|complete\|list` | Manage tasks and goals |
| Knowledge | `kb add\|search\|get` | Maintain knowledge bases |
| Health | `health`, `sync`, `backup` | File integrity and maintenance |
| Teams | `team create\|add\|list\|synthesize` | Multi-persona collaboration |
| Analytics | `analyze`, `report` | Insights and reporting |

---

### dump-files

**purpose**
: Dump contents of files in a directory respecting .gitignore

**location**
: `core/scripts/dump-files`

**language**
: Bash

**requirements**
: Must be run inside a Git repository

**usage**

```bash
dump-files <target-folder>
dump-files src/
```

**output format**
: Each file preceded by header `# <path>` followed by separator

---

### git-tree

**purpose**
: Display directory tree respecting .gitignore

**location**
: `core/scripts/git-tree`

**language**
: Bash

**requirements**
: Must be run inside a Git repository
: Requires `tree` command installed

**usage**

```bash
git-tree [target-folder]
git-tree deployments/
```

---

### git-tree-depth

**purpose**
: List directories with nesting depth information

**location**
: `core/scripts/git-tree-depth`

**language**
: Bash

**requirements**
: Must be run inside a Git repository

**output**
: Directory path and depth number (0 = target itself)

**usage**

```bash
git-tree-depth <target-folder>
git-tree-depth src/
```

---

## Deployment

### Local Development

**installation**

```bash
# Install npl-mcp package
cd mcp-server
pip install -e .

# Install CLI scripts to PATH
export PATH="$PATH:/path/to/NoizuPromptLingo/core/scripts"

# Or symlink scripts
ln -s /path/to/NoizuPromptLingo/core/scripts/npl-load ~/.local/bin/
ln -s /path/to/NoizuPromptLingo/core/scripts/npl-persona ~/.local/bin/
```

**starting MCP server**

```bash
# Run MCP server
npl-mcp

# With custom data directory
NPL_MCP_DATA_DIR=/custom/path npl-mcp
```

**environment setup**

```bash
# Optional: Set NPL paths
export NPL_HOME=/path/to/NoizuPromptLingo
export NPL_PERSONA_DIR=./.npl/personas
export NPL_MCP_DATA_DIR=./data
```

---

### Deployment Model

**deployment-method**
: Local pip install only

**environments**
: Development only (no staging/production)

**containerization**
: None

**ci-cd**
: None

**cloud-deployment**
: None - local-first design

**data persistence**
: SQLite databases in local filesystem
: Artifact files stored in `data/artifacts/`
: Chat attachments in `data/chats/`

---

## Configuration Reference

### Environment Variables

| Variable | Purpose | Default |
|:---------|:--------|:--------|
| `NPL_HOME` | Base path for NPL definitions | `./.npl`, `~/.npl`, `/etc/npl/` |
| `NPL_META` | Path for metadata files | `$NPL_HOME/meta` |
| `NPL_STYLE_GUIDE` | Path for style conventions | `$NPL_HOME/conventions` |
| `NPL_THEME` | Theme name for style loading | `default` |
| `NPL_PERSONA_DIR` | Base path for persona definitions | `./.npl/personas` |
| `NPL_PERSONA_TEAMS` | Path for team definitions | `./.npl/teams` |
| `NPL_PERSONA_SHARED` | Path for shared persona resources | `./.npl/shared` |
| `NPL_MCP_DATA_DIR` | Data directory for MCP server | `./data` |

### File Locations

| Resource | Search Order |
|:---------|:-------------|
| NPL components | `./.npl/npl/`, `~/.npl/npl/`, `/etc/npl/npl/` |
| Agents | `./.claude/agents/`, `~/.claude/agents/`, `./.npl/core/agents/` |
| Schemas | `./.npl/core/schema/`, `~/.npl/core/schema/` |
| Personas | `./.npl/personas/`, `~/.npl/personas/`, `/etc/npl/personas/` |
| Specifications | `./.npl/specifications/`, `~/.npl/specifications/` |
| Prompts | `./.npl/prompts/`, `~/.npl/prompts/` |
