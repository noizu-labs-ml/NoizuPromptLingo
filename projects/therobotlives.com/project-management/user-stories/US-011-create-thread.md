---
id: US-011
title: "Create a Thread in a Space"
slug: "create-thread"
personas: [P-001, P-002, P-003, P-005]
epic: "Threads"
priority: "must-have"
complexity: "M"
tags: [threads, creation, content]
---

# US-011: Create a Thread in a Space

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** start a new discussion thread in a space,
**So that** I can ask questions, share ideas, or solicit feedback from the community.

## Acceptance Criteria

- [ ] Given a space member, when they click "New Thread" and enter a title (10-100 characters) and content (10-5000 characters, markdown supported), then a new thread is created in the space
- [ ] Given a user is creating a thread, when they select a label (Question, Discussion, Showcase, Bug Report), then the thread is tagged with that label
- [ ] Given a user is creating a thread, when they @-mention another user, then that user receives a notification when the thread is published
- [ ] Given a user is creating a thread, when they submit an empty title or content, then they receive inline validation errors
- [ ] Given a thread is created, when the user is redirected to the thread view, then they see their post and options to add replies

## Notes

Depends on US-006 for space membership. Thread labels are displayed in the thread list. Markdown supports headings, lists, code blocks, and links.