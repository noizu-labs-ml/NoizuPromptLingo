# web/ — Next.js Landing Site

```
web/
├── src/
│   └── app/                        # Next.js App Router
│       ├── layout.tsx              #   Root layout (HTML shell, fonts, metadata)
│       ├── page.tsx                #   Homepage — hero, features, waitlist CTA
│       ├── globals.css             #   Global styles and Tailwind imports
│       └── waitlist-form.tsx       #   Waitlist signup form component
├── public/
│   └── favicon.svg                 #   Browser favicon
├── .tool-versions                  # asdf/mise — Node.js version pin
├── build.sh                        # Docker build helper script
├── Dockerfile                      # Multi-stage build (Node build → nginx serve)
├── next.config.ts                  # Next.js configuration
├── nginx.conf                      # Production reverse proxy configuration
├── package.json                    # Dependencies and npm scripts
├── postcss.config.mjs              # PostCSS plugin chain (Tailwind)
└── tsconfig.json                   # TypeScript compiler settings
```
