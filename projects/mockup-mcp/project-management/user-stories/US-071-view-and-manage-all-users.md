---
id: US-071
title: "View and manage all users"
slug: "view-and-manage-all-users"
personas: [P-004]
epic: "Admin & Moderation"
priority: "should-have"
complexity: "M"
tags: [admin, users, management, moderation]
---

# US-071: View and Manage All Users

## User Story

**As a** Startup Founder (P-004),
**I want to** view a searchable list of all registered users with their plan, usage stats, and account status,
**So that** I can support customers, investigate abuse, and manage account states directly from the admin panel.

## Acceptance Criteria

- [ ] Given the admin users page, when loaded, then a paginated list of all users is displayed with: email, plan tier, generation count (30d), account status, and join date
- [ ] Given the user list, when I search by email or name, then the list filters in real-time to matching users
- [ ] Given a specific user record, when I open it, then I can view their API keys (masked), recent generation history, and current quota usage
- [ ] Given a user record, when I toggle their account status to "suspended", then that user's API keys immediately stop authenticating and they cannot log in

## Notes

Suspension must propagate to auth and API key validation layers, not just the UI. Search should be server-side for large user bases. Related to US-075 (force-revoke key) — suspension is account-level, revoke is key-level.
