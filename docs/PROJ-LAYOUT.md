# Project Layout

> MCP Host — unified MCP hosting platform (justmcp.it | mcpjumpst.art | safemcp.com)

```
mcp-host/
├── app/                            # Application code → [layout/app.md](layout/app.md)
│   └── frontend/                   #   Next.js 15 frontend (App Router)
│       ├── src/                    #   Source: pages, config, scripts
│       └── public/                 #   Static assets (generated theme CSS)
├── design/                         # Design assets → [layout/design.md](layout/design.md)
│   ├── logos/                      #   SVG logomarks and lockups (7 variants)
│   ├── theme/                      #   YAML style-guide definitions (4 themes)
│   ├── wireframes/                 #   SVG wireframes for key pages
│   ├── SITEMAP.md                  #   Full page flow and route inventory
│   └── STYLE-DIRECTION*.md         #   Visual direction explorations (A–D)
├── docs/                           # Documentation
│   ├── PROJ-LAYOUT.md              #   This file
│   ├── PROJ-LAYOUT.summary.md      #   Condensed tree reference
│   └── layout/                     #   Detailed per-directory breakdowns
├── .gemini/                        # Gemini Code Assist config
│   ├── config.yaml                 #   Review settings, ignore patterns
│   └── styleguide.md               #   Code style guide for reviews
├── .gitignore                      # Ignores: node_modules, .next, .env*, generated CSS
└── README.md                       # Project vision, architecture, security model, roadmap
```

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `app/frontend/.npmrc` | Configured for `@the-robot-lives` GitHub Packages registry |
| `app/frontend/.env` | Create from environment — not committed (gitignored) |

## Theme System

Four YAML-driven themes in `design/theme/` are mirrored into `app/frontend/src/config/`:

| Theme | Directory |
|-------|-----------|
| Bold | `theme-bold/` |
| Enterprise | `theme-enterprise/` |
| Minimal | `theme-minimal/` |
| Nocturne | `theme-nocturne/` |

Each theme contains 12 YAML files: `branding`, `color-modes`, `color-palette`, `globals`, `meta`, `page-layouts`, `semantic-classes`, `semantic-groups`, `shell-layouts`, `spacing`, `typography`, `vars`.

CSS is generated via `npm run generate-css` → `src/scripts/generate-css.ts` → `public/themes/*.css` + `design-system.generated.css` (both gitignored).
