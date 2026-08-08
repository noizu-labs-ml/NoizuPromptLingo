---
id: US-054
title: "Suspend a User Account"
slug: "suspend-a-user-account"
personas: [P-006]
epic: "Admin & Platform Operations"
priority: "must-have"
complexity: "S"
tags: [admin, user-management, security]
---

# US-054: Suspend a User Account

## User Story

**As a** Platform Administrator, Ilya Petrov (P-006),
**I want to** suspend a user's account globally,
**So that** I can immediately cut off access for a compromised, abusive, or offboarded user across every org they belong to.

## Acceptance Criteria

- [ ] Given Ilya is on the admin user detail page for a target user, when he suspends the account and confirms, then the user's status changes to "suspended" and any active sessions are immediately signed out.
- [ ] Given a user account is suspended, when that user (or their API key/agent session) attempts any authenticated request, then the request is rejected with a clear "account suspended" error regardless of which org it targets.
- [ ] Given Ilya views the suspended user's detail page, when the suspension is active, then the UI shows suspended status, the admin who performed it, and a timestamp.
- [ ] Given Ilya un-suspends a previously suspended account, when he confirms the action, then the user regains normal access on their next authentication attempt.

## Notes

Global action independent of org membership; distinct from org-level member removal. Pairs with US-055 for role-based access changes.
