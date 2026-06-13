---
id: US-044
title: "Set narrative tone and style"
slug: "narrative-tone"
personas: [P-002]
epic: "Narrative Engine"
priority: "should-have"
complexity: "S"
tags: [narrative-engine, tone, style, prose, configuration]
---

# US-044: Set Narrative Tone and Style

## User Story

**As a** interactive fiction author with a distinct prose voice (P-002),
**I want to** configure the Narrative Engine's tone, tense, person, and stylistic constraints via a concise style profile,
**So that** all generated narrative output consistently matches my intended literary register without injecting style instructions into every individual prompt.

## Acceptance Criteria

- [ ] Given a style profile `{"tone": "melancholic", "tense": "past", "person": "second", "vocabulary": "literary"}`, when I call `engine.set_style(profile)`, then subsequent `engine.generate()` calls include these style directives in the system prompt.
- [ ] Given a style profile with `"person": "second"`, when narrative is generated, then the output uses second-person perspective (e.g. "You walk into the chamber...") rather than third-person.
- [ ] Given a style profile with `"forbidden_words": ["suddenly", "very", "really"]`, when narrative is generated and contains those words, then a `StyleViolationWarning` is emitted and the offending words are flagged in the result.
- [ ] Given no style profile configured, when `engine.generate()` is called, then a sensible default style (third-person, present tense, neutral tone) is applied without error.
- [ ] Given a style profile, when I call `engine.get_style()`, then the currently active profile dict is returned verbatim.

## Notes

This is a small story because tone configuration is purely a system-prompt injection concern. P-002's workflows require voice consistency across an entire IF work — without this, every call would require manual style injection. Style profiles should be saveable in world snapshots (US-031) for session persistence.
