---
id: US-010
title: "Accept Terms of Service and Responsible Use Agreement"
slug: "accept-terms-of-service"
personas: [P-001, P-002, P-003, P-005, P-006, P-007]
epic: "Onboarding & Authentication"
priority: "could-have"
complexity: "S"
tags: [legal, terms, responsible-use, compliance]
---

# US-010: Accept Terms of Service and Responsible Use Agreement

## User Story

**As a** new user during registration (P-001, P-002, P-003, P-005, P-006, P-007),
**I want to** review and explicitly accept the Terms of Service and Responsible Use Agreement,
**So that** I understand the ethical and legal boundaries of the platform and my account is properly credentialed for access to sensitive technique data.

## Acceptance Criteria

- [ ] Given I complete the registration form, when I reach the ToS step, then I must actively check acceptance checkboxes (separate for ToS and Responsible Use Agreement) before proceeding — no pre-checked boxes
- [ ] Given I attempt to submit registration without checking both agreements, when submission is triggered, then the unchecked fields are highlighted with a clear error and registration is blocked
- [ ] Given I click on the ToS or Responsible Use Agreement link, when the document opens, then it opens in a modal or new tab without losing my registration state
- [ ] Given a ToS version is updated, when I next log in after an update, then I am prompted to review and re-accept the new version before continuing

## Notes

The Responsible Use Agreement is a distinct document covering authorized testing, prohibition of offensive use, and disclosure obligations. Re-acceptance on version updates is a legal compliance requirement. Acceptance timestamps and version numbers must be stored per user.
