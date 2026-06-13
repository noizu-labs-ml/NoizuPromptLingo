# Project Layout

TheRobotKnows.com — AI-powered knowledge graph for creative universes. Next.js 16 frontend prototype with D3.js graph visualization.

```
therobotknows.com/
├── web/                            # Next.js application → [layout/web.md](layout/web.md)
│   ├── src/
│   │   ├── app/                    #   App Router pages (dashboard + universe routes)
│   │   ├── components/             #   UI components by domain
│   │   ├── data/                   #   Mock data modules
│   │   ├── lib/                    #   Utilities (cn, constants, mock-data)
│   │   └── types/                  #   TypeScript type definitions
│   ├── public/                     #   Static assets (favicon)
│   ├── .tool-versions              #   asdf — Node.js 22.22.0
│   ├── build.sh                    #   Docker build script
│   ├── Dockerfile                  #   Container image definition
│   ├── nginx.conf                  #   Production reverse proxy config
│   ├── package.json                #   Dependencies and scripts
│   ├── next.config.ts              #   Next.js configuration
│   ├── postcss.config.mjs          #   PostCSS / Tailwind v4 setup
│   └── tsconfig.json               #   TypeScript configuration
├── design/                         # Visual design assets
│   ├── logos/                      #   SVG logo variants + preview.html
│   ├── direction-a-vellum-ink.*    #   Design direction A (selected)
│   ├── direction-b-scholars-terminal.*
│   └── direction-c-illuminated.*
├── .gemini/                        # Gemini Code Assist config
│   ├── config.yaml
│   └── styleguide.md
├── docs/                           # Documentation
│   ├── PROJ-LAYOUT.md              #   This file
│   └── layout/                     #   Detailed breakdowns
├── .gitignore
└── README.md                       # Project spec and product vision
```

## Key Files

| File | Purpose |
|------|---------|
| `README.md` | Full product spec: problem, solution, user flows, visual direction, tech stack |
| `web/package.json` | Next.js 16, React 19, D3.js force graph, Tailwind v4, Lucide icons |
| `web/.tool-versions` | Node.js 22.22.0 (asdf) |
| `web/build.sh` | Docker image build script |
| `design/direction-a-vellum-ink.md` | Selected visual direction — "Vellum & Ink" editorial style |

## Route Map

| Route | Page |
|-------|------|
| `/` | Dashboard — universe list, recent activity |
| `/new` | Create new universe |
| `/about` | About page |
| `/[universeId]` | Universe overview |
| `/[universeId]/entries` | Entry list with filters |
| `/[universeId]/entries/[entryId]` | Entry detail — connections, flags, generation |
| `/[universeId]/graph` | D3.js knowledge graph visualization |
| `/[universeId]/timeline` | Chronological event timeline |
| `/[universeId]/generate` | AI generation studio |
| `/[universeId]/consistency` | Consistency flags and resolution queue |
