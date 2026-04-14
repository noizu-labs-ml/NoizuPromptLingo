# Project Status

> Last updated: 2026-04-14 | Branch: `take-2`

## Executive Summary

NPL MCP is a Model Context Protocol server with a meta-tool discovery pattern, an NPL syntax definition system, and a TDD agent orchestration pipeline. The **server core**, **PM tools**, **instructions**, **browser tools**, and **NPL convention system** are implemented and tested. Six modules (chat, tasks, artifacts, executors, sessions, scripts) are defined as stub catalog entries with PRD specs but no implementation yet — `.pyc` files in those directories are worktree build artifacts, not lost source. The frontend is a placeholder landing page. Server is on **FastMCP 3.2.3** (migrated from 2.14.4).

**By the numbers:**
- 11 MCP-visible tools, 22 hidden tools, 92 stub tools (125 catalog)
- 952 test functions across 26 test files (842 currently pass, 80% coverage)
- 17 PRDs (9 indexed, 8 unindexed), 138 user stories (131 draft, 7 documented)
- 5 personas, 12 agent definitions

---

## Work Threads

### 1. MCP Server Core

**Status: Complete**

The server backbone is fully operational:
- `launcher.py`: `create_app()` + `create_asgi_app()`, CLI with `--host/--port/--status/--reload/--no-frontend`, PID-based singleton, Uvicorn hosting
- Meta-tool discovery: 5 tools (ToolSummary, ToolSearch, ToolDefinition, ToolHelp, ToolCall) with static catalog merging MCP-registered, hidden, and stub tools
- SSE transport via FastMCP 2.x, FastAPI middleware for frontend serving
- PostgreSQL async pool (asyncpg, localhost:5111), Liquibase migrations (8 changesets)
- LiteLLM proxy integration for intent search and image descriptions

**Tests**: `test_mcp_server.py` (6), `test_meta_tools.py` (87), `test_tool_registry.py` (21) = **114 tests**

**No remaining work** for the current architecture. Migration to FastMCP 3.x is an open question (see Thread 9).

---

### 2. NPL Definition System

**Status: Functional, two parallel systems**

Two independent formatters exist for rendering NPL syntax definitions from YAML convention files:

#### Convention Formatter (older, richer)
- `convention_formatter.py` + `conventions/*.yaml` (8 YAML files)
- `ConventionFormatter.format_convention()`: category grouping, syntax rendering, fenced/XML examples, concise/verbose modes, heading offsets, greedy minimal example set cover
- `NPLDefinition.format()`: wraps output in `⌜NPL@{version}⌝...⌞NPL@{version}⌟` markers, resolves transitive `require` dependencies, supports extension blocks
- YAML schema: `name`, `title`, `brief`, `description`, `purpose`, `categories[]`, `components[]` with `syntax[]`, `examples[]`, `require[]`, `priority`
- Exposed as `NPLSpec` MCP tool (MCP-visible)

#### NPL Module (newer, simpler)
- `src/npl_mcp/npl/` (parser, resolver, loader, layout) reading from `npl/*.yaml`
- Expression DSL: `syntax#placeholder:+2 -pumps` — space-separated terms, `section[#component][:+N]`, `-` to subtract
- 8 sections: syntax, declarations, directives, prefixes, prompt-sections, special-sections, pumps, fences
- 3 layout strategies: YAML_ORDER (flat), CLASSIC (grouped by first label), GROUPED (by section type)
- `load_npl(expression, npl_dir, layout, include_instructional)` → markdown string

#### Static Spec
- `npl/npl-full.md`: 1,777-line pre-rendered full NPL specification

**Tests**: `test_npl_loading.py` (88 tests) — covers the convention formatter path

**Remaining work:**
- [ ] Test coverage for `npl/` module (parser, resolver, loader, layout) — 0 tests today
- [ ] Clarify relationship between the two systems — consolidate or document distinct use cases
- [ ] `include_instructional` parameter in `load_npl()` is stubbed ("reserved for future use")
- [ ] Verify `npl/*.yaml` files match the schema expected by the `npl/` resolver (may differ from `conventions/*.yaml` schema)

---

### 3. Browser Tools

**Status: Complete (6 hidden tools)**

| Tool | File | Description |
|------|------|-------------|
| ToMarkdown | `to_markdown.py` (187L) | HTML→markdown via Playwright + httpx/BeautifulSoup fallback. Chains converter → image descriptions → viewer |
| Ping | `ping.py` (110L) | HTTP check with xpath/regex/LLM sentinel validation |
| Download | `download.py` | URL + local file copy |
| Screenshot | `screenshot.py` (110L) | Playwright browser screenshot |
| Rest | `rest.py` (152L) | HTTP client (GET/POST/PUT/PATCH/DELETE/HEAD/OPTIONS) with `${secret.NAME}` placeholder resolution, 1MB input / 2MB response limits |
| Secret | `secrets.py` (111L) | Secret store via PostgreSQL |

**Tests**: `test_ping.py` (35), `test_download.py` (16), `test_screenshot.py` (16), `test_rest.py` (25), `test_secrets.py` (25), `test_to_markdown.py` (28), `test_to_markdown_strip.py` (28) = **173 tests**

**Remaining work:**
- [ ] 32 browser stub tools across 8 subcategories (Screenshots, Navigation, Input, Query, Session, Wait, Inject, Storage) — these require Playwright implementation
- [ ] PRD-006 flagged as "implemented, untested" in index — but 173 tests exist; reconcile PRD coverage metadata

---

### 4. Markdown Tools

**Status: Partial — core working, 5 gaps**

#### Working
| Component | File | Description |
|-----------|------|-------------|
| Converter | `converter.py` (367L) | URL (Jina SSE + html2text fallback), HTML file (html2text), PDF (Jina API + pdfplumber fallback), plain text/markdown passthrough |
| Viewer | `viewer.py` (205L) | Heading-based section filtering, bare/context modes, section collapsing with 📦 markers |
| Cache | `cache.py` (100L) | In-memory + disk cache. URLs: `.tmp/cache/markdown/` with 1hr TTL. Local: sibling file, no expiry. `force_refresh` and `no_cache` flags |
| Heading Filter | `filters/heading.py` (308L) | Case-insensitive name match, kebab-case normalization, h1-h6 level selectors, `>` path traversal, `*` wildcard, recursive nested search |
| Image Descriptions | `image_descriptions.py` (149L) | `![alt](uri)` parsing, parallel LLM description via multimodal API, YAML cache at `.tmp/cache/image_descriptions.yaml` |

#### Gaps (NotImplementedError)
| Gap | Location | Notes |
|-----|----------|-------|
| CSS selector filter | `filters/css.py` (23L) | "Phase 2" — markdown → HTML → CSS select → markdown |
| XPath filter | `filters/xpath.py` (23L) | "Phase 2" — markdown → HTML → XPath → markdown |
| Jina HTML file conversion | `converter.py` | No public URL support for local HTML files via Jina |
| DOCX conversion | `converter.py` | "Coming soon" |
| Image conversion | `converter.py` | "Will use vision API" |

**Tests**: `test_markdown_converter.py` (58), `test_markdown_viewer.py` (59), `test_markdown_cache.py` (31), `test_heading_filter.py` (37), `test_markdown_viewer_assets.py` (9), `test_asset_filter_nihilism.py` (16) = **210 tests**

**Remaining work:**
- [ ] Implement CSS and XPath filters (Phase 2)
- [ ] DOCX conversion backend
- [ ] Image-to-markdown via vision API
- [ ] Jina HTML file conversion path
- [ ] `fallback_parser` defaults to `False` — Jina-only mode returns empty string on Jina failure without fallback

---

### 5. Project Management Tools

**Status: Complete (13 DB-backed hidden tools + 8 file-based stubs)**

#### DB-Backed CRUD (implemented)
| Domain | Tools | Operations |
|--------|-------|------------|
| Projects | 3 | Create, Get, List (no update/delete — immutable) |
| UserPersonas | 5 | Create, Get, Update, Delete (soft), List — JSONB demographics |
| UserStories | 5 | Create, Get, Update, Delete (soft), List — filters: persona, status, priority, tags |

Statuses: draft → ready → in_progress → done → archived. Short UUIDs via `shortuuid`.

#### File-Based Tools (implemented)
| Tool | Operations |
|------|------------|
| PRDs | `get_prd`, `get_prd_functional_requirement`, `get_prd_acceptance_test` — reads from markdown + YAML index |
| Stories | `get_story`, `list_stories`, `update_story_metadata` — reads from index.yaml + markdown files |
| Personas | `get_persona`, `list_personas` — parses goals/pain_points/behaviors/demographics from markdown |

#### File-Based Stubs (8 in stub catalog)
Planned but unimplemented file-based PM tools in the stub catalog.

**Tests**: `test_pm_mcp_tools.py` (103), `test_db_stories.py` (31), `test_db_personas.py` (19), `test_db_projects.py` (12), `test_projects.py` (8) = **173 tests**

**Remaining work:**
- [ ] Project update/delete operations (currently immutable)
- [ ] 8 file-based PM stub tools
- [ ] PRD index.yaml is stale — only tracks PRDs 001–009, missing 010–017
- [ ] PRD-017 naming conflict: two directories (`PRD-017-markdown-tools`, `PRD-017-pm-mcp-tools`)
- [ ] 131/138 user stories stuck in `draft` — need triage to reflect actual implementation status

---

### 6. Instructions System

**Status: Complete (3 MCP-visible + 3 hidden tools)**

| Tool | Visibility | Description |
|------|-----------|-------------|
| Instructions | MCP-visible | Get instruction by UUID + optional version. Returns markdown or full JSON |
| Instructions.Create | MCP-visible | Create with title, description, tags, body → v1 + triggers embedding pipeline |
| Instructions.List | MCP-visible | Search by text (ILIKE), intent (cosine similarity via pgvector), or both. Tag filtering |
| Instructions.Update | Hidden | Increment version, re-embed. Change note required |
| Instructions.ActiveVersion | Hidden | Rollback/forward to any version |
| Instructions.Versions | Hidden | List all versions with change notes |

Embedding pipeline: LLM extracts 3-5 descriptive phrases → batch embed → stored in `npl_instruction_embeddings` (pgvector). Best-effort, non-blocking.

**Tests**: `test_instructions.py` (43), `test_instruction_embeddings.py` (14) = **57 tests**

**No remaining work.** Fully implemented.

---

### 7. Tool Sessions

**Status: Complete (2 MCP-visible tools)**

| Tool | Description |
|------|-------------|
| ToolSession.Generate | Upsert by (project, agent, task) triple. Supports parent hierarchy, notes append |
| ToolSession | Retrieve by UUID. Verbose mode adds task, notes, parent, timestamps |

**Tests**: `test_tool_sessions.py` (18)

**No remaining work.** Fully implemented.

---

### 8. Stub Modules (Not Yet Implemented)

Six modules exist only as stub tool definitions in the catalog — discoverable but not callable. PRD specs exist for all of them. The `.pyc` files in these directories are build artifacts from other branch worktrees (not lost source code from this branch).

| Module | PRD | Stub Tools | Scope |
|--------|-----|------------|-------|
| `artifacts/` | PRD-002, PRD-003 | 11 | Versioned artifact CRUD + review/annotation workflows |
| `chat/` | PRD-004 | 8 | Event-sourced chat rooms, messaging, reactions, todos |
| `tasks/` | PRD-005 | 13 | Task queues, statuses, priorities, activity feeds |
| `executors/` | PRD-009 | 11 | Ephemeral agent lifecycle, fabric pattern analysis |
| `sessions/` | PRD-004 | 4 | Session lifecycle for grouping rooms + artifacts |
| `scripts/` | PRD-008 | 5 | Shell wrappers: dump_files, git_tree, npl_load |

**Total: 52 stub tools across 6 modules — all need to be built from PRD specs.**

**Remaining work:**
- [ ] Prioritize which modules to implement first based on actual usage needs
- [ ] PRD coverage metadata for these modules is fictional — reset to 0%
- [ ] Clean up stale `.pyc` files from worktree bleed

---

### 9. FastMCP Version

**Status: Migrated to 3.x**

Main runs on FastMCP `>=3.0.0,<4.0.0` (installed: 3.2.3). The migration:
- `catalog.py`: `get_tools()` → `list_tools()` (one-line change)
- Tests updated: 7 tests in `test_meta_tools.py` that accessed the removed `_tool_manager._tools` private API now use the public `await mcp.get_tool(name)` / `await mcp.list_tools()`
- All 842 tests still pass, coverage unchanged at 80%, catalog.py at 92%

The `wip/` directory (a 3.x compatibility spike) was removed after migration — it was a strict subset of main. No outstanding work on transport/API migration.

---

### 10. Frontend / Website

**Status: Placeholder**

#### Next.js App (`frontend/`)
- Next.js 15.1.6, React 19, Tailwind 3.4.17, TypeScript 5
- Static export (`output: 'export'`) → builds to `src/npl_mcp/web/static/`
- Single page: hero section, 3 feature cards (MCP Tools, Chat Rooms, Artifacts), fake terminal window
- No routing, no API calls, no state, no interactive components
- ESLint and TypeScript errors suppressed during build

#### GitHub Pages (`gh-pages`)
- Git submodule — contains only `<h1>Pages</h1>`

**Remaining work:**
- [ ] PRD-007 (Web Interface) spec exists but 0% implemented
- [ ] Decide scope: dashboard for sessions/tools/instructions? Or keep as documentation site?
- [ ] gh-pages: build out or remove submodule

---

### 11. Agent Orchestration & TDD Pipeline

**Status: Defined, not programmatically integrated**

12 agent definitions in `agents/` (mirrored in `.claude/agents/`):

| Agent | Purpose | Type |
|-------|---------|------|
| npl-idea-to-spec | Feature ideas → personas + user stories | Pipeline |
| npl-prd-editor | User stories → PRD documents | Pipeline |
| npl-tdd-tester | PRD → test suites | Pipeline |
| npl-tdd-coder | Test suites → implementation | Pipeline |
| npl-tdd-debugger | Test failures → root cause analysis | Pipeline |
| npl-winnower | Response quality filtering | Utility |
| npl-technical-writer | Documentation generation | Utility |
| npl-tasker-haiku | Simple lookups (cheapest) | Executor |
| npl-tasker-fast | Moderate tasks (fastest) | Executor |
| npl-tasker-sonnet | Balanced complexity | Executor |
| npl-tasker-opus | Complex analysis (expensive) | Executor |
| npl-tasker-ultra | Opus-level, faster inference | Executor |

These agents are Claude Code agent definitions (markdown specs). They work via Claude Code's agent spawning, not via programmatic MCP orchestration.

**Remaining work:**
- [ ] PRD-011 (Agent Ecosystem): 0/45 agents loadable programmatically
- [ ] PRD-012 (Multi-Agent Orchestration): 0/5 orchestration patterns implemented as MCP tools
- [ ] PRD-009 (External Executors): implementation exists as pyc but no MCP tool exposure

---

### 12. Planning & Project Management Corpus

**Status: Substantial but stale**

#### PRDs

| Generation | PRDs | Status | Notes |
|-----------|------|--------|-------|
| Gen 1 (001–009) | 9 | `documented` in index | Structured dirs with README + FRs + ATs |
| Gen 2 (010–017) | 8 | Not indexed | Markdown specs only, no subdirectory structure |

Coverage metadata from `index.yaml` (may be stale):

| PRD | Title | Claimed Coverage |
|-----|-------|-----------------|
| PRD-001 | Database Infrastructure | 82% |
| PRD-002 | Artifact Management | 53% |
| PRD-003 | Review System | 25% |
| PRD-004 | Chat and Session Management | 78% |
| PRD-005 | Task Queue System | 0% |
| PRD-006 | Browser Automation | null |
| PRD-007 | Web Interface | 0% |
| PRD-008 | NPL Script Wrappers | 0% |
| PRD-009 | External Executors | null |

PRDs 002–005 and 008–009 claim coverage for modules that have no source files — metadata is unreliable.

#### User Stories
- 138 total, 131 `draft`, 7 `documented`
- Grouped by `prd_group` (npl_load, chat, browser, etc.)
- All linked to personas and related stories

#### Personas
5 defined: AI Agent (P-001), Product Manager (P-002), Vibe Coder (P-003), Project Manager (P-004), Dave the Developer (P-005)

**Remaining work:**
- [ ] Add PRDs 010–017 to `index.yaml`
- [ ] Resolve PRD-017 naming conflict
- [ ] Triage user stories — update statuses to reflect implementation reality
- [ ] Reconcile coverage metadata with actual test results
- [ ] index.yaml `total_prds` says 9, actual is 17

---

## Test Inventory

937 test functions across 25 files. No coverage thresholds configured despite `pytest-cov` being a dependency.

| Module Area | Test Files | Test Count |
|-------------|-----------|------------|
| PM Tools | test_pm_mcp_tools, test_db_stories, test_db_personas, test_db_projects, test_projects | 173 |
| Browser | test_ping, test_download, test_screenshot, test_rest, test_secrets, test_to_markdown, test_to_markdown_strip | 173 |
| Markdown | test_markdown_converter, test_markdown_viewer, test_markdown_cache, test_heading_filter, test_markdown_viewer_assets, test_asset_filter_nihilism | 210 |
| Meta Tools | test_meta_tools, test_tool_registry | 108 |
| NPL | test_npl_loading | 88 |
| Instructions | test_instructions, test_instruction_embeddings | 57 |
| Sessions | test_tool_sessions | 18 |
| Server | test_mcp_server | 6 |
| **Total** | **25 files** | **937** |

**Gaps**: No tests for `npl/` module (parser/resolver/loader/layout), no integration tests for end-to-end tool flows, no tests for stub modules (by definition).

---

## Infrastructure

| Service | Port | Status |
|---------|------|--------|
| NPL MCP Server | 8765 | Working |
| LiteLLM Proxy | 4111 | Required for intent search + image descriptions |
| PostgreSQL | 5111 | Working, 8 Liquibase changesets applied |

Database schema covers: sessions, tool sessions, projects, personas, stories, instructions, instruction embeddings, secrets. All managed via Liquibase YAML changelogs.

---

## Prioritized Remaining Work

### Tier 1: Housekeeping (low effort, high value)
1. Add PRDs 010–017 to `index.yaml`, resolve PRD-017 naming conflict
2. Triage 131 draft user stories — mark implemented ones as `done`
3. Reconcile PRD coverage metadata with actual test results
4. Configure pytest-cov thresholds (target: 80% new code, 100% critical paths)

### Tier 2: Testing gaps (medium effort)
5. Write test suite for `npl/` module (parser, resolver, loader, layout)
6. Run actual coverage report and identify lowest-coverage implemented modules
7. Add integration tests for end-to-end tool call flows

### Tier 3: Feature gaps in implemented modules (medium effort)
8. Markdown CSS and XPath filters (Phase 2)
9. Markdown DOCX conversion backend
10. Markdown image-to-markdown via vision API
11. Project update/delete operations

### Tier 4: Architecture decisions (blocking)
12. ~~**FastMCP 3.x migration**: Evaluate `wip/` experiment, decide migrate or stay~~ — **Done (2026-04-14)**: migrated to 3.2.3, `wip/` removed
13. **Stub module prioritization**: Decide which of the 6 unbuilt modules to tackle first (and whether all 52 stub tools are still wanted)
14. **Frontend scope**: Dashboard app vs documentation site vs remove placeholder
15. **NPL formatter consolidation**: Two parallel systems — merge the expression DSL into the convention formatter or document distinct use cases

### Tier 5: Major new features (high effort)
16. Implement stub modules: chat, tasks, artifacts (PRDs 002–005)
17. Implement executors with MCP exposure (PRD-009)
18. Build web interface (PRD-007)
19. Programmatic agent orchestration (PRDs 011–012)
20. NPL syntax parser for validation/IDE support (PRD-013)
21. CLI utilities (PRD-014)
