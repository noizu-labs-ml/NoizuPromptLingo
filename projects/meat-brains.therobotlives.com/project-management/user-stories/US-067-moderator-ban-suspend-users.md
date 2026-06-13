---
id: US-067
title: "Moderator Can Ban or Suspend Users"
slug: "moderator-ban-suspend-users"
personas: [P-004]
epic: "Admin & Moderation"
priority: "should-have"
complexity: "M"
tags: [moderation, ban, suspend, admin, user-management]
---

# US-067: Moderator Can Ban or Suspend Users

## User Story

**As a** community moderator (P-004),
**I want to** suspend or permanently ban users who repeatedly violate community guidelines,
**So that** bad actors cannot continue to harm the community after content-level actions have failed.

## Acceptance Criteria

- [ ] Given I have moderator privileges, when I visit a user's profile or mod queue entry, then I have the option to suspend (temporary) or ban (permanent) the account
- [ ] Given I apply a suspension, when I specify a duration and reason, then the user's account is locked for that period and they receive a notification with the reason and duration
- [ ] Given a suspended or banned user attempts to log in, when their credentials are validated, then they are shown a message explaining the restriction and its duration
- [ ] Given a permanent ban, when the banned user's existing content is viewed, then it remains visible with a "suspended account" label on the author attribution unless separately removed
- [ ] Given a moderator applies a ban, when the action is complete, then the audit log records the action, reason, moderator ID, and timestamp

## Notes

Suspension and ban are distinct states. Suspensions should expire automatically. Banned users should not be able to create new accounts with the same email. The appeal workflow (US-069) must reference the ban record.
