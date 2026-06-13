---
id: US-088
title: "Connected Accounts (GitHub, LinkedIn)"
slug: "connected-accounts-github-linkedin"
personas: [P-001, P-007, P-005]
epic: "Settings & Preferences"
priority: "could-have"
complexity: "M"
tags: [settings, oauth, github, linkedin, social-login]
---

# US-088: Connected Accounts (GitHub, LinkedIn)

## User Story

**As a** startup CTO / technical co-founder (P-001),
**I want to** link my GitHub and LinkedIn profiles to my account,
**So that** I can sign in with social credentials and optionally display professional context in my portal profile.

## Acceptance Criteria

- [ ] Given an authenticated user on the Connected Accounts settings page, then they see connection cards for GitHub and LinkedIn showing connected/disconnected state
- [ ] Given a disconnected provider card, when the user clicks "Connect," then the OAuth authorization flow opens in a popup or redirect, and on success the account is linked
- [ ] Given a successful connection, when the settings page reloads, then the card shows the connected external username and a "Disconnect" action
- [ ] Given a connected provider, when the user clicks "Disconnect," then a confirmation prompt appears; on confirm the OAuth link is removed but the user's primary email/password login is unaffected
- [ ] Given a user with only one connected method and no password set, when they try to disconnect it, then disconnection is blocked with a message to set a password first
- [ ] Given a LinkedIn connection, when the user authorizes it, then their LinkedIn headline and profile URL are optionally pre-filled into the profile fields (user can accept or discard)

## Notes

OAuth scopes should be minimal: GitHub (read:user, user:email), LinkedIn (r_liteprofile, r_emailaddress). Connecting does not auto-import contacts or post on behalf of the user. Related to US-083 (profile), US-086 (password).
