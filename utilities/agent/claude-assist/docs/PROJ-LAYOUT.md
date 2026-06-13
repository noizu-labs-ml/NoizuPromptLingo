# Project Layout

```
claude-assist/
├── packages/                       # Monorepo workspaces (pnpm)
│   ├── api/                        #   REST API server → [layout/api.md](layout/api.md)
│   ├── cli/                        #   Interactive TUI client → [layout/cli.md](layout/cli.md)
│   ├── shared/                     #   Shared types and parsers → [layout/shared.md](layout/shared.md)
│   └── web/                        #   Browser UI (Vite + React) → [layout/web.md](layout/web.md)
├── design/                         # Visual design assets
│   ├── logos/                      #   SVG logo variants + preview
│   ├── mockup-*.svg                #   Page mockups (dashboard, search, thread)
│   ├── SITEMAP.md                  #   Information architecture
│   ├── style-guide.md              #   Design system tokens and rules
│   └── README.md                   #   Design overview
├── docs/                           # Project documentation
│   ├── arch/                      #   Architecture detail pages
│   ├── layout/                    #   Layout detail pages
│   ├── PROJ-ARCH.md               #   Architecture overview
│   ├── PROJ-ARCH.summary.md       #   Architecture summary
│   ├── PROJ-LAYOUT.md             #   This file — project structure
│   └── PROJ-LAYOUT.summary.md     #   Layout summary
├── .gitignore                      # Ignored files
├── INSTALL.md                      # Setup and installation guide
├── package.json                    # Root workspace — scripts: dev:api, dev:web, dev:cli
├── pnpm-lock.yaml                  # Lockfile
├── pnpm-workspace.yaml             # Workspace config (packages/*)
├── tsconfig.base.json              # Shared TypeScript config
└── README.md                       # Project overview
```

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `pnpm-lock.yaml` | Run `pnpm install` after clone |
| `INSTALL.md` | Follow for first-time setup |
