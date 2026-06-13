---
id: US-092
title: "Receive Personalized Technique Recommendations"
slug: "personalized-technique-recommendations"
personas: [P-001, P-004, P-008]
epic: "Search & Discovery"
priority: "could-have"
complexity: "L"
tags: [recommendations, personalization, discovery, machine-learning, engagement]
---

# US-092: Receive Personalized Technique Recommendations

## User Story

**As a** researcher who regularly engages with specific threat domains (P-001, P-004, P-008),
**I want to** see personalized technique recommendations based on my browsing history, bookmarks, and scan targets,
**So that** I discover relevant new content without having to actively search for it.

## Acceptance Criteria

- [ ] Given I have viewed 10 or more techniques, when I visit the catalog homepage or my dashboard, then a "Recommended for You" section surfaces up to 6 technique suggestions
- [ ] Given recommendations, when I view them, then each card explains the recommendation signal (e.g., "Because you bookmarked Prompt Injection variants" or "Popular with users who scanned GPT-4 endpoints")
- [ ] Given a recommendation I find irrelevant, when I click "Not Interested", then it is dismissed and similar recommendations are suppressed
- [ ] Given a new user with no history, when they view recommendations, then the section shows "trending this week" and "top-rated by researchers" as a cold-start fallback
- [ ] Given privacy preferences, when a user opts out of personalization, then recommendations revert permanently to non-personalized trending content and no behavioral data is used
- [ ] Given the recommendation engine, when a newly published technique matches my historical interests, then it surfaces in recommendations within 24 hours of publication

## Notes

Recommendation signals: page views, bookmarks, scan targets, category watches, lab completions. Collaborative filtering is acceptable; ensure the model cannot be reverse-engineered to reveal other users' activity. GDPR compliance requires a "delete my recommendation data" action in privacy settings.
