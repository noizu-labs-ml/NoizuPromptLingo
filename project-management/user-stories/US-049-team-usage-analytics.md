---
id: US-049
title: "Team Usage Analytics Dashboard"
slug: "team-usage-analytics"
personas: [P-004, P-005]
epic: "Team & Collaboration"
priority: "could-have"
complexity: "L"
tags: [analytics, dashboard, usage, admin, reporting]
---

# US-049: Team Usage Analytics Dashboard

## User Story

**As a** startup founder (P-004),
**I want to** view usage analytics for my team's workspace,
**So that** I can understand adoption, identify bottlenecks, and justify the platform to stakeholders.

## Acceptance Criteria

- [ ] Given a workspace with activity, when I navigate to Analytics, then I see charts for mockups created, annotations added, and active users over a selectable time range
- [ ] Given the analytics dashboard, when I select a specific team member, then I see their individual contribution metrics
- [ ] Given the dashboard, when I view the MCP usage section, then I see breakdowns of which generation tools (PlantUML, SVG, Mermaid, image AI) are used most frequently
- [ ] Given the analytics dashboard, when I click "Export", then a CSV of the raw event data for the selected period is downloaded

## Notes

Analytics should be computed server-side and cached to avoid repeated aggregation queries. Data retention for analytics events should be configurable per plan (e.g., 30 days free, 1 year paid). GDPR considerations apply to per-user data.
