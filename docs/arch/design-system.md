# Design System — SecOps Terminal

## Philosophy

Dark-first, data-dense, terminal-rooted. Designed for security professionals who live in dark mode and think in severity levels. Signals operational credibility over marketing polish.

Three core signals:
1. **Authority** — structured data, consistent taxonomy, intelligence-database feel
2. **Operational utility** — dense, scannable, keyboard-navigable, fast
3. **Controlled danger** — color is information (severity), not decoration

## Typography

| Role | Font | Weights |
|------|------|---------|
| Body | Inter | 400, 500, 600 |
| Mono / Code | JetBrains Mono | 400, 600, 700 |

CSS variables: `--font-inter`, `--font-jetbrains-mono` (set via `next/font/google`).

## Color Philosophy

Colors are severity-mapped, not brand-driven:
- **Critical (red)**: Active threats, high-severity items
- **Warning (amber)**: Caution states, medium severity
- **Info (blue/accent)**: Interactive elements, CTAs, informational
- **Background**: Dark (#0B0D0F range) with layered surfaces

Tailwind CSS v4 with CSS custom properties (`--accent`, `--critical`, `--surface`, `--border`, etc.) for theming.

## Design Explorations

Three HTML mockups in `design/`:
- `direction-a-clean-room.html` — Minimal, clinical variant
- `direction-b-red-alert.html` — High-contrast, urgency variant
- `landing-page.html` — Landing page mockup

Full specification in `STYLE-GUIDE.md` (root). Interactive preview in `styleguide-secops-terminal.html`.
