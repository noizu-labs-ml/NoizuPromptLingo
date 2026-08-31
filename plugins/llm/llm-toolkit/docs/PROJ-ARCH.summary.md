# Architecture Summary

Local-first tool (**llm-toolkit** / *Claude Assist*) for indexing, searching, editing, and extracting artifacts from AI coding-agent transcripts — evolving into **agent-watch-dog** multi-harness session continuity (Claude + Codex importers live; Gemini/OpenCode/Aider stubbed). Three conversation interfaces (Hono REST API, React SPA, Ink TUI) share one SQLite DB (FTS5 + sqlite-vec). Embedded **skill-manage** Rust crate manages provider skills/agents/commands via symlinks. Self-contained at `Portfolio/Apps/AI/llm-toolkit`; `make install` → `~/.local/bin/llm-toolkit` (no k8-lib / .infra-config.yaml).

## Components

- **API** (Hono) — IndexerService (raw events → universal → flat messages; optional LLM work-item extraction; chokidar); StorageService (harness-aware schema, FTS5/vec0, settings); EmbeddingService (MiniLM 384-dim); SearchService; LlmService (Anthropic + OpenAI-compatible providers); editor/operations (versioned edits, clone/rehome/archive/tag); converter/exporter (artifacts + fine-tune datasets); harness-transform (Claude/Codex export payloads); harness-transfer + session-workflow (transfer/memory stubs — transfer pending for all targets). Routes: conversations, search, datasets, prompts, projects, tags, config, index, llm, health.
- **Web** (React + Vite + Tailwind) — Explore (unified search/browse), thread viewer/editor/convert/continue, projects, datasets, prompts, tags, settings, Safety Watch stub, style guide. `hostBridge.ts` lets the Mac app hide chrome and drive navigation/harness.
- **macOS** (SwiftUI + WKWebView) — Native window around the same SPA; starts or attaches to `:5173`/`:3100`; menus and sidebar cover every implemented web route.
- **CLI** (Ink) — One-shots: `recent` (direct DB), `search`, `list`, `show`, `index`, …; full interactive TUI (Explore, Thread, Projects, Datasets, Convert, Edit, Continue, Safety Watch, Settings, …).
- **Shared** — Types (`UniversalMessage`, `AgentHarness`, …), JSONL parsers, `ensureApi()`.
- **skill-manage** — Rust symlink enable/disable/audit + YAML catalog/work-types; `llm-toolkit skill …`.
- **bin/llm-toolkit** — zellij-aware API+web launcher, skill proxy, CLI dispatch.

## Data / Storage

- Index pipeline: harness JSONL → raw events → universal messages → flat messages (+ FTS / optional vectors / optional work items).
- DB: `~/.llm-toolkit/llm-toolkit.db` (WAL; sqlite-vec degrades gracefully).
- Defaults: Claude `~/.claude/projects`, Codex `~/.codex/sessions`; CORS locked to `localhost:5173`.

## Key Decisions

- Local-first SQLite + local embeddings; external LLM optional
- JSONL source of truth; DB derived; non-destructive versioned edits
- Raw events retained before universal normalization; transfer via Universal only
- Claude/Codex transform exporters implemented; transfer façade / memory hooks still planned
- Hono + sqlite-vec (graceful degrade); pnpm workspaces + embedded Rust skill linker
- One PATH entry (`bin/llm-toolkit`) for web, TUI, API, and skill management

## Stack (short)

Node/tsx · Hono · better-sqlite3 + sqlite-vec · MiniLM embeddings · React/Vite/Tailwind · Ink · Rust skill-manage (clap/ratatui) · pnpm workspaces
