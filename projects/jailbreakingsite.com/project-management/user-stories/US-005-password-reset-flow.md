---
id: US-005
title: "Password Reset Flow"
slug: "password-reset-flow"
personas: [P-001, P-002, P-005, P-006]
epic: "Onboarding & Authentication"
priority: "should-have"
complexity: "S"
tags: [auth, password, reset, email]
---

# US-005: Password Reset Flow

## User Story

**As a** user who has forgotten my password (P-001, P-002, P-005, P-006),
**I want to** reset my password via a secure email link,
**So that** I can regain access to my account without contacting support.

## Acceptance Criteria

- [ ] Given I submit my email on the forgot-password page, when the email is in the system, then a reset link is sent and I see a confirmation message that does not reveal whether the address exists
- [ ] Given I click a valid reset link, when I submit a new password meeting complexity requirements, then my password is updated and all existing sessions are invalidated
- [ ] Given I click a reset link that is older than 1 hour, when the page loads, then I see an expiry message with a link to request a new reset
- [ ] Given I successfully reset my password, when the flow completes, then I am automatically logged in and redirected to my dashboard

## Notes

The "does not reveal whether address exists" requirement prevents email enumeration attacks. Links must be single-use tokens. Depends on US-004 for the post-reset login behavior.
