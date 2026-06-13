# Project Layout — noizu.com

Next.js 14 marketing/portfolio site for noizu.com with scroll-driven animations, parallax effects, and published research papers.

```
noizu.com/
├── src/                            # Application source → [layout/src.md](layout/src.md)
│   ├── app/                        #   Next.js App Router pages
│   ├── components/                 #   React components (hero, sequences, UI)
│   └── hooks/                      #   Custom React hooks
├── public/                         # Static assets
│   ├── images/                     #   Background textures and overlays
│   ├── llms.txt                    #   LLM-readable site summary
│   └── manifest.json               #   PWA manifest
├── design/                         # Design references and style guides
│   ├── STYLE-GUIDE.md              #   Design system documentation
│   ├── SCROLL-EFFECTS-GUIDE.md     #   Scroll animation patterns
│   ├── style-guide.html            #   Interactive style guide preview
│   ├── circuit-board-preview.html  #   Circuit board visual prototype
│   └── screen-intellect.html       #   Screen effect prototype
├── docs/                           # Project documentation
│   ├── PROJ-LAYOUT.md              #   This file
│   ├── cypress-attributes.md       #   Test attribute conventions
│   └── UI-UX.info.md               #   UI/UX design notes
├── .tool-versions                  # asdf — Node.js 22.22.0
├── .eslintrc.json                  # ESLint configuration
├── .dockerignore                   # Docker build exclusions
├── .gitignore                      # Git exclusions
├── envrc.example                   # Environment template — copy to .envrc
├── Dockerfile                      # Production container build
├── build.sh                        # Build script
├── nginx.conf                      # Nginx reverse proxy config (production)
├── next.config.mjs                 # Next.js configuration
├── tailwind.config.ts              # Tailwind CSS theme and plugins
├── postcss.config.mjs              # PostCSS pipeline
├── tsconfig.json                   # TypeScript configuration
├── package.json                    # Dependencies and scripts
├── 00_the_accord.md                # Source content — The Accord
├── 01_manifesto.md                 # Source content — Manifesto
├── 02_technical_article.md         # Source content — Technical article
└── cognitive-architecture.html     # Standalone cognitive architecture page
```

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `.envrc` | Copy from `envrc.example`, fill secrets, run `direnv allow` |

## npm Scripts

| Command | Purpose |
|---------|---------|
| `npm run dev` | Start development server |
| `npm run build` | Production build |
| `npm run start` | Start production server |
| `npm run lint` | Run ESLint |
