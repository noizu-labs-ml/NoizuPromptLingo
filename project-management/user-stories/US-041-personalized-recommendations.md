---
id: US-041
title: "Personalized Recommendations Based on History"
slug: "personalized-recommendations"
personas: [P-001, P-002, P-005, P-006]
epic: "Search & Discovery"
priority: "should-have"
complexity: "L"
tags: [recommendations, personalization, discovery, machine-learning]
---

# US-041: Personalized Recommendations Based on History

## User Story

**As a** returning community member (P-001),
**I want to** see a feed of prompts recommended based on my voting history, saved items, and browsing patterns,
**So that** I can discover relevant content without having to manually search every session.

## Acceptance Criteria

- [ ] Given I am logged in and have at least 10 interactions (votes, views, or saves), when I open the "For You" feed, then prompts are ranked by a relevance score derived from my interaction history
- [ ] Given my recommendations are rendered, when I dismiss a recommendation by clicking "Not interested," then that item is excluded from future recommendation sets
- [ ] Given I have no interaction history (new account), when I visit the "For You" feed, then I am prompted to select interest categories to seed initial recommendations
- [ ] Given I have opted out of personalization in privacy settings, when I visit the "For You" feed, then it falls back to the standard "Hot" feed with a notice explaining why personalization is off

## Notes

Initial implementation can use collaborative filtering on shared upvote patterns. A content-based fallback (tag similarity to previously upvoted items) should be used when collaborative signals are sparse. Recommendation model updates should run asynchronously and not block feed rendering.
