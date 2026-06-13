# web/

Next.js 16 landing page / waitlist application. Deployed as a Docker container with nginx reverse proxy.

```
web/
├── public/
│   └── favicon.svg                 # Site favicon (SVG)
├── src/
│   └── app/                        # Next.js App Router
│       ├── globals.css             #   Global styles (Tailwind 4)
│       ├── layout.tsx              #   Root layout
│       ├── page.tsx                #   Landing page
│       └── waitlist-form.tsx       #   Waitlist signup component
├── .tool-versions                  # Node.js 22.22.0
├── build.sh                        # Docker build script
├── Dockerfile                      # Multi-stage container build
├── next.config.ts                  # Next.js configuration
├── nginx.conf                      # Production reverse proxy
├── package.json                    # next@16, react@19, tailwindcss@4
├── postcss.config.mjs              # PostCSS with Tailwind plugin
└── tsconfig.json                   # TypeScript strict config
```

## Stack

- **Next.js 16** (App Router) with React 19
- **Tailwind CSS 4** via PostCSS
- **TypeScript 5**
- **nginx** reverse proxy in production container
