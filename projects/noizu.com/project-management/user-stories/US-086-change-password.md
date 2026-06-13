---
id: US-086
title: "Change Password"
slug: "change-password"
personas: [P-007, P-001, P-002, P-003]
epic: "Settings & Preferences"
priority: "must-have"
complexity: "S"
tags: [settings, security, password, authentication]
---

# US-086: Change Password

## User Story

**As an** existing client with an active engagement (P-007),
**I want to** change my account password from within settings,
**So that** I can maintain security hygiene and update my credentials if I suspect compromise.

## Acceptance Criteria

- [ ] Given an authenticated user on the Security Settings page, when they navigate to the Change Password section, then they see fields for current password, new password, and confirm new password
- [ ] Given the change password form, when the current password is incorrect, then an error is shown and the new password is not applied
- [ ] Given a new password that does not meet requirements (min 12 chars, mixed case, number or symbol), then inline validation errors describe the specific requirement not met
- [ ] Given a successful password change, when saved, then all other active sessions for the user are invalidated and a confirmation email is sent
- [ ] Given a user who signed up via OAuth (no password set), when they view this section, then a message explains they must set a password before using password-based login, with a "Set Password" flow

## Notes

Session invalidation on password change is a security requirement. The email notification gives the user an alert if the change was unauthorized. Related to US-087 (2FA), US-083 (profile). Password strength meter (visual) is a nice-to-have in the same story.
