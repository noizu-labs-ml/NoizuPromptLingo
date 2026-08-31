---
id: US-067
title: "Bulk-tag multiple conversations"
slug: bulk-tag-multiple-conversations
personas: [P-005, P-001]
epic: "Conversation Operations"
priority: could-have
complexity: medium
tags: [ops, tagging, bulk]
---

# US-067: Bulk-Tag Multiple Conversations

## User Story

**As an** engineering lead auditing team AI usage (or solo power-user developer)
**I want to** multi-select conversations from Browse and apply a tag to all of them in one action
**So that** I can label a whole batch of sessions (e.g. all threads from a given sprint or client) without tagging them one by one

## Acceptance Criteria

- **Given** I am on the Browse view
  **When** I enable multi-select mode and check several conversations across one or more project groups
  **Then** a "Bulk tag" action becomes available in the selection toolbar

- **Given** I have multiple conversations selected
  **When** I enter a tag in the bulk-tag dialog and confirm
  **Then** the tag is applied to every selected conversation, and each one already carrying that tag is left unchanged (no duplicates)

- **Given** a bulk-tag operation is applied to a large selection (e.g. 50+ conversations)
  **When** the operation runs
  **Then** the UI shows progress and confirms completion with a count of conversations updated

## Notes
Daniel would use this to tag an entire week's threads as "reviewed" in one pass instead of per-thread; Marcus would batch-tag all sessions from a given client repo. Marked could-have — it's a productivity accelerator on top of the must-have single-conversation tagging (US-061), not required for MVP.
