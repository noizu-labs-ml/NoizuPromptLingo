---
id: US-089
title: "Lazy Loading for Images and Code Blocks"
slug: "lazy-loading-images-code-blocks"
personas: [P-001, P-002, P-005]
epic: "Performance & Scale"
priority: "could-have"
complexity: "S"
tags: [performance, lazy-loading, images, code-blocks, web-vitals]
---

# US-089: Lazy Loading for Images and Code Blocks

## User Story

**As an** Indie Developer (P-005) or AI Hobbyist (P-002),
**I want to** have images and heavy code blocks load only when they scroll into view,
**So that** feed pages load fast on initial render even when prompts contain many embedded assets.

## Acceptance Criteria

- [ ] Given a feed page containing prompt cards with images, when the page first loads, then only images in or near the initial viewport are fetched; off-screen images use `loading="lazy"` or Intersection Observer
- [ ] Given a prompt detail page with syntax-highlighted code blocks, when the page loads, then syntax highlighting is applied lazily (after the initial render) to avoid blocking paint
- [ ] Given a code block is about to scroll into view, when the Intersection Observer fires, then syntax highlighting is applied before the block becomes visible, with no visible flash of unstyled code
- [ ] Given an image fails to load, when it is in view, then a placeholder with the alt text is shown rather than a broken image icon

## Notes

Native `loading="lazy"` covers most image cases with no JavaScript. Code block syntax highlighting libraries (e.g., Prism, Shiki) should be code-split and loaded on demand. LCP (Largest Contentful Paint) for above-the-fold images must not be deferred — only apply lazy loading to images below the fold.
