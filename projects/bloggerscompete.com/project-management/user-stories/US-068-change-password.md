---
id: US-068
title: "Change Password"
slug: "change-password"
personas: [P-001, P-002, P-003, P-004]
epic: "Settings & Account"
priority: "must-have"
complexity: "S"
tags: [settings, password, security, account]
---

# US-068: Change Password

## User Story

**As a** registered user,
**I want to** change my account password from within settings,
**So that** I can maintain account security and recover from situations where I suspect my password is compromised.

## Acceptance Criteria

- [ ] Given I navigate to /settings/security, when the page loads, then I see a change password form with fields for: current password, new password, and confirm new password
- [ ] Given I submit the form with an incorrect current password, when validation runs, then an error message "Current password is incorrect" is shown and the new password is not applied
- [ ] Given I submit a new password that does not meet requirements (min 8 chars, at least 1 number, 1 symbol), when validation runs, then inline errors describe which requirements are unmet
- [ ] Given I submit valid current and new passwords that match, when the change succeeds, then all other active sessions for my account are invalidated, a confirmation email is sent, and I see a success toast
- [ ] Given my account was created via OAuth (Google/GitHub) and has no password set, when I visit /settings/security, then I see a "Set password" flow instead of "Change password"

## Notes

Session invalidation on password change is a security requirement — users must re-login on other devices. OAuth users should be able to add password auth in addition to OAuth. See US-067 for profile edit, US-002 for OAuth login.
