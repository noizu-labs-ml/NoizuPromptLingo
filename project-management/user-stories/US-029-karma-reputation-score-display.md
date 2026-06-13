---
id: US-029
title: "Karma / Reputation Score Display"
slug: "karma-reputation-score-display"
personas: [P-001, P-002, P-005, P-006, P-008]
epic: "Voting & Reputation"
priority: "must-have"
complexity: "M"
tags: [karma, reputation, profile, display]
---

# US-029: Karma / Reputation Score Display

## User Story

**As a** community member (P-002),
**I want to** see my karma score and other users' karma scores,
**So that** I can gauge credibility, track my own standing, and understand whose contributions carry weight.

## Acceptance Criteria

- [ ] Given I visit my profile page, when the page loads, then my total karma score is displayed prominently alongside a breakdown by post karma and comment karma
- [ ] Given I hover over or tap another user's username, when the tooltip/mini-profile appears, then their karma score and join date are visible
- [ ] Given my karma score changes due to votes received, when the change occurs, then my displayed score updates within 60 seconds without requiring a page reload
- [ ] Given a user has negative karma, when their profile is displayed, then the score is shown in a visually distinct style (e.g., red) to distinguish it from positive scores

## Notes

Karma is the sum of upvotes minus downvotes received on all contributions, weighted by voter reputation tier. Real-time updates can be implemented via WebSocket or polling. Karma breakdown (posts vs. comments) helps users understand where their value is recognized.
