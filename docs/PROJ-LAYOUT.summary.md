# Project Layout — Summary

```
mcp-host/
├── app/
│   └── frontend/               # Next.js 15 (App Router, Tailwind 4)
│       ├── src/
│       │   ├── app/            # Pages: landing, styleguide
│       │   ├── config/         # Theme YAML configs (4 themes × 12 files)
│       │   └── scripts/        # CSS generation script
│       ├── public/themes/      # Generated theme CSS (gitignored)
│       ├── package.json
│       ├── tsconfig.json
│       └── .npmrc
├── design/
│   ├── logos/                  # SVG logomarks and lockups
│   ├── theme/                  # Source-of-truth YAML themes (4 themes)
│   ├── wireframes/             # SVG wireframes
│   ├── SITEMAP.md              # Page flow and route inventory
│   └── STYLE-DIRECTION*.md     # Visual direction docs
├── docs/
│   ├── PROJ-LAYOUT.md
│   ├── PROJ-LAYOUT.summary.md
│   └── layout/
├── .gemini/                    # Gemini Code Assist config
├── .gitignore
└── README.md
```
