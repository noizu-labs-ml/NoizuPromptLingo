# Project Architecture — noizu.com

## Overview

A statically-exported Next.js 14 site serving as the professional portfolio and research publication platform for Keith Brings / Noizu Labs. The site combines a scroll-sequence-driven single-page homepage (Fractional CTO and Principal Engineer services) with a multi-page research paper section on AI rights and cognitive architecture. Built with TypeScript, Tailwind CSS, and Framer Motion, it exports to static HTML and deploys as an nginx container pushed to a private registry at `ops.noizu.com`.

## System Diagram

```mermaid
graph TB
    subgraph Build["Build Pipeline"]
        SRC[Next.js Source] -->|next build / export| STATIC[Static HTML in out/]
        STATIC -->|Docker multi-stage| IMG[nginx:alpine Image]
        IMG -->|build.sh| REG[ops.noizu.com Registry]
    end

    subgraph Serve["Runtime"]
        REG -->|pull| NGINX[nginx Container]
        CF[Cloudflare CDN] --> NGINX
        USER[Browser] --> CF
    end

    subgraph Content["Content Sources"]
        MD[Root .md Files] -->|react-markdown| PAPERS[/papers/* Routes]
        COMPONENTS[Sequence Components] --> HOME[/ Homepage]
    end
```

## Core Components

| Component | Purpose |
|-----------|---------|
| Scroll Sequences | Full-viewport scroll-driven homepage sections (Hero, Projects, Services, Testimonials, CTA) |
| Paper Pages | Research paper rendering via react-markdown + remark-gfm |
| Hero System | Multi-layer SVG parallax (circuit board, grid, nodes, photo layers) |
| Interaction Library | MouseLightCard, MagneticButton, TiltCard, TypedText, TextReveal, FadeIn |
| Design Tokens | Tailwind config with Noizu gold scale (`#ffca02`), dark theme (`zinc-950`) |
| Static Export | `output: "export"` in next.config.mjs — no server runtime |

## Rendering & Animation

The homepage uses a stacked scroll-sequence pattern where each `*Sequence` component occupies a full viewport and stacks via `clip-path: inset(0)` with descending `zIndex` props. Animations are driven by Framer Motion with `prefers-reduced-motion` support. D3 powers data visualizations; Mermaid renders diagrams in papers.

→ *See [arch/scroll-sequences.md](arch/scroll-sequences.md) for details*

## Content Pipeline

Four research papers live as root-level `.md` and `.html` files and render at `/papers/*` routes. The papers cover AI rights (The Copacetic Accord v4.1), manifesto on moral urgency, engineering feasibility of synthetic personhood, and distributed cognitive architecture.

→ *See [arch/content-pipeline.md](arch/content-pipeline.md) for details*

## Build & Deploy

Two-stage Docker build: `node:22-alpine` runs `next build` (static export to `out/`), then `nginx:alpine` serves the output. `build.sh` builds for `linux/amd64`, tags as `ops.noizu.com/noizu-website:{tag}`, and pushes. nginx config includes gzip, 1-year cache on `_next/static/`, SPA fallback, and security headers.

→ *See [arch/build-deploy.md](arch/build-deploy.md) for details*

## Technology Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Framework | Next.js (App Router) | 14.2 |
| Language | TypeScript | 5.3 |
| Styling | Tailwind CSS | 3.4 |
| Animation | Framer Motion | 11.x |
| Data Viz | D3 | 7.9 |
| Diagrams | Mermaid | 11.14 |
| Markdown | react-markdown + remark-gfm | 10.1 |
| Fonts | Inter (body), JetBrains Mono (code) | Google Fonts |
| Container | nginx:alpine | — |
| Registry | ops.noizu.com (private) | — |

## SEO & Discoverability

JSON-LD structured data (Person + WebSite schemas) injected in root layout. `sitemap.ts` and `robots.ts` generate standards-compliant files. `public/llms.txt` provides an LLM-readable site summary for AI answer engines.

## Key Decisions

- **Why static export**: No dynamic content; eliminates server runtime, simplifies hosting, maximizes cache efficiency
- **Why scroll sequences over traditional pages**: Single narrative flow for portfolio presentation; research papers get their own routes
- **Why private registry**: Aligns with existing `ops.noizu.com` infrastructure; not yet promoted to first-class K8s project
- **Why dark theme**: Brand identity — professional, technical aesthetic with gold accent (`#ffca02`)
