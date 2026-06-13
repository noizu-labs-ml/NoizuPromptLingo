---
id: US-072
title: "Change Email Address"
slug: "change-email-address"
personas: [P-001, P-002, P-005, P-007]
epic: "Settings & Preferences"
priority: "should-have"
complexity: "M"
tags: [settings, account, email, security, verification]
---

# US-072: Change Email Address

## User Story

**As an** indie developer (P-005),
**I want to** change the email address associated with my account,
**So that** I can keep my account accessible if my primary email changes.

## Acceptance Criteria

- [ ] Given I am authenticated, when I navigate to account settings and enter a new email address, then a verification email is sent to the new address before the change is applied
- [ ] Given the verification email is sent, when I click the confirmation link within 24 hours, then my email is updated and a security notification is sent to my old address
- [ ] Given the verification link expires before I click it, when I attempt to use it, then I receive an error and must re-initiate the change
- [ ] Given the new email address is already in use by another account, when I try to save it, then I receive an inline error and the change is not processed

## Notes

Sending a security notice to the old email is critical to protect against account takeover. The verification link should be single-use and time-limited (24 hours). Rate-limit email change requests to prevent abuse.
