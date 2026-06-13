---
id: US-050
title: "Multi-language narrative support"
slug: "multi-language-narrative"
personas: [P-005, P-002]
epic: "Narrative Engine"
priority: "could-have"
complexity: "XL"
tags: [narrative-engine, i18n, localization, accessibility, language]
---

# US-050: Multi-Language Narrative Support

## User Story

**As a** blind accessibility-focused game developer serving a global audience (P-005),
**I want to** configure the Narrative Engine to generate output in a target language and have all game-facing strings (location descriptions, system messages, error fallbacks) respect that locale,
**So that** players who use screen readers in languages other than English receive native-language narrative without post-processing translation steps that introduce latency and inconsistency.

## Acceptance Criteria

- [ ] Given a locale configured via `engine.set_locale("es")`, when `engine.generate(action)` is called, then the system prompt instructs the LLM to respond in Spanish and the returned narrative is in Spanish.
- [ ] Given a locale change mid-session via `engine.set_locale("ja")`, when subsequent `engine.generate()` calls are made, then new responses are in Japanese while prior history in the context window is preserved as-is (not retroactively translated).
- [ ] Given a fallback narrative string registered in English, when `engine.set_locale("fr")` is active and no French fallback is registered, then the English fallback is used and a `MissingLocaleString` warning is logged with locale "fr" and key name.
- [ ] Given a world YAML file with a `locales` block providing location name translations `{"en": "Dark Forest", "de": "Dunkler Wald"}`, when locale is set to "de" and context is assembled, then the German location name is used in the prompt.
- [ ] Given a locale set to a BCP-47 tag the LLM adapter has not been tested with, when `engine.generate()` is called, then a `LocaleSupportWarning` is raised (not an error) and generation proceeds with the requested locale tag in the prompt.
- [ ] Given a game with locale "ar" (Arabic, RTL), when the engine returns narrative text, then the `NarrativeResult` includes a `text_direction="rtl"` field so the rendering layer can apply correct directionality.
- [ ] Given a multi-language integration test suite, when it runs against a live LLM for locales `["en", "es", "fr", "de", "ja", "ar"]`, then all six locales return non-empty, non-English narrative (verified by language detection heuristic, not exact match).

## Notes

This is XL because it spans prompt engineering, world data localization, fallback string registries, RTL support metadata, and integration testing across languages. P-005's accessibility mandate makes locale support a direct inclusion concern, not a nice-to-have. P-002 sees multi-language support as a commercial distribution requirement for IF works. Depends on US-038 (import world data) for localized world YAML support and US-044 (narrative tone) for locale-aware style profiles.
