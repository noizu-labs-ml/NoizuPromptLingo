---
id: US-092
title: "CDN-Cached Static Assets"
slug: "cdn-cached-static-assets"
personas: [P-005, P-007]
epic: "Performance & Scale"
priority: "won't-have-yet"
complexity: "M"
tags: [performance, cdn, caching, infrastructure, web-vitals]
---

# US-092: CDN-Cached Static Assets

## User Story

**As an** Enterprise AI Lead (P-007) or Indie Developer (P-005),
**I want to** have all static assets (JS bundles, CSS, fonts, images) served from a CDN edge network,
**So that** pages load fast for users regardless of their geographic location and the origin server is not the bottleneck for static content.

## Acceptance Criteria

- [ ] Given the application is built and deployed, when static asset URLs are generated, then they include a content hash in the filename (e.g., `main.a3f4b1.js`) enabling long-lived `Cache-Control: immutable` headers
- [ ] Given a user requests a static asset, when it is served, then the response includes `Cache-Control: public, max-age=31536000, immutable` and an `ETag` header
- [ ] Given a new deployment is published, when the build completes, then old asset URLs remain valid (old content hashes) and new URLs serve updated content without cache invalidation needed
- [ ] Given CDN configuration is in place, when the CDN edge node does not have a cached copy, then it fetches from origin once and serves subsequent requests from cache for the TTL duration

## Notes

Asset hashing is a build-time concern (handled by Next.js by default). CDN integration requires infrastructure work outside the application layer — Cloudflare or CloudFront are natural choices given the existing Cloudflare usage in the k8 infrastructure. Deferring until post-launch when traffic patterns justify the CDN configuration overhead.
