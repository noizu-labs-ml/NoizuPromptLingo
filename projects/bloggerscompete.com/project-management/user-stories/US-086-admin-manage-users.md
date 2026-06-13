---
id: US-086
title: "Admin: Manage Users (Ban/Warn)"
slug: "admin-manage-users"
personas: [P-008]
epic: "Admin & Moderation"
priority: "must-have"
complexity: "M"
tags: [admin, users, ban, warn, moderation, accounts]
---

# US-086: Admin: Manage Users (Ban/Warn)

## User Story

**As a** platform admin (P-008),
**I want to** warn or ban users who violate platform policies,
**So that** the community remains safe and rule-abiding for legitimate users.

## Acceptance Criteria

- [ ] Given I am on the admin user management page, when I search by email or username, then matching user accounts are shown with their plan, join date, blog count, and account status (Active/Warned/Banned).
- [ ] Given I click "Warn" on a user, when I enter a reason and confirm, then the user receives a warning email, their account is flagged with a warning, and the warning is logged with timestamp and admin ID.
- [ ] Given a user is warned, when they log in, then a dismissible banner informs them of the warning reason and links to the community guidelines.
- [ ] Given I click "Ban" on a user, when I enter a reason and optional ban duration (temporary: 7/30 days, or permanent), then the user's session is invalidated, login is blocked, and they receive a ban notification email with reason and appeal instructions.
- [ ] Given a user is temporarily banned, when the ban duration expires, then their account is automatically restored to Active status.
- [ ] Given a banned user attempts to log in, when authentication is attempted, then they receive an error: "Your account has been suspended. [Reason] — Contact support to appeal."
- [ ] Given I view a user's profile in admin, when I click "View Activity," then I see a log of their submissions, competition entries, flags received, and warnings/bans.

## Notes

Ban must revoke all active auth tokens. Banned user's public content (blogs, leaderboard entries) should be hidden during ban period. All admin actions (warn, ban, unban) must be logged in an `admin_audit_log` table with acting admin ID. Relates to US-083, US-084.
