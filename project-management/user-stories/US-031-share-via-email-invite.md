---
id: US-031
title: "Share Mockup with Specific Team Members via Email Invite"
slug: "share-via-email-invite"
personas: [P-002, P-004]
epic: "Stakeholder Feedback"
priority: "must-have"
complexity: "M"
tags: [sharing, email, invitations, access-control]
---

# US-031: Share Mockup with Specific Team Members via Email Invite

## User Story

**As a** startup founder (P-004),
**I want to** invite specific people by email to view or comment on a mockup,
**So that** I can gather structured feedback from targeted stakeholders without broadcasting a public link.

## Acceptance Criteria

- [ ] Given a mockup, when I enter one or more email addresses and click "Invite", then each recipient receives an email with a direct link
- [ ] Given an invite is sent, when the recipient clicks the link and has no account, then they are prompted to create one or use guest access
- [ ] Given pending invites, when I view the share panel, then I can see who has been invited and whether they have accepted
- [ ] Given an invite, when I revoke it before acceptance, then the invite link is invalidated

## Notes

Email delivery should use transactional email (e.g., SendGrid/Postmark). Accepted invites should respect the permission level set at invite time per US-032.
