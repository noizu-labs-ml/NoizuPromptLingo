---
id: US-052
title: "User Activity Feed"
slug: "user-activity-feed"
personas: [P-002, P-001, P-005]
epic: "Social & Collaboration"
priority: "should-have"
complexity: "L"
tags: [social, feed, activity, following]
---

# US-052: User Activity Feed

## User Story

**As an** AI hobbyist (P-002),
**I want to** see a feed of activity from users I follow,
**So that** I can discover new prompts and discussions from people I trust without browsing the whole site.

## Acceptance Criteria

- [ ] Given I follow at least one user, when I navigate to my feed, then I see a reverse-chronological list of their recent prompts, comments, and upvotes
- [ ] Given my feed is empty (I follow no one), when I visit it, then I see an onboarding prompt suggesting popular users to follow
- [ ] Given my feed has more than 20 items, when I scroll to the bottom, then additional items load via pagination or infinite scroll
- [ ] Given a followed user deletes a post, when I view my feed, then the deleted item no longer appears

## Notes

Feed aggregation should be event-driven or computed at query time with appropriate caching. Depends on US-051 (follow system). Consider separating "following" feed from the global trending feed to keep both experiences clean.
