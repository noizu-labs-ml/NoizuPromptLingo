---
id: US-015
title: "Link Status Indicators"
slug: "link-status-indicators"
personas: [P-003, P-001, P-008]
epic: "Site Listings"
priority: "should-have"
complexity: "S"
tags: [link-health, status, freshness, indicators]
---

# US-015: Link Status Indicators

## User Story

**As a** Research Journalist (P-003),
**I want to** see whether a listed site is currently live and reachable,
**So that** I don't waste time clicking dead links during research sessions.

## Acceptance Criteria

- [ ] Given a site in the directory has been checked within the past 24 hours, when I view its card, then a status indicator shows "live," "degraded," or "unreachable."
- [ ] Given a site has been unreachable for more than 7 consecutive days, when I view its card, then a prominent warning badge is displayed and the site is deprioritized in default sort order.
- [ ] Given I am an editor (P-005), when a site has been unreachable for 30+ days, then it appears in an "At Risk" moderation queue for review and potential removal.

## Notes

Link rot is a primary quality concern for a web directory. Status checks should run automatically on a crawl schedule (daily for active sites, weekly for stale). Unreachable sites should not be removed immediately — some sites have intermittent downtime.
