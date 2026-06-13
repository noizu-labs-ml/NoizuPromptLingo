# Project Layout Summary

```
therobotknows.com/
├── web/                            # Next.js 16 application
│   ├── src/
│   │   ├── app/                    # App Router (dashboard + universe route groups)
│   │   ├── components/             # UI by domain (entries, graph, generation, layout, ui)
│   │   ├── data/                   # Mock data modules
│   │   ├── lib/                    # Utilities
│   │   └── types/                  # TypeScript types
│   ├── public/                     # Static assets
│   ├── .tool-versions              # Node.js 22.22.0
│   ├── Dockerfile
│   ├── build.sh
│   └── package.json
├── design/                         # Visual design assets + logo SVGs
│   ├── logos/
│   └── direction-{a,b,c}-*        # Three design directions
├── .gemini/                        # Gemini Code Assist config
├── docs/                           # Documentation
│   ├── PROJ-LAYOUT.md
│   ├── PROJ-LAYOUT.summary.md
│   └── layout/web.md
├── .gitignore
└── README.md                       # Full product spec
```
