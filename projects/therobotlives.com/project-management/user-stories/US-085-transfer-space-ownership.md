---
id: US-085
title: "Transfer Space Ownership"
slug: "transfer-space-ownership"
personas: [P-003]
epic: "Spaces - Advanced"
priority: "could-have"
complexity: "M"
tags: [spaces, ownership, permissions]
---

# US-085: Transfer Space Ownership

## User Story

**As an** Engineering Team Lead (P-003),
**I want to** transfer ownership of a space I created to another trusted member,
**So that** community leadership can continue smoothly when I step back.

## Acceptance Criteria

- [ ] Given I am a space owner, when I access space settings, then I see a "Transfer Ownership" option
- [ ] Given I click "Transfer Ownership" and select a member from the space's member list, when I confirm the transfer, then the selected member becomes the new owner and I become a regular member
- [ ] Given I attempt to transfer ownership to a non-member, when I submit, then I see an error message "User must be a space member to become owner"
- [ ] Given I initiate a transfer, when confirmation dialog appears, then I see a warning "This action cannot be undone" and a text input to type "TRANSFER" to confirm
- [ ] Given a space owner transfers ownership, when the transfer completes, then both the old and new owners receive in-app notifications about the ownership change

## Notes

Ownership transfer should require explicit confirmation. The system should maintain an audit log of all ownership transfers. Limit one transfer per 30 days to prevent abuse.