# Project Layout Summary — derobot.is/frontend

```
frontend/
├── src/
│   ├── app/
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   ├── globals.css
│   │   ├── about/page.tsx
│   │   ├── contact/page.tsx
│   │   ├── login/page.tsx
│   │   ├── portfolio/page.tsx
│   │   ├── portfolio/[domain]/page.tsx
│   │   ├── process/page.tsx
│   │   ├── signup/page.tsx
│   │   ├── sitemap/page.tsx
│   │   └── styleguide/page.tsx
│   ├── components/
│   │   ├── blur-tagline.tsx
│   │   ├── decision-flow.tsx
│   │   ├── hero-section.tsx
│   │   ├── logo.tsx
│   │   ├── navbar.tsx
│   │   ├── pipeline-flow.tsx
│   │   ├── robot-egghead.tsx
│   │   ├── robot-foundry.tsx
│   │   ├── robot-grid.tsx
│   │   ├── robot-poses.tsx
│   │   ├── verb-cycle.tsx
│   │   └── generated/demo.ts
│   ├── config/theme-style-guide/      # 16 YAML theme files
│   ├── context/auth.tsx
│   ├── lib/
│   │   ├── api.ts
│   │   └── products.ts
│   └── scripts/generate-css.ts
├── public/
│   ├── icon.svg
│   ├── logo-b.svg
│   └── themes/derobot.css
├── docs/
│   ├── arch/                          # 3 architecture docs
│   └── layout/src.md
├── .npmrc.template
├── .tool-versions
├── .dockerignore
├── Dockerfile
├── Dockerfile.dev
├── next.config.ts
├── package.json
├── postcss.config.mjs
└── tsconfig.json
```
