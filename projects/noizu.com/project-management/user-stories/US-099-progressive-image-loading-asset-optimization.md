---
id: US-099
title: "Progressive Image Loading & Asset Optimization"
slug: "progressive-image-loading-asset-optimization"
personas: [P-001, P-002, P-003, P-004, P-005, P-006, P-007, P-008]
epic: "Performance & Scale"
priority: "should-have"
complexity: "M"
tags: [performance, images, web-vitals, optimization, next-image, lcp]
---

# US-099: Progressive Image Loading & Asset Optimization

## User Story

**As a** prospective client visiting noizu.com for the first time,
**I want** pages to load quickly with images appearing progressively,
**So that** I get a professional first impression and the site feels fast even on slower connections.

## Acceptance Criteria

- [ ] Given any page with images, when loaded on a 3G-simulated connection, then images use lazy loading and only images in the initial viewport are fetched on page load
- [ ] Given Next.js `<Image>` component usage, when images are served, then they are automatically converted to WebP/AVIF format with appropriate srcset for responsive sizes
- [ ] Given a large hero or content image, when it loads, then a low-quality image placeholder (LQIP) blurs in before the full image, preventing layout shift
- [ ] Given images, when rendered, then explicit `width` and `height` attributes are always set to prevent Cumulative Layout Shift (CLS > 0.1 fails)
- [ ] Given the site's Largest Contentful Paint (LCP) element, when measured in Lighthouse, then LCP is under 2.5 seconds on a simulated mid-tier mobile device
- [ ] Given static assets (fonts, icons, CSS), when served, then they include long-lived Cache-Control headers and are fingerprinted for cache busting

## Notes

Use Next.js built-in `<Image>` component for all content images. SVG icons delivered inline or via sprite to avoid render-blocking requests. Google Fonts self-hosted via `next/font` to eliminate third-party font DNS lookup. Core Web Vitals target: LCP < 2.5s, CLS < 0.1, INP < 200ms. Related to US-098 (pagination/infinite scroll for list performance).
