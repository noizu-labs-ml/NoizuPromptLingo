---
id: US-023
title: "Recently Added Sites Feed"
slug: "recently-added-sites"
personas: [P-002, P-008, P-001]
epic: "Discovery & Exploration"
priority: "should-have"
complexity: "S"
tags: [recent, discovery, new-sites, feed]
---

# US-023: Recently Added Sites Feed

## User Story

**As a** Community Curator (P-008),
**I want to** see a chronological feed of sites recently added to the directory,
**So that** I can track new additions and follow the growth of the directory over time.

## Acceptance Criteria

- [ ] Given I navigate to the "Recently Added" page or section, when it loads, then I see sites ordered by approval date (newest first), showing up to 50 entries paginated.
- [ ] Given I view a recently added site card, when it renders, then it shows the site name, category, summary, score, and date added.
- [ ] Given a site was added more than 30 days ago, when the "Recently Added" feed is viewed, then it no longer appears in this feed (30-day rolling window).

## Notes

This feed serves as a lightweight activity stream for engaged users (P-002, P-008) who want to track the directory's growth. An RSS/Atom feed of recently added sites would also serve P-007 (API Developer). Connects to US-017 (sort by date added) and US-022 (trending).
