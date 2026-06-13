# Project Layout

```
robots-unite.com/
├── web/                            # Next.js 15 landing page
│   ├── app/                        #   App Router pages and global styles
│   │   ├── layout.tsx              #     Root layout (fonts, metadata, body)
│   │   ├── page.tsx                #     Landing page — assembles all sections
│   │   ├── globals.css             #     Tailwind directives + custom properties
│   │   └── waitlist-form.tsx       #     Email capture form component
│   ├── components/                 #   Shared React components
│   │   ├── layout/                 #     Page-level structure (header, footer)
│   │   ├── sections/               #     Landing page sections (hero, features, CTA, etc.)
│   │   └── ui/                     #     Primitives (button, input)
│   ├── lib/                        #   Utility functions
│   │   └── utils.ts                #     clsx + tailwind-merge helper
│   ├── .tool-versions              #   asdf/mise runtime versions
│   ├── build.sh                    #   Docker build script
│   ├── Dockerfile                  #   Multi-stage Next.js + nginx image
│   ├── nginx.conf                  #   Production reverse proxy config
│   ├── next.config.ts              #   Next.js configuration
│   ├── package.json                #   Dependencies and scripts
│   ├── postcss.config.mjs          #   PostCSS (Tailwind)
│   ├── tailwind.config.ts          #   Tailwind theme customization
│   └── tsconfig.json               #   TypeScript configuration
├── design/                         # Brand assets and style reference
│   ├── robots-unite-logo.svg       #   Primary logo
│   ├── robots-unite-mark.svg       #   Logo mark
│   ├── robots-unite-mark-reversed.svg  # Reversed mark (dark backgrounds)
│   ├── robots-unite-favicon.svg    #   Favicon
│   ├── logo-preview.html           #   Logo preview page
│   ├── styleguide.html             #   Interactive style guide
│   ├── styleguide.md               #   Style guide (markdown)
│   └── styleguide-tokens.md        #   Design token reference
├── docs/                           # Project documentation
│   ├── PROJ-ARCH.md                #   Architecture overview
│   ├── PROJ-ARCH.summary.md        #   Architecture summary (companion)
│   ├── PROJ-LAYOUT.md              #   This file
│   ├── PROJ-LAYOUT.summary.md     #   Companion tree summary
│   └── arch/                       #   Detailed architecture documents
│       ├── build-pipeline.md       #     Docker build and deploy pipeline
│       ├── frontend.md             #     Frontend component architecture
│       └── platform-design.md      #     Planned full platform architecture
├── .gemini/                        # Gemini Code Assist configuration
│   ├── config.yaml
│   └── styleguide.md
├── .gitignore                      # Git ignore rules
└── README.md                       # Project overview, concept, and roadmap
```

## Key Files

| File | Purpose |
|------|---------|
| `web/app/page.tsx` | Landing page entry — composes all section components |
| `web/app/globals.css` | Design tokens as CSS custom properties + Tailwind |
| `web/Dockerfile` | Production build: Next.js static export → nginx |
| `web/build.sh` | Builds the Docker image |
| `design/styleguide-tokens.md` | Authoritative color, typography, and spacing tokens |
| `README.md` | Full product concept, IA, user flows, and MVP scope |

## Dev Commands

| Command | Where | Purpose |
|---------|-------|---------|
| `npm run dev` | `web/` | Start Next.js dev server |
| `npm run build` | `web/` | Production build |
| `npm run lint` | `web/` | Run ESLint |
| `./build.sh` | `web/` | Build Docker image |
