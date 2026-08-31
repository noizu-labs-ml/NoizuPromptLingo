# Changelog — utilities/agent/claude-assist

Claude Assist — local dev tool for searching, browsing, editing, and mining Claude Code conversations (pnpm workspace: `api`, `cli`, `shared`, `web`).

## [Unreleased]
- Native macOS app (`apps/macos`) hosts the full web console with SwiftUI chrome, menus, server supervisor, and route parity for every implemented SPA page
- Web Layout/Harness grow a Mac-host bridge (`hostBridge.ts`) so the desktop shell can hide web chrome, navigate, and switch harnesses
- NPL architecture/layout docs refreshed: `docs/PROJ-ARCH.md`, `docs/PROJ-LAYOUT.md`, summaries, and per-package `docs/layout/{api,cli,web}.md` (commit `ff72b3565bf`, 2026-07-16)

## [m3-tui-and-provider-config] — 2026-06-27 — tag: `utilities-agent-claude-assist/m3-tui-and-provider-config`
Milestone summary: major interactive TUI expansion plus configurable LLM provider endpoints and interface selection.

### Added
- Session-continue workflow in the CLI: `ContinueSessionPage` + `sessionWorkflow` service for resuming conversations
- New TUI pages: Safety Watch and Style Guide; richer Explore page, Header, and conversation rows
- Custom LLM provider support in TUI Settings (provider, model, API key, base URL, apiType openai/anthropic)
- Interface selection at launch: `--interface web|tui` flag and `CLAUDE_ASSIST_DEFAULT_INTERFACE` env vars, with tests
- Focus context and selected-line components for keyboard navigation
- Indexer/search/storage service growth (~380 lines) with new indexer and search tests

### Changed
- API bootstrap (`index.ts`) rewired for the expanded indexer and storage services

## [m2-thread-editing-and-operations] — 2026-06-26 — tag: `utilities-agent-claude-assist/m2-thread-editing-and-operations`
Milestone summary: hardened conversation operations (non-destructive JSONL editing) and LLM API-key resolution.

### Added
- Operations service: JSONL entry loading, non-message-entry bucketing, edited-record building, synthetic records, session rewrites — with operations test suite
- Expanded web Edit page supporting the new editing operations
- LLM API-key resolution chain: masked-key detection, per-provider env vars (Anthropic, OpenAI, Groq, Cerebras, DeepSeek, Z.ai, LiteLLM), stored `app_config` fallback

### Changed
- Conversations routes and indexer updated for the new operation semantics; shared types extended

### Fixed
- Stray accidental file `2` committed then removed (net zero)

## [m1-subtree-import] — 2026-06-14 — tag: `utilities-agent-claude-assist/m1-subtree-import`
Milestone summary: project imported into the monorepo as a squashed git subtree and wired into utility installation.

### Added
- Initial import of Claude Assist (squashed subtree from external repo commit `c17f75c84fe`): Hono API with FTS5 + semantic search, React web UI, Ink interactive CLI, shared types package

### Changed
- Makefile install targets adjusted for monorepo utility installation
