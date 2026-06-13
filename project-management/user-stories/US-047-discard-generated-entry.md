---
id: US-047
title: "Discard Generated Entry"
slug: "discard-generated-entry"
personas: [P-001, P-002, P-004, P-005]
epic: "Generation Engine"
priority: "must-have"
complexity: "S"
tags: [generation, discard, draft, workflow, cleanup]
---

# US-047: Discard Generated Entry

## User Story

**As a** game master who generated content that doesn't fit my campaign direction (P-002),
**I want to** discard a generated draft cleanly,
**So that** rejected AI output does not clutter my universe or appear in the knowledge graph.

## Acceptance Criteria

- [ ] Given a generated draft is displayed, when I click "Discard", then a confirmation dialog appears asking me to confirm the discard action.
- [ ] Given I confirm the discard, when the action completes, then the draft is removed from the active Generation Studio view and does not appear in the universe's canon entries.
- [ ] Given I discard a draft, when I later check generation history (US-045), then the discarded draft is still visible in history with a "Discarded" status.
- [ ] Given I accidentally discard a draft, when I open Generation History, then I can restore it as a new draft for review within the history retention window.
- [ ] Given I discard a draft, when the action completes, then no canon entry is created and the knowledge graph is not affected.

## Notes

Depends on US-036. Discard is non-destructive — the draft is retained in generation history (US-045) for recoverability. The confirmation dialog prevents accidental loss of generation credits. Related: US-046 (promote), US-045 (history).
