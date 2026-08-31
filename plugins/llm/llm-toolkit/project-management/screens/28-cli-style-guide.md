# 28: CLI Style Guide

| Field | Value |
|-------|-------|
| ID | SCR-28 |
| Surface | cli-ink |
| Type | primary |
| Category | Internal / Meta |
| Route / Entry | interactive router: `style-guide` |
| Primary Personas | — (internal/dev-facing) |
| User Stories | — |

## Description
Terminal counterpart to Web Style Guide Reference (SCR-15): renders the bundled style guide markdown as scrollable terminal text. No interaction beyond scroll.

## Entry Points
- Router/sidebar navigation

## Key Components
- Scrollable markdown-to-terminal text renderer

## States
- **Loading:** n/a — content is bundled, not fetched

## Interactions
- Standard scroll (arrow/page keys) via the shared scroll hook

## Navigation
- **From:** router / sidebar
- **To:** n/a
