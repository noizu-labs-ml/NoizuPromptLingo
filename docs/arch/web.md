# Web Architecture

## Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Framework | Next.js (App Router) | 16.1.6 |
| UI | React | 19.2.3 |
| Styling | Tailwind CSS | 4.x |
| Build | PostCSS pipeline | via `@tailwindcss/postcss` |
| Runtime | Node.js | per `.tool-versions` |
| Container | Docker + nginx | Production reverse proxy |

## Structure

```
web/
├── src/app/
│   ├── layout.tsx          # Root layout (fonts, metadata, global providers)
│   ├── page.tsx            # Homepage (hero, code example, value props, waitlist)
│   ├── waitlist-form.tsx   # Email capture component
│   └── globals.css         # Tailwind directives + custom properties
├── public/
│   └── favicon.svg         # Browser favicon
├── Dockerfile              # Multi-stage build (build → nginx serve)
├── nginx.conf              # Reverse proxy config for containerized deployment
├── build.sh                # Docker build helper
├── next.config.ts          # Next.js configuration
├── postcss.config.mjs      # PostCSS/Tailwind pipeline
├── tsconfig.json           # TypeScript strict mode
└── package.json            # Dependencies and scripts
```

## Build & Deploy

```bash
# Local development
cd web && npm install && npm run dev

# Production container
./build.sh                  # Builds Docker image
# Deployed behind Cloudflare TLS via nginx reverse proxy
```

## Design System

The site uses a "Workshop & Wonder" visual direction:
- **Dark mode primary** with deep blue-black backgrounds (`#0F0F13`)
- **Purple accent** (`#7C5CFC`) as the signature color (magic, creativity)
- **Inter** for UI text, **JetBrains Mono** for code, **Source Serif 4** for narrative accents
- RPG domain colors for game content (gold for legendary, red for HP, blue for mana)

Three design direction explorations exist as standalone HTML files in `design/`:
- `direction-a-workshop.html` — Technical workshop aesthetic
- `direction-b-wonder.html` — Whimsical wonder aesthetic
- `direction-c-grimoire.html` — Dark grimoire aesthetic
