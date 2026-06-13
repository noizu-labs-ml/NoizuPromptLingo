---
id: US-070
title: "View Moderation Queue for Space Moderators"
slug: "moderation-queue"
personas: [P-001, P-002, P-003]
epic: "Moderation"
priority: "could-have"
complexity: "L"
tags: [moderation, admin, workflow]
---

# US-070: View Moderation Queue for Space Moderators

## User Story

**As a** Prompt Engineer Power User (P-001), AI/ML Engineer (P-002), or Engineering Team Lead (P-003) acting as a space moderator,
**I want to** see a unified queue of all reported content and moderation actions for my spaces,
**So that** I can efficiently review reports, take appropriate action, and maintain community standards.

## Acceptance Criteria

- [ ] Given I am a moderator for one or more spaces, when I access the moderation queue, then I see a table of pending reports with: reported content type (post/resource/thread), report reason, reporter (anonymous ID), reported user, space name, timestamp, and priority level
- [ ] Given moderation queue is populated, when I filter by space or priority, then the list updates to show only matching reports
- [ ] Given I click a report, when the detail view opens, then I see the full reported content, report details, previous moderation history for the user, and action buttons (dismiss/warn user/hide content/timeout user/ban user)
- [ ] Given multiple moderators exist, when I review a report, then the system tracks which moderator handled it with timestamp and action taken
- [ ] Given a report is resolved, when I view the queue, then it moves to a "resolved" tab with option to reopen if needed

## Notes

Priority levels should be auto-calculated based on severity (hate speech = high, spam = medium) and number of reports for same content. Bulk actions should be available for handling multiple similar reports. Moderation actions should log to audit trail for compliance and accountability.