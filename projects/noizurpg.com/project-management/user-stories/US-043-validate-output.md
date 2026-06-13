---
id: US-043
title: "Validate LLM output against world rules"
slug: "validate-output"
personas: [P-001, P-006]
epic: "Narrative Engine"
priority: "must-have"
complexity: "L"
tags: [narrative-engine, validation, world-rules, content-safety, llm]
---

# US-043: Validate LLM Output Against World Rules

## User Story

**As a** game studio lead responsible for production content quality (P-006),
**I want to** run LLM-generated narrative through the world rules validator before it reaches the player,
**So that** narratively inconsistent or world-breaking content (e.g. magic working in a magic-dead zone) is caught and either retried or flagged for review rather than silently served.

## Acceptance Criteria

- [ ] Given a generated narrative that would violate a registered world rule, when `engine.validate_output(narrative, events)` is called, then `ValidationResult.valid` is `False` and the violated rule IDs are listed.
- [ ] Given a validation failure with `retry_on_violation=True` configured, when a violation is detected, then the engine automatically re-prompts the LLM with the violation details appended to the system context, up to `max_retries` attempts.
- [ ] Given a validation failure after all retries are exhausted, when `fallback_strategy="flag"` is set, then the narrative is returned with `ValidationResult.flagged=True` rather than raising an exception.
- [ ] Given a validation failure after all retries are exhausted, when `fallback_strategy="raise"` is set, then a `WorldRuleViolationError` is raised with the full violation report.
- [ ] Given a generated narrative that passes all rules, when `engine.validate_output()` is called, then `ValidationResult.valid=True` is returned in under 50ms (excluding LLM call time for retries).
- [ ] Given validation results across 100 calls, when I query `engine.validation_stats()`, then aggregate counts of passes, failures, retries, and flagged responses are returned.

## Notes

Depends on US-030 (world rules) for the constraint definitions and US-041 (parse events) to extract the events being validated. P-006 needs this for production deployments; P-001 needs it during development to catch prompt engineering failures early. Validation stats (last criterion) feed into US-047 (token cost tracking) since retries consume tokens.
