# Handoff: NPL MCP User Story Sprint — Continue Implementation

## Project

`/Users/keithbrings/Github/ai/NoizuPromptLingo` — NPL MCP server + Next.js companion dashboard. FastMCP 3.2.3 backend, Next.js 15 static-export frontend with hybrid mock/REST API client.

## Auto mode is active

Execute autonomously. Launch subagents in parallel for independent work. Target batch size is 3-5 parallel subagents per wave. No planning mode, no confirmation dialogs — just ship.

## State of the world

**Tests**: 933+ passing (`uv run -m pytest tests/ --ignore=tests/test_mcp_server.py -q`). Server runs at `http://127.0.0.1:8765`.

**Frontend routes built**: `/`, `/tools` + `/tools/[name]`, `/npl`, `/npl/elements`, `/sessions` + `/sessions/[uuid]`, `/instructions` + `/instructions/[uuid]`, `/projects` + `/projects/[id]`, `/prds` + `/prds/[id]`, `/docs/[slug]`, `/explorer`, `/skills/validate`, `/markdown`, `/metrics`, `/chat`, `/artifacts`, `/orchestration`, 404.

**16 MCP-visible tools**: NPLSpec, NPLLoad, ToolSummary, ToolSearch, ToolDefinition, ToolHelp, ToolCall, ToolSession.Generate, ToolSession, Instructions, Instructions.Create, Instructions.List, Skill.Validate, Skill.Evaluate, Agent.List, Agent.Load. 27 hidden (browser + PM + instructions + scripts). 87 stubs.

**REST endpoints**: `/api/catalog*`, `/api/sessions*`, `/api/instructions*`, `/api/projects*`, `/api/prds*`, `/api/docs/{slug}`, `/api/npl/elements`, `/api/npl/coverage`, `/api/project/tree`, `/api/project/file`, `/api/skills/validate`, `/api/skills/evaluate`, `/api/stories/{id}` PATCH, `/api/errors`, `/api/browser/to-markdown`.

**Key infrastructure**:
- Hybrid API client at `frontend/lib/api/client.ts` — imports from `./impl/hybrid` which routes most domains to REST, tier-3 (chat/artifacts/orchestration) to mock.
- Catalog architecture: `src/npl_mcp/meta_tools/catalog.py` with `@mcp_discoverable` helper (combines `@mcp.tool` + `@discoverable`, auto-derives tags/meta).
- Migrations in `liquibase/changelogs/` — latest is changeset-009 (tool errors).
- Conventions source of truth: `conventions/*.yaml` (not `npl/`). `npl-docs-regen` console script rebuilds `npl/npl-full.md`.
- CLAUDE.md has NPL loading guidance with DSL examples.

## Immediate cleanup required

Before anything else, **fix one pre-existing TS error** at `frontend/lib/api/client.ts` around line 175 — references an `agents` namespace that doesn't exist in `impl/hybrid.ts` (orphan from incomplete US-221 work). Either remove the orphan reference or add `agents` namespace wiring across `types.ts` / `client.ts` / `impl/mock.ts` / `impl/rest.ts` / `impl/hybrid.ts` — then `cd frontend && node node_modules/typescript/bin/tsc --noEmit` must be clean.

## Three in-flight stories to finish

### US-221 — Agent Metadata Gallery (frontend only; backend already done by US-086)

Backend has `list_agents()`/`get_agent()` in `src/npl_mcp/agents/catalog.py` + MCP tools `Agent.List`/`Agent.Load`. **Backend REST endpoints `/api/agents` and `/api/agents/{name}` need to be added** to `src/npl_mcp/api/router.py`, then:

- `frontend/app/agents/page.tsx` — filter by `kind` (pipeline/utility/executor), grid of cards with name/display_name/kind Badge/description/model/allowed_tools count, link to detail.
- `frontend/app/agents/[name]/page.tsx` — server wrapper with `generateStaticParams` reading the 12 agent filenames (use `fs.readdirSync` on `agents/` at build time).
- `frontend/app/agents/[name]/AgentDetailClient.tsx` — two tabs (Overview + Full Body).
- Add types `AgentInfo` / `AgentDetail` to `frontend/lib/api/types.ts`.
- Add `AgentsAPI` to `client.ts`, wire in rest.ts/mock.ts/hybrid.ts.
- Sidebar link "Agents" under Collab or Ops with `UserGroupIcon`.

### US-120 — Skill Quality Evaluator frontend

Backend already has `/api/skills/evaluate` + `Skill.Evaluate` MCP tool. Types `QualityScore`/`EvaluationResult` added. **Frontend not done.** Edit `frontend/app/skills/validate/page.tsx` to add a "Validate" / "Evaluate" toggle. In Evaluate mode show overall score ring + per-dimension cards + suggestions + validation errors below.

### Health dashboard

Add to `src/npl_mcp/api/router.py`:
- `GET /api/health` with subsystems: server (uptime + fastmcp version), database (SELECT 1 latency), litellm (GET /models ping), catalog (tool counts), frontend_build (dist exists).
- `GET /api/health/ping` — simple liveness.

Then `frontend/app/health/page.tsx` with auto-refresh via SWR `refreshInterval`, subsystem cards with status Badges. Sidebar "Health" under Ops with `HeartIcon`.

## Then continue the backlog

After the three above are green, pick up more Tier-A/B stories from the survey. Already deferred (Tier C) are blocked by unbuilt modules (chat, artifacts, tasks, executors). Good candidates for next:

- **US-226** — Read user story by id (backend already has it — just add a standalone page `/stories/[id]`).
- **US-220** — NPL syntax validation CLI (extend skill validator to run on arbitrary prompt files).
- **US-222** — NPL IDE syntax highlighting (generate a tmLanguage JSON from conventions/).
- **US-224** — Skip-loaded-resources flag for NPLLoad (add to expression DSL).
- **US-091 / US-095** — Web content programmatic extract and fabric pattern analysis (wrapper around ToMarkdown + LLM post-processing).
- **US-225** — Cross-agent worklog communication (add `notes` append endpoint for sessions).
- **US-223 extensions** — hyperlink from `/npl/elements` table rows to `/npl?expr=section#name`.

Tier-C candidates to unlock by implementing the smallest parts of stub modules:

- **scripts/** is already done.
- **sessions/** (generic, distinct from `tool_sessions/`) — if it only needs a basic session-lifecycle tool, could be small.
- **tasks/** — task queue. Small MVP: just `Tasks.Create`, `Tasks.Get`, `Tasks.List`, `Tasks.UpdateStatus`. One migration for `npl_tasks` table. That unblocks ~9 stories.
- **artifacts/** — similar scope: `Artifact.Create`, `Artifact.Get`, `Artifact.ListRevisions`. Blocks 8 stories.

## How to work

1. **Never** launch a single subagent when two can run in parallel. Every wave = 3-5 subagents.
2. For each user story, a single subagent should own the whole vertical: migration (if any) + backend endpoint + MCP tool (if applicable) + frontend types + API wiring + page + tests. Don't split the vertical across agents — they conflict.
3. Subagents receive **self-contained prompts** with: context (what's in the codebase), exact files to edit, exact test assertions, verification commands. Give them everything; don't assume they'll re-discover it.
4. After each wave: `cd /Users/keithbrings/Github/ai/NoizuPromptLingo && uv run -m pytest tests/ --ignore=tests/test_mcp_server.py -q 2>&1 | tail -3` — must pass. Then `cd frontend && node node_modules/typescript/bin/tsc --noEmit` — must be clean. Then `node node_modules/next/dist/bin/next build 2>&1 | tail -5` — must build.
5. If a subagent permission-prompt interrupts, treat that as a soft stop — move on to other parallel work and retry with a more focused scope.
6. Use `TaskCreate` + `TaskUpdate` religiously. Mark `in_progress` before spawning, `completed` only after tests green.

## Key conventions and gotchas

- **Node 25 bug**: `npm run build` and `npx tsc` fail via the `.bin/` shim. Always call `node node_modules/typescript/bin/tsc --noEmit` and `node node_modules/next/dist/bin/next build` directly from `frontend/`.
- **Path alias**: `@/*` resolves to `frontend/*`.
- **Primitives are NAMED exports**: `import { Card, Badge, DataTable, PageHeader, Tag, CodeBlock, EmptyState, SearchBox, FilterListbox, Skeleton } from "@/components/primitives/..."` — never default imports.
- **Every interactive page is `"use client"`**. Next.js static export requires it.
- **Dynamic routes under `output: 'export'`** need `generateStaticParams` in a server wrapper + a client component sibling that uses `useParams`.
- **Frontend expects same-origin `/api/*`** but the rest.ts has a `BASE` constant switching to `http://127.0.0.1:8765` when running on port 3000 (dev). Don't break that.
- **Shared utilities**: `relativeTime`, `formatNumber`, `truncate` from `@/lib/utils/format`. `kindVariant` from `@/lib/utils/badges`. Don't re-implement.
- **Python tests** are mock-based — DB is never real. Use `patch("npl_mcp.storage.pool.get_pool")` to return `AsyncMock`.
- **`EXPECTED_MCP_TOOL_NAMES`** is duplicated in `tests/test_catalog_migration.py`, `tests/test_meta_tools.py` (set in `TestMCPRegistration`), and `tests/test_mcp_server.py`. When adding an MCP tool, update **all three**.
- **Liquibase changelogs**: chain new migrations in `liquibase/changelogs/changelog.yaml` as `include: file: changeset-NNN.description.yaml`. Next number is 010.
- **MCP tool registration**: use `@mcp_discoverable(mcp, name=..., category=..., description=...)` in `launcher.py`. Don't stack `@mcp.tool` + `@discoverable` manually — the helper does both.
- **Server restarts**: after changing Python code, the user restarts manually. Don't `kill` processes. Verify via `uv run npl-mcp --status`.

## Don't

- Don't touch `wip/` — it was deleted. Don't re-create it.
- Don't switch frontend to `output: 'standalone'` mode.
- Don't add authentication — this is a local dashboard.
- Don't replace our custom catalog with `AggregateProvider` — our three-tier merge + hidden-but-callable semantic has no 3.x equivalent.
- Don't write to `conventions/` without running `uv run npl-docs-regen` afterwards.
- Don't delete stub pages (`/chat`, `/artifacts`, `/orchestration`) — they have "coming soon" banners and prove the IA.

## Verification ritual after every wave

```bash
cd /Users/keithbrings/Github/ai/NoizuPromptLingo
uv run -m pytest tests/ --ignore=tests/test_mcp_server.py -q 2>&1 | tail -3
cd frontend
node node_modules/typescript/bin/tsc --noEmit
node node_modules/next/dist/bin/next build 2>&1 | tail -5
```

All three green ≡ ship.

## Session goal

Implement as many user stories as possible. Aim for 15-20 stories landed end-of-day, with full backend + frontend + tests for each.
