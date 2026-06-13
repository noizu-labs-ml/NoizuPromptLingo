---
id: US-065
title: "Moderator Queue for Flagged Content"
slug: "moderator-queue-flagged-content"
personas: [P-004]
epic: "Admin & Moderation"
priority: "must-have"
complexity: "L"
tags: [moderation, queue, admin, flagged-content]
---

# US-065: Moderator Queue for Flagged Content

## User Story

**As a** community moderator (P-004),
**I want to** have a dedicated moderation queue showing all flagged content,
**So that** I can efficiently review, act on, and resolve reports without manually searching the site.

## Acceptance Criteria

- [ ] Given I have moderator privileges, when I access the mod queue, then I see a list of flagged prompts and comments sorted by report count and recency
- [ ] Given a flagged item, when I view its queue entry, then I can see the content, the report reason(s), the reporter count, and the submission timestamp
- [ ] Given I take an action (approve, remove, warn user), when I submit it, then the item is removed from the active queue and the action is logged with a timestamp and my moderator ID
- [ ] Given the queue has no pending items, when I view it, then a clear "all clear" state is shown
- [ ] Given a non-moderator user, when they attempt to access the mod queue URL, then they receive a 403 forbidden response

## Notes

Moderator actions should be auditable — all decisions logged for accountability. The queue should support bulk actions for efficiency at scale. Integrates with US-063 (report prompt), US-064 (report comment), US-066 (remove posts), and US-067 (ban users).
