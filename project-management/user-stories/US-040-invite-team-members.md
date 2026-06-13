---
id: US-040
title: "Invite Team Members to Workspace"
slug: "invite-team-members"
personas: [P-004, P-002]
epic: "Team & Collaboration"
priority: "must-have"
complexity: "M"
tags: [workspace, invitations, team, onboarding]
---

# US-040: Invite Team Members to Workspace

## User Story

**As a** startup founder (P-004),
**I want to** invite colleagues to my workspace by email,
**So that** the whole team can collaborate on mockups under a shared context.

## Acceptance Criteria

- [ ] Given I am a workspace admin, when I enter email addresses in the invite form, then invitation emails are sent with a workspace join link
- [ ] Given an invite link, when a recipient clicks it and creates an account, then they are added to the workspace with the pre-assigned role
- [ ] Given pending invitations, when I view the Members page, then pending invites are listed separately from accepted members
- [ ] Given an invite, when 7 days pass without acceptance, then it expires and I can resend

## Notes

Bulk invite via CSV upload is a future enhancement. Workspace admins can configure whether invite links are single-use or reusable. Ties directly to US-041 (role assignment at invite time).
