# 16: CLI Explore

| Field | Value |
|-------|-------|
| ID | SCR-16 |
| Surface | cli-ink |
| Type | primary |
| Category | Discovery |
| Route / Entry | `llm-toolkit interactive` (default landing page); reachable in-app via router as the fallback route |
| Primary Personas | P-001, P-008 |
| User Stories | US-021, US-022, US-023, US-024, US-025, US-026, US-027, US-028, US-070, US-071, US-072 |

## Description
Terminal counterpart to Web Explore (SCR-01): browse (grouped-by-project or flat) and full-text/semantic search over the same conversation index, without leaving the terminal. Modal UI state machine — one key press at a time swaps between browse, search, sort, tag-filter, and page-size sub-modes.

## Entry Points
- `llm-toolkit interactive` cold start
- Router fallback (any unmatched interactive route returns here)

## Key Components
- SelectableList — keyboard-navigable list, backs both grouped and flat display modes
- ConversationRow — single-line thread summary (title, project, date, message count) rendered per SelectableList item, with group-header rows interleaved in grouped mode
- Pagination — footer page indicator + key-driven page turns
- StatusLine — bottom bar showing current mode and available keys
- IndexStatus indicator in Header

## States
- **Loading:** Spinner (`@inkjs/ui`) while conversations/search results resolve
- **Empty:** "No results" text row when a search query returns nothing
- **UI sub-modes:** `browse | search | sort | include-tags | exclude-tags | page-size` — each swaps the footer prompt and captures subsequent keystrokes as `TextInput`/`Select` input rather than list navigation

## Interactions
- Typing `/`-style search or a dedicated key enters `search` mode and debounces query input (`useDebouncedValue`)
- Cycling preview mode (both/first/last/none) and group mode (grouped/flat) via dedicated keys, mirroring the web FilterBar options
- Enter on a ConversationRow navigates to CLI Thread (SCR-19)

## Navigation
- **From:** app launch
- **To:** SCR-19 CLI Thread, SCR-17 CLI Projects
