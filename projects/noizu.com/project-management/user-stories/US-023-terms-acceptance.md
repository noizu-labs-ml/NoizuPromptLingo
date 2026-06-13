---
id: US-023
title: "Terms of Service & Privacy Policy Acceptance"
slug: "terms-acceptance"
personas: [P-007, P-006]
epic: "Authentication & Onboarding"
priority: "should-have"
complexity: "S"
tags: [legal, terms, privacy, compliance, onboarding]
---

# US-023: Terms of Service & Privacy Policy Acceptance

## User Story

**As a** new client completing registration (P-007),
**I want to** review and accept the Terms of Service and Privacy Policy,
**So that** I understand the data handling practices and engagement terms before accessing the platform.

## Acceptance Criteria

- [ ] Given a user completes registration (US-018), when the onboarding flow begins, then a terms acceptance screen is shown before dashboard access is granted.
- [ ] Given the terms screen is shown, when rendered, then links to both `/legal/terms` and `/legal/privacy` are present and open in a new tab.
- [ ] Given a user checks the acceptance checkbox and submits, when the record is saved, then the acceptance is stored with a timestamp and the version of terms accepted.
- [ ] Given a user attempts to skip the terms screen by navigating directly to the dashboard URL, when the middleware evaluates their session, then they are redirected back to the terms screen.
- [ ] Given the Terms of Service are updated (new version), when an existing user next logs in, then they are presented with the updated terms and must re-accept before continuing.

## Notes

Store terms_version alongside accepted_at timestamp in the user record to handle future re-acceptance flows. Terms and Privacy pages should be static, human-readable, and linked from the site footer as well. Related: US-018 (registration), US-024 (onboarding flow).
