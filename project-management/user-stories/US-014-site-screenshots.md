---
id: US-014
title: "Site Screenshots on Listings"
slug: "site-screenshots"
personas: [P-001, P-004, P-002]
epic: "Site Listings"
priority: "should-have"
complexity: "M"
tags: [screenshots, visual, preview, site-card]
---

# US-014: Site Screenshots on Listings

## User Story

**As a** Web Nostalgia Explorer (P-001),
**I want to** see a thumbnail screenshot of each listed site,
**So that** I can visually preview the site's design aesthetic before clicking through.

## Acceptance Criteria

- [ ] Given I am viewing site listings in grid mode, when the page loads, then each site card displays a screenshot thumbnail of the site's homepage.
- [ ] Given a screenshot could not be captured or is older than 30 days, when the card renders, then a placeholder icon or gradient is shown rather than a broken image.
- [ ] Given I hover over a screenshot thumbnail on desktop, when the hover state activates, then the image expands to a slightly larger preview without navigating away.

## Notes

Screenshots are particularly valuable in grid view (US-016). Screenshot capture should be automated on site approval and refreshed periodically. Design quality score (US-012) should ideally correlate with screenshot presentation. Screenshots should be lazy-loaded to avoid impacting page performance.
