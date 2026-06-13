---
id: US-089
title: "Graceful 404 Page with Navigation Suggestions"
slug: "graceful-404-page"
personas: [P-001, P-002, P-003, P-004, P-005, P-006, P-007, P-008]
epic: "Edge Cases & Error States"
priority: "must-have"
complexity: "S"
tags: [error-handling, 404, navigation, ux, seo]
---

# US-089: Graceful 404 Page with Navigation Suggestions

## User Story

**As a** visitor who followed a broken or mistyped link,
**I want to** land on a helpful 404 page with navigation options,
**So that** I can quickly find what I was looking for without frustration or leaving the site.

## Acceptance Criteria

- [ ] Given any request to a URL that does not match a valid route, when the page renders, then an HTTP 404 status is returned and a branded error page is displayed
- [ ] Given the 404 page, then it displays a clear message, a brief explanation, and at least 3 suggested navigation links (Home, Services, Research, Contact)
- [ ] Given the 404 page, when the user is authenticated, then an additional link to "My Dashboard" is shown
- [ ] Given the 404 page, then it shares the site header/footer and maintains full navigation context
- [ ] Given a 404 triggered by a known moved page (e.g., old URL pattern), then a 301 redirect is in place and the 404 page is not reached
- [ ] Given a 404 page, then it does not display stack traces, server paths, or internal error details

## Notes

SEO: ensure Next.js returns true 404 status (not 200 with error content). Consider a subtle brand-consistent illustration or typographic treatment. Related to US-092 (session expiration) for other error-state pages. Redirect map maintained in `next.config.js` redirects array.
