---
id: US-085
title: "Handle empty state for new users"
slug: "empty-state-new-user"
personas: [P-004, P-006]
epic: "Edge Cases & Error States"
priority: "should-have"
complexity: "S"
tags: [onboarding, empty-state, ux]
---

# US-085: Handle empty state for new users

## User Story

**As a** Startup Founder (P-004),
**I want to** see helpful guidance when I first log in with no mockups yet,
**So that** I know exactly how to get started and don't feel lost in an empty interface.

## Acceptance Criteria

- [ ] Given a new user has no mockups, when they visit the dashboard or gallery, then they see an illustrated empty state with a headline, a brief description of what they can do, and a prominent "Generate your first mockup" CTA
- [ ] Given a user has no mockups in a filtered view (e.g., type filter applied), when the filtered results are empty, then they see a contextual empty state indicating the filter is the cause, with a "Clear filters" link
- [ ] Given the empty state CTA is clicked, when the action fires, then the user is taken to the mockup generation flow with a pre-filled example prompt

## Notes

The illustrated empty state should differ from the filtered-empty-state to avoid confusion. Example prompt in the CTA should match the user's account type if known (e.g., architect persona gets an architecture diagram example).
