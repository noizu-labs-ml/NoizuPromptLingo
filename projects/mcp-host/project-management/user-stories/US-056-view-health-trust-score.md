---
id: US-056
title: "View health status and trust score for MCP servers"
slug: "view-health-trust-score"
personas: [P-002, P-003, P-001]
epic: "Registry & Discovery"
priority: "must-have"
complexity: "L"
tags: [registry, health-checks, trust-score, observability]
---

# US-056: View Health Status and Trust Score for MCP Servers

## User Story

**As a** Platform Engineer (P-002),
**I want to** see a health status and trust score for each MCP server in the registry,
**So that** I can assess operational reliability and publisher credibility before integrating a server into my production environment.

## Acceptance Criteria

- [ ] Given the user is viewing any registry listing (search results, category page, or detail page), when a server entry is rendered, then it displays a health status badge (healthy, degraded, unhealthy, unknown) derived from the continuous health probes (US-060).
- [ ] Given the user hovers over a health status badge, when the tooltip appears, then it shows the last probe timestamp, response time p50/p99 over the last 24 hours, and the specific check that caused a degraded or unhealthy status.
- [ ] Given the user is viewing an MCP server detail page (US-054), when they navigate to the health section, then a time-series chart displays health probe results over configurable time windows (1h, 24h, 7d, 30d).
- [ ] Given a server has a trust score, when it is displayed, then the score is computed from: publisher verification status (US-057), uptime percentage over 30 days, community reviews (US-070), adoption metrics, and security audit results.
- [ ] Given the user clicks on a trust score, when the breakdown panel opens, then it displays each contributing factor with its weight and individual score.
- [ ] Given a server's health status changes from healthy to unhealthy, when the change is detected, then any user who starred the server (US-069) or subscribed to its category (US-059) receives a notification.

## Notes

Trust scoring is a composite metric that should be transparent so users understand what drives a score. The health badge must be visible in all registry views (search, browse, detail) for at-a-glance assessment. Related: US-054, US-057, US-059, US-060, US-069, US-070.
