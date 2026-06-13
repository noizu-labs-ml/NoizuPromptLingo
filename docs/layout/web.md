# web/ — Next.js Landing Site

Next.js 16 + React 19 + Tailwind 4 waitlist/landing page for aifighter.com.

```
web/
├── public/
│   └── favicon.svg                 # Site favicon
├── src/
│   ├── app/
│   │   ├── favicon.ico             # Fallback favicon
│   │   ├── globals.css             # Global styles (Tailwind imports)
│   │   ├── layout.tsx              # Root layout (metadata, fonts)
│   │   └── page.tsx                # Landing page
│   └── components/
│       ├── CounterAnimation.tsx    # Animated counter widget
│       ├── NeuralCanvas.tsx        # Neural network background animation
│       └── WaitlistForm.tsx        # Email waitlist signup form
├── .gitignore                      # web-specific ignores
├── .tool-versions                  # Node.js version (mise/asdf)
├── build.sh                        # Docker build script
├── Dockerfile                      # Multi-stage container build
├── eslint.config.mjs               # ESLint 9 flat config
├── next.config.ts                  # Next.js configuration
├── nginx.conf                      # Production nginx reverse proxy
├── package.json                    # Dependencies: next 16, react 19, tailwind 4
├── package-lock.json               # Lockfile (gitignored at root)
├── postcss.config.mjs              # PostCSS with Tailwind plugin
└── tsconfig.json                   # TypeScript configuration
```

## Scripts

| Command | Purpose |
|---------|---------|
| `npm run dev` | Start dev server |
| `npm run build` | Production build |
| `npm run start` | Serve production build |
| `npm run lint` | Run ESLint |
| `./build.sh` | Build Docker image |
