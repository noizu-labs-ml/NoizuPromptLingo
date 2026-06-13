# Claude Assist

A local dev tool for searching, browsing, editing, and managing Claude Code conversations — then extracting reusable agents, skills, workflows, and fine-tuning datasets from them.

Your Claude Code conversations contain valuable reasoning and solutions that disappear into JSONL archives. Claude Assist makes them searchable, browsable, editable, and reusable.

## Features

**Search** — Find conversations by keyword (FTS5) or meaning (semantic search with local embeddings). Filter by project, date, or role.

**Browse** — Project-grouped conversation list with sorting by date, message count, or title.

**Thread Viewer** — Full conversation renderer with rendered markdown, syntax-highlighted code blocks, Mermaid diagrams, LaTeX math, and collapsible tool calls / thinking blocks. Includes resume command to jump back into any session.

**Thread Editing** — Non-destructive editing: collapse verbose sequences, remove tangents, inject context, reorder messages. All edits produce a new version — source JSONL is never modified.

**Convert** — Extract reusable artifacts from conversations: agent definitions, skills, slash commands, code snippets, or step-by-step runbooks.

**Datasets** — Tag message ranges as fine-tuning data with quality labels (gold/silver/bronze). Export in OpenAI, Anthropic, or raw JSONL formats.

**Operations** — Clone, rehome (move JSONL file to a different project directory), archive, and tag conversations.

## Quick Start

```bash
# Prerequisites: Node.js >= 18, pnpm >= 8
cd projects/claude-assist
pnpm install

# Start both servers
pnpm dev:api   # API on http://localhost:3100
pnpm dev:web   # Web UI on http://localhost:5173
```

Open http://localhost:5173. The API auto-indexes conversations from `~/.claude/projects/` on first boot.

### CLI

```bash
# Search
npx tsx packages/cli/bin.ts search "auth middleware"

# List recent conversations
npx tsx packages/cli/bin.ts list

# View a conversation
npx tsx packages/cli/bin.ts show <conversation-id>

# Rebuild the search index
npx tsx packages/cli/bin.ts index
```

## Architecture

```
claude-assist/
├── packages/
│   ├── shared/         # Types, JSONL parser, API launcher
│   ├── api/            # Hono server, SQLite storage, FTS5 + vector search, indexer
│   ├── cli/            # Ink (React for terminals) — search, list, show, index
│   └── web/            # React + Vite + Tailwind — 10 pages, markdown rendering
├── design/             # Style guide, mockups, logos, sitemap
└── package.json        # pnpm workspace root
```

### Data Flow

```
~/.claude/projects/**/*.jsonl
        │
        ▼
    Indexer ──▶ SQLite (conversations, messages, FTS5, vectors)
                    │
                    ▼
                API Server (Hono, port 3100)
                 ╱          ╲
           CLI (Ink)     Web UI (Vite, port 5173)
```

### Tech Stack

| Layer | Technology |
|-------|-----------|
| Runtime | Node.js + tsx |
| API | Hono + @hono/node-server |
| Database | better-sqlite3 (WAL mode) |
| Full-text search | SQLite FTS5 |
| Vector search | sqlite-vec + all-MiniLM-L6-v2 (via @huggingface/transformers) |
| CLI | Ink 5 (React for terminals) |
| Web | React 18, Vite 6, Tailwind 3.4, react-router-dom 7 |
| Markdown | react-markdown, remark-gfm, rehype-katex, react-syntax-highlighter |
| Diagrams | Mermaid.js |
| File watching | chokidar |

### Database Schema

Six tables across three concerns:

**Content** — `conversations` (metadata, project path, source file), `messages` (role, content, timestamp), `messages_fts` (FTS5 virtual table, auto-synced via triggers)

**Vectors** — `conversation_vectors` (sqlite-vec KNN, 384-dim MiniLM embeddings)

**Curation** — `thread_edits` (non-destructive edit versions), `datasets` + `dataset_entries` (fine-tuning data with quality labels)

## Web UI Pages

| Route | Purpose |
|-------|---------|
| `/` | Dashboard — stats, search bar, recent conversations |
| `/search` | Full-text + semantic search with filters |
| `/browse` | Project-grouped conversation list |
| `/thread/:id` | Thread viewer with markdown, code, Mermaid, LaTeX |
| `/thread/:id/edit` | Non-destructive thread editor |
| `/thread/:id/convert` | Artifact extraction wizard |
| `/datasets` | Dataset list and creation |
| `/datasets/:name` | Dataset entries, quality labels, export |
| `/settings` | Index paths, embedding provider, reindex |

## API Endpoints

### Conversations
- `GET /api/conversations` — List (sort, limit, project filter)
- `GET /api/conversations/:id` — Get one
- `GET /api/conversations/:id/messages` — Flattened messages
- `GET /api/conversations/:id/thread` — Raw JSONL records (for rich rendering)
- `GET /api/conversations/:id/metadata` — Title, tags, summary
- `GET /api/conversations/:id/edits` — Edit versions
- `POST /api/conversations/:id/edits` — Create edit (operations: collapse, remove, reorder, inject)
- `GET /api/conversations/:id/candidates` — AI-suggested extraction points
- `POST /api/conversations/:id/convert` — Generate artifact
- `POST /api/conversations/:id/clone` — Duplicate conversation
- `POST /api/conversations/:id/rehome` — Move JSONL file to target project directory + update index
- `POST /api/conversations/:id/archive` — Archive
- `POST /api/conversations/:id/tag` — Update tags

### Search
- `GET /api/search?q=...&mode=fts|semantic&project=...&role=...` — Search conversations

### Datasets
- `GET /api/datasets` — List datasets
- `POST /api/datasets` — Create dataset
- `GET /api/datasets/:name` — Dataset details
- `GET /api/datasets/:name/entries` — List entries
- `POST /api/datasets/:name/entries` — Add entry
- `PATCH /api/datasets/:name/entries/:id` — Update quality/prompt
- `DELETE /api/datasets/:name/entries/:id` — Remove entry
- `GET /api/datasets/:name/export?format=openai|anthropic|jsonl` — Export

### Index & Config
- `POST /api/index/rebuild` — Trigger reindex
- `GET /api/index/status` — Index status
- `GET /api/config` — Current config
- `PATCH /api/config` — Update config

## Development

```bash
pnpm test         # Run tests across all packages (91 tests)
pnpm typecheck    # Type-check all packages
pnpm build        # Build all packages
pnpm clean        # Remove dist/ directories
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CLAUDE_ASSIST_DATA_DIR` | `~/.claude-assist` | Database and config storage |
| `CLAUDE_ASSIST_WATCH_PATHS` | `~/.claude/projects` | Colon-separated JSONL scan paths |
| `CLAUDE_ASSIST_WATCH` | `true` | Set to `false` to disable file watcher |
| `PORT` | `3100` | API server port |

### Project Structure

```
packages/api/src/
├── index.ts                 # Server startup, service wiring
├── routes/
│   ├── conversations.ts     # CRUD + edit + convert + operations
│   ├── search.ts            # FTS5 + semantic search
│   ├── datasets.ts          # Dataset CRUD + export
│   ├── config.ts            # Config persistence
│   └── index-routes.ts      # Rebuild + status
└── services/
    ├── storage.ts           # SQLite (6 tables, 20+ methods)
    ├── indexer.ts            # JSONL scanner, incremental, watch mode
    ├── search.ts             # FTS5 + semantic search
    ├── embeddings.ts         # Transformers.js (MiniLM-L6-v2, 384-dim)
    ├── editor.ts             # Pure edit operations (collapse, remove, reorder, inject)
    ├── converter.ts          # Pattern detection + artifact generation
    ├── exporter.ts           # OpenAI / Anthropic / JSONL formatters
    └── operations.ts         # Clone, rehome, archive, tag

packages/web/src/
├── pages/
│   ├── Dashboard.tsx        # Stats + recent conversations
│   ├── Search.tsx           # Full search UI
│   ├── Browse.tsx           # Project-grouped list
│   ├── Thread.tsx           # Rich thread viewer
│   ├── Edit.tsx             # Thread editor
│   ├── Convert.tsx          # Artifact wizard
│   ├── Settings.tsx         # Config + reindex
│   ├── Datasets.tsx         # Dataset list
│   └── DatasetDetail.tsx    # Entries + export
├── components/
│   ├── Layout.tsx           # App shell, sidebar nav
│   └── MarkdownView.tsx     # Rendered/source toggle, Mermaid, LaTeX, syntax highlighting
└── hooks/
    └── useApi.ts            # Typed React hooks (useConversations, useSearch, etc.)
```

## How Conversations Are Stored

Claude Code stores conversations as JSONL files at `~/.claude/projects/{encoded-path}/{session-id}.jsonl`. The directory name encodes the project's absolute path (`/Users/foo/bar` becomes `-Users-foo-bar`). Each line is a JSON record linked by `parentUuid` chains.

Record types: `user`, `assistant` (with content blocks: text, tool_use, tool_result, thinking), `permission-mode`, `attachment`, `system`, `file-history-snapshot`, `last-prompt`, `queue-operation`.

Claude Assist indexes the `user` and `assistant` records into SQLite for search and display, and reads the raw JSONL on demand for the thread viewer's rich rendering.

## License

MIT
