---
id: US-098
title: "User switches platform language from English to another supported language"
slug: "language-switching"
personas: [P-007, P-001]
epic: "Accessibility & i18n"
priority: "could-have"
complexity: "L"
tags: [i18n, localization, language, l10n, accessibility]
---

# US-098: User Switches Platform Language from English to Another Supported Language

## User Story

**As a** Solo AI Hobbyist (P-007),
**I want to** switch the platform's display language from English to my preferred language,
**So that** I can use the platform in the language I am most comfortable with and reduce cognitive overhead for non-English-speaking users.

## Acceptance Criteria

- [ ] Given a user navigates to Settings > Language, when the language selector loads, then it displays all supported languages with their native names (e.g., "Deutsch", "Espanol", "Francais", "Japanese") alongside English names
- [ ] Given a user selects a different language, when the selection is saved, then the entire platform UI (navigation, labels, buttons, error messages, empty states, tooltips) updates to the selected language without requiring a page reload
- [ ] Given a user switches to a language with right-to-left (RTL) text direction (e.g., Arabic, Hebrew), when the UI renders, then the layout mirrors appropriately (navigation on the right, text aligned right, bidirectional text handled correctly)
- [ ] Given a language has incomplete translations for some UI elements, when those elements are rendered, then the untranslated strings fall back to English with a visual indicator (subtle dotted underline) that the translation is pending

## Notes

Start with English as the default and plan for an initial batch of 5-8 languages based on user geography data. All user-facing strings must be externalized into translation files (not hardcoded). Technical terms (MCP, API, OAuth) may remain untranslated. Error messages from the backend API should include locale-aware message keys. Related to US-086 (timezone/date format) as part of the broader localization effort.
