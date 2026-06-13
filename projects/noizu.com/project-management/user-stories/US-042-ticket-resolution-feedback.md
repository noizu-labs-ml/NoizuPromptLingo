---
id: US-042
title: "Ticket Resolution Feedback"
slug: "ticket-resolution-feedback"
personas: [P-007]
epic: "Support & Communication"
priority: "could-have"
complexity: "S"
tags: [support, feedback, satisfaction, tickets]
---

# US-042: Ticket Resolution Feedback

## User Story

**As a** client whose support ticket has been resolved (P-007),
**I want to** provide quick feedback on whether the resolution was satisfactory,
**So that** Keith can continuously improve response quality and identify tickets that need follow-up despite being "closed".

## Acceptance Criteria

- [ ] Given my ticket is marked resolved, when I view the ticket or receive the resolution email, then I see a simple satisfaction prompt (e.g. "Was this resolved to your satisfaction? Yes / No")
- [ ] Given I select "Yes", when my response is recorded, then the ticket is closed and no further prompting occurs
- [ ] Given I select "No", when my response is recorded, then the ticket is automatically reopened with a "needs follow-up" flag and I am prompted for optional comments
- [ ] Given I do not respond within 72 hours of resolution, when the timeout elapses, then the ticket auto-closes and counts as implicitly satisfied
- [ ] Given I provide optional written feedback, when it is submitted, then it is stored against the ticket and visible to Keith in the admin view

## Notes

Keep the UI minimal — a two-button prompt in-app and in email. Do not force a rating scale at this stage; a simple yes/no reduces friction. The "No" path reopening the ticket is the highest-value behavior here. Feedback data could feed a future client satisfaction dashboard for Keith. Related to US-041 (resolution email includes feedback link).
