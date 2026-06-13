---
id: US-015
title: "Thread Labels"
slug: "thread-labels"
personas: [P-001, P-002, P-003, P-005]
epic: "Threads"
priority: "should-have"
complexity: "S"
tags: [threads, labeling, taxonomy]
---

# US-015: Thread Labels

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** categorize my threads with labels like "Question" or "Showcase",
**So that** others can quickly understand the thread's purpose and find relevant discussions.

## Acceptance Criteria

- [ ] Given a user is creating a thread, when they select a label from the dropdown (Question, Discussion, Showcase, Bug Report), then the label is displayed next to the thread title in listings
- [ ] Given a user is viewing a space's thread list, when they click a filter label, then the list shows only threads with that label
- [ ] Given a thread is created without a label, when it is saved, then it defaults to "Discussion"
- [ ] Given a thread author, when they edit their thread and change the label, then the change is reflected immediately in listings and detail views
- [ ] Given a space moderator, when they view a thread, then they can change the label without requiring author permission

## Notes

Depends on US-011 for thread creation. Labels are space-scoped; each space can have custom labels in future iterations. Default label is Discussion for now.