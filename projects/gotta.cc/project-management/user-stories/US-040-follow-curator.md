---
id: US-040
title: "Follow Other Curators"
slug: "follow-curator"
personas: [P-001, P-004, P-008]
epic: "Community & Social"
priority: "should-have"
complexity: "M"
tags: [community, following, social, discovery]
---

# US-040: Follow Other Curators

## User Story

**As a** web nostalgia explorer (P-001),
**I want to** follow curators whose taste I trust,
**So that** their new discoveries surface in my feed without me having to check their profiles manually.

## Acceptance Criteria

- [ ] Given I am on a submitter profile (US-038), when I click "Follow," then I subscribe to their discoveries and the button changes to "Following"
- [ ] Given I follow a curator, when they have an approved submission, then their new find appears in my personalized discovery feed with a "from [curator name]" attribution label
- [ ] Given I am viewing my following list, when I navigate to it from my account settings, then I see all curators I follow with their recent activity and an Unfollow option per entry
- [ ] Given a curator I follow has no recent activity in 60 days, when I view my following list, then their entry is visually muted with an "Inactive" label to help me prune my list

## Notes

Follow data is used to personalize the discovery feed and is not exposed publicly (follower counts are not displayed to prevent social anxiety dynamics). Related to the weekly digest feature (US-043).
