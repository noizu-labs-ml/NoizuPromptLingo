---
id: US-051
title: "Timeline Contradiction Detection"
slug: "timeline-contradiction-detection"
personas: [P-001, P-002, P-003]
epic: "Consistency Engine"
priority: "must-have"
complexity: "XL"
tags: [consistency, timeline, validation, contradiction]
---

# US-051: Timeline Contradiction Detection

## User Story

**As a** epic novelist (P-001),
**I want to** have the system automatically detect when events in my timeline contradict each other (e.g., a character dies before an event they participate in),
**So that** I catch anachronisms and plot holes before they reach my readers.

## Acceptance Criteria

- [ ] Given a universe with dated events and character entries, when I save a new event or update an existing one, then the system compares all event dates and participant lifespans for contradictions within 30 seconds.
- [ ] Given a contradiction is detected (e.g., character present at event after their recorded death date), when the consistency check runs, then a flagged issue appears in the Consistency Dashboard with the conflicting entry IDs, a plain-language description, and a severity of "error."
- [ ] Given multiple timeline contradictions exist, when I view the Consistency Dashboard, then contradictions are listed in chronological order of the earliest conflicting event date.
- [ ] Given I have entries without explicit dates, when the system scans for timeline contradictions, then undated entries are skipped and a notice indicates they were excluded from timeline analysis.

## Notes

Depends on US-057 (consistency dashboard). The detection engine must support both absolute dates (e.g., "Year 432 of the Third Age") and relative ordering markers (e.g., "before the Fall"). Related: US-053 (duplicate name detection), US-060 (real-time consistency on edit).
