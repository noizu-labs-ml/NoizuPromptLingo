---
id: US-096
title: "CDN-cached mockup delivery for shared links"
slug: "cdn-cached-mockup-delivery"
personas: [P-002, P-004, P-006]
epic: "Performance & Scale"
priority: "should-have"
complexity: "M"
tags: [performance, cdn, caching, sharing]
---

# US-096: CDN-cached mockup delivery for shared links

## User Story

**As a** Product Manager (P-002),
**I want to** shared mockup links to load quickly for all recipients regardless of location,
**So that** stakeholders around the world get a fast, reliable experience when reviewing mockups I send them.

## Acceptance Criteria

- [ ] Given a mockup has a public share link, when a recipient accesses the link, then the mockup image and metadata are served from a CDN edge node nearest to the recipient
- [ ] Given a mockup is updated after a share link is created, when the updated mockup is viewed via the share link, then the CDN cache is invalidated and the fresh version is served within 60 seconds
- [ ] Given a mockup is deleted by its owner, when the share link is accessed, then the CDN returns a 404 and the UI shows a "Mockup not found or deleted" message

## Notes

CDN integration should use Cloudflare (already in infrastructure stack) with cache purge API calls triggered on mockup update/delete events. Immutable static assets (thumbnails) can use long TTLs; the share page HTML should use shorter TTLs or stale-while-revalidate. Related to US-094, US-095.
