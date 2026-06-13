---
id: US-073
title: "Review flagged/reported content"
slug: "review-flagged-content"
personas: [P-004, P-007]
epic: "Admin & Moderation"
priority: "should-have"
complexity: "M"
tags: [admin, moderation, flagged-content, trust-safety]
---

# US-073: Review Flagged/Reported Content

## User Story

**As a** Startup Founder (P-004),
**I want to** review a queue of mockups or feedback that have been flagged by users or automated filters,
**So that** I can take moderation action (approve, remove, warn user) and maintain platform trust and safety.

## Acceptance Criteria

- [ ] Given the admin moderation queue, when loaded, then all flagged items are listed with: artifact ID, reporter, flag reason, flag timestamp, and current status (pending/reviewed)
- [ ] Given a flagged item, when I open the detail view, then I can preview the flagged content, see the flag reason, and choose an action: approve (unflag), remove content, or warn user
- [ ] Given I take a moderation action, when applied, then the item's status updates and the action is recorded in the audit log (US-074) with the admin's identity and timestamp
- [ ] Given automated content filters flag a generation, when it appears in the queue, then it is visually distinguished from user-reported flags with a "Auto-flagged" label

## Notes

Flag reasons should be a controlled vocabulary (inappropriate content, spam, copyright concern, other) rather than free text, to enable future analytics. Admin actions on content feed into US-074 audit log.
