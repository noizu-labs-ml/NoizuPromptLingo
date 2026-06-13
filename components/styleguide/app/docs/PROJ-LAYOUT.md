# Project Layout — styleguide-engine/app

A Next.js app that generates a live design-system style guide from YAML configuration. Supports multiple themes with inheritance.

```
app/
├── src/                                # Source code → [layout/app-src.md](layout/app-src.md)
│   ├── app/                            #   App Router pages, API routes, globals.css
│   │   ├── api/                        #   Dev-time REST endpoint (save-config)
│   │   ├── section/                    #   Section route
│   │   ├── globals.css                 #   Tailwind + imports generated CSS
│   │   ├── layout.tsx                  #   Root layout, theme init, ThemeCSS
│   │   └── page.tsx                    #   Main page — loads all configs, renders sections
│   ├── components/                     #   UI components (40+)
│   │   ├── demos/                      #   Interactive demo components
│   │   ├── generated/                  #   Auto-generated JSX from snippets (gitignored)
│   │   ├── pkg/                        #   Reusable UI primitives
│   │   ├── sections/                   #   Page section renderers (21 registered)
│   │   │   └── index.ts                #   Section registry — maps IDs to components
│   │   ├── ThemeAwareSections.tsx       #   Client-side theme-aware section renderer
│   │   ├── ThemeConfigContext.tsx        #   React context for active theme
│   │   ├── ThemeCSS.tsx                 #   Per-theme CSS lazy loader
│   │   └── *.tsx                        #   Showcases, previews, and UI utilities
│   ├── config/                         #   Theme configurations — 3 themes
│   │   ├── theme-style-guide/          #   Base theme (19 YAML facets)
│   │   ├── theme-cyberpunk/            #   Cyberpunk theme (inherits base)
│   │   ├── theme-sumi-e/               #   Sumi-e theme (inherits base)
│   │   ├── loader.ts                   #   Theme discovery, merge, normalize
│   │   └── branding-loader.ts          #   Brand identity config loader
│   ├── lib/                            #   Generation engine and utilities
│   │   ├── css-gen/                    #   22 CSS generators + defaults cascade
│   │   │   ├── index.ts                #   Orchestrator — generateCSSSections()
│   │   │   └── defaults.ts             #   4-pass token cascade (~300 tokens)
│   │   ├── jsx-gen/                    #   JSX snippet assembler + import collation
│   │   ├── css-cache.ts                #   SHA-256 cache, scoping, output assembly
│   │   ├── normalizer.ts               #   YAML simple → internal typed format
│   │   ├── types.ts                    #   All TypeScript interfaces
│   │   └── topo-sort.ts                #   Topological sort for snippet dependencies
│   └── scripts/                        #   Build-time scripts
│       ├── generate-css.ts             #   Entry point for CSS generation
│       └── watch-yaml.ts               #   YAML file watcher
├── docs/                               # Documentation
│   ├── arch/                           #   Architecture (8 docs)
│   │   ├── config-pipeline.md          #     Config loading pipeline
│   │   ├── generation.md               #     CSS generation architecture
│   │   ├── rendering.md                #     Page rendering flow
│   │   ├── yaml-configuration.md       #     YAML format decisions
│   │   ├── adding-generators.md        #     How to extend CSS pipeline
│   │   ├── css-scoping.md              #     Multi-theme scoping model
│   │   ├── snippets.md                 #     CSS/JSX snippet assembly
│   │   └── custom-sections.md          #     Page section extensibility
│   ├── guides/                         #   Theme author guides (3 docs)
│   │   ├── creating-themes.md          #     Scaffolding, inheritance, custom sections
│   │   ├── branding.md                 #     Logo, intro hero, font loading
│   │   └── variants.md                 #     Override/variant file system
│   ├── reference/                      #   Reference material (4 docs)
│   │   ├── yaml-config.md              #     All 19 YAML file schemas
│   │   ├── token-reference.md          #     ~300 auto-generated CSS tokens
│   │   ├── cascade.md                  #     4-pass defaults resolver
│   │   └── css-generators.md           #     22 generators, pipeline order
│   ├── troubleshooting/                #   Diagnostics (1 doc)
│   │   └── troubleshooting.md          #     Common issues and checklists
│   ├── layout/                         #   Detailed layout breakdowns
│   │   └── app-src.md                  #     Full src/ tree
│   ├── resources/                      #   Research PDFs, UX notes
│   ├── overview.md                     #   Entry point — purpose, skill workflow
│   ├── PROJ-ARCH.md                    #   Architecture overview
│   ├── PROJ-ARCH.summary.md            #   Architecture summary
│   ├── PROJ-LAYOUT.md                  #   You are here
│   └── PROJ-LAYOUT.summary.md          #   Layout summary
├── public/
│   └── themes/                         # Per-theme CSS (generated)
│       ├── style-guide.css
│       ├── cyberpunk.css
│       └── sumi-e.css
├── scripts/
│   └── create-theme.sh                # Theme scaffolding script
├── out/                                # Static export output (gitignored)
├── .gitignore
├── next.config.ts                      # Static export, YAML raw-loader
├── package.json                        # Dependencies and scripts
├── postcss.config.mjs                  # Tailwind v4 via @tailwindcss/postcss
├── regen.sh                            # Clear caches, regenerate CSS from YAML
└── tsconfig.json                       # TypeScript config (bundler resolution)
```

## Key Scripts

| Script | Command | Purpose |
|--------|---------|---------|
| `regen.sh` | `./regen.sh` | Clear `.cache/`, regenerate CSS, nudge Tailwind |
| `scripts/create-theme.sh` | `./scripts/create-theme.sh <slug>` | Scaffold a new theme directory |
| generate-css | `npm run generate-css` | Run CSS generation from YAML config |
| dev | `npm run dev` | Start Next.js dev server |

**Do not run** `npx next build` — it breaks the running dev server. Use `tsc --noEmit` for type checking.

## Generated Files (gitignored)

| File | Source |
|------|--------|
| `src/app/design-system.generated.css` | `generate-css.ts` from YAML config |
| `src/components/generated/*.tsx` | JSX snippet assembly pipeline |
| `public/themes/*.css` | Per-theme CSS for lazy loading |
| `.cache/` | Checksum-keyed CSS cache |
| `out/` | Static export output |

## Configuration Pipeline

```
src/config/theme-{name}/*.yaml (3 themes × ~19 facets each)
        ↓
src/config/loader.ts + branding-loader.ts (discover, merge, normalize)
        ↓
src/lib/css-gen/defaults.ts (4-pass cascade: 12 seeds → 300 tokens)
        ↓
src/lib/css-gen/*.ts (22 generators)
        ↓
src/lib/css-cache.ts (scope per theme, assemble, checksum)
        ↓
src/app/design-system.generated.css + public/themes/{slug}.css
```

### Themes

| Theme | Directory | Description |
|-------|-----------|-------------|
| style-guide | `theme-style-guide/` | Base theme — 19 facets, all defaults |
| cyberpunk | `theme-cyberpunk/` | Neon/terminal aesthetic (inherits base) |
| sumi-e | `theme-sumi-e/` | Japanese ink-wash aesthetic (inherits base) |
