# app/ — Application Code

```
app/
└── frontend/                           # Next.js 15 frontend
    ├── src/
    │   ├── app/                        # App Router pages
    │   │   ├── layout.tsx              #   Root layout
    │   │   ├── page.tsx                #   Landing page (/)
    │   │   ├── globals.css             #   Global stylesheet
    │   │   ├── design-system.generated.css  # Generated (gitignored)
    │   │   └── styleguide/
    │   │       └── page.tsx            #   Style guide viewer (/styleguide)
    │   ├── config/                     # YAML theme configurations
    │   │   ├── theme-bold/             #   Bold theme (12 YAML files)
    │   │   ├── theme-enterprise/       #   Enterprise theme (12 YAML files)
    │   │   ├── theme-minimal/          #   Minimal theme (12 YAML files)
    │   │   └── theme-nocturne/         #   Nocturne theme (12 YAML files)
    │   └── scripts/
    │       └── generate-css.ts         #   YAML → CSS generator
    ├── public/
    │   └── themes/                     # Generated per-theme CSS (gitignored)
    │       ├── bold.css
    │       ├── enterprise.css
    │       ├── minimal.css
    │       └── nocturne.css
    ├── package.json                    # Dependencies: Next 15, React 19, Tailwind 4
    ├── tsconfig.json                   # TypeScript configuration
    ├── next.config.ts                  # Next.js configuration
    └── .npmrc                          # GitHub Packages registry for @the-robot-lives
```

## Build Commands

| Command | Purpose |
|---------|---------|
| `npm run dev` | Start development server |
| `npm run generate-css` | Regenerate CSS from YAML themes |
| `npm run build` | Generate CSS + Next.js production build |
| `npm run regen` | Clear cache + regenerate CSS |
| `npm run lint` | Run Next.js lint |

## Key Dependencies

- `@the-robot-lives/styleguide` — shared design system engine (GitHub Packages)
- `@headlessui/react` — accessible UI primitives
- `@monaco-editor/react` — code editor component
- `tailwindcss` v4 — utility-first CSS
- `sonner` — toast notifications
