---
id: US-080
title: "Personalized Recommendations Based on Activity"
slug: "personalized-recommendations"
personas: [P-001, P-004, P-006]
epic: "Explore & Homepage"
priority: "should-have"
complexity: "L"
tags: [recommendation, personalization, algorithm]
---

# US-080: Personalized Recommendations Based on Activity

## User Story

**As a** Content Creator (P-006),
**I want to** see personalized recommendations for spaces, threads, and resources based on my activity history,
**So that** I can discover content aligned with my interests without manual searching.

## Acceptance Criteria

- [ ] Given I have engaged with spaces, threads, or resources, when I visit the homepage, then I see a "Recommended for You" section with 5 personalized suggestions
- [ ] Given I've joined "AI Engineering" spaces and forked Python resources, when recommendations load, then suggestions prioritize Python-related content in AI contexts
- [ ] Given I'm a new user with little activity history, when I view recommendations, then the system suggests popular spaces and resources from trending topics
- [ ] Given I click "Dismiss" on a recommendation, when I view subsequent feeds, then the dismissed item no longer appears in recommendations
- [ ] Given I bookmark a thread, when recommendations refresh, then future suggestions include similar threads from the same space or topic

## Notes

Recommendation algorithm should use collaborative filtering (users like me liked X) and content-based filtering (similar to items you engaged with). Update frequency: every 24 hours.