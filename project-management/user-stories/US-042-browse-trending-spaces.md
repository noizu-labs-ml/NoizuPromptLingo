---
id: US-042
title: "Browse Trending Spaces"
slug: "browse-trending-spaces"
personas: [P-004, P-006, P-007]
epic: "Search & Discovery"
priority: "should-have"
complexity: "M"
tags: [discovery, spaces, analytics]
---

# US-042: Browse Trending Spaces

## User Story

**As a** Content Creator (P-006),
**I want to** browse trending spaces to find active communities,
**So that** I can join conversations where there's momentum and engagement.

## Acceptance Criteria

- [ ] Given I'm on the spaces discovery page, when I view trending spaces, then I see spaces ranked by growth in active members and message volume over the last 7 days
- [ ] Given trending spaces, when I view them, then each shows member count, messages this week, and a short description
- [ ] Given a trending space, when I click it, then I'm taken to the space page with the option to join if I'm not already a member
- [ ] Given I filter trending spaces, when I select categories (e.g., AI agents, MCP development), then only spaces tagged with those categories appear

## Notes

Trending is calculated at midnight UTC daily. Spaces must be public and have at least 5 members to trend. "New & Rising" filter shows spaces < 30 days old with high engagement velocity.