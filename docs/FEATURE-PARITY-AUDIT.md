# NoizuPromptLingo — Feature Parity Audit

**Date:** 2026-06-21
**Scope:** Current Elixir/Next.js rewrite (`NoizuPromptLingo`) vs deprecated Python build (`NoizuPromptLingo.deprecated`)
**Sources audited:** deprecated `project-management/PRDs` (PRD-001..018), `project-management/user-stories` (151 stories), deprecated `src/npl_mcp` + `tools/`, current `backend/lib/.../domains` + `mcp/` + `frontend/`.

## Legend

| Mark | Meaning |
|------|---------|
| ✅ | Implemented / at parity |
| 🟡 | Partial — exists but reduced scope |
| ❌ | Not present in this build |
| 📋 | Spec'd in a PRD but never implemented (even in deprecated) |
| ☁️✗ | **Cannot cloud-deploy as-is** (needs local FS / browser / git working tree) |

Columns:
- **PRD** — was it specified in a deprecated PRD?
- **Old** — implemented in the deprecated Python build?
- **New** — covered in the current Elixir rewrite?

---

## 1. Core Collaboration Domains (the heart of the product)

| Feature / Tool group | PRD | Old | New | Notes |
|---|---|---|---|---|
| **Artifacts** (create / revise / get / list / list-revisions / get-binary) | PRD-002, 010 | ✅ 6 tools | ✅ 7 tools | At parity. New adds `Artifact_Overview`. |
| **Review system** (create / comment / overlay / get / complete) | PRD-003, 010 | ✅ 5 tools | ✅ 8 tools | New adds `ReviewCompile`, `ReviewAttach`, `Review_Overview`. **Improved.** |
| **Chat** (rooms / messages / members / events / react / notifications / share artifact) | PRD-004, 010 | ✅ 14 tools | ✅ 13 tools | At parity. Old `CreateTodo` folds into `CreateEvent`(todo); attach via `ChatAttach`. |
| **Sessions** (generic work sessions: create/get/list/update/archive/contents) | PRD-004 | ✅ 6 tools (was stubbed in catalog, impl present) | ✅ 6 tools | At parity. |
| **Organizations** (create/get/list/update) | — (new concept) | ❌ | ✅ 5 tools | **New** — multi-tenant org layer didn't exist in deprecated. |
| **Projects** (create/get/list/update) | PRD-018 (DB CRUD) | 🟡 hidden `Proj.Projects.*` | ✅ 5 tools | At parity + promoted to first-class. |

## 2. Task / Ticket / PM Tooling

| Feature / Tool group | PRD | Old | New | Notes |
|---|---|---|---|---|
| **Task queue** (queues, tasks, status, assign, complexity, artifact links, activity feeds) | PRD-005, 010 | ✅ ~13 tools (0% test cov) | ✅ **Tickets** domain (27 tools: CRUD, comment, watch, attach, feed, links, queues, type/field defs) | **Superseded & expanded.** New tri-scoped ticket type/field definitions go well beyond the old flat task queue. |
| **PM MCP tools** (get_story, list_stories, update_story_metadata, get_prd, get_prd_FR, get_prd_AT, get_persona) | PRD-018 | 🟡 hidden `Proj.UserStories/UserPersonas.*` CRUD only; PRD/FR/AT/persona-file accessors = stubs | ❌ | **GAP.** No story/PRD/persona MCP accessors in new build. (Personas/stories tooling lives in the NPL agent/skill layer instead.) |
| **Wiki** (spaces/pages/comments/attachments/reactions) | — | ❌ | ✅ 19 tools | **New** domain, no deprecated equivalent. |

## 3. NPL Convention Engine (the namesake feature)

| Feature / Tool group | PRD | Old | New | Notes |
|---|---|---|---|---|
| **npl_load** (expression-DSL convention loader, layouts, priority filters) | PRD-008, 014, 015 | ✅ | ✅ | At parity (ported from `.old`; `npl.yaml` under `/npl:`). |
| **npl_spec** (generate NPL definition/extension blocks) | PRD-015 | ✅ NPLSpec | ✅ | At parity. |
| **NPL convention corpus** (~317 YAML components: syntax/directives/pumps/prefixes/sections) | PRD-013, 015 | ✅ | ✅ `priv/conventions/npl.yaml` | At parity. |
| **NPL syntax parser / validator** (AST, `npl-syntax validate`, 155+ elements, line/col errors) | PRD-013 | 📋 draft only | ❌ | Never built in either. Frontend has an `npl-conventions` browser, not a validator. |
| **NPL advanced loading extension** (cross-section expressions, coverage report) | PRD-015 | ✅ (loader supports DSL) | 🟡 | Loader ported; verify cross-section subtraction + coverage report parity. |

## 4. Discovery / Meta Tooling

| Feature / Tool group | PRD | Old | New | Notes |
|---|---|---|---|---|
| **Discovery** (ToolSummary / ToolSearch / ToolDefinition / ToolHelp / ToolCall) | PRD-010 | ✅ 5 | ✅ 5 (per server) | At parity, now per-domain server. |
| **Tool sessions** (Generate/lookup session UUID by agent+task) | — | ✅ 2 | ❌ | Old agent-coordination primitive; not ported. |
| **Instructions store** (versioned instruction docs + embeddings/semantic search) | — | ✅ 3+3 | ❌ | **GAP** — no instruction-document store in new build. |
| **Agent input/output pipes** (AgentInputPipe / AgentOutputPipe — agent-to-agent YAML messaging) | PRD-012 | ✅ 2 | ❌ | **GAP** — inter-agent message bus not ported. |

## 5. Agent Ecosystem & Orchestration

| Feature / Tool group | PRD | Old | New | Notes |
|---|---|---|---|---|
| **Agent catalog/loader** (Agent.List / Agent.Load over markdown defs) | PRD-011 | ✅ 2 | ❌ (in MCP) | Agents now live as Claude Code subagents/skills, not an MCP-served registry. |
| **Multi-agent orchestration** (5 patterns, worklog, quality gates) | PRD-012 | 🟡 Orchestration.Trigger/Patterns/Execute/Status (MVP) | ❌ | **GAP** — orchestration engine not ported. |
| **External executors — taskers** (spawn/get/list/touch/dismiss/keep_alive ephemeral taskers) | PRD-009 | ✅ 6 (impl, not exposed) | ❌ | Not ported. (Overlaps with Claude Code Agent tool.) |
| **External executors — Fabric** (apply/analyze/list patterns via fabric CLI) | PRD-009 | ✅ 3 | ❌ ☁️✗ | Not ported; CLI-shell dependent. |

## 6. Browser / Visual Tools — ☁️ deployment-constrained

| Feature / Tool group | PRD | Old | New | Notes |
|---|---|---|---|---|
| **Screenshot capture** (viewport/theme/full-page → base64 PNG) | PRD-006 | ✅ Browser.Capture/Screenshot | ❌ ☁️✗ | Needs headless browser; flagged as non-cloud. |
| **Interactive browser** (navigate/click/fill/get-state/list/close sessions) | PRD-006 | ✅ 6 | ❌ ☁️✗ | Playwright-backed; not portable to cloud MCP. |
| **Visual diff / checkpoints** (diff, checkpoint, list, compare) | PRD-006 | ✅ 5 | ❌ ☁️✗ | Depends on screenshot capture. |
| **Ping / sentinel** (xpath/regex/LLM connectivity check) | PRD-006 | ✅ | ❌ | Could be cloud-deployed (HTTP-only); not ported. |
| **REST client w/ secret injection** | PRD-006 | ✅ Rest | ❌ | Not ported. |
| **Download** (URL/file → dest) | PRD-006 | ✅ | ❌ ☁️✗ | FS-write dependent. |

## 7. Markdown / HTML / File Helpers — ☁️ deployment-constrained

| Feature / Tool group | PRD | Old | New | Notes |
|---|---|---|---|---|
| **HTML/web → Markdown** (to_markdown / 2md / web_to_md, Jina reader) | PRD-017, 008 | ✅ 3 | ❌ | **GAP** (user-flagged). Web→MD is cloud-safe (HTTP); local-file→MD is ☁️✗. |
| **Markdown viewer/filter** (view_markdown / md-view — collapse, heading filter) | PRD-017 | ✅ 2 | ❌ | **GAP** (user-flagged). |
| **Image convert / describe** (image_convert, image_descriptions) | PRD-017 | ✅ | ❌ | Not ported. |
| **dump_files** (aggregate file contents + tree) | PRD-008 | ✅ | ❌ ☁️✗ | Local FS — non-cloud. |
| **git_tree / git_tree_depth** (git-aware dir tree) | PRD-008, 014 | ✅ | ❌ ☁️✗ | **Non-cloud** (user-flagged). Note: new build has a **GitHub** domain (repos/branches/pulls/issues) instead. |
| **git_dump** (repo file dump) | PRD-008 | ✅ | ❌ ☁️✗ | Non-cloud. |

## 8. Skills Tooling

| Feature / Tool group | PRD | Old | New | Notes |
|---|---|---|---|---|
| **Skill validator** (structure/frontmatter/format validation) | PRD-016 | ✅ Skill.Validate | ❌ | **GAP.** |
| **Skill evaluator** (quality scoring, Arize Phoenix, notebook gen) | PRD-016 | ✅ Skill.Evaluate (Arize partial) | ❌ | **GAP.** |

## 9. New Capabilities (no deprecated equivalent)

| Feature / Tool group | New | Notes |
|---|---|---|
| **Assets domain** (media-prompt entries: create/get/update/list/generate/regenerate/set-active/publish/archive/history + outputs accept/reject + request-review) | ✅ 15 tools | Brand-new media-prompt pipeline. ContentGenerator LLM step still a placeholder. |
| **GitHub domain** (repos/branches/pulls/issues + comments/merge) | ✅ 14 tools | Cloud-native replacement for old local git_tree/git_dump. |
| **Organizations + multi-tenant authz** | ✅ | New org/project scoping, MCP API keys, admin console. |
| **Mock MCP** (define mock MCP servers + mock LLMs, call log) | ✅ | Testing harness; no deprecated analog. |
| **Web app** (40+ Next.js routes: dashboards, browsers per domain, admin, styleguide) | ✅ | Far beyond the deprecated FastAPI/Jinja templates (PRD-007). |

---

## Summary — Gaps to triage

### Genuinely missing & cloud-deployable (candidates to port)
1. **HTML/web → Markdown** + **Markdown viewer/filter** (PRD-017) — user-flagged. Web-fetch path is cloud-safe.
2. **PM MCP accessors** (PRD-018) — get_story/list_stories/get_prd/get_prd_FR/get_prd_AT/get_persona. Useful for agents reading the project-management corpus.
3. **Instructions store** (versioned instruction docs + semantic search).
4. **Agent pipes** (AgentInputPipe/AgentOutputPipe) and **tool sessions** — inter-agent coordination primitives.
5. **Skill validator / evaluator** (PRD-016).
6. **Multi-agent orchestration patterns** (PRD-012) — though largely subsumed by Claude Code's own Agent/Workflow tooling.
7. **Ping/sentinel** and **REST-with-secrets** (HTTP-only subset of browser tools).

### Cannot cloud-deploy as-is (☁️✗ — expected gaps, by design)
- Screenshot capture, interactive browser, visual diff/checkpoints (Playwright).
- git_tree / git_dump / dump_files (local working tree) → **replaced by GitHub domain**.
- Fabric CLI, Download-to-FS.

### Never implemented even in deprecated (PRD drafts only)
- NPL syntax parser/validator (PRD-013).
- Most of PRD-010/011/012/014/018 beyond MVP stubs.

### Net assessment
The rewrite **meets or exceeds parity** on the core collaboration product (artifacts, review, chat, sessions, projects, tasks→tickets) and the **NPL engine** (npl_load/npl_spec/corpus). It **adds** Assets, Wiki, GitHub, Organizations, Mock-MCP, and a full web app. The real losses are the **agent-coordination / dev-utility layer** (instructions store, agent pipes, orchestration, skill validation) and the **local-FS / browser utilities** — the latter being intentionally non-cloud.

---

## Resolution status — 2026-06-21 (gap-closing pass)

The audit above slightly under-counted: `instructions` and `personas` were already built
(12 MCP domains, not 9). This pass closed most remaining feasible gaps:

| Gap | Status | Where |
|---|---|---|
| HTML/web → Markdown + Markdown viewer/filter (PRD-017) | ✅ **Done** | new `markdown` MCP domain (`Markdown.Convert`/`View`/`Overview`) — Req fetch + Floki, optional Jina; `markdown.<host>/mcp` |
| Agent pipes (PRD-012) | ✅ **Done** | new `pipes` MCP domain (`Pipe.Output`/`Input`/`Overview`), DB changelog `043-agent-pipes.yaml`; `pipes.<host>/mcp` |
| Instructions store | ✅ Already built | `instructions` domain (pre-existing) |
| PM accessors (get_story/get_prd/get_persona, PRD-018) | ✅ **Folded into tickets** | `user_story` + `prd` global ticket types seeded via `mix tickets.seed`; personas via `personas` domain |
| Local-FS utilities (file search, grep, git_tree, git_dump, dump_files, file_read) | ✅ **Done** | standalone **`local-mcp/`** Node MCP, downloadable as a tarball from the mcp-keys page (`GET /api/v1/config/local-mcp/download`, `make local-mcp-package`) |
| Browser / screenshot / interactive (PRD-006) | 🟡 **In progress** | cloud-relayed: new `browser` cloud domain + local Playwright `browser-controller/` bridged over a Phoenix channel (not intentionally-out anymore — the cloud drives a browser on the user's machine) |
| Skill validator/evaluator (PRD-016) | ⏸ Deferred | skipped this pass per decision |
| Multi-agent orchestration (PRD-012), NPL syntax parser (PRD-013) | ⏸ Out | subsumed by Claude Code Agent/Workflow; parser never built |

Net: the only intentionally-dropped local utilities now have a home (the local MCP), the
markdown/pipes cloud gaps are closed, PM lives in tickets, and browser control is being made
cloud-addressable via a local controller bridge.
