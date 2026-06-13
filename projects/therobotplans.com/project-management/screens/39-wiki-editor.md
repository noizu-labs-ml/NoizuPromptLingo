# Wiki Page Editor/Viewer

| Field | Value |
|-------|-------|
| **ID** | `wiki-page` |
| **Type** | Primary |
| **Category** | Documentation & Wiki |
| **User Stories** | US-056, US-057 |

## Description

Markdown wiki with hierarchical page structure, cross-linking with autocomplete, version history, code-link declarations (pages linked to source files), and staleness indicators for outdated content.

## Key Components

- **Markdown editor** — Rich markdown editing with live preview
- **Sidebar tree nav** — Hierarchical page tree for navigation
- **Cross-link autocomplete** — `[[page]]` syntax with autocomplete
- **Version history panel** — View page revisions and diffs
- **Code-link frontmatter** — Declare source files this doc is linked to
- **Stale indicator** — Badge when linked code changes but doc hasn't updated
- **Permissions control** — Per-page read/write permissions

## Interactions

- Edit inline with live preview or split view
- Type `[[` for cross-link autocomplete
- View version history and restore previous versions
- Stale indicator triggers when linked source code changes
- Reorganize page hierarchy via drag in sidebar

## Navigation

- Accessible from: Main nav (docs/wiki), Knowledge Search
- Links to: Other wiki pages, Source code (via code-links), ADR Index
