---
id: US-063
title: "Report a Prompt as Spam or Harmful"
slug: "report-prompt-spam-harmful"
personas: [P-002, P-004, P-007, P-008]
epic: "Admin & Moderation"
priority: "must-have"
complexity: "M"
tags: [moderation, reporting, spam, safety, community-health]
---

# US-063: Report a Prompt as Spam or Harmful

## User Story

**As a** community moderator (P-004),
**I want** any authenticated user to be able to report a prompt as spam or harmful,
**So that** problematic content is surfaced to moderators quickly and the community stays safe.

## Acceptance Criteria

- [ ] Given I am authenticated and viewing a prompt, when I click "Report," then I see a modal with report reason options (spam, harmful content, misinformation, off-topic, other)
- [ ] Given I select a reason and optionally add details, when I submit the report, then the report is logged and I receive confirmation that it has been received
- [ ] Given a prompt receives multiple reports, when it exceeds a threshold, then it is automatically flagged for moderator review and optionally hidden pending review
- [ ] Given I have already reported a prompt, when I visit it again, then the report button indicates I have already reported it and prevents duplicate submissions

## Notes

Reports should be anonymous to other community members but visible to moderators with reporter identity. Depends on the moderator queue (US-065). Threshold-based auto-hiding should be configurable to avoid abuse of the reporting system.
