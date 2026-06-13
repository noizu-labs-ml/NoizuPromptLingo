---
id: US-093
title: "Deterministic Mode for CI"
slug: "deterministic-mode"
personas: [P-003, P-006]
epic: "Developer Experience & Community"
priority: "must-have"
complexity: "M"
tags: [testing, ci, determinism, reproducibility, quality]
---

# US-093: Deterministic Mode for CI

## User Story

**As an** AI/ML researcher (P-003) and game studio lead (P-006),
**I want to** run NoizuRPG in a deterministic mode where all LLM outputs are seeded or replayed,
**So that** my CI pipeline produces identical results on every run and I can reliably regression-test my game logic independent of LLM non-determinism.

## Acceptance Criteria

- [ ] Given `NoizuRPGConfig(mode="deterministic", seed=42)`, when I run a complete game session, then all random state transitions, dice rolls, and LLM-influenced branches produce the same outputs on every run with the same seed
- [ ] Given deterministic mode with a replay cache configured (US-082), when a test makes an LLM call that has no cached response, then a `DeterministicModeViolation` error is raised immediately rather than making a live non-deterministic call
- [ ] Given a deterministic mode session, when I compare two runs with the same seed and same input sequence, then the final world state, character state, and event log are byte-for-byte identical
- [ ] Given the CI environment variable `NOIZURPG_DETERMINISTIC=1`, when the framework initializes without an explicit config, then it automatically enters deterministic mode with a default seed, enabling CI pipelines to enforce determinism without code changes
- [ ] Given deterministic mode enabled, when any internal component uses Python's `random` or `datetime.now()`, then those calls are intercepted and seeded/frozen so their outputs are reproducible

## Notes

This story formally separates "reproducible game logic" from "deterministic LLM outputs" — the former is handled by seeding, the latter by the replay cache (US-082). Together they provide complete reproducibility. This is a hard requirement for P-006 studios doing regression testing before each release.
