---
id: US-070
title: "Accessible Dialogue Output Formatting"
slug: "accessible-dialogue"
personas: [P-005]
epic: "Dialogue Manager"
priority: "should-have"
complexity: "M"
tags: [dialogue-manager, accessibility, screen-reader, a11y, output-formatting]
---

# US-070: Accessible Dialogue Output Formatting

## User Story

**As a** blind accessibility-focused game developer (P-005),
**I want to** retrieve NPC dialogue output in a screen-reader-safe structured format,
**So that** I can present conversation content to players using assistive technology without stripping or transforming the raw LLM output myself.

## Acceptance Criteria

- [ ] Given `speak()` called with `output_format="accessible"`, when the response is returned, then it is a dict with keys `speaker_name`, `text`, `emotion_label` (if applicable), and `mode`, with `text` containing no markdown syntax characters (`*`, `_`, `#`, `` ` ``, `[`, `]`).
- [ ] Given `output_format="accessible"` and an NPC in `"grief"` emotional state, when the response dict is returned, then `emotion_label` is set to `"grieving"` (a human-readable label) rather than a numeric intensity.
- [ ] Given `output_format="raw"` (the default), when `speak()` returns, then the response is the unmodified LLM text string for backward compatibility.
- [ ] Given a dialogue turn with `output_format="accessible"` and a skill check result attached, when the response is built, then a `skill_check_outcome` key is present with a plain-text description (e.g., "Persuasion succeeded").
- [ ] Given `dialogue_manager.conversation_transcript(npc_id, player_id, format="accessible")`, when called, then each turn in the returned list has the same accessible dict structure, with `speaker_name` identifying either the NPC name or `"player"`.
- [ ] Given accessible output passed to a plain-text assertion check for ARIA-unsafe characters (`*`, `_`, `#`, `` ` ``), then zero such characters are present in the `text` field.

## Notes

Tomás Rivera (P-005) is the primary driver for accessibility across the framework. Accessible output format should be consistent with US-060 (accessible quest journal) in its approach to symbol stripping. The `emotion_label` field requires US-069 (emotional state) but degrades gracefully if that feature is absent.
