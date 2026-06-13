---
id: US-040
title: "Tone and Voice Matching for Generation"
slug: "tone-voice-matching"
personas: [P-001, P-004, P-008]
epic: "Generation Engine"
priority: "should-have"
complexity: "L"
tags: [generation, tone, voice, style, consistency, style-guide]
---

# US-040: Tone and Voice Matching for Generation

## User Story

**As a** fiction podcaster with a distinctive horror-noir narrative voice (P-004),
**I want to** configure a tone and voice style for my universe that the AI uses when generating content,
**So that** generated entries sound like they belong to my world rather than generic AI output.

## Acceptance Criteria

- [ ] Given I am in universe Settings, when I open the Generation section, then I can write or paste a style guide sample (up to 500 words) that the AI will use as a voice reference.
- [ ] Given a style guide is configured, when I generate a new entry, then the AI receives the style guide sample as part of its instructions and attempts to match the tone.
- [ ] Given a style guide is active, when I view the Generation Studio, then a badge or indicator confirms that voice matching is enabled for this generation.
- [ ] Given I want to temporarily override the style guide, when I generate, then I can check a "Ignore style guide" option for a one-off generation without changing the universe settings.
- [ ] Given no style guide is configured, when I generate, then the AI uses a neutral, world-building-appropriate default tone.

## Notes

Depends on US-036. Depends on US-050 (style guide/voice configuration) for the settings UI. Style guide injection increases token usage — this should be surfaced in generation cost tracking (US-048). Related: US-039, US-050.
