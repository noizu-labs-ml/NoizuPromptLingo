# Project Layout

```
aifighter.com/
├── design/                         # Visual design assets and prototypes
│   ├── landing-page.html           #   Landing page HTML prototype
│   ├── style-guide.html            #   Interactive style guide (rendered)
│   └── style-guide.md              #   Style guide source (Neural Neon theme)
├── project/                        # Project management artifacts
│   ├── personas/                   #   User personas (10) → [layout/project.md](layout/project.md)
│   └── user-stories/               #   User stories (US-001–US-100) → [layout/project.md](layout/project.md)
├── web/                            # Next.js 16 landing/waitlist site → [layout/web.md](layout/web.md)
│   ├── public/                     #   Static assets (favicon)
│   ├── src/                        #   App source (App Router + components)
│   ├── .tool-versions              #   mise/asdf runtime versions
│   ├── build.sh                    #   Docker build helper
│   ├── Dockerfile                  #   Container image definition
│   ├── nginx.conf                  #   Production reverse proxy config
│   ├── package.json                #   Dependencies and scripts
│   └── tsconfig.json               #   TypeScript configuration
├── docs/                           # Documentation
│   ├── PROJ-LAYOUT.md              #   This file
│   ├── PROJ-LAYOUT.summary.md      #   Tree-only quick reference
│   └── layout/                     #   Detailed directory breakdowns
├── .gemini/                        # Gemini Code Assist configuration
│   ├── config.yaml                 #   Review settings
│   └── styleguide.md               #   Code style rules for Gemini
├── .gitignore                      # Git ignore rules
├── README.md                       # Project brief — concept, market, MVP scope
├── style-guide.html                # Root-level style guide (copy of design/)
└── STYLE-GUIDE.md                  # Root-level style guide source
```

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `web/.tool-versions` | Ensure Node.js version is installed via mise/asdf |
| `web/package.json` | Run `npm install` in `web/` before dev |

## Quick Reference

- **Landing site**: `web/` — Next.js 16 + React 19 + Tailwind 4
- **Design assets**: `design/` — HTML prototypes, style guide
- **Personas**: `project/personas/` — 10 personas (01-the-tinkerer through 10-the-data-artist)
- **User stories**: `project/user-stories/` — 100 stories (US-001 through US-100)
