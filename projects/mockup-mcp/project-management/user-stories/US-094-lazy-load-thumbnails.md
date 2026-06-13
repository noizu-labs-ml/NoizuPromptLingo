---
id: US-094
title: "Lazy-load mockup thumbnails in gallery view"
slug: "lazy-load-thumbnails"
personas: [P-001, P-002, P-003]
epic: "Performance & Scale"
priority: "should-have"
complexity: "S"
tags: [performance, lazy-loading, images, gallery]
---

# US-094: Lazy-load mockup thumbnails in gallery view

## User Story

**As a** Full-Stack Developer (P-001),
**I want to** mockup thumbnails to load lazily as I scroll through the gallery,
**So that** the initial page load is fast and bandwidth is not wasted on thumbnails I never reach.

## Acceptance Criteria

- [ ] Given I load the gallery page, when the initial render completes, then only thumbnails visible in the viewport are fetched; off-screen thumbnails are not requested
- [ ] Given I scroll down in the gallery, when a thumbnail enters the viewport, then it loads with a smooth fade-in transition replacing a skeleton placeholder
- [ ] Given a thumbnail fails to load, when the image request errors, then a fallback icon or placeholder image is shown in its place without breaking the layout

## Notes

Use the native `loading="lazy"` attribute combined with `IntersectionObserver` for browsers that need progressive enhancement. Thumbnails should be served in WebP format with appropriate `srcset` for HiDPI screens. Pairs with US-095 (pagination) and US-096 (CDN delivery).
