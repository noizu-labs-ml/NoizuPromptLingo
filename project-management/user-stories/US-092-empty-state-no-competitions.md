---
id: US-092
title: "Empty State: No Competitions Available"
slug: "empty-state-no-competitions"
personas: [P-001, P-004, P-006]
epic: "Edge Cases & Error States"
priority: "should-have"
complexity: "S"
tags: [edge-case, empty-state, competitions, UX, onboarding]
---

# US-092: Empty State: No Competitions Available

## User Story

**As a** new blogger eager to compete (P-004),
**I want to** see a helpful and encouraging message when no competitions are currently available,
**So that** I understand the situation and know what to do next instead of assuming the platform is broken.

## Acceptance Criteria

- [ ] Given I navigate to the competitions browse page and no competitions are active or upcoming, when the page renders, then an empty state component displays with an illustration, heading "No competitions running right now," and body copy explaining that new competitions are added regularly.
- [ ] Given the empty state is shown, when I view it, then a CTA button "Notify me when a competition starts" is displayed; clicking it subscribes me to competition launch notifications.
- [ ] Given I am already subscribed to competition notifications, when the empty state is shown, then the CTA reads "You're on the list — we'll notify you!" (disabled/confirmation state).
- [ ] Given I filter the competitions list to a specific category and no competitions match, when the empty state is shown, then the message is contextual: "No {category} competitions running. Try browsing all categories."
- [ ] Given the empty state for a competition with no entries yet, when I am the first potential entrant, then the message reads "Be the first to enter this competition!" with the entry button prominently displayed.
- [ ] Given the empty state component, when rendered, then it does not use generic placeholder text like "No data found" or "null" — all messages are human-readable and encouraging in tone.

## Notes

Empty states are UX moments, not error states. Each distinct empty scenario (no competitions, no entries, no results for search/filter) needs its own tailored copy. Illustration should be a lightweight SVG to avoid loading overhead. Relates to US-093 (rate limiting), US-098 (infinite scroll — handles "no more items" state).
