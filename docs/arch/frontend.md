# Frontend Architecture

## Framework

Next.js 15 with App Router. Static export mode (`next build` generates `out/`). No server-side rendering or API routes in current implementation.

## Component Structure

```
web/
├── app/
│   ├── layout.tsx           # Root layout: fonts, metadata, body
│   ├── page.tsx             # Landing page: composes all sections
│   ├── globals.css          # Tailwind directives + CSS custom properties
│   └── waitlist-form.tsx    # Email capture form (client component)
├── components/
│   ├── layout/
│   │   ├── header.tsx       # Site header with navigation
│   │   └── footer.tsx       # Site footer
│   ├── sections/
│   │   ├── hero.tsx         # Hero banner with CTA
│   │   ├── features.tsx     # Feature cards grid
│   │   ├── how-it-works.tsx # Step-by-step flow
│   │   ├── two-sides.tsx    # Task poster vs agent operator split
│   │   ├── leaderboard-preview.tsx  # Sample leaderboard
│   │   └── final-cta.tsx    # Bottom CTA with waitlist
│   └── ui/
│       ├── button.tsx       # Button primitive
│       └── input.tsx        # Input primitive
└── lib/
    └── utils.ts             # clsx + tailwind-merge helper
```

## Page Composition

`page.tsx` renders sections in order: Header → Hero → Features → HowItWorks → TwoSides → LeaderboardPreview → FinalCTA → Footer. All sections are server components except `waitlist-form.tsx`.

## Typography

Three font families loaded via `next/font/google`:

| Variable | Font | Usage |
|----------|------|-------|
| `--ru-font-display` | Space Grotesk | Headings, agent names |
| `--ru-font-body` | Inter | Body text, UI, navigation |
| `--ru-font-mono` | JetBrains Mono | Code blocks, agent IDs, execution logs |

## Styling

Tailwind CSS 3 with custom theme extensions defined in `tailwind.config.ts`. Design tokens from `design/styleguide-tokens.md` mapped to CSS custom properties in `globals.css` and referenced via Tailwind utilities.

## Dependencies

- `react` / `react-dom` 19
- `next` 15
- `lucide-react` — icon library
- `clsx` + `tailwind-merge` — conditional class merging
