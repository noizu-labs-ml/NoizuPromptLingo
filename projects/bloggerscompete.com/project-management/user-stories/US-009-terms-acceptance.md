---
id: US-009
title: "Terms of Service and Privacy Policy Acceptance"
slug: "terms-acceptance"
personas: [P-001, P-004]
epic: "Onboarding & Auth"
priority: "must-have"
complexity: "S"
tags: [onboarding, legal, terms, privacy]
---

# US-009: Terms of Service and Privacy Policy Acceptance

## User Story

**As a** new user (P-004),
**I want to** review and accept the Terms of Service and Privacy Policy during registration,
**So that** I understand the platform rules and my data rights before using the service.

## Acceptance Criteria

- [ ] Given I am completing registration, when the registration form is rendered, then a checkbox is shown with the label "I agree to the [Terms of Service] and [Privacy Policy]" where both terms are clickable links opening the respective documents in a new tab
- [ ] Given the terms checkbox is unchecked, when I attempt to submit the registration form, then the submission is blocked and an inline error "You must accept the Terms of Service and Privacy Policy to continue" is shown
- [ ] Given I check the terms checkbox and register, when my account is created, then the acceptance is recorded with a timestamp and the version of the terms accepted
- [ ] Given the platform updates its Terms of Service, when I next log in, then I am shown a modal requiring acceptance of the updated terms before I can continue (dismissing or navigating away returns me to the modal)
- [ ] Given I am a returning user being asked to accept updated terms, when I click "Decline", then I am offered the option to download my data and delete my account before the modal closes

## Notes

Terms version number and acceptance timestamp must be stored per user for compliance. Related: US-001 (email registration), US-002 (OAuth registration should also record acceptance).
