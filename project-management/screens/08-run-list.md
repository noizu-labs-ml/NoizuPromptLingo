# Run List

| Field | Value |
|-------|-------|
| **ID** | `run-list` |
| **Type** | Primary |
| **Category** | Results & Dashboards |
| **User Stories** | US-025, US-026, US-027, US-028, US-029, US-077, US-079, US-080 |

## Description

Reverse-chronological list of all runs in the organization. Supports rich filtering by script, agent, status, verdict, persona, and date range. Entry point for opening run details and triggering comparisons.

## Key Components

- **Run table** — Rows with run ID, script name + version, agent name + version, status badge, verdict badge, started_at, duration (US-025)
- **Script filter** — Typeahead selector to filter by script (US-026)
- **Agent filter** — Typeahead selector to filter by agent (US-027)
- **Status filter** — Multi-select for pending/running/completed/failed/cancelled (US-028)
- **Verdict filter** — PASS/WARN/FAIL filter for completed runs (US-028)
- **Persona filter** — Filter by persona head (US-080)
- **Date range filter** — Quick presets (today/7d/30d/90d) and custom range picker (US-079)
- **Compare button** — Multi-select two runs to open diff view (US-077)
- **Pagination** — 50 per page with infinite scroll or pager (US-025)
- **Empty state** — Explains how to trigger a run (US-025)

## Interactions

- Apply filters (combined additively); filter state reflected in URL query string
- Click a run row to navigate to Run Detail
- Multi-select two runs and click "Compare" for side-by-side diff
- Clear filters to return to unfiltered list

## Navigation

- Accessible from: Global sidebar navigation
- Links to: Run Detail (click row), Run Diff (compare action)
