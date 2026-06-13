# Project Layout Summary — noizu.com

```
noizu.com/
├── src/
│   ├── app/                    # Next.js App Router pages
│   │   ├── papers/             # Published research papers (4 papers)
│   │   ├── projects/           # Projects showcase
│   │   ├── globals.css
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   ├── robots.ts
│   │   └── sitemap.ts
│   ├── components/
│   │   ├── hero/               # Hero SVG layers (4 files)
│   │   ├── sequences/          # Scroll-driven sections (5 files)
│   │   └── *.tsx               # Animation + UI components (18 files)
│   └── hooks/
│       └── useMediaQuery.ts
├── public/                     # Static assets + llms.txt
├── design/                     # Style guides and prototypes
├── docs/                       # Project documentation
├── .tool-versions              # Node.js 22.22.0
├── envrc.example               # Environment template
├── Dockerfile                  # Container build
├── nginx.conf                  # Production proxy config
├── next.config.mjs
├── tailwind.config.ts
├── tsconfig.json
├── package.json
├── 0{0,1,2}_*.md               # Source content for papers
└── cognitive-architecture.html
```
