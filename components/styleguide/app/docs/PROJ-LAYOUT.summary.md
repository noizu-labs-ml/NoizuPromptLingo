# Project Layout Summary — styleguide-engine/app

```
app/
├── src/
│   ├── app/                    # Pages, API routes, globals.css
│   ├── components/             # UI: sections (21), showcases, demos, pkg
│   │   ├── sections/index.ts   #   Section registry
│   │   └── generated/          #   Auto-generated JSX (gitignored)
│   ├── config/                 # 3 themes × ~19 YAML facets + loaders
│   │   ├── theme-style-guide/  #   Base theme
│   │   ├── theme-cyberpunk/    #   Cyberpunk (inherits base)
│   │   └── theme-sumi-e/       #   Sumi-e (inherits base)
│   ├── lib/                    # CSS generators (22), defaults cascade, JSX gen
│   │   ├── css-gen/            #   22 generators + 4-pass defaults
│   │   ├── jsx-gen/            #   Snippet assembler
│   │   └── css-cache.ts        #   Scoping, caching, output
│   └── scripts/                # generate-css.ts, watch-yaml.ts
├── docs/
│   ├── arch/                   # Architecture docs (8)
│   ├── guides/                 # Theme author guides (3)
│   ├── reference/              # YAML schemas, tokens, cascade, generators (4)
│   ├── troubleshooting/        # Diagnostic checklists (1)
│   ├── layout/                 # Detailed breakdowns
│   ├── resources/              # Research PDFs and notes
│   ├── overview.md             # Entry point — purpose, skill workflow
│   ├── PROJ-ARCH.md            # Architecture overview
│   └── PROJ-LAYOUT.md          # Project structure
├── public/themes/              # Per-theme CSS (generated)
├── scripts/create-theme.sh     # Theme scaffolding
├── regen.sh                    # Regenerate CSS from YAML
├── next.config.ts
├── package.json
├── postcss.config.mjs
└── tsconfig.json
```
