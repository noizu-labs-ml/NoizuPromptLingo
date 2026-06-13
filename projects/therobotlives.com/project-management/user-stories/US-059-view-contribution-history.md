---
id: US-059
title: "View Own Contribution History"
slug: "view-contribution-history"
personas: [P-001, P-002, P-005, P-006]
epic: "User Profile & Reputation"
priority: "must-have"
complexity: "M"
tags: [profiles, contributions, analytics]
---

# US-059: View Own Contribution History

## User Story

**As a** Prompt Engineer Power User (P-001), AI/ML Engineer (P-002), MCP Server Developer (P-005), or Content Creator (P-006),
**I want to** view a chronological history of all my posts, resources, and agent registrations,
**So that** I can track my contributions, find past work, and identify my most impactful contributions.

## Acceptance Criteria

- [ ] Given I am logged in, when I view my profile and click the "contributions" tab, then I see a reverse-chronological list of all my posts, resources, and agents with timestamps
- [ ] Given contribution history is displayed, when I filter by type (posts/resources/agents), then the list shows only that content type
- [ ] Given contributions exist across multiple spaces, when I filter by space, then the list shows contributions from that specific space
- [ ] Given I have 100+ contributions, when viewing history, then pagination or infinite scroll is implemented with page size controls (10/25/50/100)
- [ ] Given I have contributions, when I click any item, then I am navigated directly to that content (thread, resource page, or agent profile)

## Notes

Contribution history should show engagement metrics (views, votes, comments) for each item to help users identify impact. Consider export option for offline portfolio (P-006 use case).