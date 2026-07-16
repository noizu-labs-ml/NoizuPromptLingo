---
id: US-085
title: "Block Registration on Expired or Exhausted Invite Tokens"
slug: "register-with-expired-invite-token"
personas: [P-008]
epic: "Edge Cases & Error States"
priority: "must-have"
complexity: "S"
tags: [onboarding, invites, auth, error-handling]
---

# US-085: Block Registration on Expired or Exhausted Invite Tokens

## User Story

**As** Tomás Lindqvist, the Evaluating Newcomer (P-008),
**I want to** see a clear, plain-language explanation when my invite link no longer works,
**So that** I understand whether to request a new invite instead of assuming the product is broken.

## Acceptance Criteria

- [ ] Given an invite token whose expiry timestamp has passed, when Tomás opens the registration link, then the page shows a distinct "this invite has expired" message with guidance to request a new invite, not a generic 404 or 500.
- [ ] Given an invite token that has already reached its max-use count, when a subsequent user registers with it, then the page shows a distinct "this invite has already been used" message, separate from the expiry case.
- [ ] Given either failure state is shown, when the registration attempt fails, then no partial account or org-membership record is created server-side.
- [ ] Given Tomás's browser locale is non-English, when the error page renders, then the message displays correctly without mojibake or layout breakage.

## Notes

Serves the low-familiarity edge-case persona directly — message clarity matters more here than for power users. See US-093 for the general i18n rendering guarantee this error copy relies on.
