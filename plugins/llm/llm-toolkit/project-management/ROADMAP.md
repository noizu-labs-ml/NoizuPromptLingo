# Claude Assist — Product Roadmap

Phased roadmap derived from the epic × priority matrix in [user-stories/index.yaml](user-stories/index.yaml) (100 stories, 18 epics) and the outstanding items in [design/README.md](../design/README.md). No calendar dates — phases are ordered by dependency and priority (must-have gaps first, then should-have depth, then exploratory/could-have).

---

## Shipped (m1 → m3)

The tool is already a working end-to-end product, not a prototype. Per [CHANGELOG.md](../CHANGELOG.md):

| Milestone | Delivered |
|---|---|
| `m1-subtree-import` | Core import: Hono API, SQLite + FTS5 + semantic search (sqlite-vec/MiniLM), React web UI (10 pages), Ink CLI, shared types |
| `m2-thread-editing-and-operations` | Non-destructive thread editing (collapse/remove/reorder/inject), conversation operations (clone/rehome/archive/tag), LLM API-key resolution chain |
| `m3-tui-and-provider-config` | Full TUI (Explore, Safety Watch, Style Guide, session-continue), custom LLM provider config, `--interface web\|tui` selection |

**Functionally present today:** indexing & ingestion, search (FTS5 + semantic), thread viewer, thread editing, convert wizard (backend + page), datasets (CRUD + export), conversation operations, CLI + TUI, provider config, skill-manage (core: catalog/enable/batch-enable).

**Not yet started:** onboarding/first-run flow, accessibility work, most edge-case/error-state handling, performance-at-scale validation, skill-manage audit tooling.

---

## Phase m4 — Onboarding & Reliability

**Goal:** Close every remaining must-have gap that blocks a safe first run or breaks under real-world scale/malformed data. This is the "make it safe to hand to someone else" phase.

| Epic | Story range | Priority mix |
|---|---|---|
| Onboarding & Install | US-001–009 | 4 must, 4 should, 1 could |
| Edge Cases & Error States | US-081–087 | 2 must, 4 should, 1 could |
| Performance & Scale | US-080, US-097–100 | 2 must, 2 should, 1 could |
| Accessibility & i18n | US-037–040, US-058 | 1 must, 2 should, 2 could |

**Exit criteria:**
- First-run indexing wizard, CLI `init`, embedding-model setup, and post-install health check shipped (US-001, 002, 006, 007)
- Malformed JSONL and locked/corrupted index handled without crashing (US-014, US-081)
- Large-history indexing is non-blocking; semantic search latency validated against a realistic corpus size (US-080, US-097)
- Full keyboard navigation in the thread viewer (US-037)
- Design debt item #4 (accessibility audit) complete — this is a **gate**, not parallel work; contrast/keyboard fixes from the audit feed directly into US-037/038

**Sizing:** L (4 epics, foundational)
**Risks / dependencies:** needs a realistic large-corpus test fixture to validate US-080/097 meaningfully; accessibility audit must land before US-037/038 can be called done rather than guessed at.

---

## Phase m5 — Feature Depth & Admin Maturity

**Goal:** Turn already-shipped features from "works" into "polished." This is should-have depth layered onto the m1–m3 core — no new epics, just rounding out existing ones.

| Epic | Story range | Focus |
|---|---|---|
| Datasets | US-056 | Quality-breakdown visibility |
| Convert | US-048 + design debt #5 | AI-suggested candidates, Convert/Edit/Merge mockups |
| Search & Discovery | US-024–027 | Role/date filters, mode-toggle guidance, similarity scores |
| Thread Viewer | US-031, 034, 036 | Mermaid, thinking-block collapse, jump-to-message |
| Thread Editing | US-043, 044, 046 | Reorder, inject, version history/diff |
| Conversation Operations | US-064, 065, 068, 069 | Archive/restore, merge export, delete confirmation |
| Settings & LLM Provider Config | US-018, 020 | Embedding model switch, connectivity validation |
| Admin & Oversight | US-071, 074, 075 | Sort by activity, secret spot-check, conversion tracking |
| CLI (Ink) | US-060 | JSON output for scripting |
| skill-manage (core) | US-079 | Batch-enable skill bundles |

**Exit criteria:** each listed should-have story shipped or explicitly deferred with a written reason; design debt items #3 (Ink component sketches) and #5 (Convert/Edit/Merge mockups) closed out to unblock remaining UI polish.

**Sizing:** L (broadest surface area of any phase — 10 epics, all incremental)
**Risks / dependencies:** if velocity is low, split into per-epic sub-milestones rather than one m5 tag; US-036 (jump-to-message) benefits from virtualized rendering (US-099, m4) landing first so it's built against the final rendering path, not a throwaway one.

---

## Phase m6 — skill-manage Audit & Observability

**Goal:** Net-new capability (not polish) for multi-provider tinkerers: drift detection and context-budget visibility across skill/agent/command catalogs.

| Epic | Story range | Priority mix |
|---|---|---|
| skill-manage (audit) | US-094–096 | 2 must, 1 should |

**Exit criteria:** symlink-drift audit (US-094) and context-budget report (US-095) shipped; TUI provider-comparison view (US-096) at least prototyped.

**Sizing:** M
**Risks / dependencies:** depends on skill-manage core (already shipped) remaining stable underneath; needs test fixtures spanning multiple provider catalogs (Claude + at least one other) to validate drift detection meaningfully.

---

## Phase m7 — Integration Hardening & Exploratory

**Goal:** Harden the API surface for safety, then opportunistically sweep the remaining could-have backlog. Lowest priority, safe to compress or drop under time pressure.

| Epic | Story range | Focus |
|---|---|---|
| Integration & API | US-088, 089, 091 (harden/verify), US-090 (confirm already covered) | Localhost-only binding enforcement + test coverage |
| Could-have sweep (cross-epic) | US-005, 028, 032, 039, 058, 067, 075, 100 | Glossary panel, search-as-you-type, LaTeX, high-contrast theme, plaintext fallback, bulk-tag, conversion tracking, dashboard-at-scale |
| Design debt #6 | — | Interactive p5.js/HTML prototype for search + thread-navigation flow, if bandwidth allows |

**Explicitly out of scope (wont-have):** US-092 (event stream for newly indexed conversations) and US-093 (Gemini/OpenCode/Aider harness import, stubbed) — no push-based eventing and no multi-harness import for the foreseeable future. Revisit only if a concrete external-integration need materializes.

Note: US-073 (Safety Watch flags unusual threads, could-have) already shipped in m3 as a TUI page — verify it meets the full story acceptance criteria rather than re-building.

**Sizing:** S/M
**Risks / dependencies:** low risk — this phase is intentionally the release valve; trim first if m4–m6 run long.

---

## Design debt

Pulled from [design/README.md](../design/README.md) "Next Steps" (items 1–2 already done: logos, dashboard/thread/search mockups):

| # | Item | Landed in |
|---|---|---|
| 3 | Ink CLI component sketches (terminal equivalents of web components) | m5 |
| 4 | Accessibility audit — verify contrast pairs on real screens | m4 (gate) |
| 5 | Edit/Convert/Merge page mockups | m5 |
| 6 | Interactive prototype (p5.js or HTML) for search + thread navigation | m7 (stretch) |

---

## Summary

| Phase | Theme | Size | Epics touched |
|---|---|---|---|
| m4 | Onboarding & Reliability | L | Onboarding & Install, Edge Cases & Error States, Performance & Scale, Accessibility & i18n |
| m5 | Feature Depth & Admin Maturity | L | Datasets, Convert, Search, Thread Viewer, Thread Editing, Conversation Ops, Settings, Admin & Oversight, CLI, skill-manage (core) |
| m6 | skill-manage Audit & Observability | M | skill-manage (audit) |
| m7 | Integration Hardening & Exploratory | S/M | Integration & API, could-have sweep |
