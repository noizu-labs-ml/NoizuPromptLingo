---
id: US-076
title: "Empty State for New User Feed"
slug: "empty-state-new-user-feed"
personas: [P-002, P-008]
epic: "Edge Cases & Error States"
priority: "should-have"
complexity: "S"
tags: [empty-state, onboarding, feed, ux]
---

# US-076: Empty State for New User Feed

## User Story

**As an** AI Hobbyist (P-002) or AI Newcomer (P-008),
**I want to** see helpful guidance when my personalized feed has no content yet,
**So that** I understand why the feed is empty and know what actions to take to populate it.

## Acceptance Criteria

- [ ] Given a new user with no followed tags or users, when they visit their feed, then a friendly empty state illustration and message is displayed explaining the feed is empty
- [ ] Given the empty state is shown, when the user views it, then it includes at least two actionable CTAs (e.g., "Explore trending prompts" and "Follow topics you care about")
- [ ] Given a user who has followed tags but no prompts exist in those tags yet, when they view the feed, then the empty state message reflects that specific context ("No prompts yet in your followed topics")
- [ ] Given the empty state, when a new prompt is posted matching the user's interests, then it appears in the feed without requiring a page reload

## Notes

Empty states should be treated as onboarding touchpoints, not dead ends. The illustrations and copy should feel warm and encouraging rather than clinical. Depends on the feed personalization and tag follow systems.
