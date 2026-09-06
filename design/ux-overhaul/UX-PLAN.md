# NPL App — UX Overhaul & Gap-Fill Plan

- **Branch**: `worktree-ux-overhaul` (from `feature/story-review-overhaul`)
- **Inputs**: `work-overhaul.md`, `project-management/reviews/story-status-table.md`, frontend inventory (`frontend/src`), theme workspace (`design/`)
- **Companions**: `design/ux-overhaul/mockups/` (barebones unstyled Next.js wireframes), `design/ux-overhaul/directions/` (shell-direction image mockups + `.media.prompt` sources), `design/ux-overhaul/STATE-MATRIX.md`
- **Date**: 2026-09-06

---

## 0. Where we actually are (findings that change the plan)

| Finding | Consequence |
|---|---|
| Frontend is **inside this repo** (`frontend/`, Next.js 16 App Router, React 19), not external as earlier notes assumed | UI work ships in the same PR stream as backend work; stories can be re-baselined against real routes |
| Visual direction is **already locked to Nocturne** (`frontend/src/config/theme-style-guide`), with 8 explored themes and a 47-screen `.media.prompt` inventory in `design/asset-prompts/screens/` | Do **not** re-litigate palette. Direction mockups in this pass test **shell/layout structure**, rendered in the Nocturne palette |
| Two-tier quality split: 16 pages on the descriptor-driven console framework (`DataTable`, `ConsoleDetailPage`) are good; ~45 pages are bespoke, "Loading…" text, no skeletons, no permission states | The overhaul is mostly **migration onto one framework + a state kit**, not redesign from zero |
| No data layer (3.3k-line fetch wrapper + `useEffect` per page); Phoenix channels wired with **zero consumers** | Foundations phase must come first or every new screen inherits staleness and refetch storms |
| A finished but **orphaned kit** exists at `frontend/components/` (AppShell, CommandPalette, SearchBox, Skeleton, EmptyState-adjacent primitives, 33 files, imported by nothing) | Cheapest gap-fill: adopt/port these instead of authoring new |
| Nav is a 6-group accordion over ~30 org-scoped destinations; no palette, no global search, no breadcrumbs | Violates the ≤12-destination rule for a sidebar; shell archetype must change |
| `next-intl` installed, zero `useTranslations` calls; two `aria-live` regions app-wide | a11y/i18n stories (US-091–095) are frontend-only work with **no backend blocker** |
| Story reviews call US-094 theme switch "not implemented" but the navbar has a persisted dark/light toggle | Re-baseline US-094 to "high-contrast + reduced-motion prefs missing"; the toggle exists |
| Notification and activity tables are never written (S6) | Inbox and feed screens render **permanently empty** until producers land; build the UI against fixtures but gate the route |

---

## 1. Object & permission model (what every screen is about)

```
Org ─┬─ Membership(role: owner|admin|member|viewer, suspended?)
     ├─ Project ─┬─ Session (agent work session; tool scope; status)
     │           ├─ Board ─ Stage ─ Ticket(type, custom fields, links, PRD) ─ ActivityEvent
     │           ├─ Review ─ Verdict
     │           ├─ Wiki Space ─ Page ─ Comment / Attachment / Reaction
     │           ├─ Artifact ─ Revision
     │           ├─ Asset ─ Output      Campaign ─ AdGroup ─ Variant
     │           └─ VFS Mount ─ Node (domain-mounted; group-gated read/write)
     ├─ ChatRoom ─ Message(thread, pin, scheduled, reaction) ─ Notification
     ├─ Persona ─ Journal / KnowledgeEntry / Reinforcement / CallSign
     ├─ Memory(vector recall, valence, associations)
     ├─ Instruction(versioned, embedded)
     ├─ MCP Key / Endpoint / Scope preset / Custom scope
     ├─ DB Service ─ Credential ─ QueryRun ─ WriteApproval ─ AuditRow
     └─ Integration: GitHub repo/PR, Webhook, Dev tunnel, Mock MCP, Browser capture
Platform admin: Users, Orgs, LLM providers, Media providers, OAuth clients, PBAC/ToolGuard
```

**Who can do what (UI contract):**

| Actor | Sees | Never sees |
|---|---|---|
| viewer | read-only everything in org; no create/edit affordances rendered | edit buttons that 403 on submit |
| member | create/edit own sessions, tickets, chat, wiki, artifacts; VFS write only where group-gate grants | admin sections |
| admin | members, roles, invites, settings, MCP scopes, DB credentials, write approvals | platform admin |
| owner | + billing/danger zone | — |
| suspended (any role) | a single blocking "account suspended" page with contact path | anything else |
| platform admin | Admin shell mode (separate rail) | — |

Rule: **permission state is rendered, not discovered**. A page knows its `effective_role` before painting and hides or disables accordingly (see §5 state matrix).

---

## 2. Information architecture & shell

### 2.1 Shell decision: **Collapsible icon-rail sidebar + command palette + breadcrumbs**

Rationale: 8 primary destinations (rule: ≤9 for a rail), the primary object mix is list-heavy (sessions, tickets, chat) but has canvas surfaces (editor, board, SQL console) that need width. Rail collapses to 56 px; palette (⌘K) and global search (`/`) absorb the ~30 secondary destinations that currently bloat the accordion.

Alternative shells are tested visually in `directions/` (§8) but this is the recommendation.

### 2.2 Primary rail (org-scoped)

| # | Destination | Contains (secondary, reached via section landing, tabs, palette) | Archetype |
|---|---|---|---|
| 1 | **Home** | Org dashboard (bento), notification inbox, activity feed, first-run checklist | Dashboard / stream |
| 2 | **Work** | Sessions, Boards (kanban), Tickets (list), Reviews, Iterations | Index → record detail (tab-in-tab) |
| 3 | **Chat** | Rooms list → room view (threads, pins, scheduled, mute) | Three-pane list-detail |
| 4 | **Knowledge** | Wiki, Instructions (prompt library), Memory, Personas, Artifacts, NPL conventions, Glyph codex | Index / editor |
| 5 | **Files** | VFS mount picker → file tree browser → editor; live-update badges; mount docs | Dual sidebar (tree + inspector) |
| 6 | **Data** | DB services → schema browser, SQL console, vector search, write-approval queue, audit/pool dashboard | Dual sidebar / dashboard |
| 7 | **Integrations** | MCP setup (keys, endpoints, scopes), GitHub, Mock MCP, Browser relay, Webhooks, Dev tunnels | Settings-like index |
| 8 | **Settings** | Org profile, members & roles & invites, scope presets, notification prefs, key vault, danger zone | Settings |

Global chrome: org switcher (top of rail, not hidden in the brand mark), user menu, theme/accessibility quick toggle, notification bell (unread count from inbox), `⌘K` palette, `/` search. Admin becomes a **separate rail mode** (Users, Orgs, AuthZ/PBAC, LLM, Media, OAuth, MCP catalog, Marketing) entered from the org switcher, never mixed into the org rail.

### 2.3 URL scheme (state in the URL)

```
/app/[org]/                           home (dashboard)
/app/[org]/inbox                      notifications (?filter=unread|mentions|all)
/app/[org]/activity                   activity feed (?scope=project:x|board:y)
/app/[org]/work/sessions[/[id]]       list ?status=&project=&q=&cursor=  → detail tabs: overview|events|tools|artifacts
/app/[org]/work/boards/[id]           kanban ?iteration=&stage=&cursor=   (column-level cursor paging)
/app/[org]/work/tickets[/[id]]        list w/ custom-field filters ?f.<field>=  → detail tabs: fields|links|activity|prd
/app/[org]/chat[/[room]][?thread=id]  three-pane; thread in URL
/app/[org]/knowledge/{wiki|instructions|memory|personas|artifacts}[/[id]]
/app/[org]/files[/[mount]/[...path]]  ?view=tree|editor  selection in URL
/app/[org]/data[/[service]]/{schema|console|vectors|approvals|audit}
/app/[org]/integrations/{mcp|github|mock-mcp|browser|webhooks|tunnels}
/app/[org]/settings/{general|members|invites|roles|scopes|notifications|keys|danger}
/admin/{users|orgs|authz|llm|media|oauth|mcp|marketing}
/suspended · /invite/[token] · /403 (rendered inline, not a redirect)
```

---

## 3. Screen inventory (existing 47 + 25 new), backend readiness

Readiness key: **R** backend ready · **P** partial · **M** missing (from story reviews). Stories cited by ID.

### 3.1 Existing screens to keep (migrate onto framework + state kit)

01 landing · 02 login · 03 sso-callback · 04 registration-invite · 05 email-verify · 06 org picker · 07 profile · 08 MCP keys · 09–16 admin (users, orgs, authz, github, llm, custom scopes, media) · 17 org dashboard · 18/19 projects · 20/21 sessions · 22/23 chat · 24 board · 25/26 tickets · 27 ticket type/field admin · 28 wiki · 29/30 reviews · 31/32 artifacts · 33 personas · 34 creative assets · 35 instructions · 36 memory · 37/38 github · 39 browser relay · 40/41 mock MCP · 42 glyph codex · 43 conventions · 44 members · 45 org settings · 46 campaigns · 47 competitor research

Per-screen migration notes live in the mockups app `README.md`; the systemic changes are §4/§5.

### 3.2 New screens (gap fill)

| # | Screen | Stories | Backend | Notes |
|---|---|---|---|---|
| 48 | Notification inbox | US-021, US-051 | **P** (S6: no producers) | Build UI on fixtures; ship behind flag until producers land |
| 49 | Activity feed (project/board/ticket scopes) | US-013, US-082 | **P** (S6) | Same gate as 48 |
| 50 | Command palette | — (A5, nav scale) | R (client-only) | Port from orphaned kit |
| 51 | Global search results | US-065–071 | P (wiki body search missing) | Federated: tools, tickets, wiki, instructions, files |
| 52 | VFS mount picker + auth state | US-302, US-306 | P | Shows token status, re-auth prompt (S2) |
| 53 | VFS file tree browser | US-301 | **R** | Dual-sidebar: tree + inspector |
| 54 | VFS editor (create/edit/delete) | US-303, US-304 | P | Scope-gated actions rendered per group-gate; denial copy never names missing scope (§8 D2) |
| 55 | VFS live-update badges | US-305 | P | First Phoenix channel consumer |
| 56 | VFS mount docs panel | US-307 | M | Side drawer from mount picker |
| 57 | DB services index + tenant-scope chip | US-403 | M | Every Data screen carries the scope chip |
| 58 | DB schema browser | US-402 | M | Tree + column grid |
| 59 | SQL query console | US-401 | M | Monaco + DataTable results; read-only default; writes → approval |
| 60 | Write-approval queue | US-405 | M | Master-detail triage; diff preview |
| 61 | Vector search | US-406 | M (decision pending) | Build against Weaviate recall API if §8 D1 accepted |
| 62 | Query audit / pool dashboard | US-407 | P | Redacted args (S9) |
| 63 | DB credential provisioning (settings) | US-404 | M | Reveal-once secret pattern |
| 64 | Invite accept (OIDC + magic link) | US-039 | M | Cap error surfaced pre-submit (S4) |
| 65 | Suspended state page | S3 | P | Single blocking page |
| 66 | Permission-denied inline state | S10, US-083–090 | P | Component, not a route; every screen uses it |
| 67 | Key vault (org settings) | US-053, S7 | P | Rotate / revoke / last-used; reveal-once |
| 68 | Chat thread + pins + scheduled send + mute | US-016–019 | M/P | Extends screen 23 |
| 69 | Persona reinforcement + call-sign tracker | US-027, US-028 | M | Extends 33 |
| 70 | Campaign / ad-group builder + variant review + approve | US-029–032 | M | Wizard + review panel |
| 71 | Bulk generation queue | US-099 | M | Stream/log archetype |
| 72 | Accessibility & theme preferences | US-094, US-095 | R (client) | Dark/light/high-contrast, reduced motion, density |
| 73 | First-run checklist (org home empty state) | US-037–046 | R | Activation: add key → connect MCP → first session |
| 74 | PBAC denial explainer (admin) | US-061/062 | P | Exists partially; fold into Admin › AuthZ |

---

## 4. Gap-fill component library

Adopt-or-port from `frontend/components/` (orphaned kit) first; author only what is missing.

| Component | Source | Contract highlights |
|---|---|---|
| `AppShell` / `Rail` / `TopBar` | port from kit | `destinations[]`, `mode: org|admin`, collapse persisted, `aria-current` |
| `Breadcrumbs` | new | derived from URL segments + entity titles; last crumb is the page title |
| `CommandPalette` | port from kit | actions + navigation + recent; `⌘K`; provider registry so screens contribute actions |
| `SearchBox` / `GlobalSearch` | port + new results page | `/` shortcut; federated result groups; zero-results guidance |
| `PageHeader` | app-starter | title, breadcrumbs, one primary action, overflow menu |
| `EmptyState` | app-starter | required `title`, `description`, `primaryAction`; variants first-run / filtered / error |
| `PermissionState` | new | `reason: role|suspended|scope`; never leaks scope names |
| `Skeleton` / `SkeletonGrid` / `SkeletonTable` | port from kit | shape-matched to DataTable/Board/Chat |
| `DataTable` | keep (existing 785-line) | add virtualization + cursor paging adapter; density modes |
| `Board` | keep Lit component, wrap | add column cursor paging (US-096), roving-tabindex + arrow/space/enter drag (US-091), `aria-live` on moves |
| `VirtualList` | new | chat (US-097), audit rows, activity feed |
| `NotificationBell` / `InboxList` | new | unread count, mark-read, mute-room shortcut |
| `ActivityFeed` | new | grouped by day; actor / verb / object; deep links |
| `FileTree` | new | lazy children, keyboard tree (WAI-ARIA treeview), live badges |
| `CodeEditor` | wrap existing Monaco | dirty state, save model (explicit save + ⌘S), conflict banner |
| `SqlConsole` | new (Monaco + DataTable) | run / explain / limit; write detection → approval |
| `SchemaTree` | new | tables → columns → indexes; copy identifier |
| `ScopeChip` | new | tenant / mount / db-service scope, always visible in Data & Files |
| `ApprovalCard` | new | diff preview, approve/reject with reason, undo window |
| `ThreadPanel` / `PinPanel` / `ScheduleSendPopover` / `MuteToggle` | new | chat extensions |
| `ConfirmDialog` | app-starter | destructive requires typed confirm for irreversible ops; prefer toast-undo otherwise |
| `SecretRow` | new | reveal-once, copy, rotate, last-used, revoke |
| `LiveRegion` provider | new | single polite + assertive region; screens post announcements (US-092) |
| `Toast` w/ undo | port from kit / sonner | 6 s undo for reversible mutations |

**Foundations (not components but prerequisites):**
1. **Data layer**: TanStack Query over the existing `api.ts`; keys by (org, entity, id); mutations invalidate siblings; optimistic for reactions, moves, mark-read.
2. **Realtime**: Phoenix channel consumers for chat, board, session events, VFS `vfs/subscribe` (scoped per S2), notifications.
3. **i18n activation**: wrap all new components in `useTranslations`; logical CSS properties; RTL smoke via `dir="rtl"` fixture route.
4. **Tokens**: keep Nocturne seeds; add density (`compact|comfortable`), high-contrast overlay, reduced-motion.

---

## 5. State matrix (contract applied to every screen)

Written before layout. Full per-screen matrix in `STATE-MATRIX.md`; the shared contract:

| State | Rendering rule |
|---|---|
| loading (first) | shape-matched skeleton, never text "Loading…" |
| loading (refresh) | keep content, subtle progress bar in PageHeader |
| empty (first-run) | `EmptyState` with the one action that creates first value |
| empty (filtered) | "No results for these filters" + clear-filters action |
| error (recoverable) | inline `role="alert"` with retry; keep chrome |
| error (fatal) | page-level error with request id |
| permission (role) | affordances hidden; page shows `PermissionState` if whole page is denied |
| permission (scope/gate) | action disabled with tooltip; denial copy generic (no scope leak) |
| suspended | global redirect to `/suspended` |
| offline / stale | banner + last-synced time; mutations queued or disabled |
| long-running | progress + cancel; never block navigation |
| live update | badge / row highlight + `aria-live="polite"` announcement |

---

## 6. Keyboard & accessibility plan

- Shortcut model: `⌘K` palette · `/` search · `g h/w/c/k/f/d` go-to · `j/k` list traversal · `Enter` open · `Esc` close/restore focus · `?` shortcut sheet.
- Board: roving tabindex across cards; `Space` picks up, arrows move across stages, `Enter` drops, `Esc` cancels; announce "moved X to Stage Y" (US-091/092).
- Every overlay traps focus and restores on close; only one modal level.
- Live regions: a single `LiveRegion` provider; dashboards announce KPI/state changes; chat announces new messages only when focused.
- Targets ≥ 24×24 CSS px; contrast 4.5:1 text, 3:1 UI on Nocturne and high-contrast.
- Reduced motion respected for board drag, toast, skeleton shimmer (US-095).
- i18n: string growth tested with hostile fixtures; RTL mirrored rail and breadcrumbs (US-093).

---

## 7. Phased roadmap (aligned to `work-overhaul.md` §6 waves)

| Phase | Scope | Stories | Backend gate | Est. |
|---|---|---|---|---|
| **0 Foundations** | Query layer, channel consumers, shell swap (rail + palette + breadcrumbs + search), state kit (skeleton/empty/permission/error), LiveRegion, theme/a11y prefs, migrate bespoke pages onto console framework | US-083–095 (partial), US-094/095 | none | 3 wk |
| **1 Wave-1 surfaces** | Inbox, activity feed (flagged), VFS picker/tree/editor/live badges/docs, invite accept, key vault, suspended + permission states, first-run checklist | US-013/021/039/053/301–307 | S1/S6 producers, S2 token re-verify, S3 suspension | 3 wk |
| **2 Collaboration depth** | Chat threads/pins/schedule/mute + virtualization, board cursor paging + keyboard nav, ticket custom-field filters, persona reinforcement/call-sign, wiki body search + real attachment upload | US-016–019/027/028/072/075/091/096/097 | chat features, US-071/075 backend | 3 wk |
| **3 Data services** | DB services index, schema browser, SQL console, approval queue, audit/pool dashboard, vector search, credential provisioning | US-401–407 | entire epic + §8 D1 | 4 wk |
| **4 Creative & scale** | Campaign builder/variant review/approval, landing-page draft editor, bulk generation queue, PBAC explainer polish | US-029–032/099/061/062 | creative backend | 3 wk |

Each phase exits through: render → `design-lint-cli.mjs` (light/dark) → visual pass → hostile-fixture stress → keyboard drive → app-UI rubric ≥ 7.0.

---

## 8. Decisions needed from the product owner

| # | Decision | Recommendation | UI impact |
|---|---|---|---|
| D1 | US-406 pgvector vs Weaviate | Re-scope to Weaviate-backed recall | Screen 61 built once; no second store UI |
| D2 | US-303 scope model | Rewrite AC2 to group-gate cascade; denials stay generic | `PermissionState` copy; no "missing scope X" text |
| D3 | US-047 key-prefix case | Follow schema (uppercase) | Key vault validation/copy |
| D4 | Shell direction | Icon-rail + palette (this doc) — see `directions/` renders | Whole app |
| D5 | Ship inbox/feed before S6 producers? | Yes, behind `feature.inbox` flag with fixture mode for demos | Phase 1 scope |
| D6 | Retire or port the orphaned kit at `frontend/components/` | Port into `src/components` and delete the orphan | Phase 0 |

---

## 9. Story re-baseline actions

- US-094: mark theme switch **Partially Implemented** (toggle exists; high-contrast + reduced-motion prefs missing).
- Split US-092 into dashboard live regions vs. board move announcements.
- Add stories: command palette, global search results, breadcrumbs, activity feed producers (backend), suspended page, permission state component, first-run checklist, DB tenant scope chip. Draft IDs: US-501–508 (UX Foundations epic) — to be created via `npl-idea-to-spec`.
- Re-point stories still citing `worktrees/main/mcp-server`, `unified.py`, SQLite (D1–D6 drift in `work-overhaul.md`).
