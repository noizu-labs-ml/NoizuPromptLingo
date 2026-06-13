---
id: US-084
title: "Screen Reader Support for Voting"
slug: "screen-reader-voting-support"
personas: [P-001, P-002, P-008]
epic: "Accessibility & i18n"
priority: "should-have"
complexity: "M"
tags: [accessibility, screen-reader, aria, voting, wcag, a11y]
---

# US-084: Screen Reader Support for Voting

## User Story

**As an** AI Hobbyist (P-002) or AI Newcomer (P-008) who uses a screen reader,
**I want to** understand the current vote state and vote count of each prompt, and be able to cast my vote,
**So that** I can participate fully in community curation without visual feedback.

## Acceptance Criteria

- [ ] Given a screen reader user on a prompt card, when focus lands on the upvote button, then the screen reader announces the button label, current vote count, and whether the user has already voted (e.g., "Upvote, 42 votes, not yet voted")
- [ ] Given a screen reader user activates the upvote button, when the vote is registered, then an ARIA live region announces the updated count and new state (e.g., "Upvoted. 43 votes.")
- [ ] Given a screen reader user on the downvote button, when focused, then the same pattern of announcement applies as for upvote
- [ ] Given vote counts update via real-time sync while a screen reader user is on the page, when the count changes, then the live region update is polite (not assertive) to avoid interrupting other announcements

## Notes

Use `aria-pressed` on toggle-style vote buttons and `aria-live="polite"` regions for dynamic count updates. Vote count elements should use `aria-label` to provide full context rather than relying on adjacent visible text. Screen reader testing should cover NVDA+Firefox, JAWS+Chrome, and VoiceOver+Safari.
