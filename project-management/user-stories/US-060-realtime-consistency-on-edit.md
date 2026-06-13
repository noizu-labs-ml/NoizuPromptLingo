---
id: US-060
title: "Real-Time Consistency Check on Edit"
slug: "realtime-consistency-on-edit"
personas: [P-001, P-002, P-005]
epic: "Consistency Engine"
priority: "should-have"
complexity: "L"
tags: [consistency, real-time, editor, inline, validation]
---

# US-060: Real-Time Consistency Check on Edit

## User Story

**As a** hobbyist worldbuilder (P-005),
**I want to** see consistency warnings appear inline while I'm editing an entry,
**So that** I catch contradictions in the moment of creation rather than discovering them in a separate review step.

## Acceptance Criteria

- [ ] Given I am editing a canon entry in the Canon Editor, when I change a date, name, or reference field and pause typing for 2 seconds, then the system runs targeted consistency checks relevant to the changed fields and displays any new issues as inline callouts within the editor without saving the entry.
- [ ] Given an inline consistency callout appears, when I hover or tap it, then I see the same detail (conflicting entry, description, severity) that would appear on the Consistency Dashboard, with a link to the full issue view.
- [ ] Given a real-time check produces no new issues, when I finish editing, then no callouts are shown and the save action proceeds normally without a consistency blocking gate.
- [ ] Given real-time checks are running, when the editor has unsaved changes, then the consistency callouts are clearly marked as "preview — based on unsaved changes" and do not create permanent issues in the dashboard until the entry is saved.

## Notes

Real-time checks should be scoped to fast, low-cost checks (name duplicates, direct timeline conflicts) — expensive checks (full geographic traversal) should be deferred to batch. Depends on US-051, US-053, US-057. Related: US-058 (batch check).
