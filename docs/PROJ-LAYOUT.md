# Project Layout

```
jailbreakingsite.com/
├── design/                             # Static design explorations (HTML mockups)
│   ├── direction-a-clean-room.html     #   Clean-room aesthetic variant
│   ├── direction-b-red-alert.html      #   Red-alert aesthetic variant
│   └── landing-page.html               #   Landing page mockup
├── web/                                # Next.js 16 application (primary deliverable)
│   ├── src/
│   │   └── app/                        #   App Router pages and components
│   │       ├── globals.css             #     Global styles (Tailwind v4)
│   │       ├── layout.tsx              #     Root layout
│   │       ├── page.tsx                #     Landing page
│   │       └── waitlist-form.tsx       #     Waitlist signup component
│   ├── .tool-versions                  #   asdf/mise — Node.js 22.22.0
│   ├── build.sh                        #   Production build script
│   ├── Dockerfile                      #   Container image definition
│   ├── next.config.ts                  #   Next.js configuration
│   ├── nginx.conf                      #   Reverse proxy config (container)
│   ├── package.json                    #   Dependencies and scripts
│   ├── postcss.config.mjs              #   PostCSS (Tailwind plugin)
│   └── tsconfig.json                   #   TypeScript configuration
├── docs/                               # Project documentation
│   ├── PROJ-LAYOUT.md                  #   This file
│   └── PROJ-LAYOUT.summary.md         #   Quick-reference tree
├── .gemini/                            # Gemini Code Assist configuration
│   ├── config.yaml                     #   Review triggers and settings
│   └── styleguide.md                   #   Style guide for Gemini reviews
├── .gitignore                          # Git ignore rules
├── README.md                           # Project overview, problem/solution, roadmap
├── STYLE-GUIDE.md                      # SecOps terminal design system spec
└── styleguide-secops-terminal.html     # Interactive style guide preview (generated)
```

## Key Files

| File | Purpose |
|------|---------|
| `web/src/app/page.tsx` | Landing page — primary entry point |
| `web/src/app/waitlist-form.tsx` | Waitlist signup component |
| `STYLE-GUIDE.md` | SecOps terminal design system (colors, typography, components) |
| `web/Dockerfile` | Container build for deployment |
| `web/.tool-versions` | Pins Node.js 22.22.0 via asdf/mise |

## Stack

- **Framework:** Next.js 16 (App Router) + React 19
- **Styling:** Tailwind CSS v4 via PostCSS
- **Language:** TypeScript 5
- **Runtime:** Node.js 22
- **Container:** Docker + nginx reverse proxy
