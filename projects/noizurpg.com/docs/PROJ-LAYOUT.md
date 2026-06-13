# Project Layout

```
noizurpg.com/
├── design/                         # Visual design assets and direction explorations
│   ├── logos/                      #   Logo suite (SVG mark, combo, favicon)
│   │   ├── LOGO-USAGE.md          #     Usage guidelines and variants
│   │   ├── noizurpg-combo-*.svg   #     Combo mark (dark/light)
│   │   ├── noizurpg-mark-*.svg    #     Standalone mark (color/mono)
│   │   ├── noizurpg-favicon.svg   #     Browser favicon source
│   │   └── preview.html           #     Logo preview page
│   ├── direction-a-workshop.html  #   Design direction: Workshop theme
│   ├── direction-b-wonder.html    #   Design direction: Wonder theme
│   └── direction-c-grimoire.html  #   Design direction: Grimoire theme
├── web/                            # Next.js landing site → [layout/web.md](layout/web.md)
│   ├── src/app/                    #   App Router pages and components
│   ├── public/                     #   Static assets (favicon)
│   ├── .tool-versions              #   asdf/mise runtime versions
│   ├── build.sh                    #   Docker build helper script
│   ├── Dockerfile                  #   Container image definition
│   ├── next.config.ts              #   Next.js configuration
│   ├── nginx.conf                  #   Reverse proxy config (production)
│   ├── package.json                #   Dependencies and scripts
│   ├── postcss.config.mjs          #   PostCSS / Tailwind pipeline
│   └── tsconfig.json               #   TypeScript compiler options
├── docs/                           # Documentation
│   ├── PROJ-LAYOUT.md              #   This file
│   ├── PROJ-LAYOUT.summary.md     #   Tree-only quick reference
│   └── layout/                     #   Detailed layout breakdowns
├── .gemini/                        # Gemini Code Assist configuration
│   ├── config.yaml                 #   PR review settings
│   └── styleguide.md               #   Style guide for reviews
├── .gitignore                      # Git ignore rules
└── README.md                       # Project overview, problem statement, architecture
```

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `web/.tool-versions` | Ensure Node.js version is installed via asdf/mise |
| `web/package.json` | Run `npm install` in `web/` before dev |
