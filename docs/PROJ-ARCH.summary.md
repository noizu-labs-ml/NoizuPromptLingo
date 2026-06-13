# Architecture Summary

Local-first tool for indexing and searching Claude Code JSONL conversation logs. Three interfaces (REST API, browser SPA, terminal TUI) backed by a single SQLite database with FTS5 and sqlite-vec for full-text + semantic search. File watching via chokidar for incremental re-indexing.

## Components

- **API** (Hono) — IndexerService parses JSONL, StorageService persists to SQLite (6 core tables + FTS5/vec0 virtual tables), EmbeddingService generates 384-dim vectors via all-MiniLM-L6-v2, SearchService queries FTS5 + cosine similarity. Routes: conversations, search, datasets, prompts, projects, tags, config, index.
- **Web** (React + Vite + Tailwind) — SPA with unified Explore page (search/browse), thread viewer, editor, project detail, dataset manager, prompt library, tag management, style guide
- **CLI** (Ink) — TUI commands: search, list, show, index
- **Shared** — TypeScript types, JSONL parsers, API auto-launcher

## Key Decisions

- Local-first: SQLite + local embeddings, no external services
- JSONL as source of truth; database is a derived index
- Monorepo with pnpm workspaces for shared types
- Hono over Express; sqlite-vec over pgvector (graceful degradation if unavailable)
