# NPL UX Overhaul — Wireframe Mockups

Standalone, barebones, unstyled Next.js (App Router, TypeScript) wireframes for
`design/ux-overhaul/UX-PLAN.md` §2–5. Grayscale, semantic HTML, no CSS framework,
no fetch — all data comes from `lib/fixtures.ts`. This app tests **shell and
layout structure and the state contract**, not visual direction (that's
`design/ux-overhaul/directions/`, rendered in the Nocturne palette).

## Run it

```bash
npm install
npm run dev
# or verify the build:
npx next build
```

No env vars, no backend, no auth. Everything is a static fixture.

## The `?state=` convention

Every route reads `?state=` and renders the matching variant via the shared
`ScreenStates` server component (`components/ScreenStates.tsx`), and always
shows `STATE: <value>` at the top of the page:

| Value | Renders |
|---|---|
| *(omitted)* | `default` — normal content |
| `loading` | shape-matched skeleton (`Skeleton` / `SkeletonTable`), never "Loading…" text |
| `empty` | `EmptyState` with a screen-specific first-run title/description/action |
| `error` | inline `role="alert"` error with a request id and retry |
| `denied` | `PermissionState` (role-based denial, generic copy, no scope leak) |
| `suspended` | `PermissionState` (suspended-account variant) |

Example: `/acme/work/sessions?state=loading`, `/acme?state=empty`.

## Route index

Org-scoped routes use org slug `acme` below; the org switcher in the top bar
also offers a CJK-slug org (`検索インデックス`) to stress-test the shell with
hostile data live.

| Route | Purpose | Story IDs |
|---|---|---|
| `/[org]` | Home dashboard: bento of 6 KPI blocks; `?state=empty` shows the first-run checklist variant | US-037–046 |
| `/[org]/inbox` | Notification inbox, read/unread + filter | US-021, US-051 |
| `/[org]/activity` | Activity feed, scoped by `?scope=` | US-013, US-082 |
| `/[org]/work/sessions` | Sessions list, filters, cursor paging | — |
| `/[org]/work/sessions/[id]` | Session detail, tabs: overview/events/tools/artifacts | — |
| `/[org]/work/boards/[id]` | Kanban: 4 stages, cards, per-column "Load more", keyboard hint, toast w/ undo | US-091, US-096 |
| `/[org]/work/tickets` | Ticket list w/ custom-field filters (`?f.<field>=`) | US-072 |
| `/[org]/work/tickets/[id]` | Ticket detail, tabs: fields/links/activity/prd | — |
| `/[org]/chat` | Room list | US-016–019 |
| `/[org]/chat/[room]` | Three-pane: rooms / messages / thread+pins panel; mute + schedule-send | US-016–019 |
| `/[org]/knowledge/instructions` | Instruction (prompt library) list | — |
| `/[org]/files` | VFS mount picker + auth state (connected/expired/denied) | US-302, US-306 |
| `/[org]/files/[mount]/[...path]` | Tree (aside, `role="tree"`) / editor (main) / inspector (aside, live badge) | US-301, US-303–305 |
| `/[org]/data` | DB services index, each with a `ScopeChip` | US-403 |
| `/[org]/data/[service]/schema` | Schema browser: tables / columns / indexes | US-402 |
| `/[org]/data/[service]/console` | SQL console: textarea + results table + "write detected → requires approval" notice | US-401 |
| `/[org]/data/[service]/approvals` | Write-approval queue, master-detail, diff preview | US-405 |
| `/[org]/data/[service]/audit` | Query audit / pool dashboard, redacted args | US-407 |
| `/[org]/data/[service]/vectors` | Vector search over the recall index | US-406 |
| `/[org]/integrations` | Integrations index (GitHub, Mock MCP, webhooks, tunnels) | — |
| `/[org]/settings/members` | Member table + invite form showing seat cap remaining | US-053 |
| `/[org]/settings/keys` | Key vault: `SecretRow` (reveal-once, rotate, revoke, last-used) | US-053, S7 |
| `/[org]/settings/accessibility` | Theme, high-contrast, reduced-motion, density radios | US-094, US-095 |
| `/invite/[token]` | Invite accept flow (SSO + magic link), seat-cap error surfaced pre-submit | US-039 |
| `/suspended` | Single blocking suspended-account page | S3 |
| `/admin/authz` | PBAC denial explainer (admin rail mode) | US-061/062 |
| `/search?q=` | Federated search results (tickets/wiki/files groups) | US-065–071 |
| `/palette` | Command palette rendered as `<dialog open>` for static review | — |

Layouts: `app/(app)/[org]/layout.tsx` (org shell: rail, top bar, main) and
`app/admin/layout.tsx` (admin shell: separate rail, no org switcher).

## Shared components (`components/`)

`Shell`, `Rail`, `TopBar`, `Breadcrumbs`, `PageHeader`, `EmptyState`,
`PermissionState`, `ErrorState`, `Skeleton` / `SkeletonTable`, `ScreenStates`,
`DataTable` (sort-as-button headers, cursor "Next" link), `Board`, `FileTree`
(`role="tree"`), `ScopeChip`, `SecretRow`, `ApprovalCard`, `ThreadPanel`,
`CommandPalette`, `LiveRegion` (`aria-live` div, mounted in the org layout),
`Toast` (static example with Undo, shown on the board screen).

`Rail` and `TopBar` are client components (`usePathname`) so the active rail
item and breadcrumbs are derived from the real URL rather than hardcoded per
page — this is a wireframe-only convenience; the real app should still derive
breadcrumbs from loaded entity titles, not just URL segments.

## Hostile data

`lib/fixtures.ts` reuses several cases from
`assets/hostile-fixtures/hostile-data.json` (200-char name, CJK, RTL, combining
diacritics, null fields, whitespace-only strings, a 12-digit number, a negative
number) across sessions, tickets, board cards, chat, files, members, and audit
rows — by default, not as a separate stress pass.

## Per-screen migration notes (existing 47 screens)

Grouped by UX-PLAN §3.1 numbering. This mockup app does not re-implement these
47 screens; it establishes the shell/state contract they migrate onto. "Kit"
below means the orphaned `frontend/components/` kit (UX-PLAN §0, §4, decision D6).

**Auth & onboarding (01–07, 64)**
Move off bespoke layout onto the shared shell where applicable (post-login
screens only — 01–06 stay outside the org shell); replace ad hoc loading text
with `Skeleton`; invite/registration gets the seat-cap-before-submit pattern
from `/invite/[token]` in this mockup; SSO callback (03) needs no visual
change, only state-kit wiring for error.

**MCP keys & admin (08–16)**
08 (MCP keys) migrates onto `SecretRow` (reveal-once/rotate/revoke/last-used)
as shown in `/[org]/settings/keys`. 09–16 (admin users/orgs/authz/github/llm/
scopes/media) move into `app/admin/layout.tsx`'s rail mode; 74/PBAC explainer
folds into the `/admin/authz` pattern here.

**Org home & dashboard (17–19)**
17 migrates onto the bento + first-run-checklist pattern in `/[org]` — replace
the accordion nav entirely with the rail; 18/19 (projects) become secondary
destinations reached via breadcrumbs/palette, not top-level rail items.

**Sessions & boards (20, 21, 24)**
20/21 migrate onto `DataTable` + tab-in-tab detail exactly as `/[org]/work/
sessions[/[id]]`; 24 (board) adopts the `Board` component, adds column cursor
paging and roving-tabindex keyboard drag (US-091/096) as sketched here.

**Tickets (25–27)**
25/26 migrate onto `DataTable` with `?f.<field>=` custom-field filters (see
`/[org]/work/tickets`); 27 (ticket type/field admin) stays a settings-style
CRUD screen, ported onto the same table primitives.

**Chat (22, 23, 68)**
22/23 collapse into the three-pane `/[org]/chat/[room]` pattern; 68 (threads,
pins, schedule-send, mute) is exactly the `ThreadPanel` shown here — extends
rather than replaces 23.

**Knowledge (28, 31–33, 35, 36, 42, 43, 69)**
28 (wiki), 31/32 (artifacts), 35 (instructions), 36 (memory), 42 (glyph
codex), 43 (conventions) all move under the Knowledge rail destination as
index/editor pairs, following the `/[org]/knowledge/instructions` list
pattern. 33 (personas) + 69 (reinforcement/call-sign) extend the same index
with a detail editor; out of scope for this mockup pass.

**Files / VFS (52–56, new)**
Net-new screens, fully covered here: `/[org]/files` (mount picker + auth
state) and `/[org]/files/[mount]/[...path]` (tree/editor/inspector with live
badge). No legacy screen to migrate from.

**Data services (57–63, new)**
Net-new epic, fully covered here: services index with `ScopeChip`, schema
browser, SQL console (write-detection notice), approval queue, audit/pool
dashboard, vector search. Gated on UX-PLAN §8 D1/D2.

**Reviews & iterations (29, 30)**
Fold into the Work rail as additional tabs/sub-lists on sessions or tickets;
migrate onto `DataTable` + `ApprovalCard`-style verdict cards (not built in
this pass — same primitives as `/[org]/data/[service]/approvals`).

**GitHub, mock MCP, browser relay (37–41)**
Migrate onto the Integrations index pattern shown in `/[org]/integrations`;
each becomes a settings-like sub-page reached from that index, not its own
rail item.

**Creative & campaigns (34, 46, 47, 70, 71)**
34 (creative assets) moves under Knowledge; 46/47 (campaigns, competitor
research) and 70/71 (campaign builder, bulk generation queue) are Phase 4
work — no mockup in this pass; when built, reuse `DataTable` for the variant
review grid and a stream/log archetype (not yet in `components/`) for the
bulk queue.

**Members & org settings (44, 45)**
44 migrates onto the members table + invite form with seat-cap copy shown in
`/[org]/settings/members`; 45 (org settings) becomes the remaining Settings
sub-pages (general, danger zone) around the accessibility/keys pages built
here.

**Cross-cutting for all 47**
Every migrated screen adopts: `ScreenStates` for the six-state contract (no
more bare "Loading…" text), `PermissionState` instead of hidden/broken
buttons, `LiveRegion` for one shared `aria-live` announcer instead of the
current two, and the rail + palette + breadcrumbs shell instead of the
6-group accordion nav.
