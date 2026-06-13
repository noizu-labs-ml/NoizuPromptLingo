---
id: US-092
title: "Comprehensive Test Fixtures"
slug: "test-fixtures"
personas: [P-003, P-007]
epic: "Developer Experience & Community"
priority: "should-have"
complexity: "M"
tags: [testing, fixtures, dev-experience, quality, research]
---

# US-092: Comprehensive Test Fixtures

## User Story

**As an** AI/ML researcher (P-003) and community contributor (P-007),
**I want to** access a rich library of pre-built test fixtures (characters, worlds, quest chains, dialogue trees, memory snapshots) bundled with the framework,
**So that** I can write focused unit and integration tests for my custom components without spending hours manufacturing realistic test data.

## Acceptance Criteria

- [ ] Given `from noizurpg.testing import fixtures`, when I access `fixtures.characters.warrior_level_5`, then I receive a fully-populated `Character` object with stats, inventory, traits, and history appropriate for mid-game testing scenarios
- [ ] Given the fixtures library, when I enumerate its contents, then it includes at minimum: 5 character archetypes, 3 world state snapshots (early/mid/late game), 2 complete quest chains, 3 dialogue tree examples, and 5 memory snapshots at varying sizes (10 / 100 / 1000 / 5000 / 10000 entries)
- [ ] Given a fixture object, when I modify it in a test, then the modification does not affect other tests (fixtures are returned as deep copies, not shared references)
- [ ] Given `fixtures.providers.mock_provider`, when I use it in a test, then it returns configurable canned responses for any prompt without making network calls, and supports `assert_called_with(prompt_substring)` for verifying prompt content
- [ ] Given the fixtures documentation, when I read it, then every fixture is documented with its intended use case and the scenario it represents (e.g., "warrior_level_5: Hero who has completed the first act, suitable for testing mid-game combat dialogue")

## Notes

The mock provider fixture complements `CachingProvider` (US-082) — the mock is for unit tests with fully controlled outputs, while the caching provider is for integration tests replaying real LLM outputs. Fixtures are importable from `noizurpg.testing` to signal they are test-only dependencies.
