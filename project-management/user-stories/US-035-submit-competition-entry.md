---
id: US-035
title: "Submit Competition Entry"
slug: "submit-competition-entry"
personas: [P-001, P-002, P-004]
epic: "Competition Entry"
priority: "must-have"
complexity: "M"
tags: [competitions, entry, submission, confirmation, email]
---

# US-035: Submit Competition Entry

## User Story

**As a** blogger who has reviewed my competition entry preview (P-001),
**I want to** officially submit my entry with a single confirmation action,
**So that** my blog is registered in the competition and I can track my standing.

## Acceptance Criteria

- [ ] Given I am on the final confirmation step, when I click "Submit Entry," then the entry is recorded with a timestamp, my selected posts are locked to the entry, and I am shown a success screen
- [ ] Given my entry is successfully submitted, when the success screen displays, then I see my entry confirmation number, competition name, deadline, and a link to track my entry status
- [ ] Given my entry is successfully submitted, when I check my email, then I receive a confirmation email within 5 minutes containing my entry details and a link to my entry status page
- [ ] Given a network error occurs during submission, when the error is shown, then I can retry without re-entering my post selections (idempotent submission)
- [ ] Given I submit an entry, when I return to the competition detail page, then the entry count has incremented and my entry is reflected in the participant count
- [ ] Given the competition deadline has passed between my preview and submission, when I attempt to submit, then I receive a clear error message that the competition has closed and my entry was not recorded

## Notes

Idempotency is critical — double-clicks or network retries must not create duplicate entries. Use a submission token generated at the preview step. Related to US-032 (entry flow), US-034 (preview), US-036 (entry status). Email confirmation should reference US-036 for status tracking.
