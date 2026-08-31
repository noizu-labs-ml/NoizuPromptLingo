# 15: Style Guide Reference

| Field | Value |
|-------|-------|
| ID | SCR-15 |
| Surface | web |
| Type | primary |
| Category | Internal / Meta |
| Route / Entry | `/style-guides` (index), `/style-guides/:slug` (rendered guide) |
| Primary Personas | — (internal/dev-facing, not persona-scoped) |
| User Stories | — (not tied to an end-user story; supports design/implementation consistency) |

## Description
Renders the project's own `design/style-guide.md` content in-app via Markdown, keyed by versioned slug (e.g. `2026-Q2-1`). Not part of the product's user-facing feature set — a living reference for contributors implementing UI against the Nocturne + Minimal Tech system, reachable at a real route so it can be linked/shared like any other page.

## Entry Points
- Direct link `/style-guides` from documentation or developer tooling
- Not linked from primary nav (internal use)

## Key Components
- StyleGuideIndex — list of available guide versions when no slug is given
- MarkdownView — renders the guide's markdown content (headings, tables, code)

## States
- **Loading:** n/a — content is bundled at build time (in-file template literal), not fetched
- **Empty:** unknown slug falls back to the index list rather than a broken page
- **Error:** n/a

## Interactions
- Index entries link to their versioned slug route

## Navigation
- **From:** direct link only
- **To:** n/a
