---
id: US-042
title: "Transfer Mockup Ownership"
slug: "transfer-mockup-ownership"
personas: [P-002, P-004]
epic: "Team & Collaboration"
priority: "could-have"
complexity: "S"
tags: [ownership, transfer, mockups, team]
---

# US-042: Transfer Mockup Ownership

## User Story

**As a** product manager (P-002),
**I want to** transfer ownership of a mockup to another workspace member,
**So that** when team responsibilities change, the correct person has full control over design artifacts.

## Acceptance Criteria

- [ ] Given I own a mockup, when I select a workspace member and click "Transfer Ownership", then they become the new owner and I retain editor access
- [ ] Given a transfer is initiated, when the target user accepts, then the mockup appears under their ownership in the dashboard
- [ ] Given a transfer, when the new owner is confirmed, then both parties receive an email confirmation
- [ ] Given a mockup transfer, when I view the mockup history, then the ownership change is logged with timestamp

## Notes

Transfer should require explicit acceptance by the recipient to prevent unwanted ownership assignments. Workspace admins can force-transfer without acceptance in edge cases (e.g., offboarding).
