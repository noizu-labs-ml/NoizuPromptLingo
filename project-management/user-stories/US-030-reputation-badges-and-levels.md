---
id: US-030
title: "Reputation Badges and Levels"
slug: "reputation-badges-and-levels"
personas: [P-001, P-002, P-006, P-007]
epic: "Voting & Reputation"
priority: "should-have"
complexity: "M"
tags: [badges, reputation, gamification, profile]
---

# US-030: Reputation Badges and Levels

## User Story

**As a** community contributor (P-001),
**I want to** earn badges and advance through reputation levels as my karma grows,
**So that** my expertise is visually communicated and I feel motivated to keep contributing quality content.

## Acceptance Criteria

- [ ] Given a user reaches a defined karma threshold, when the threshold is crossed, then a corresponding level badge is automatically awarded and displayed on their profile
- [ ] Given a user earns a badge, when the award event occurs, then the user receives an in-app notification describing the badge and what triggered it
- [ ] Given I view another user's profile, when the page loads, then their current level badge and any special achievement badges are displayed next to their username
- [ ] Given an admin views the badge management panel, when they edit thresholds or create new badges, then changes take effect for all future badge evaluations without retroactive revocation

## Notes

Initial levels should include tiers such as Newcomer, Contributor, Expert, and Authority with karma thresholds of 0, 100, 500, and 2000 respectively. Badges should be rendered as small SVG icons to maintain crisp display at all DPI levels.
