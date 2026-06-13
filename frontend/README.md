# NPL MCP Companion — Frontend

Static Next.js 15 dashboard for the [NoizuPromptLingo MCP server](../README.md).

---

## Overview

This dashboard provides a read-only (and eventually interactive) web UI for the NPL MCP server. It surfaces the tool catalog, session history, instructions, projects, and metadata — all rendered as a fully static export (`output: 'export'` in `next.config.js`), deployable to any static host.

---

## Development

### Frontend only (mock data)

```bash
cd frontend
npm install
npm run dev          # → http://localhost:3000
```

The dev server uses the mock API implementation — no running server required.

### Full stack (real MCP server)

```bash
uv run npl-mcp       # starts FastAPI + MCP server → http://localhost:8765
```

Then `npm run dev` in a second terminal. When `lib/api/impl/rest.ts` is active, the frontend will proxy to `localhost:8765`.

### Build

```bash
npm run build        # static export → out/
```

---

## Architecture

### API Facade Pattern

All data access goes through a single facade: `lib/api/client.ts`.

```
lib/api/
  client.ts          ← stable public surface (never changes)
  types.ts           ← shared TypeScript interfaces
  impl/
    mock.ts          ← in-memory canned data (active today)
    mock/            ← per-domain mock helpers
    rest.ts          ← future: wraps fetch("/api/...")
```

Pages and components **only** import from `@/lib/api/client`. The underlying implementation is an internal detail.

### Mock-to-Real Swap

When the REST backend is ready, change **one line** at the bottom of `lib/api/client.ts`:

```diff
- import * as impl from "./impl/mock";
+ import * as impl from "./impl/rest";
```

Then add `lib/api/impl/rest.ts` implementing the same surface by wrapping `fetch`:

```ts
// lib/api/impl/rest.ts
export const tools = {
  list: () => fetch("/api/tools").then(r => r.json()),
  // ...
};
```

No page or component changes needed.

---

## Directory Layout

```
frontend/
  app/                    Next.js App Router pages
    layout.tsx            Root layout wrapping all pages in AppShell
    page.tsx              Overview dashboard (/)
    not-found.tsx         404 page
    tools/                /tools and /tools/[name]
    sessions/             /sessions and /sessions/[uuid]
    instructions/         /instructions and /instructions/[uuid]
    projects/             /projects and /projects/[id]
    npl/                  /npl — NPL expression explorer
    globals.css           CSS variables + Tailwind base

  components/
    shell/
      AppShell.tsx        Root layout shell (sidebar + topbar + palette)
      Sidebar.tsx         Left nav with grouped links
      TopBar.tsx          Top bar with breadcrumbs, theme toggle, search
      CommandPalette.tsx  ⌘K command palette (tools/sessions/instructions/projects/nav)
      ThemeToggle.tsx     Dark/light toggle persisted to localStorage

    primitives/
      Badge.tsx           Small label chip
      Card.tsx            Surface container
      EmptyState.tsx      Zero-state placeholder with icon + action
      PageHeader.tsx      Page title + description header
      Skeleton.tsx        Animated loading placeholder
      CodeBlock.tsx       Syntax-highlighted code block
      DataTable.tsx       Generic sortable table
      Tag.tsx             Compact tag chip

    forms/                Form controls (inputs, selects, etc.)

  lib/
    api/                  API facade (see above)
```

---

## Conventions

- Every interactive page starts with `"use client"`.
- Primitives use **named exports** (e.g. `import { Badge } from "@/components/primitives/Badge"`).
- Use the `@/*` path alias — never relative paths across directories.
- Tailwind design tokens: `bg-background`, `bg-surface`, `bg-surface-raised`, `text-foreground`, `text-muted`, `text-subtle`, `border-border`, `text-accent`, `bg-brand-500`.
- Theme is controlled via `data-theme` on `<html>`: `"dark"` (default) or `"light"`. CSS vars in `globals.css` respond accordingly.

---

## Regenerate Mock Catalog

If the MCP tool registry changes, refresh the mock data with:

```bash
uv run python -c "
from npl_mcp.pm_tools import export_mock_catalog
import json, pathlib
data = export_mock_catalog()
pathlib.Path('frontend/lib/api/impl/mock-catalog.json').write_text(json.dumps(data, indent=2))
print('done')
"
```

Then update `lib/api/impl/mock.ts` to import from the new JSON.

---

## Known Stubs (Tier 2 / 3)

These routes render a "coming soon" banner. Implementation depends on backing server modules that are not yet complete.

| Route | Status |
|---|---|
| `/metrics` | Tier 2 — awaiting metrics module |
| `/chat` | Tier 3 — awaiting chat module |
| `/artifacts` | Tier 3 — awaiting artifact store |
| `/orchestration` | Tier 3 — awaiting pipeline runner |
