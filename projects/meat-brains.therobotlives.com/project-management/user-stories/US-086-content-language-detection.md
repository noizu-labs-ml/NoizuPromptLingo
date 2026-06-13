---
id: US-086
title: "Content Language Detection for Prompts"
slug: "content-language-detection-prompts"
personas: [P-001, P-003, P-006]
epic: "Accessibility & i18n"
priority: "could-have"
complexity: "M"
tags: [i18n, language-detection, accessibility, content, metadata]
---

# US-086: Content Language Detection for Prompts

## User Story

**As a** Content Creator (P-006) or ML Researcher (P-003),
**I want to** have the language of my prompt automatically detected and tagged,
**So that** users can filter prompts by language and screen readers announce content in the correct language.

## Acceptance Criteria

- [ ] Given a user submits a prompt body, when the submission is processed, then the detected language is stored as metadata and displayed as a language tag on the prompt card
- [ ] Given a prompt has a detected language different from the UI language, when the prompt text is rendered, then the `lang` attribute is set correctly on the element containing the prompt body
- [ ] Given a user browsing the feed, when they apply a language filter, then only prompts matching the selected language(s) are shown
- [ ] Given language detection produces a low-confidence result (below 80%), when the prompt is displayed, then the language tag is shown with a note that the language is unconfirmed, and the author is prompted to manually select it

## Notes

Language detection can be server-side using a library such as `franc` or `langdetect`. The `lang` HTML attribute on prompt content is important for screen readers to use the correct pronunciation engine — this is both an i18n and accessibility requirement. Short prompts (under 20 words) may have unreliable detection and should always offer manual override.
