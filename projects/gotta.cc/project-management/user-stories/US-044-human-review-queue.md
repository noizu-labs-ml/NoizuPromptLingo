---
id: US-044
title: "Human Review Queue for Borderline Scores"
slug: "human-review-queue"
personas: [P-005]
epic: "Moderation & Review"
priority: "must-have"
complexity: "L"
tags: [moderation, review, queue, scoring, human-in-loop]
---

# US-044: Human Review Queue for Borderline Scores

## User Story

**As a** content moderator (P-005),
**I want to** see a prioritized queue of submissions with AI scores between 60 and 70,
**So that** I can apply human judgment to edge cases that the AI cannot confidently classify.

## Acceptance Criteria

- [ ] Given a submission is scored in the 60–70 range by the AI, when scoring completes, then it is automatically placed in the human review queue rather than auto-approved or auto-rejected
- [ ] Given I open the review queue, when it loads, then submissions are sorted by queue age (oldest first) with score, flagged dimensions, and a rendered preview of the submitted site
- [ ] Given I am reviewing a queue item, when I click into it, then I see the full AI score breakdown, the raw page content the AI analyzed, and any submitter notes provided at submission
- [ ] Given I complete my review of an item, when I approve or reject it, then the item is removed from the queue and the submitter is notified with the outcome and rationale per US-045

## Notes

The review queue also surfaces community-flagged listings (US-047). Queue depth and throughput metrics are tracked in the moderator dashboard (US-046). Items older than 7 days without moderator action trigger an alert.
