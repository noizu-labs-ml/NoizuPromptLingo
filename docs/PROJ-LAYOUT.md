# Project Layout

```
therobotmakes.com/
├── blueprint/                      # Blueprint theme — HTML component showcases + CSS
│   ├── style.css                   #   Theme stylesheet
│   ├── head.html                   #   Shared HTML head
│   ├── nav.html                    #   Shared navigation
│   └── *.html                      #   Component pages (buttons, cards, typography, etc.)
├── brush/                          # Brush (ink/calligraphy) theme — same structure
│   ├── style.css
│   ├── head.html
│   ├── header.html
│   └── *.html                      #   Includes screen-* pages (landing, dashboard, etc.)
├── cyberpunk/                      # Cyberpunk theme — same structure as blueprint
├── sumi-e/                         # Sumi-e (Japanese ink) theme — same structure
├── swiss/                          # Swiss (modernist) theme — same structure
├── template/                       # Shared styleguide template assets
│   ├── hui.css                     #   Base UI CSS
│   ├── sg.css                      #   Styleguide CSS
│   └── sg.js                       #   Styleguide JS (theme switching, nav)
├── web/                            # Next.js application (primary)
│   ├── src/app/                    #   App Router pages
│   │   ├── layout.tsx              #     Root layout
│   │   ├── page.tsx                #     Homepage
│   │   ├── globals.css             #     Global styles
│   │   └── favicon.ico             #     Browser icon
│   ├── public/                     #   Static assets (SVG icons)
│   ├── build.sh                    #   Docker build script
│   ├── Dockerfile                  #   Container image definition
│   ├── nginx.conf                  #   Reverse proxy config
│   ├── package.json                #   Dependencies and scripts
│   ├── next.config.ts              #   Next.js configuration
│   ├── tsconfig.json               #   TypeScript configuration
│   ├── eslint.config.mjs           #   ESLint configuration
│   └── postcss.config.mjs          #   PostCSS configuration
├── web.sumi-e/                     # Next.js application (sumi-e variant)
│   └── ...                         #   Same structure as web/
├── project/                        # Project management artifacts
│   ├── personas/                   #   User personas (10 files)
│   │   ├── index.md                #     Persona index
│   │   └── 01-*.md … 10-*.md      #     Individual persona definitions
│   └── user-stories/               #   User stories (100 files)
│       ├── index.md                #     Story index
│       └── INK-001.md … INK-100.md #     Individual stories
├── docs/                           # Documentation
│   ├── PROJ-ARCH.md                #   Architecture and system design
│   ├── PROJ-ARCH.summary.md        #   Architecture summary
│   ├── PROJ-LAYOUT.md              #   This file
│   ├── PROJ-LAYOUT.summary.md      #   Layout summary
│   ├── arch/                       #   Architecture decision records
│   │   ├── backend-integration.md
│   │   ├── component-hierarchy.md
│   │   ├── decisions.md
│   │   └── theme-system.md
│   └── layout/                     #   (legacy — may be removed)
├── .claude/                        # Claude Code configuration
│   ├── agents/                     #   Agent definitions (9 agents)
│   └── commands/                   #   Slash command definitions
├── .gemini/                        # Gemini Code Assist configuration
│   ├── config.yaml                 #   Review settings
│   └── styleguide.md               #   Style guide for Gemini
├── styleguide-*.html               # Standalone HTML style guides (5 themes × v1/v2)
├── styleguide-components.css       # Shared component styles for styleguides
├── styleguide-components.js        # Shared component JS for styleguides
├── styleguide-reference.html       # Reference styleguide
├── styleguide-template.html        # Template styleguide
├── .gitignore                      # Git ignore patterns
├── .tool-versions                  # ASDF tool versions (Node.js 22.22.0)
└── README.md                       # Project documentation
```

## Key Notes

- **5 Design Themes** — Blueprint, Brush, Cyberpunk, Sumi-e, Swiss — each as a standalone directory with HTML showcases
- **Dual Web Apps** — `web/` (primary) and `web.sumi-e/` (sumi-e themed variant), both Next.js 15 with App Router
- **Static Styleguides** — Root-level `styleguide-*.html` files are self-contained theme previews
- **Project Management** — 10 personas and 100 user stories under `project/`
- **Docker-Ready** — Each web app includes Dockerfile, build.sh, and nginx.conf

## Build Commands

```bash
cd web
npm install          # Install dependencies
npm run dev          # Start development server
npm run build        # Production build
npm start            # Start production server
```
