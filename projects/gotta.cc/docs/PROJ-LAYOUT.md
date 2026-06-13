# Project Layout

```
gotta.cc/
├── design/                     # Visual direction & brand assets
│   ├── README.md               #   Decision framework for 3 design directions
│   ├── direction-a-*.md/html   #   Ink & Paper — editorial 100%
│   ├── direction-b-*.md/html   #   Warm Browse — editorial + playful
│   ├── direction-c-*.md/html   #   Retro Revival — bold expressive
│   ├── gotta-cc-combo.svg      #   Combined logo mark
│   ├── gotta-cc-favicon.svg    #   Favicon
│   ├── gotta-cc-mark.svg       #   Logo mark only
│   ├── gotta-cc-mono.svg       #   Monochrome variant
│   └── gotta-cc-reversed.svg   #   Reversed (light-on-dark)
├── web/                        # Next.js 16 landing page / waitlist
│   ├── src/
│   │   └── app/
│   │       ├── layout.tsx      #     Root layout
│   │       ├── page.tsx        #     Landing page
│   │       ├── waitlist-form.tsx#    Waitlist signup form
│   │       └── globals.css     #     Global styles (Tailwind 4)
│   ├── public/
│   │   └── favicon.svg         #   Favicon asset
│   ├── build.sh                #   Docker build script
│   ├── Dockerfile              #   Multi-stage Next.js container
│   ├── nginx.conf              #   Nginx config for container
│   ├── next.config.ts          #   Next.js configuration
│   ├── package.json            #   Dependencies (Next 16, React 19, Tailwind 4)
│   ├── postcss.config.mjs      #   PostCSS / Tailwind setup
│   ├── tsconfig.json           #   TypeScript config
│   └── .tool-versions          #   Node.js 22.22.0 (asdf/mise)
├── docs/                       # Documentation
│   ├── PROJ-LAYOUT.md          #   This file
│   └── PROJ-LAYOUT.summary.md  #   Quick-reference tree
├── .gemini/                    # Gemini Code Assist config
│   ├── config.yaml             #   Review settings, ignore patterns
│   └── styleguide.md           #   Code style guide for Gemini
├── .gitignore                  # Git ignores (node_modules, .next, .env*, etc.)
└── README.md                   # Product spec — elevator pitch, scoring system, IA, flows
```

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `web/.tool-versions` | Ensure Node.js 22.22.0 via asdf or mise |
| `web/package.json` | Run `npm install` in `web/` before dev |

## Status

Concept / pre-development. The `web/` directory contains a Next.js waitlist landing page. The `design/` directory has three visual directions pending selection.
