---
id: US-060
title: "Quest Journal Accessible Output"
slug: "accessible-quest-journal"
personas: [P-005]
epic: "Quest Engine"
priority: "should-have"
complexity: "M"
tags: [quest-engine, accessibility, screen-reader, journal, a11y]
---

# US-060: Quest Journal Accessible Output

## User Story

**As a** blind accessibility-focused game developer (P-005),
**I want to** retrieve quest journal state as structured, screen-reader-friendly text,
**So that** I can surface quest progress to players using assistive technologies without building my own serialization layer.

## Acceptance Criteria

- [ ] Given a player with two active quests and one completed quest, when `quest_engine.journal(player_id, format="text")` is called, then the returned string lists all quests grouped by status with no markdown symbols that would be read aloud as punctuation by screen readers.
- [ ] Given `journal()` called with `format="structured"`, when the return value is inspected, then it is a dict with keys `active`, `completed`, and `failed`, each containing a list of quest summary dicts with `title`, `current_stage_description`, and `objectives` fields.
- [ ] Given a quest with three objectives where two are complete, when the journal entry for that quest is rendered as text, then each objective is prefixed with "complete" or "incomplete" as a spoken word rather than a symbol.
- [ ] Given `journal()` called with `include_hints=True`, when an active quest has an `npc_hint` field on the current stage, then the hint text is appended to the stage description in the journal output.
- [ ] Given a player with no quests of any status, when `journal()` is called, then the returned text contains an explicit "No quests" message rather than blank output or empty list notation.
- [ ] Given `journal(format="text")` output, when it is passed through a standard ARIA live-region update (simulated by checking for absence of `#`, `*`, `_`, `[`, `]` characters), then none of those characters appear in the output string.

## Notes

Tomás Rivera (P-005) is the primary driver for accessibility across the framework. The `format="text"` output must be safe to inject directly into ARIA live regions or TTS pipelines. See also US-070 (accessible dialogue output) for the corresponding Dialogue Manager story.
