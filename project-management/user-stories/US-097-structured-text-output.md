---
id: US-097
title: "Structured Text Output Mode"
slug: "structured-text-output"
personas: [P-005]
epic: "Accessibility & Integration"
priority: "must-have"
complexity: "M"
tags: [accessibility, screen-reader, output, a11y, blind]
---

# US-097: Structured Text Output Mode

## User Story

**As a** blind accessibility game developer (P-005),
**I want to** configure NoizuRPG to produce all narrative, dialogue, and state output as clean structured plain text with no decorative characters, emoji, markdown symbols, or ANSI escape codes,
**So that** screen readers can consume framework output faithfully and I can build accessible games without post-processing every string the framework emits.

## Acceptance Criteria

- [ ] Given `NoizuRPGConfig(output_mode="structured_text")`, when the Narrative Engine produces a scene description, then the output contains no emoji, no ANSI color codes, no markdown syntax characters (`*`, `#`, `_`, `` ` ``), and no decorative box-drawing characters
- [ ] Given structured text mode, when a combat event occurs with stat changes, then the output uses plain prose or labeled key-value pairs (e.g., `Health: 45/100 (-15)`) rather than visual bars or symbolic representations
- [ ] Given structured text mode, when dialogue choices are presented, then each option is numbered plainly (e.g., `1. Agree with the merchant`) with no surrounding brackets, arrows, or decorative punctuation
- [ ] Given structured text mode, when an error or system message is emitted, then it is prefixed with `[ERROR]`, `[WARNING]`, or `[INFO]` in plain ASCII with no color or symbols, making it parseable programmatically as well as audibly
- [ ] Given a game built on top of NoizuRPG that passes all output through structured text mode, when it is evaluated with a major screen reader (NVDA, JAWS, or VoiceOver), then no output produces garbled, skipped, or repeated readings due to special characters

## Notes

This mode must be respected by every component's output path, including the CLI helper utilities and any built-in formatters. Pairs with US-098 (ARIA event output) for the full accessible game development story. P-005 represents a small but critically important user segment — accessibility must be first-class, not an afterthought.
