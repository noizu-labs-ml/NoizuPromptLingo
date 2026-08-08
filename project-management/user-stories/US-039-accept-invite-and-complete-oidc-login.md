---
id: US-039
title: "Accept an Invite and Complete OIDC Login"
slug: "accept-invite-and-complete-oidc-login"
personas: [P-008]
epic: "Onboarding & Auth"
priority: "must-have"
complexity: "M"
tags: [invites, oidc, onboarding, newcomer]
---

# US-039: Accept an Invite and Complete OIDC Login

## User Story

**As an** Evaluating Newcomer (P-008) with low familiarity with the platform,
**I want to** accept an organization invite and be guided straight into OIDC login,
**So that** I can join the organization without needing to understand the underlying auth mechanics first.

## Acceptance Criteria

- [ ] Given I open a valid, unexpired invite link, when the invite page loads, then I see the inviting organization's name and a single clear call-to-action to continue via SSO login.
- [ ] Given I select "continue" on a valid invite, when I am routed through `/auth/oidc` and complete the Authentik login, then my account is created or linked and I am added as a member of the inviting organization.
- [ ] Given I open an invite link that is expired or already exhausted, when the page loads, then I see a plain-language error explaining the invite is no longer valid, without exposing internal token details.

## Notes

Depends on an invite issued per US-038. The login portion continues into the first-time SSO callback in US-040.
