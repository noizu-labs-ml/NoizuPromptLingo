---
id: US-045
title: "Approve or Reject Submission with Rationale"
slug: "approve-reject-with-rationale"
personas: [P-005]
epic: "Moderation & Review"
priority: "must-have"
complexity: "M"
tags: [moderation, decision, rationale, transparency]
---

# US-045: Approve or Reject Submission with Rationale

## User Story

**As a** content moderator (P-005),
**I want to** record a rationale when approving or rejecting a borderline submission,
**So that** the submitter receives meaningful feedback and future moderators can understand decision precedent.

## Acceptance Criteria

- [ ] Given I am reviewing a submission, when I click Approve, then I may optionally add a short note (up to 280 characters) before confirming the decision
- [ ] Given I click Reject, when the rejection dialog opens, then I am required to select at least one rejection reason from a predefined list and may add an optional free-text note before confirming
- [ ] Given a decision is confirmed, when the system processes it, then the submitter receives a notification email linking to the detailed outcome view (US-028 for rejection, US-027 for approval)
- [ ] Given I approve a submission, when the approval is recorded, then the site's listing is created with the confirmed category, AI score, and my moderator note attached as an internal audit log entry (not shown to public)

## Notes

Moderator notes on rejections are surfaced to submitters (US-028) to support the feedback loop. Decisions are logged for auditing and pattern analysis in score recalibration (US-050).
