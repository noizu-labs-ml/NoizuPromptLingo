---
id: US-055
title: "Change a User's Global Role with Self-Lockout Guard"
slug: "change-a-users-global-role-with-self-lockout-guard"
personas: [P-006]
epic: "Admin & Platform Operations"
priority: "must-have"
complexity: "M"
tags: [admin, rbac, self-lockout]
---

# US-055: Change a User's Global Role with Self-Lockout Guard

## User Story

**As a** Platform Administrator, Ilya Petrov (P-006),
**I want to** change a user's global platform role while being guarded against locking myself out,
**So that** I can manage platform-admin staffing without risking the platform ending up with zero admins.

## Acceptance Criteria

- [ ] Given Ilya is viewing another admin's user detail page, when he changes their global role to a non-admin role and confirms, then the change is applied and takes effect on their next request.
- [ ] Given Ilya is the only remaining platform admin, when he attempts to demote his own account from admin to a non-admin role, then the action is blocked with an explanatory error preventing zero-admin lockout.
- [ ] Given at least two platform admins exist, when Ilya demotes his own account, then the action succeeds because another admin remains to manage the platform.
- [ ] Given Ilya changes another user's role, when the change is saved, then an audit log entry records who made the change, the prior role, the new role, and when.

## Notes

The self-lockout guard restricts only removal of the *last* admin, not all self-role edits. Complements US-054 — suspension is orthogonal to role.
