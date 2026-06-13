---
id: US-088
title: "Admin: View Flagged Content Queue"
slug: "view-flagged-content"
personas: [P-008]
epic: "Admin & Moderation"
priority: "should-have"
complexity: "S"
tags: [admin, moderation, flagged, queue, review]
---

# US-088: Admin: View Flagged Content Queue

## User Story

**As a** platform admin (P-008),
**I want to** see all user-flagged content in a dedicated moderation queue,
**So that** I can prioritize review of community-reported problems and take action promptly.

## Acceptance Criteria

- [ ] Given I navigate to `/admin/moderation`, when the page loads, then I see a queue of all content flagged by users, sorted by flag count descending (most-reported first).
- [ ] Given a flagged item in the queue, when I view its row, then I see: content type (Blog/Comment), content title/excerpt, reporter usernames, flag reason(s), flag count, date first flagged, and current status.
- [ ] Given I click "Review" on a flagged item, when the detail panel opens, then I can preview the content inline (blog URL rendered in iframe or preview card) without leaving the admin interface.
- [ ] Given I review a flagged item and decide it is a false report, when I click "Dismiss Flag," then the flag is cleared, the content status reverts to Active, and the flag count resets to 0.
- [ ] Given I review a flagged item and decide action is warranted, when I click "Remove Content," then the content is soft-deleted and the queue item is marked "Resolved — Removed."
- [ ] Given the moderation queue is empty, when I view the page, then an empty state shows: "No flagged content — the community is behaving!" with a green checkmark icon.

## Notes

Flagging is distinct from admin flagging (US-084) — this queue surfaces user-generated reports. Each unique user can flag a piece of content once. Flag reasons from the user's perspective: Spam, Inappropriate, Broken/Dead Link, Other. Relates to US-083, US-084, US-087.
