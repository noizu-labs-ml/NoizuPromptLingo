---
id: US-023
title: "Add a journal entry documenting completed work"
slug: "add-journal-entry-documenting-completed-work"
personas: [P-002]
epic: "Agent Personas & Memory"
priority: "must-have"
complexity: "S"
tags: [personas, journal, worklog, mvp]
---

# US-023: Add a journal entry documenting completed work

## User Story

**As the** Autonomous Coding Agent (P-002),
**I want to** append a journal entry to my persona's work-log after finishing a task,
**So that** there is a durable, chronological record of what I did that I or a teammate can review later.

## Acceptance Criteria

- [ ] Given Sable has a registered persona (US-022), when it submits a journal entry summarizing completed work, then the entry is appended to the persona's journal with a timestamp and, if provided, a reference to the related session or ticket.
- [ ] Given multiple journal entries exist for a persona, when the journal is fetched, then entries are returned in consistent chronological order.
- [ ] Given a journal entry submission with no summary text, when Sable attempts to submit it, then the system rejects it with a validation error.
- [ ] Given a journal entry linked to a session ID, when a human operator views the persona's journal, then they can trace that entry back to the originating session.

## Notes

The journal is treated as append-only — no update/delete acceptance criteria are included here since the log is meant to be immutable history.
