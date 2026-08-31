# 06: Search Result Row

| Field | Value |
|-------|-------|
| ID | CMP-06 |
| Category | Data Display |
| Surfaces | web, cli-ink, cli-command |
| Used In | SCR-01, SCR-16, SCR-31 |

## Description
A search-specific variant of the conversation list item: thread title, matched snippet with query terms highlighted, project, date, and a relevance score. Distinct from CMP-05 because it's driven by search-match data (snippet + score) rather than static conversation metadata.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Default | Explore search-mode results (web/cli-ink) |
| Plain-text | `llm-toolkit search` command output (SCR-31) — no highlight markup, score printed as a plain number |

## Props / Configuration
- `snippet` — string with highlight markers around matched terms
- `relevance` — number (0–1 or percentage)
- `mode` — `"fts" \| "semantic"` — affects whether relevance is a keyword-match score or a similarity score (US-027)

## Interactions
- Click/Enter navigates to Thread Viewer, ideally scrolled/jumped to the matched message
