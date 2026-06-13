---
id: US-020
title: "Related Sites on Site Detail"
slug: "related-sites"
personas: [P-001, P-004, P-003]
epic: "Site Listings"
priority: "could-have"
complexity: "M"
tags: [related, discovery, rabbit-hole, site-detail]
---

# US-020: Related Sites on Site Detail

## User Story

**As a** Web Nostalgia Explorer (P-001),
**I want to** see a "You might also like" section when viewing a site's detail page,
**So that** I can follow a thread of related sites the way I used to follow blogrolls.

## Acceptance Criteria

- [ ] Given I am viewing a site detail page, when the page loads, then a "Related Sites" section displays up to 6 sites sharing category or tags.
- [ ] Given the related sites section renders, when I view it, then each related site card shows name, domain, and composite score (no screenshot required).
- [ ] Given a site has fewer than 3 closely related sites, when the section renders, then it is omitted entirely rather than shown with a sparse single-item list.

## Notes

Related sites power the "rabbit hole" navigation pattern described in US-024. Relatedness should be computed from shared category + tag overlap, weighted by score quality. This is a lightweight version; full rabbit hole UX is handled in US-024.
