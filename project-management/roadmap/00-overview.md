# NoizuPromptLingo Roadmap — Overview

## Mission

NoizuPromptLingo (NPL) is a full-stack collaboration platform for humans and autonomous
coding agents working side by side: an Elixir/Phoenix backend exposing MCP servers
(`tobor-sessions`, `tobor-organizations`, and the tool-discovery surface) plus a Next.js 16
web app, unified by org/session-scoped identity. This roadmap sequences the delivery of all
104 user stories in **dependency order, not calendar time** — every milestone states only what
must already be true before it starts and what must be verifiably true before it exits. No
dates, durations, or estimates appear anywhere in this document set; wall-clock time is an
emergent property of how many worker lanes run in parallel, never an input to the plan.

The sequence runs from the identity/auth/session substrate every request depends on (M0),
through the core collaboration primitives (M1) and the knowledge/memory/review layer (M2),
into platform governance and provider configuration (M3), then the growth studio and discovery
surfaces that build on a configured platform (M4), and finally the cross-cutting hardening that
makes every prior feature resilient, accessible, performant, and integration-reachable (M5).

## Core principles

1. **Sequence, not schedule.** M0→M5 is a strict dependency ordering. The only temporal claims
   allowed are entry gates ("what must already be merged") and exit gates ("what must be
   verifiably true"). No dates or estimates.
2. **Parallel lanes, exclusive ownership.** Each milestone decomposes into worker lanes; a lane
   owns an exclusive set of file-path globs and no two lanes in the same milestone edit the same
   file. Anything a lane needs from a sibling is a **contract** fixed at milestone entry or a
   change-request to the owning lane.
3. **Contract-first entry.** Every milestone opens with a thin `LK.A` contracts lane that
   freezes the milestone's data model (Ecto migrations), API/MCP tool specs, and the `data-cy`
   selector schema *before* implementation lanes start — so backend, frontend, and QA build
   concurrently against stubs instead of waiting on each other.
4. **Vertical feature lanes.** NPL's backend is domain-per-directory
   (`backend/lib/noizu_prompt_lingua/domains/<domain>/`) and its frontend is route-per-area
   (`frontend/src/app/<area>/`), so most lanes own a full-stack vertical slice — one domain's
   backend dir plus its frontend route namespace plus its own tests. Cross-cutting milestones
   (M5) cut by concern (security, accessibility, performance, integration) instead.
5. **Interface-first tests.** E2E specs are keyed to the frozen `data-cy` selector schema from
   `LK.A` and are written against the API stub *before* the frontend they exercise exists — the
   test lane never waits on the UI lane.
6. **MoSCoW orders work within a lane, not across milestones.** Musts land before shoulds and
   coulds *inside* a lane's task list; but some must-haves (search, PBAC, accessibility) land in
   a late milestone anyway because they depend on substrate that doesn't exist yet.
7. **Traceability.** Every one of the 104 user stories is assigned to exactly one primary
   milestone and lane. Where a second lane materially supports a story that is noted as
   "supports US-XXX", never claimed as a second primary owner.

## Milestone summary

| ID | Name | Mission | Lanes | Stories |
|---|---|---|---|---|
| M0 | Foundation: Identity, Auth & Session Scoping | Org registration, OIDC/SSO login, MCP API-key and Guardian-JWT plumbing, and the org/project-scoped work session every action hangs off. | 5 | 15 |
| M1 | Collaboration Core: Tickets & Rooms | The daily-driver workspace primitives — kanban tickets/boards with custom fields, and chat rooms with threads, notifications, and realtime delivery. | 4 | 16 |
| M2 | Knowledge, Memory & Review | The durable-content layer — agent personas with journals and semantic memory recall, plus wiki, code review, GitHub, and pub/sub. | 4 | 17 |
| M3 | Platform Governance, Roles & Providers | Configuring and governing the platform — custom roles, MCP custom scopes, LLM and media provider config, PBAC policy simulation, and admin/audit operations. | 4 | 18 |
| M4 | Growth Studio & Discovery | Applied productivity on the configured platform — the campaign/creative-asset studio and the tool/glyph/wiki discovery surface. | 4 | 16 |
| M5 | Hardening & Reach: Resilience, Access, Scale & Integrations | Cross-cutting quality over everything already built — auth/error edge cases, accessibility and i18n, performance at scale, and external integrations. | 5 | 22 |

Story count check: M0=15, M1=16, M2=17, M3=18, M4=16, M5=22 → 104, matching the story corpus
exactly. See [`story-coverage.md`](story-coverage.md) for the full per-story traceability matrix.

Milestone docs: [`01-M0-foundation.md`](01-M0-foundation.md) ·
[`02-M1-collaboration-core.md`](02-M1-collaboration-core.md) ·
[`03-M2-knowledge-memory-review.md`](03-M2-knowledge-memory-review.md) ·
[`04-M3-governance-roles-providers.md`](04-M3-governance-roles-providers.md) ·
[`05-M4-growth-studio-discovery.md`](05-M4-growth-studio-discovery.md) ·
[`06-M5-hardening-reach.md`](06-M5-hardening-reach.md)

## How to read this roadmap

1. Open your milestone's doc and read its **Entry criteria** — every gate it lists must already
   be satisfied (the prior milestone's exit criteria, plus any named contracts merged).
2. Find your lane under **Worker lanes**. Its **Zone / exclusive paths** line is the only code
   you may edit; consume sibling lanes only through the milestone's frozen **Contracts**.
3. Work your lane's task list in priority order — musts (`M`) before shoulds (`S`) and coulds
   (`C`). Tasks tagged `[contract]` block sibling lanes and land first.
4. A milestone is not "done" from one lane's view — exit requires every lane's exit criteria
   *plus* the milestone's cross-lane integration task merged green.

## Traceability

Every user story is assigned to exactly one primary milestone/lane; a small number carry a
"supports US-XXX" note where a second lane materially contributes. The full matrix — story,
title, priority, epic, milestone, lane — plus an epic→milestone summary lives in
[`story-coverage.md`](story-coverage.md).
