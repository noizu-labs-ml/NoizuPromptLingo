# Project Architecture Summary — noizu.com

Statically-exported Next.js 14 portfolio and research publication site. Dark-themed, scroll-sequence-driven single-page homepage with multi-page research paper section. TypeScript + Tailwind CSS + Framer Motion. Exports to static HTML, containerized with nginx, pushed to private registry at ops.noizu.com.

## Core Components

Scroll Sequences compose the homepage (Hero, Projects, Services, Testimonials, CTA). Paper Pages render research content via react-markdown. Hero System uses multi-layer SVG parallax. Interaction Library provides MouseLightCard, MagneticButton, TiltCard, and text animation effects. Design Tokens define Noizu gold scale and dark zinc theme in Tailwind config.

## Rendering & Animation

Stacked scroll-sequence pattern with clip-path inset stacking and Framer Motion animations. D3 for data viz, Mermaid for diagrams. Respects prefers-reduced-motion.

## Content Pipeline

Four root-level research papers (.md/.html) render at /papers/* routes covering AI rights, manifesto, engineering feasibility, and cognitive architecture.

## Build & Deploy

Two-stage Docker build: node:22-alpine builds static export, nginx:alpine serves. build.sh targets linux/amd64, tags as ops.noizu.com/noizu-website:{tag}. nginx config includes gzip, long-term caching, SPA fallback, security headers.

## Technology Stack

Next.js 14.2, TypeScript 5.3, Tailwind CSS 3.4, Framer Motion 11.x, D3 7.9, Mermaid 11.14, react-markdown 10.1, Inter + JetBrains Mono fonts, nginx:alpine container.

## SEO & Discoverability

JSON-LD (Person + WebSite), sitemap.ts, robots.ts, public/llms.txt for AI answer engines.

## Key Decisions

Static export for zero server runtime. Scroll sequences for narrative portfolio flow. Private registry aligned with ops.noizu.com infrastructure. Dark theme with gold accent for brand identity.
