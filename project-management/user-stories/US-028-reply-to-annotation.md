---
id: US-028
title: "Reply to an Existing Annotation"
slug: "reply-to-annotation"
personas: [P-002, P-003, P-004]
epic: "Stakeholder Feedback"
priority: "must-have"
complexity: "S"
tags: [annotations, feedback, threading, comments]
---

# US-028: Reply to an Existing Annotation

## User Story

**As a** product manager (P-002),
**I want to** reply to an existing annotation thread,
**So that** conversations stay contextually grouped and reviewable without losing context.

## Acceptance Criteria

- [ ] Given an annotation exists, when I click "Reply", then a text input appears nested under the original comment
- [ ] Given a reply is submitted, when others view the annotation, then all replies are displayed in chronological order within the thread
- [ ] Given a thread has replies, when I collapse the thread, then only the root annotation and reply count are shown
- [ ] Given an annotation thread, when a new reply is added by another user, then existing participants receive a notification (see US-033)

## Notes

Threading depth should be limited to 2 levels (comment + replies) to avoid deep nesting. Supports @mention syntax per US-045.
