---
id: US-096
title: "Rate agent outputs with thumbs up/down and feedback"
personas: [maya-chen]
domain: agent-eval
priority: high
mvp_phase: "v0.2"
---

## User Story

As a **Maya Chen (Solo Dev/Indie Hacker)**, I want to rate agent outputs with thumbs up/down plus optional text feedback directly in context so that I can build a quality signal over time without breaking my workflow to fill out evaluation forms.

## Acceptance Criteria

- [ ] Every agent output (task completion, suggestion, report, code change) displays inline thumbs-up and thumbs-down buttons that are always visible without hovering
- [ ] Clicking a rating optionally expands a text field for freeform feedback — the rating is saved immediately even without text
- [ ] Ratings are stored with full context: the agent, prompt version, task type, input, output, and timestamp
- [ ] A keyboard shortcut (e.g., `Ctrl+Up` / `Ctrl+Down`) allows rating the most recent agent output without reaching for the mouse
- [ ] Rating data is aggregated per agent and per prompt version, feeding into the eval dashboard and prompt-archival annotations

## Notes

This is the foundational data collection mechanism for the entire agent-eval domain — without user ratings, there is no ground truth for agent quality. The design constraint is minimal friction: if rating takes more than 2 seconds, users won't do it. The inline placement matters — ratings must appear where the output appears, not in a separate evaluation interface. For Maya's keyboard-first workflow, the shortcut is essential. Consider a "rate later" queue for outputs that need more thought before rating. The thumbs model is intentionally simple — resist the urge to add 5-star scales or multi-dimensional rubrics at this phase. Binary signal with volume beats nuanced signal with sparse data.
