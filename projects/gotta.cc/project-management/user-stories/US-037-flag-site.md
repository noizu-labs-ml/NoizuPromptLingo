---
id: US-037
title: "Flag a Site as Low-Quality or Miscategorized"
slug: "flag-site"
personas: [P-001, P-003, P-004, P-008]
epic: "Community & Social"
priority: "must-have"
complexity: "M"
tags: [community, moderation, flagging, quality]
---

# US-037: Flag a Site as Low-Quality or Miscategorized

## User Story

**As a** research journalist (P-003),
**I want to** flag a listed site that appears to be AI-generated slop or is in the wrong category,
**So that** the directory's quality is maintained and moderators are alerted to review it.

## Acceptance Criteria

- [ ] Given I am viewing a listing, when I open the flag menu, then I can choose a reason: Low Quality, Likely AI-Generated, Miscategorized, Broken/Dead Link, or Spam
- [ ] Given I submit a flag, when it is recorded, then I see a confirmation that the flag is under review, and the listing remains visible to others until a moderator acts
- [ ] Given a listing accumulates 5 or more unique user flags, when the threshold is crossed, then it is automatically escalated to the human review queue (US-047) with a flag-reason summary
- [ ] Given I have already flagged a listing, when I view it again, then the flag button reflects my previous submission and prevents duplicate flagging from the same account

## Notes

Flags feed directly into the moderator queue (US-047). Anti-spam logic (US-049) also monitors for coordinated flag brigading. The flagging system should be available even to non-logged-in users for broken links, though account-based flags carry more weight.
