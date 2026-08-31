# 01: Explore — Unified Search & Browse

| Field | Value |
|-------|-------|
| ID | SCR-01 |
| Surface | web |
| Type | primary |
| Category | Discovery |
| Route / Entry | `/` (index), `/search`, `/browse` — all three routes render the same `Explore` page component, distinguished by URL query params (`q`, `mode`) and default sort/group state |
| Primary Personas | P-001, P-007, P-005 |
| User Stories | US-003, US-004, US-005, US-013, US-021, US-022, US-023, US-024, US-025, US-026, US-027, US-028, US-040, US-065, US-070, US-071, US-072, US-081, US-082, US-097, US-100 |

## Description
The single entry surface for finding and orienting around indexed conversations. Combines what the draft `design/SITEMAP.md` originally specced as three separate pages — Dashboard, Search, Browse — into one adaptive page: with no query it behaves as a browse/dashboard list (grouped or flat, sortable), and as soon as a query is typed it becomes a live full-text/semantic result view. This is the "what was I working on / find that thread" screen most sessions start on.

## Entry Points
- App launch (`llm-toolkit serve` → opens `/`)
- Global nav "Search"/"Browse" links (both point into this same page)
- Command palette (`Cmd+K`) free-text jump
- Deep link with `?q=` from an external tool or shared URL

## Key Components
- SearchBar — query input + full-text/semantic mode toggle (`ToggleChip`)
- FilterBar — include/exclude tag input, sort select, group mode (grouped by project / flat), preview mode (both/first/last/none), page size
- ResultCard — thread title, matched snippet with highlights, project, date, relevance score (search mode)
- ThreadCard — title, project badge, date, message count, preview snippet (browse mode, grouped by project)
- Pagination — server-side page controls
- IndexStatus — indexer state indicator (idle/running/stale) sourced from `GET /api/index/status`
- EmptyState — "No results" + suggested query relaxations, or first-run guided setup when the index is empty (US-003)
- GlossaryPanel — optional in-app glossary of tool-specific terms (full-text vs. semantic, project scope, dataset, artifact) for novice users, opened from a help affordance (US-005)
- KeyboardShortcutsPanel — reference overlay listing all global and page-level shortcuts, opened via CommandPalette or a dedicated `?`-style affordance (US-040)

## States
- **Loading:** skeleton rows for both conversation list and search result list while `useConversations`/`useSearch` are in flight
- **Empty (no query):** guided empty-state messaging when no conversations are indexed yet (first run)
- **Empty (search):** "No results for '{query}'" with suggestions — relax filters, switch mode, check spelling
- **Error:** inline banner if the index is locked/corrupted (US-081) or the API call fails, with a clear distinction from a plain "no results" state
- **Archived filter:** an "Archived" group-mode/filter option lists archived conversations with a restore action per row (US-065), separate from the default active-conversation view
- **Search at scale:** semantic search stays responsive against large indexes via server-side ANN/vector search rather than full client-side scans (US-097); the dashboard/list view itself stays responsive as the corpus grows (US-100), via the same server-side pagination that backs SCR-01 generally
- **First-run guided empty state:** when nothing is indexed yet, the empty state (CMP-34) walks a novice user through pointing the tool at a conversation directory rather than showing a bare "no data" message (US-003)
- **Index health:** IndexStatus (CMP-33) in the navbar doubles as a dashboard health indicator — idle/running/stale — so staleness is visible without opening Settings (US-013)

## Interactions
- Typing in SearchBar debounces into `GET /api/search?q=&mode=fts|semantic`
- Mode toggle switches between full-text and semantic ranking without losing filters
- Tag include/exclude chips are additive and combine with date/role/project filters
- Group mode toggle re-renders the same result set as project-grouped sections vs. a flat sorted list
- Clicking a card navigates to Thread Viewer (SCR-04)

## Navigation
- **From:** app launch, global nav, command palette
- **To:** SCR-04 Thread Viewer (card/result click), SCR-02 Projects (project badge click)

## Reconciliation Note
`design/SITEMAP.md` documents Dashboard (`/`), Search (`/search`), and Browse (`/browse`) as three distinct pages with three distinct component trees. The shipped code (`packages/web/src/App.tsx`) routes all three paths to a single `Explore` component. Legacy `Dashboard.tsx`, `Search.tsx`, and `Browse.tsx` files still exist under `packages/web/src/pages/` but are not imported by `App.tsx` and are unreachable — dead code superseded by `Explore.tsx`. This screen file documents the shipped unified surface; see `project-management/screens/README.md` for the full reconciliation note.
