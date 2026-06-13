---
id: US-015
title: "Genre and Tone Configuration"
slug: "genre-tone-configuration"
personas: [P-001, P-002, P-008]
epic: "Universe Management"
priority: "should-have"
complexity: "M"
tags: [universe, genre, tone, ai, configuration]
---

# US-015: Genre and Tone Configuration

## User Story

**As a** webcomic creator (P-008),
**I want to** configure the genre and narrative tone of my universe with fine-grained options,
**So that** AI-generated lore and consistency rules match the dark, grounded aesthetic of my comic rather than producing generic fantasy output.

## Acceptance Criteria

- [ ] Given I am in Universe Settings under "Genre & Tone," when I view the configuration panel, then I can set: primary genre (single select), sub-genres (multi-select, up to 3), tone descriptors (multi-select from a curated list of 20+), and a free-text "style note" field (max 200 chars) for AI context.
- [ ] Given I save genre/tone configuration, when the Generation Studio is opened, then the AI system prompt is automatically enriched with the selected genre, sub-genres, tone descriptors, and style note without requiring me to type them manually.
- [ ] Given I have set a "gritty realism" tone, when the Consistency Checker runs, then anachronistic or tonally inconsistent generated entries are flagged as warnings.
- [ ] Given the style note field, when I enter text, then a live character count is displayed and submission is blocked above 200 characters.

## Notes

Depends on US-010 (edit universe settings). The style note is injected as a system-level context prefix in all AI calls for the universe. Related: US-011 (wizard step 2), US-016 (canon entries use this config).
